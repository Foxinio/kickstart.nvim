# AGENTS.md

Guidance for future coding agents working in this Neovim config.

## Working Style

- Be minimal. Prefer the smallest correct change over new abstractions or broad rewrites.
- Read the relevant files first. Most bugs here are merge/load-order regressions, not missing architecture.
- Preserve user changes. This repo is often dirty; never reset or checkout files unless explicitly asked.
- Use `rg`/`rg --files` for search.
- Use `apply_patch` for manual edits.
- Keep Lua modules boring: return a table
- Keep behavior in helper modules
- Keep plugin specs mostly declarative - module defined at the top of the file, and filled throughout it.
- Validate changed Lua with `luac -p <files>`.
- `nvim --headless -u init.lua +q` may fail on older local Neovim/plugin-version mismatches; do not treat that alone as a regression.

## Repo Layout

- Plugin specs live in `lua/plugins/*.lua`.
- Shared behavior belongs in helper modules:
  - `lua/plugin-utils/*.lua` for plugin-specific helpers.
  - `lua/utils/*.lua` for general purpose helpers.
- Keep callback-heavy behavior out of plugin config files when it grows past a tiny wrapper.
- Overseer custom components live in `lua/overseer/component/*.lua`.

## Merge Review Checklist

When checking a merge, always compare against the source branch as well as `HEAD`:

```sh
git status --porcelain=v1
git merge-base HEAD dev
git diff --name-status dev
git diff --check
rg -n "<<<<<<<|=======|>>>>>>>" lua init.lua lazy-lock.json
```

Also search for stale module paths after moves:

```sh
rg -n "utils\.float-command|plugin-utils\.float-command" lua
```

Do not assume a clean `git diff` means no changes: check staged diff too.

```sh
git diff --cached --name-status
git diff --cached --check
```

## General plugin intuitions

- There is an unwritten set of `core` plugins which are to be loaded immediately
    or to not delay loading for single file quick change, to be loaded on `VeryLazy`.
- All other plugins (technology specific, etc.) should not be loaded and should have
    clear loading handle (ft, cmd, mapping,...). Those plugins should have `M.module = false`


## Plugin specific instructions
### CMake Tools

- `cmake-tools.nvim` should not load at startup. Use `M.module = false` and `M.cmd = { ... }`.
- Custom CMake commands must use `force = true`; lazy.nvim/upstream command stubs can already exist.
- The user wants Overseer, not ToggleTerm or integrated terminals.
- Keep `use_terminal = false` for CMake/Overseer job output.
- Preserve CMake color and parallel-build behavior:
  - `cmake_generate_options` should include color diagnostics and compile commands.
  - `cmake_build_options` should use `--parallel` with a CPU-count helper.
  - CMake/Overseer dependencies should include `Foxinio/term-color-parser.nvim`.
- Keep `strip_ansi_lines` before `on_output_quickfix` in CMake Overseer components. It strips ANSI before quickfix parsing while `ansi_colorize` still handles output display.
- `CMakeBuildSingleTarget` should select/build explicit targets via `cmake_tools.build`, not regress to plain `quick_build`.
- Code-model retry logic should clear stale `.cmake/api/v1/reply` and regenerate once for ENOENT/invalid JSON file-api errors.
- CMake notifications should be quiet during progress but still notify final success/failure through Overseer.

### Overseer

- Overseer is the task UI. Avoid adding terminals or terminal plugins.
- Use `force_color` for task env; preserve `TERM`, `FORCE_COLOR`, `CLICOLOR_FORCE`, `CMAKE_COLOR_DIAGNOSTICS`, `GTEST_COLOR`, and `PY_COLORS`.
- `OverseerDisposeAll` should clear/dispose all tasks.
- Keep output highlights for programs that do not emit colors.
- `OverseerList` should not show raw ANSI sequences; strip render/list paths if needed without breaking colored output buffers.

### Telescope

- Preserve these mappings:
  - Telescope `<C-f>` in insert and normal mode opens the selected entry in Float via `utils.float-command.open_telescope_selection`.
- Editable live grep uses `<C-s>` for changing search root and `<C-a>` for changing runtime arguments.
- `plugin-utils.telescope` owns editable-root/search-root picker behavior.

### Float

- `:Float` is a command wrapper for opening command results/files in a floating window.
- The implementation currently lives at `lua/utils/float-command.lua`.
- LSP, Telescope, and nvim-tree integrations depend on it. Before changing paths, update every caller.

### Lspconfig

- LSP actions that open locations should have current-window, split, vertical split, Float, and tab variants when practical.
- Preserve Float variants for definitions/references/implementations/type definitions/declarations.

### nvim-tree

- In nvim-tree, `<C-f>` opens the selected file in Float.

### AutoSession and Tabs

- AutoSession should save real file buffers only.
- Close unsupported/panel windows before save; hidden buffers not visible in any pane should be deleted.
- Git tab is recreated on restore when cwd is exactly a git root. Do not save fugitive/panel buffers just to preserve it.
- Do not run `:tab Git` outside a git root or if a `GIT` tab/fugitive buffer already exists.

### Which-Key

- Command-line mode may use which-key, but `\` must not trigger it in cmdline.
- If command-line which-key appears while typing leader-like text, inspect trigger modes before changing mappings.

## Verification

Minimum useful checks after edits:

```sh
luac -p <changed lua files>
git diff --check
rg -n "<<<<<<<|=======|>>>>>>>" lua init.lua lazy-lock.json
```

For merge/keymap regressions, compare with `dev`:

```sh
git diff dev -- lua/plugins/telescope.lua lua/plugin-utils/lspconfig.lua lua/plugins/nvim-tree.lua lua/plugins/cmake-tools.lua
```
