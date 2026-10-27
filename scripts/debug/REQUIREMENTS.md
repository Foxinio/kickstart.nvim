# Debug plugin requirements

Behavior to preserve if we replace the current debug plugin stack. This records
the requested interaction model and the existing workflows documented in this
configuration; it is not a commitment to a particular plugin architecture.
The current implementation uses nvim-dap, dap-ui, Telescope, CMake Tools and
Overseer. A replacement must preserve the behavior below across their callers.

## Workspace and focus

- Use one dedicated debug tab for execution controls and persistent debugger
  panes. Reuse it across sessions and recreate it if manually closed.
- Keep editing tabs and their split layouts intact. Stopping closes debugger
  panes but leaves the debug tab and its source window available.
- Separate finding/creating the debug tab and source window from focusing them.
  Automatic updates must not unconditionally focus the source.
- Preserve the invoking cwd when routing commands to the debug tab, including
  relative executable resolution. Capture cursor-dependent context before moving.
- Keep ordinary tab navigation (`gt` / `gT`) available.

`<leader>` is `\` in the bindings below.

| Binding | Required behavior |
| --- | --- |
| `\b` | Toggle the breakpoint at the invoking cursor; stay in that window. |
| `\B` | Set/edit the conditional breakpoint at the invoking cursor; stay there. |
| `\dK` | Show value hover beside the invoking cursor; stay in the invoking tab. |
| `\dg` | Display the selected frame's source in the invoking window, preserving splits and frame selection. |
| `F5`, `\dc` | Switch to the debug tab and start/continue. With no session, use CMake debugging in a CMake project, otherwise normal debugger configuration selection. |
| `F10`, `F11`, `F12` | Switch to the debug tab and step over/into/out. |
| `\dR`, `\dq` | Switch to the debug tab and restart/terminate. |
| `\dC` | Launch the selected CMake target in the debug tab. |
| `\df` | Launch CMake current-file debugging in the debug tab, retaining the invoking file. |
| `\dl` | Capture the invoking file/line, switch to the debug tab and run to that location. |
| `\dk`, `\dj` | Switch to the debug tab and move up/down the stack. |
| `\dS` | Select a stack frame in the debug tab. |
| `\ds` | Select a debugger configuration in the debug tab. |
| `\db` | Show the breakpoint list in the debug tab. |
| `F7`, `\dr` | Switch to the debug tab and toggle debugger panes / REPL. |

Local source navigation (`\dg`) must support both files and DAP-provided source
buffers. Report missing sessions/frames/sources without changing windows. It is
navigation only: do not reselect the frame or modify debugger state.

## REPL

- Submitting a command keeps keyboard focus in the REPL, including input mode.
- `up`, `down`, `frame` and aliases update the selected frame, debug source,
  variables and other frame-dependent panes together, without focusing source.
- Stepping/continuing retains REPL focus when the next asynchronous stop arrives.
- Printing, helper commands, command errors and history navigation also retain
  focus and input mode.
- Do not schedule unconditional REPL restoration: if the user deliberately moves
  elsewhere while execution runs, do not later select the old REPL window.
- Source-window frame bindings still focus the debug source normally.
- Reopening panes after restart follows the same focus rule.
- Use a debugger REPL, not an interactive terminal. Multiline GDB definitions
  belong in startup commands.

### Commands

| Commands | Meaning |
| --- | --- |
| `s`, `n`, `si`, `ni`, `fin`, `c` | Step into/over, instruction steps, step out, continue. |
| `p expression`, `i locals` | GDB print and info shortcuts. |
| `gdb arbitrary-command` | Explicit GDB passthrough. |
| `up [n]`, `down [n]` | Move toward callers/callees; default one frame, clamp at stack ends. |
| `frame n`, `f n` | Select a zero-based stack frame. |
| `frame` | Show the current frame. |
| `bt [n]`, `backtrace [n]`, `where [n]` | List numbered frames, optionally limited to n. |
| `pn`, `pnt`, `jstash`, `js`, `jtree`, `jt`, `dtf`, `watchedit`, `proot` | Verilator compiler helper commands. |

Frame numbers refer to stack positions, not adapter frame IDs. Reject invalid
arguments and unavailable stopped stacks with a useful REPL response. GDB helpers
require a GDB/cppdbg session. `jtree`/`jt` require astsee in GDB's Python environment.

### History

- Enter records submitted commands; ignore empty input and consecutive duplicates.
- In insert mode, Up/Down search history by the currently typed prefix. Empty
  input browses all commands.
- Up stops at the oldest match. Down past the newest match restores the original
  typed prefix. Editing recalled text starts a new search.
- Keep history available when the REPL is reopened during the Neovim session.
  The current history bound is 100 commands; disk persistence is not established
  as a requirement.

## Profiles and executable selection

- Keep reusable JSON profiles outside the config repository, under Neovim's
  data directory (`verilator-debug/profiles`). Seed a Verilator profile when empty
  and remember the selected profile across Neovim sessions.
- Support load, edit, save, clone and delete. Reload the selected profile after
  its JSON file is saved. Reject invalid profile names, shapes, arguments and
  environment entries.
- Protect externally modified profiles from accidental overwrite; `save!` is the
  explicit override. Write profiles atomically with private file permissions.
- Omitted action/profile/test/file arguments open Telescope selection. Explicit
  arguments bypass selection. Cancelling a picker must not trigger the action.
- Executable selection is session-only and separate from profiles. Loading,
  saving or cloning a profile must not change the selected executable.
- Default to `build/src/verilator_bin_dbg`, resolved against the invoking cwd
  on each launch. Allow relative and absolute overrides; an invalid override
  preserves the previous selection. The executable picker starts at Neovim's cwd.
- Infer `VERILATOR_ROOT` from the selected binary's checkout before following
  symlinks. Support binaries under `bin/`, `build/src/` and paths outside cwd.
- An explicit profile `root` is relative to the compiler directory; `cwd` is
  relative to the derived root and defaults to that root.
- Save reusable settings only. Captured test commands, paths and environments
  stay in the DAP session and can be restarted there. Ignore legacy `replay` and
  `program` profile fields on load and remove them on save.

### Public commands

| Command | Purpose |
| --- | --- |
| `DebugProfile [action] [name]` | Profile management; `clone [new-name]` supports naming the copy. |
| `VerilatorDebugBinary [path]` | Select the compiler executable. |
| `VerilatorDebug` | Repeat the last Verilator compiler/model launch with its original settings. |
| `VerilatorDebugBin [profile]` | Start a fresh manual compiler debugging session. |
| `VerilatorDebugTest [test]` | Capture and debug a regression compiler invocation. |
| `VerilatorDebugSim [test]` | Prepare, capture and debug a generated simulation. |

All these commands use the debug tab. Preserve lazy-loading command handles and
force command registration when replacing pre-existing lazy/upstream stubs.

`VerilatorDebug` must repeat the last launch from `VerilatorDebugBin`,
`VerilatorDebugTest` or `VerilatorDebugSim`, including the original executable,
arguments, cwd, environment and startup commands. Keep this snapshot separate
from profile settings and adapter mutations, for the current Neovim session.
Do not recapture the test, resolve a new executable or use subsequently edited
profile arguments. Report a missing previous launch or an active session.

### Profile settings

| Field | Behavior |
| --- | --- |
| `args` | Manual compiler arguments; empty by default. |
| `extra_args` | Append unchanged to manual and captured compiler arguments. |
| `simulation_args` | Append only to captured model runtime arguments. |
| `regress_args` | Regression driver arguments; default `--vlt`. |
| `environment` | String-to-string overrides for the launch environment. |
| `setup_commands` | Additional GDB startup commands. |
| `root`, `cwd` | Root and working-directory overrides as described above. |

Do not filter, deduplicate or reinterpret argument strings. Preserve arguments
containing spaces. Do not automatically add `-CFLAGS -g` to compiler profiles;
simulation preparation supplies generated-model debug symbols separately.

## Verilator capture and launch

- Capture a real invocation through the regression runner without modifying
  Verilator. Use `/usr/bin/python3` for capture helpers and the runner, independent
  of Python executables on PATH.
- Capture the first relevant compiler/model invocation, preserving the actual
  executable, argv, environment and `test_regress` cwd. Stop the preparation runner
  and launch the debugger with that invocation.
- Force a single regression worker. For simulations, enable `--gdbsim` so the
  driver supplies compile/link debug symbols for the generated model.
- Accept regression test selection and explicit test names/paths.
- Use Overseer for preparation/build output with `use_terminal = false`.
  Cancelling capture stops its entire preparation process tree.
- Reject overlapping captures and launching/capturing over an active session.
- Failed, cancelled, skipped or uncaptured tests must report failure and must not
  launch a stale executable. Clean up temporary capture data and keep private
  settings/environments private.
- Capturing prepares a debugging session; it does not complete the regression
  checks. Keep `VerilatorRegress` available for checking the eventual fix.
- Launch GDB with pretty printing, bounded initial print depth, persistent GDB
  command history, correct `VERILATOR_ROOT` / `VERILATOR_BIN`, and profile startup
  commands. Stop at entry for manual/captured launches.
- Compiler sessions source the checkout's `src/.gdbinit`, enable `catch throw`,
  and define `proot` to dump the global AST. Simulation sessions must not inherit
  compiler-only startup commands.

## Integration and panes

- Preserve existing CMake and non-C++ debugger configurations and adapter support
  when changing the Verilator workflow; this is not a Verilator-only debugger.
- Keep scopes/variables, breakpoints, stacks, watches, REPL and console accessible
  as persistent debugger panes, with execution controls and value inspection.
- Use Overseer for jobs; do not introduce ToggleTerm or another terminal UI.
- Preserve CMake colored diagnostics, compile commands and parallel builds, and
  the existing ANSI parsing/color display behavior in Overseer.
- CMake remains lazy-loaded through explicit commands/bindings. Its single-target
  build path selects/builds explicit targets; file-api recovery regenerates once
  after removing stale reply data. Keep progress quiet and final task outcomes
  visible through Overseer. These are integration constraints, not a request for
  the debugger to reimplement the build system.

## Pane interactions and source-window investigation

### Buffer-specific actions

- Stacks: provide buffer-local bindings, including Enter on a frame to select
  that frame, update its source/variables, and move focus to the debug source
  window at that frame. Keep toggling subtle frames distinct from frame activation.
- Breakpoints: provide buffer-local actions to enable/disable a selected
  breakpoint, remove it, and navigate to its location in the shared debug source
  window with focus there. Navigation must not change the selected stack frame.
- Enabling/disabling must retain breakpoint conditions, hit conditions and log
  messages. Disabled entries must remain visible and removable.
- Keep these bindings local to their panes so ordinary source editing mappings
  are unaffected. Stacks uses Enter/`o` to activate and Space/`t` to toggle subtle
  frames. Breakpoints uses Enter/`o` to navigate, `t` to toggle and `d` to remove.

The implementation uses nvim-dap-ui's `element_mappings` and routes pane opens to
the existing debug source pane. A helper works around upstream removal retaining
disabled entries. Regression checks cover frame selection, source routing,
condition preservation across toggling and removal of disabled breakpoints.

### One named DAP Source window

Investigation only: do not implement the named/dedicated DAP Source window.

The intended purpose is a stable destination for debugger source navigation,
transparent to other plugins. Track one source window in the debug tab by its
window ID. Stops, frame changes, and Stacks/Breakpoints navigation target that
window, replacing its displayed buffer as needed rather than opening new source
splits. Recreate the destination if closed. Routing and focus remain separate,
so automatic updates retain the established REPL focus behavior.

Keep the explicit local-action exceptions: breakpoint editing and hover use the
invoking cursor, and `\dg` displays the selected frame in the invoking window.

Display original file buffers in the tracked window. Normal editing, undo,
saving to the real file, LSP, Tree-sitter, diagnostics, completion and existing
plugin mappings should work as in any other source window. Edits are shared
with other windows displaying the same buffer.

Neovim windows display buffers; file identity and attached editing services
belong to those buffers. Most destination tracking and routing already exist in
`debug-ui.lua` and `debug-panes.lua`. The smallest additional change would be an
optional window-local `DAP Source` label, using Neovim's native winbar. The title
is cosmetic; routing must not depend on it. Do not rename real
file buffers to `DAP Source` or copy their contents into a scratch buffer merely
to obtain a stable title. This is a feasibility direction, not an implemented
or verified design. Allow normal user navigation and splitting; do not police
other windows or require all plugins to route their navigation through this pane.

Before implementation, check that buffer switching preserves language services,
file writes and unsaved edits, that window recreation and user-created splits
behave sensibly, and that source updates follow the existing REPL focus rules.
Adapter-provided sources still need navigation support; their edit/save semantics
must be assessed separately from real files. Record limitations before choosing
the design.

## Extracted ownership

[verilator-dev.nvim](../../external/verilator-dev.nvim/README.md) owns profiles,
capture/replay, Verilator GDB helpers, regression and AST commands.
[nvim-dap-extra.nvim](../../external/nvim-dap-extra.nvim/README.md) owns routing,
panes, generic REPL behavior and cleanup. They are independently usable.
The host retains adapters/Mason, languages, global mappings, CMake and Telescope
DAP pickers. DebugProfile is a host alias for VerilatorDebugProfile.
The proposed named DAP Source window above remains investigation only.

## Acceptance checks

- `DapClean` terminates debugging, clears debugger virtual text and cached
  frames, and closes debugger panes and the REPL. It also works after the session
  has ended and is safe to repeat. Preserve source tabs, file edits and breakpoints.

- Local breakpoint/hover actions preserve the invoking tab, source cursor and
  split layout. Breakpoint actions remain in the invoking window.
- Execution actions reuse one debug tab; run-to-cursor and current-file launches
  retain their original source context. Relative binaries retain the invoking cwd.
- Local frame navigation changes only the invoking window's source and cursor,
  supports file and adapter sources, and leaves frame selection unchanged.
- REPL frame selection and simulated asynchronous stops update source/variables
  without stealing REPL focus or input mode. A deliberate move elsewhere is not
  undone by delayed restoration.
- Closing/recreating the debug tab and reopening panes after restart work.
- Profile validation, overwrite protection, picker cancellation, argument
  preservation and executable resolution retain regression coverage.
- Capture checks cover actual compiler/model commands, runner cancellation and
  process-tree cleanup; live checks cover GDB launch, helpers and breakpoints.
- Run Lua syntax checks and `git diff --check`; live-test REPL stepping, frame
  navigation, hover and local source navigation. Headless mocks alone do not
  establish interactive focus behavior.

See the plugin READMEs above for the separated tests and prerequisites;
[test_loading.lua](../../external/verilator-dev.nvim/tests/test_loading.lua) checks combined host lazy loading.
