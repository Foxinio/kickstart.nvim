" Vim systax file
" Language: fram

if exists("b:current_syntax")
	finish
endif

" fram is case sensitive
syntax case match

" keywords
syntax keyword framEffect handle handler finally return
highlight link framEffect Keyword

syntax keyword framDefinition import pub open data let rec in and effect extern method label implicit fn type of
highlight link framDefinition Statement

syntax keyword framConditional if then else match with end
highlight link framConditional Conditional

syntax keyword framTodo TODO Todo ToDo FIXME fixme FixMe XXX
highlight link framTodo Todo

setlocal iskeyword+=_
setlocal iskeyword+=:
setlocal iskeyword+=/
setlocal iskeyword+==
setlocal iskeyword+=>
setlocal iskeyword+=-
setlocal iskeyword+=\|
setlocal iskeyword+=;

syntax keyword framOther _ : / => -> \| \= ;
highlight link framOther Keyword

" comments

syntax match framCommentErr "*)"

syntax region  framComment start=/(\*/  end=/\*)/
highlight link framComment Comment

" delimiters

syntax region framParen   transparent matchgroup=framKeyword start="("  matchgroup=framKeyword  end=")"   contains=ALLBUT,framParenErr
syntax region framBracket transparent matchgroup=framKeyword start="\[" matchgroup=framKeyword  end="\]"  contains=ALLBUT,framBracketErr
syntax region framCurly   transparent matchgroup=framKeyword start="{"  matchgroup=framKeyword  end="}"   contains=ALLBUT,framCurlyErr

highlight def link framParen   Keyword
highlight def link framBracket Keyword
highlight def link framCurly   Keyword
highlight def link framKeyword Keyword

" data

syntax match   framConstructor /\u\(\w\)*\>/
highlight link framConstructor Constant

syntax match   framIdentifier /\<\l\(\w\)*\>/
highlight link framIndentifier Identifier

syntax match framDecimal     "\d\+"
syntax match framBinary      "0\(b\|B\)\(0\|1\)+"
syntax match framOctal       "0\(o\|O\)\(0\|1\|2\|3\|4\|5\|6\|7\)\+"
syntax match framHexadecimal "0\(x\|X\)\(\d\|A\|B\|C\|D\|E\|F\|a\|b\|c\|d\|e\|f\)\+"

highlight link framDecimal     Number
highlight link framBinary      Number
highlight link framOctal       Number
highlight link framHexadecimal Number

" how to you group these into a larger group?

highlight link framNumber Number

syntax match framUnit "(\ *)"
highlight link framUnit Constant

syntax region framString start=/"/ skip=/\\"/ end=/"/
highlight link framString String

" errors

highlight def link framParenErr   Error
highlight def link framBracketErr Error
highlight def link framCurlyErr   Error
highlight def link framCommentErr Error

set nospell

