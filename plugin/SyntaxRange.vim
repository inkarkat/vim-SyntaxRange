" SyntaxRange.vim: summary
"
" DEPENDENCIES:
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	05-Jul-2012	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_SyntaxRange') || (v:version < 700)
    finish
endif
let g:loaded_SyntaxRange = 1

function! s:SyntaxIgnore( startLine, endLine )
    if a:startLine == a:endLine
	execute printf('syntax match synIgnoreLine /\%%%dl/', a:startLine)
    else
	execute printf('syntax match synIgnoreLine /\%%>%dl\%%<%dl/', (a:startLine - 1), (a:endLine + 1))
    endif
endfunction

command! -bar -range SyntaxIgnore call <SID>SyntaxIgnore(<line1>, <line2>)

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
