# Verilator debugging

See [REQUIREMENTS.md](REQUIREMENTS.md) for the behavior to preserve in a future
replacement debug plugin.

Start with `:DebugProfile load`, select `verilator`, then use
`:DebugProfile edit` to adjust the reusable flags.
Profiles live in `~/.local/share/nvim/verilator-debug/profiles/` (or Neovim's
equivalent XDG data directory), outside this configuration repository.

Commands with an omitted selection argument open Telescope:

| Command | Selection |
| --- | --- |
| `DebugProfile` | Profile action |
| `DebugProfile load/edit/save/delete [name]` | Profile |
| `DebugProfile clone [new-name]` | Source profile, then new name input |
| `VerilatorDebugBinary [path]` | Executable file |
| `VerilatorDebug` | Repeat the last compiler or simulation launch with its original arguments |
| `VerilatorDebugBin [profile]` | Profile for a fresh manual compiler launch |
| `VerilatorDebugTest [test]` | Regression compiler invocation |
| `VerilatorDebugSim [test]` | Regression simulation invocation |

`save!` explicitly allows replacing an externally modified profile. Editing a
loaded profile reloads it on write. Binary selection is separate from profiles.
Each launch resolves `build/src/verilator_bin_dbg` against Neovim's current
working directory by default. Set a session-only override with
`:VerilatorDebugBinary ../bin/verilator_bin_dbg` if needed; loading, saving or
cloning profiles does not change it. Omit the path to search from Neovim's cwd
with Telescope. Absolute overrides remain supported.

`VERILATOR_ROOT` is inferred from the compiler's location (`bin/` or `build/src/`),
before trying its symlink target. An optional `root` field overrides inference
and is relative to the compiler's directory. Optional `cwd` is relative to the
derived root; omitted means the root.

## Arguments

- `args`: general flags for manual compiler launches (empty by default).
- `extra_args`: appended to manual and captured compiler arguments, unchanged.
- `simulation_args`: appended only to the model's captured runtime arguments.
- `regress_args`: regression driver arguments; defaults to `--vlt`. Capture
  forces one worker. Simulation capture also enables the driver's `--gdbsim`,
  which supplies generated-model compile/link debug symbols.
- `environment`: string-to-string environment overrides.
- `setup_commands`: additional GDB startup commands.

No flags are filtered or merged. Compiler profiles do not automatically add
`-CFLAGS -g`; model-debug preparation supplies debug symbols separately.

Both regression commands use `/usr/bin/python3` for capture helpers and the
regression driver, independently of Python executables on `PATH`.
They run test preparation and capture the **first** relevant
invocation. They preserve its actual `test_regress` cwd, arguments and environment,
then stop the runner and launch DAP. They do not finish the regression checks.
Use `:VerilatorRegress` afterward to verify a fix. Preparation and build output is
in Overseer; cancelling its capture task stops the preparation process tree.

Captured test arguments, paths and environments stay in the DAP session;
restart it with `<leader>dR`. Saving or cloning a profile saves reusable settings,
not the captured invocation. Legacy saved `replay` entries are ignored on load
and removed on save, as are legacy profile `program` entries. Test-specific
arguments come from the regression runner.
After termination, `:VerilatorDebug` repeats the last launch from this Neovim
session, including manual, regression compiler and simulation launches. It reuses
the executable, arguments, cwd, environment and startup commands without recapture
or resolving the binary again. Use `:VerilatorDebugBin [profile]` for a fresh
manual launch. Repeating requires a previous launch and no active session.

## Debug controls

The debugger uses one dedicated tab across sessions. Execution, stack selection,
configuration and breakpoint-list actions, pane toggles and profile/Verilator
commands switch to that tab. Run-to-cursor and CMake current-file debugging
retain the invoking file and cursor; relative binaries use the invoking cwd.
Breakpoint editing and value hover stay in the invoking window and tab.
Use `gt` / `gT` to switch between tabs. Stopping closes the debugger panes but
leaves its source tab available.

Use `:DapClean` to terminate debugging, clear inline debugger annotations and
cached values, and close debugger panes and the REPL, even after a session has
already ended. It preserves the source tab, file buffers and breakpoints. Use
`:tabclose` afterward if you also want to close that tab.

`<F5>` continues a running session; `<F10>/<F11>/<F12>` step over/into/out.
`<leader>b` toggles a source breakpoint, `<leader>B` sets a condition,
`<leader>dq` terminates, `<leader>dr` toggles the REPL and `<F7>` toggles the UI.
`<leader>dK` inspects the expression under the cursor in a floating debugger window.
`<leader>dg` shows the selected frame in the invoking window, preserving splits
and frame selection, including adapter-provided sources.
Existing CMake and non-C++ debugger configurations remain available.

In Stacks, Enter or `o` selects the frame and focuses its source in the existing
debug source pane; Space or `t` toggles subtle frames for the thread. In
Breakpoints, Enter or `o` focuses the breakpoint's source without changing frame
selection, `t` enables/disables it, and `d` removes it (including disabled entries).
These bindings are buffer-local.

The REPL accepts `s`, `n`, `si`, `ni`, `fin`, `c`, `p expression`, `i locals`,
and `gdb arbitrary-command`. Compiler sessions also expose `pn`, `pnt`,
`jstash`, `js`, `jtree`, `jt`, `dtf`, `watchedit`, and `proot` directly.
`jtree`/`jt` require `astsee` in GDB's Python environment. Multiline definitions
belong in startup commands; this pane is a DAP REPL, not an interactive terminal.
REPL commands and subsequent stops update the debug source and variables without
taking focus or leaving REPL input mode. Moving elsewhere during execution is
respected; source-window stack bindings focus the debug source normally.

In insert mode, Up/Down search commands submitted with Enter using the text
you have typed as a prefix. Empty input browses all commands. Down past the
newest match restores your typed prefix; editing it starts a new search.

Use `up [n]` / `down [n]` to move toward callers / callees (default one frame),
`frame n` or `f n` to select a zero-based frame, and `frame` to show the current
frame. `bt [n]`, `backtrace [n]` and `where [n]` list numbered frames, optionally
limited to the first n. Frame selection updates the source and variables through
DAP, keeping them synchronized. Relative moves stop at the ends of the stack.

Run focused checks with:

```
nvim --headless -u NONE -i NONE -l scripts/debug/test.lua
nvim --headless -u NONE -i NONE -l scripts/debug/test_panes.lua
python3 scripts/debug/test_capture.py
```
