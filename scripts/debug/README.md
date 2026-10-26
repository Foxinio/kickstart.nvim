# Debug workflow integration

- [verilator-dev.nvim](../../external/verilator-dev.nvim/README.md) owns profiles,
  capture/replay, compiler helpers, regression tasks and AST HTML/diff.
- [nvim-dap-extra.nvim](../../external/nvim-dap-extra.nvim/README.md) owns reusable
  debugger panes, routing, REPL commands/history and cleanup.
- [REQUIREMENTS.md](REQUIREMENTS.md) retains the cross-plugin behavior reference
  and the unimplemented DAP Source investigation.

The host owns adapters/Mason, language configurations, global mappings, CMake,
and Telescope's DAP extension. Its DebugProfile alias forwards arguments/bang to
VerilatorDebugProfile. Both lazy specs use Foxinio GitHub identities with local
dir overrides; remove the overrides to install from GitHub after publication.
No repositories or remotes are created by this extraction.

Run each plugin's documented suites and the combined host check:

```sh
nvim --headless -u NONE -i NONE -l scripts/debug/test_loading.lua
DEBUG_LOAD_ORDER=verilator nvim --headless -u NONE -i NONE -l scripts/debug/test_loading.lua
```
