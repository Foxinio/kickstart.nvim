# nvim-dap-extra.nvim

Reusable DAP tab/source routing, REPL history and frame commands, pane bindings,
and cleanup. Requires Neovim 0.11+. No global keymaps or Verilator dependency.

## Installation

```lua
{
  'Foxinio/nvim-dap-extra.nvim',
  module = false,
  cmd = { 'DapClean' },
  dependencies = {
    'mfussenegger/nvim-dap', 'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio', 'theHamsta/nvim-dap-virtual-text',
  },
  opts = { dapui = {}, virtual_text = {} },
}
```

`require('dap-extra').setup(opts)` merges `dapui` and `virtual_text` tables
over the bundled UI defaults. Setup may be repeated; listeners, commands,
history hooks and compatibility patches do not stack. Repeated calls leave the
existing configuration in place. Adapter registration,
language configurations, Mason, and global mappings belong to the caller.
Only generic GDB REPL shortcuts need a GDB/cppdbg session; loading the plugin
does not require GDB or an adapter.

## UI helpers

```lua
local ui = require('dap-extra.ui')
-- Bind these in your own configuration, after loading the plugin:
vim.keymap.set('n', '<F5>', ui.action(function() require('dap').continue() end))
vim.keymap.set('n', '<leader>dg', ui.local_frame)
```

`action(callback, use_cursor)` routes to a shared debug tab and forwards all
arguments. Set `use_cursor` for source-sensitive actions such as run-to-cursor.
`focus()`, `toggle()`, `repl()`, `open()`, `close()`, `jump(buf, line, column)`,
`local_frame()`, and `cleanup()` remain available. Columns passed to `jump`
are one-based. Local frame navigation preserves the selected frame and splits.

The debugger uses one dedicated tab across sessions. Execution, stack selection,
configuration and breakpoint-list actions and pane toggles switch to that tab.
Run-to-cursor and CMake current-file debugging
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
Language and CMake mappings shown above are examples of host configuration.

In Stacks, Enter or `o` selects the frame and focuses its source in the existing
debug source pane; Space or `t` toggles subtle frames for the thread. In
Breakpoints, Enter or `o` focuses the breakpoint's source without changing frame
selection, `t` enables/disables it, and `d` removes it (including disabled entries).
These bindings are buffer-local.

The REPL accepts `s`, `n`, `si`, `ni`, `fin`, `c`, `p expression`, `i locals`,
and `gdb arbitrary-command`. Compiler-specific helpers belong to verilator-dev.nvim.
Multiline definitions
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


## Checks

```sh
nvim --headless -u NONE -i NONE -l tests/test.lua
nvim --headless -u NONE -i NONE -l tests/test_panes.lua
nvim --headless -u NONE -i NONE -l tests/test_focus_live.lua
```

Run from this plugin directory. Tests use only declared dependencies in
Neovim's data/lazy (`NVIM_TEST_DEPENDENCIES` overrides the parent directory)
and change to an unrelated cwd. The live suite needs cc, GDB, ptrace and
OpenDebugAD7 in Neovim's data/mason/bin.
