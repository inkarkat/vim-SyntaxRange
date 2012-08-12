" SyntaxRange.vim: Define a different filetype syntax on regions of a buffer.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - SyntaxRange.vim autoload script
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

command! -bar -range          SyntaxIgnore  call SyntaxRange#SyntaxIgnore(<line1>, <line2>)
command! -bar -range -nargs=1 SyntaxInclude call SyntaxRange#SyntaxInclude(<line1>, <line2>, <q-args>)

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
