" Don't try to be vi compatible
set nocompatible

" Helps force plugins to load correctly when it is turned back on below
filetype off

" Vundle configuration
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Git wrapper plugin
Plugin 'tpope/vim-fugitive'
" surround with stuff
Plugin 'tpope/vim-surround'
" plugin for commenting stuff out
Plugin 'scrooloose/nerdcommenter'
" neovim like filesystem navigation tool plugin
Plugin 'wincent/command-t'
" html templates plugin
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" general utility plugin
Plugin 'ascenator/L9', {'name': 'newL9'}


" My Plugins
Plugin 'neoclide/coc.nvim'
Plugin 'dense-analysis/ale'
" Plugin 'vim-syntastic/syntastic'
" Plugin 'nickspoons/vim-sharpenup'
Plugin 'OmniSharp/Omnisharp-vim'
Plugin 'ap/vim-css-color'
" Plugin 'khzaw/vim-conceal'
Plugin 'lervag/vimtex'
Plugin 'joom/latex-unicoder.vim'
Plugin 'whonore/Coqtail'

" never used
" Plugin 'powerman/vim-plugin-AnsiEsc'

" Grep integration plugin for Rgrep
Plugin 'vim-scripts/grep.vim'

" Jupyter handling (never used)
Plugin 'jupyter-vim/jupyter-vim'

" A Vim Plugin for Lively Previewing LaTeX PDF Output
Plugin 'xuhdev/vim-latex-live-preview'
Plugin 'markdown-preview.nvim'


call vundle#end()            " required
filetype plugin indent on    " required


" Turn on syntax highlighting
syntax on

