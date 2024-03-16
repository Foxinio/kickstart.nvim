" Vim systax file
" Language: dbl 

if exists("b:current_syntax")
	finish
endif

" dbl is case sensitive
syntax case match

" keywords
syntax keyword dblEffect handle handler finally return
highlight link dblEffect Keyword

syntax keyword dblDefinition data let rec in and effect extern method label implicit fn type of
highlight link dblDefinition Statement

syntax keyword dblConditional if then else match with end
highlight link dblConditional Conditional

syntax keyword dblTodo TODO Todo ToDo FIXME fixme FixMe XXX
highlight link dblTodo Todo

setlocal iskeyword+=_
setlocal iskeyword+=:
setlocal iskeyword+=/
setlocal iskeyword+==
setlocal iskeyword+=>
setlocal iskeyword+=-
setlocal iskeyword+=\|
setlocal iskeyword+=;

syntax keyword dblOther _ : / => -> \| \= ;
highlight link dblOther Keyword

" comments

syntax match dblCommentErr "*)"

syntax region  dblComment start=/(\*/  end=/\*)/
highlight link dblComment Comment

" delimiters

syntax region dblParen   transparent matchgroup=dblKeyword start="("  matchgroup=dblKeyword  end=")"   contains=ALLBUT,dblParenErr
syntax region dblBracket transparent matchgroup=dblKeyword start="\[" matchgroup=dblKeyword  end="\]"  contains=ALLBUT,dblBracketErr
syntax region dblCurly   transparent matchgroup=dblKeyword start="{"  matchgroup=dblKeyword  end="}"   contains=ALLBUT,dblCurlyErr

highlight def link dblParen   Keyword
highlight def link dblBracket Keyword
highlight def link dblCurly   Keyword
highlight def link dblKeyword Keyword

" data

syntax match   dblConstructor /\u\(\w\)*\>/
highlight link dblConstructor Constant

syntax match   dblIdentifier /\<\l\(\w\)*\>/
highlight link dblIndentifier Identifier

syntax match dblDecimal     "\d\+"
syntax match dblBinary      "0\(b\|B\)\(0\|1\)+"
syntax match dblOctal       "0\(o\|O\)\(0\|1\|2\|3\|4\|5\|6\|7\)\+"
syntax match dblHexadecimal "0\(x\|X\)\(\d\|A\|B\|C\|D\|E\|F\|a\|b\|c\|d\|e\|f\)\+"

highlight link dblDecimal     Number
highlight link dblBinary      Number
highlight link dblOctal       Number
highlight link dblHexadecimal Number

" how to you group these into a larger group?

highlight link dblNumber Number

syntax match dblUnit "(\ *)"
highlight link dblUnit Constant

syntax region dblString start=/"/ skip=/\\"/ end=/"/
highlight link dblString String

" errors

highlight def link dblParenErr   Error
highlight def link dblBracketErr Error
highlight def link dblCurlyErr   Error
highlight def link dblCommentErr Error

