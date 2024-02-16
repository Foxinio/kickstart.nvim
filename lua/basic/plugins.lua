--  Command-t config
-- let g:CommandTPreferredImplementation='ruby'

--  Omnisharp-vim config
-- let g:OmniSharp_server_stdio = 1
-- let g:OmniSharp_server_use_mono = 1

--  Ale config
-- let g:ale_linters = {
-- \ 'cs': ['OmniSharp']
-- \}

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

--  Most VimTeX mappings rely on localleader and this can be changed with the
--  following line. The default is usually fine and is the symbol "\".
--    let maplocalleader = ","

--  NERDCommenter settings:
--  Create default mappings
-- let g:NERDCreateDefaultMappings = 0

--  Add spaces after comment delimiters by default
-- let g:NERDSpaceDelims = 1

--  Use compact syntax for prettified multi-line comments
-- let g:NERDCompactSexyComs = 1

--  Align line-wise comment delimiters flush left instead of following code indentation
-- let g:NERDDefaultAlign = 'left'

--  Set a language to use its alternate delimiters by default
--  let g:NERDAltDelims_java = 1

--  Add your own custom formats or override the defaults
-- let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

--  Allow commenting and inverting empty lines (useful when commenting a region)
-- let g:NERDCommentEmptyLines = 1

--  Enable trimming of trailing whitespace when uncommenting
-- let g:NERDTrimTrailingWhitespace = 1

--  Enable NERDCommenterToggle to check all selected lines is commented or not 
-- let g:NERDToggleCheckAllLines = 0


-- noremap <silent> <C-/> <plug>NERDCommenterToggle


--  Vim-latex-live-preview config:

vim.g.livepreview_previewer = 'firefox'
vim.g.livepreview_cursorhold_recompile = 0





--  Markdown-preview.nvim config:


--  set to 1, nvim will open the preview window after entering the Markdown buffer
--  default: 0
vim.g.mkdp_auto_start = 1

--  set to 1, the nvim will auto close current preview window when changing
--  from Markdown buffer to another buffer
--  default: 1
vim.g.mkdp_auto_close = 0

--  set to 1, Vim will refresh Markdown when saving the buffer or
--  when leaving insert mode. Default 0 is auto-refresh Markdown as you edit or
--  move the cursor
--  default: 0
vim.g.mkdp_refresh_slow = 0

--  set to 1, the MarkdownPreview command can be used for all files,
--  by default it can be use in Markdown files only
--  default: 0
vim.g.mkdp_command_for_global = 0

--  set to 1, the preview server is available to others in your network.
--  By default, the server listens on localhost (127.0.0.1)
--  default: 0
vim.g.mkdp_open_to_the_world = 0

--  use custom IP to open preview page.
--  Useful when you work in remote Vim and preview on local browser.
--  For more details see: https://github.com/iamcco/markdown-preview.nvim/pull/9
--  default empty
vim.g.mkdp_open_ip = ''

--  specify browser to open preview page
--  for path with space
--  valid: `/path/with\ space/xxx`
--  invalid: `/path/with\\ space/xxx`
--  default: ''
vim.g.mkdp_browser = '/usr/bin/firefox'

--  set to 1, echo preview page URL in command line when opening preview page
--  default is 0
vim.g.mkdp_echo_preview_url = 1

--  a custom Vim function name to open preview page
--  this function will receive URL as param
--  default is empty
vim.g.mkdp_browserfunc = ''

--  options for Markdown rendering
--  mkit: markdown-it options for rendering
--  katex: KaTeX options for math
--  uml: markdown-it-plantuml options
--  maid: mermaid options
--  disable_sync_scroll: whether to disable sync scroll, default 0
--  sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
--    middle: means the cursor position is always at the middle of the preview page
--    top: means the Vim top viewport always shows up at the top of the preview page
--    relative: means the cursor position is always at relative positon of the preview page
--  hide_yaml_meta: whether to hide YAML metadata, default is 1
--  sequence_diagrams: js-sequence-diagrams options
--  content_editable: if enable content editable for preview page, default: v:false
--  disable_filename: if disable filename header for preview page, default: 0
vim.g.mkdp_preview_options = {
    mkit = {},
    katex = {},
    uml = {},
    maid = {},
    disable_sync_scroll = 0,
    sync_scroll_type = 'middle',
    hide_yaml_meta = 1,
    sequence_diagrams = {},
    flowchart_diagrams = {},
    content_editable = false,
    disable_filename = 0,
    toc = {}
}

--  use a custom Markdown style. Must be an absolute path
--  like '/Users/username/markdown.css' or expand('~/markdown.css')
vim.g.mkdp_markdown_css = ''

--  use a custom highlight style. Must be an absolute path
--  like '/Users/username/highlight.css' or expand('~/highlight.css')
vim.g.mkdp_highlight_css = ''

--  use a custom port to start server or empty for random
vim.g.mkdp_port = ''

--  preview page title
--  ${name} will be replace with the file name
vim.g.mkdp_page_title = '「${name}」'

--  use a custom location for images
vim.g.mkdp_images_path = '/media/foxinio/work/foxinio-work/.markdown-cache/markdown_images'

--  recognized filetypes
--  these filetypes will have MarkdownPreview... commands
vim.g.mkdp_filetypes = { 'markdown' }

--  set default theme (dark or light)
--  By default the theme is defined according to the preferences of the system
vim.g.mkdp_theme = 'dark'

--  combine preview window
--  default: 0
--  if enable it will reuse previous opened preview window when you preview markdown file.
--  ensure to set let g:mkdp_auto_close = 0 if you have enable this option
vim.g.mkdp_combine_preview = 0

--  auto refetch combine preview contents when change markdown buffer
--  only when g:mkdp_combine_preview is 1
vim.g.mkdp_combine_preview_auto_refresh = 0
