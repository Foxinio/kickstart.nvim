--  Omnisharp-vim config
-- let g:OmniSharp_server_stdio = 1
-- let g:OmniSharp_server_use_mono = 1

vim.keymap.set('n', '<M-down>', '<Plug>CoqNext', { noremap = true })
vim.keymap.set('n', '<M-up>',   '<Plug>CoqUndo', { noremap = true })

--  This is necessary for VimTeX to load properly. The "indent" is optional.
--  Note that most plugin managers will do this automatically.
-- filetype plugin indent on

--  This enables Vim's and neovim's syntax-related features. Without this, some
--  VimTeX features will not work (see ":help vimtex-requirements" for more
--  info).
--  syntax enable

--  Viewer options: One may configure the viewer either by specifying a built-in
--  viewer method:
--  let g:vimtex_view_method = 'zathura'

--  Or with a generic interface:
vim.g.vimtex_view_general_viewer = 'okular'
vim.g.vimtex_view_general_options = '--unique file:@pdf\\#src:@line@tex'

--  VimTeX uses latexmk as the default compiler backend. If you use it, which is
--  strongly recommended, you probably don't need to configure anything. If you
--  want another compiler backend, you can change it as follows. The list of
--  supported backends and further explanation is provided in the documentation,
--  see ":help vimtex-compiler".
--  let g:vimtex_compiler_method = 'latexrun'

--  Vim-latex-live-preview config:

vim.g.livepreview_previewer = 'firefox'
vim.g.livepreview_cursorhold_recompile = 0




