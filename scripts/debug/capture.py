"""Capture one real compiler/model invocation without modifying Verilator."""

import json
import os
from pathlib import Path
import shlex
import signal
import subprocess
import sys
import time


def capture(config, program, args):
    environment = dict(os.environ)
    environment.pop("NVIM_VLT_CAPTURE", None)
    environment.pop("VERILATOR_GDB", None)
    environment["VERILATOR_BIN"] = config["program"]
    environment["VERILATOR_ROOT"] = config["root"]
    record = Path(config["record"])
    temporary = record.with_suffix(".tmp")
    temporary.write_text(json.dumps({
        "program": os.path.abspath(program), "args": args,
        "cwd": os.getcwd(), "environment": environment,
        "simulation": config["simulation"],
    }))
    temporary.chmod(0o600)
    temporary.replace(record)
    # The supervisor stops the whole preparation tree after reading the record.
    while True:
        time.sleep(1)


def descendants(pid):
    try:
        children = Path(f"/proc/{pid}/task/{pid}/children").read_text().split()
    except FileNotFoundError:
        return []
    result = []
    for child in children:
        result += descendants(int(child)) + [int(child)]
    return result


def stop_tree(process):
    # The driver creates separate PTY sessions, so killing one group is insufficient.
    children = descendants(process.pid)
    for pid in children + [process.pid]:
        try:
            os.kill(pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
    try:
        process.wait(timeout=1)
    except subprocess.TimeoutExpired:
        pass
    for pid in children + [process.pid]:
        try:
            os.kill(pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
    process.wait()


def run(config, config_path):
    environment = dict(os.environ, **config.get("environment", {}))
    environment.pop("TEST_REGRESS", None)
    environment["VERILATOR_ROOT"] = config["root"]
    environment["NVIM_VLT_CAPTURE"] = config_path
    helper = [sys.executable, os.path.abspath(__file__)]
    environment["VERILATOR_BIN"] = shlex.join(helper + ["compiler", config_path])
    command = [sys.executable, config["root"] + "/test_regress/driver.py"]
    command += config.get("regress_args", ["--vlt"])
    command += ["--jobs=1"]
    if config["simulation"]:
        wrapper = shlex.join(helper + ["model", config_path])
        environment["VERILATOR_GDB"] = shlex.join([
            "gdb", "-nx", "-batch", "-ex", "set exec-wrapper " + wrapper,
        ])
        command += ["--gdbsim"]
    command += [config["test"]]
    process = subprocess.Popen(command, cwd=config["root"] + "/test_regress",
                               env=environment, start_new_session=True)

    def cancel(_signum, _frame):
        raise KeyboardInterrupt

    for signum in (signal.SIGTERM, signal.SIGHUP, signal.SIGINT):
        signal.signal(signum, cancel)
    try:
        while process.poll() is None:
            if Path(config["record"]).is_file():
                return 0
            time.sleep(0.05)
        return process.returncode or 1
    except KeyboardInterrupt:
        return 130
    finally:
        for signum in (signal.SIGTERM, signal.SIGHUP, signal.SIGINT):
            signal.signal(signum, signal.SIG_IGN)
        stop_tree(process)


def main():
    mode, config_path = sys.argv[1:3]
    config = json.loads(Path(config_path).read_text())
    args = sys.argv[3:]
    if mode == "runner":
        return run(config, config_path)
    if mode == "model":
        capture(config, args[0], args[1:])
    elif mode == "compiler":
        # Driver compilation commands carry --prefix; capability probes do not.
        if "--prefix" in args:
            if not config["simulation"]:
                capture(config, config["program"], args)
            args += config.get("extra_args", [])
        os.environ["VERILATOR_BIN"] = config["program"]
        os.execv(config["program"], [config["program"]] + args)
    else:
        raise ValueError("Unknown capture mode: " + mode)


if __name__ == "__main__":
    sys.exit(main())
