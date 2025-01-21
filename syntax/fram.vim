" Vim syntax file
" Language: fram

if exists("b:current_syntax")
	finish
endif

syn case match

syn keyword framTodo contained TODO FIXME XXX NOTE

" Parentheses

syn match framParenErr ")"
syn match framBraceErr "}"
syn match framBrackErr "\]"

syn region framParen transparent matchgroup=framParenGroup start="(" end=")" contains=ALLBUT,framParenErr
syn region framBrace transparent matchgroup=framBraceGroup start="{" end="}" contains=ALLBUT,framBraceErr
syn region framBrack transparent matchgroup=framBrackGroup start="\[" end="\]" contains=ALLBUT,framBrackErr

" Keywords

syn keyword framKeyword as data effect else end extern finally fn handle handler if implicit in
syn keyword framKeyword labela let match method module of open rec return then type with
syn keyword framSpecialKw abstr import pub resume

" Identifiers

syn match framOp "[<>&$?!@^+\-~*%;,=|:./]\+"

syn match framIllegalOp "[~?][<>&$?!@^+\-~*%;,=|:./]\@!"
syn match framSpecialOp "\([-=]>\|[|:,.=]\|;;\|>.\)[<>&$?!@^+\-~*%;,=|:./]\@!"

syn match framVariable "\<[a-z_][0-9a-zA-Z_']*\>" contains=framKeyword,framSpecialKw
syn match framImplicit "\~[a-z_][0-9a-zA-Z_']*"
syn match framOptional "?[a-z_][0-9a-zA-Z_']*" contains=framKeyword,framSpecialKw
syn match framType     "\<[A-Z][0-9a-zA-Z_']*\>"

" Numbers

syn match framNumber "[0-9]\+L\?" contained
syn match framNumber "0[bB][01]\+L\?" contained
syn match framNumber "0[oO][0-7]\+L\?" contained
syn match framNumber "0[xX][0-9a-fA-F]\+L\?" contained

syn match framNumberLit "[0-9][0-9a-zA-Z_']*" contains=framNumber

" Characters and strings

syn match framEscapeErr "\\\([^\\'\"\n0nbtrvafxX]\|[xX][^0-9a-fA-F]\|[xX][0-9a-fA-F][^0-9a-fA-F]\)" contained

syn match framCharLit "'\([^\\\n]\|\\\(['\"\\0nbtrvaf]\|[xX][0-9a-fA-F][0-9a-fA-F]\)\)'"
syn match framStringLit "\"\([^\\\n\"]\|\\\(.\)\)*\(\"\|$\)" contains=@Spell,framEscapeErr

" Comments

syn region framComment start="{#\z\([^\x00-\x20{}\x7f]*\)" end="\z1#}" contains=@Spell,framTodo
syn match framCommentL "#.*$" contains=@Spell,framTodo

syn match framCommentErr "#}"

" =================================================================================================

let b:current_syntax = "fram"

syn sync minlines=50
syn sync maxlines=500

hi def link framTodo Todo
hi def link framComment  Comment
hi def link framCommentL Comment

hi def link framParenGroup   Keyword
hi def link framBraceGroup   Keyword
hi def link framBrackGroup   Keyword

hi def link framKeyword    Keyword
hi def link framSpecialKw  Special
hi def link framImplicit   Identifier
hi def link framOptional   Identifier
hi def link framType       Type
hi def link framSpecialOp  Keyword

hi def link framNumber     Number
hi def link framCharLit    Character
hi def link framStringLit  String

hi def link framNumberLit  Error
hi def link framCommentErr Error
hi def link framParenErr   Error
hi def link framBraceErr   Error
hi def link framBrackErr   Error
hi def link framIllegalOp  Error
hi def link framEscapeErr  Error
