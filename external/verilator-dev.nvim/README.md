# verilator-dev.nvim

Verilator compiler/model debugging, regression tasks, and AST HTML/diff pickers.
Requires Neovim 0.11+. No global keymaps or dependency on dap-extra.

## Installation

```lua
{
  'Foxinio/verilator-dev.nvim',
  module = false,
  cmd = {
    'VerilatorDebugProfile', 'VerilatorDebugBinary', 'VerilatorDebug',
    'VerilatorDebugBin', 'VerilatorDebugTest', 'VerilatorDebugSim',
    'VerilatorRegress', 'VerilatorHtml', 'VerilatorDiff',
  },
  dependencies = {
    'mfussenegger/nvim-dap', 'stevearc/overseer.nvim',
    'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim',
    'Foxinio/editable-telescope.nvim', 'Foxinio/term-color-parser.nvim',
  },
  opts = {},
}
```

Configure Telescope and Overseer normally, and register a cppdbg/OpenDebugAD7
adapter in nvim-dap before launching. The plugin does not install adapters.
GDB and a built Verilator checkout with its `src/.gdbinit` are needed for
compiler debugging. Capture needs Linux `/proc`, `/usr/bin/python3`, and the
checkout's regression/build prerequisites; model capture also needs ptrace/GDB.
These tools are feature requirements, not requirements for loading the plugin.

AST commands need `astsee_verilator` on PATH, `rg` for interactive selection,
and a working system HTML opener (`vim.ui.open`). GDB `jtree`/`jt` need astsee
in GDB's Python environment.

## Setup

`require('verilator-dev').setup(opts)` registers commands and restores profiles.
The only optional callback decorator is `wrap_debug_action`; it applies to
debug/profile handlers. For example, the host may supply
`wrap_debug_action = require('dap-extra.ui').action`. Without it, handlers run
in their invoking context. The plugin never imports or detects dap-extra.
`DebugProfile` is a host compatibility alias, not a plugin command.

Start with `:VerilatorDebugProfile load`, select `verilator`, then use
`:VerilatorDebugProfile edit` to adjust the reusable flags.
Profiles live in `~/.local/share/nvim/verilator-debug/profiles/` (or Neovim's
equivalent XDG data directory), outside this configuration repository.

Commands with an omitted selection argument open Telescope:

| Command | Selection |
| --- | --- |
| `VerilatorDebugProfile` | Profile action |
| `VerilatorDebugProfile load/edit/save/delete [name]` | Profile |
| `VerilatorDebugProfile clone [new-name]` | Source profile, then new name input |
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


## Regression and AST commands

`:VerilatorRegress` selects a regression; Ctrl-A edits remembered shell arguments.
Arguments remain in Neovim's state directory at `verilator-regress-args`.
Overseer handles output, completion notification, and cancellation.
Tasks supply their own color environment/components and use job output buffers.

`:VerilatorHtml [num]` and `:VerilatorDiff [num1 num2]` accept dump numbers
0–999 or open editable Telescope pickers. Ctrl-S changes the search root and
Ctrl-A edits astsee arguments (initially `--verbose`); selections and arguments
are remembered for the session. Cancelling a picker produces no output.
Rendered HTML is written to the invoking cwd and opened with the system opener.

## Checks

Run from this plugin directory (dependencies default to Neovim's data/lazy;
override their parent directory with `NVIM_TEST_DEPENDENCIES`):

```sh
nvim --headless -u NONE -i NONE -l tests/test.lua
nvim --headless -u NONE -i NONE -l tests/test_workflows.lua
python3 tests/test_capture.py
MODE=compiler nvim --headless -u NONE -i NONE -l tests/test_integration.lua
MODE=simulation nvim --headless -u NONE -i NONE -l tests/test_integration.lua
```

Integration requires `VERILATOR_DEBUG_BINARY` pointing to a debug compiler and
a configured OpenDebugAD7 executable in Neovim's data/mason/bin. Tests load only
this plugin and declared dependencies, then change to an unrelated cwd.

`tests/test_loading.lua` separately checks combined lazy loading against the host
Neovim config and sibling dap-extra plugin. It requires this checkout's directory
layout; see the host's [test commands](../../scripts/debug/README.md).
