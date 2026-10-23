# Verilator debugging

Start with `:DebugProfile load`, select `verilator`, then use
`:DebugProfile edit` to adjust the seeded executable and flags.
Profiles live in `~/.local/share/nvim/verilator-debug/profiles/` (or Neovim's
equivalent XDG data directory), outside this configuration repository.

Commands with an omitted selection argument open Telescope:

| Command | Selection |
| --- | --- |
| `DebugProfile` | Profile action |
| `DebugProfile load/edit/save/delete [name]` | Profile |
| `DebugProfile clone [new-name]` | Source profile, then new name input |
| `VerilatorDebugBinary [path]` | Executable file |
| `VerilatorDebug [profile]` | Profile to launch |
| `VerilatorDebugTest [test]` | Regression compiler invocation |
| `VerilatorDebugSim [test]` | Regression simulation invocation |

`save!` explicitly allows replacing an externally modified profile. Editing a
loaded profile reloads it on write. Changing the binary saves the current profile
and clears its captured replay. Relative binary paths in JSON are relative to
the profile directory; the binary command stores an absolute path.

`VERILATOR_ROOT` is inferred from the compiler's location (`bin/` or `build/src/`),
before trying its symlink target. An optional `root` field overrides inference
and is relative to the compiler's directory. Optional `cwd` is relative to the
derived root; omitted means the root.

## Arguments

- `args`: manual compiler invocation.
- `extra_args`: appended to manual and captured compiler arguments, unchanged.
- `simulation_args`: appended only to the model's captured runtime arguments.
- `regress_args`: regression driver arguments; defaults to `--vlt`. Capture
  forces one worker. Simulation capture also enables the driver's `--gdbsim`,
  which supplies generated-model compile/link debug symbols.
- `environment`: string-to-string environment overrides.
- `setup_commands`: additional GDB startup commands.

No flags are filtered or merged. Compiler profiles do not automatically add
`-CFLAGS -g`; model-debug preparation supplies debug symbols separately.

Both regression commands run test preparation and capture the **first** relevant
invocation. They preserve its actual `test_regress` cwd, arguments and environment,
then stop the runner and launch DAP. They do not finish the regression checks.
Use `:VerilatorRegress` afterward to verify a fix. Preparation and build output is
in Overseer; cancelling its capture task stops the preparation process tree.

Capturing updates the loaded profile's in-memory `replay`. Restart it with
`<leader>dR`; save or clone the profile to persist it. Remove `replay` from the
profile to return to its manual `args`. Saved replay environments may contain
test-specific variables; profiles and temporary captures are private files.

## Debug controls

`<F5>` continues a running session; `<F10>/<F11>/<F12>` step over/into/out.
`<leader>b` toggles a source breakpoint, `<leader>B` sets a condition,
`<leader>dq` terminates, `<leader>dr` toggles the REPL and `<F7>` toggles the UI.
Existing CMake and non-C++ debugger configurations remain available.

The REPL accepts `s`, `n`, `si`, `ni`, `fin`, `c`, `p expression`, `i locals`,
and `gdb arbitrary-command`. Compiler sessions also expose `pn`, `pnt`,
`jstash`, `js`, `jtree`, `jt`, `dtf`, `watchedit`, and `proot` directly.
`jtree`/`jt` require `astsee` in GDB's Python environment. Multiline definitions
belong in startup commands; this pane is a DAP REPL, not an interactive terminal.

Run focused checks with:

```
nvim --headless -u NONE -i NONE -l scripts/debug/test.lua
python3 scripts/debug/test_capture.py
```
