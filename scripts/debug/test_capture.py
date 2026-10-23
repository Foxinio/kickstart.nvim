"""Run with python3 scripts/debug/test_capture.py (simulation needs ptrace)."""

import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time
import unittest

HELPER = Path(__file__).with_name("capture.py").resolve()

DRIVER = '''
import json, os, pathlib, shlex, subprocess, sys, time
if os.environ.get("TEST_WAIT"):
    child = subprocess.Popen([sys.executable, "-c", "import time; time.sleep(60)"], start_new_session=True)
    pathlib.Path("child.pid").write_text(str(child.pid))
    time.sleep(60)
compiler = shlex.split(os.environ["VERILATOR_BIN"])
probe = subprocess.run(compiler + ["-get-supported", "DEV_ASAN"], capture_output=True, text=True)
assert probe.returncode == 0 and probe.stdout.strip() == "0", probe.stdout
args = ["--prefix", "Vt_example", "-f", "input.vc", "a source.v"]
if "--gdbsim" in sys.argv:
    args += ["-CFLAGS", "-ggdb", "-LDFLAGS", "-ggdb"]
subprocess.run(compiler + args, check=True)
if "--gdbsim" in sys.argv:
    debugger = shlex.split(os.environ["VERILATOR_GDB"])
    subprocess.run(debugger + ["/bin/true", "-ex", "run +seed=7 \\"spaced argument\\""], check=True)
'''

COMPILER = '''#!/usr/bin/env python3
import json, os, pathlib, sys
args = sys.argv[1:]
if "-get-supported" in args:
    print("0")
    sys.exit(2 if os.environ.get("PROBE_FAIL") else 0)
pathlib.Path("compiled.json").write_text(json.dumps(args))
'''


class CaptureTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="nvim-debug-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        (self.root / "test_regress").mkdir()
        (self.root / "bin").mkdir()
        (self.root / "test_regress/driver.py").write_text(DRIVER)
        self.program = self.root / "bin/verilator_bin_dbg"
        self.program.write_text(COMPILER)
        self.program.chmod(0o755)
        self.record = self.root / "record.json"
        self.settings = self.root / "config.json"

    def start(self, simulation=False, environment=None):
        self.settings.write_text(json.dumps({
            "root": str(self.root), "program": str(self.program),
            "test": "t/example.py", "simulation": simulation,
            "regress_args": ["--vlt"], "extra_args": ["--user-option", "value with spaces"],
            "environment": dict(TEST_SENTINEL="preserved", **(environment or {})),
            "record": str(self.record),
        }))
        return subprocess.Popen([sys.executable, str(HELPER), "runner", str(self.settings)],
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

    def finish(self, process):
        try:
            output = process.communicate(timeout=20)[0]
        except subprocess.TimeoutExpired:
            process.terminate()
            process.communicate(timeout=5)
            self.fail("Capture did not finish")
        self.assertEqual(process.returncode, 0, output)
        return json.loads(self.record.read_text())

    def test_compiler_capture_after_capability_check(self):
        record = self.finish(self.start())
        self.assertEqual(record["args"], ["--prefix", "Vt_example", "-f", "input.vc", "a source.v"])
        self.assertEqual(record["cwd"], str(self.root / "test_regress"))
        self.assertEqual(record["environment"]["VERILATOR_ROOT"], str(self.root))
        self.assertEqual(record["environment"]["VERILATOR_BIN"], str(self.program))
        self.assertEqual(record["environment"]["TEST_SENTINEL"], "preserved")
        self.assertNotIn("NVIM_VLT_CAPTURE", record["environment"])
        self.assertFalse((self.root / "test_regress/compiled.json").exists())

    def test_simulation_build_then_runtime_capture(self):
        record = self.finish(self.start(simulation=True))
        self.assertTrue(record["simulation"])
        self.assertEqual(record["args"], ["+seed=7", "spaced argument"])
        self.assertEqual(record["cwd"], str(self.root / "test_regress"))
        compiled = json.loads((self.root / "test_regress/compiled.json").read_text())
        self.assertIn("-ggdb", compiled)
        self.assertEqual(compiled[-2:], ["--user-option", "value with spaces"])
        self.assertNotIn("VERILATOR_GDB", record["environment"])

    def test_preparation_failure(self):
        process = self.start(environment={"PROBE_FAIL": "1"})
        process.communicate(timeout=10)
        self.assertNotEqual(process.returncode, 0)
        self.assertFalse(self.record.exists())

    def test_cancellation_kills_separate_session_child(self):
        process = self.start(environment={"TEST_WAIT": "1"})
        pidfile = self.root / "test_regress/child.pid"
        for _ in range(100):
            if pidfile.exists():
                break
            time.sleep(0.02)
        self.assertTrue(pidfile.exists())
        pid = int(pidfile.read_text())
        process.send_signal(signal.SIGTERM)
        process.communicate(timeout=5)
        self.assertEqual(process.returncode, 130)
        # A killed orphan may briefly remain as a zombie until init reaps it.
        status = Path(f"/proc/{pid}/stat")
        self.assertTrue(not status.exists() or status.read_text().split()[2] == "Z")


if __name__ == "__main__":
    unittest.main()
