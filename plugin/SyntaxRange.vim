" SyntaxRange.vim: Define a different filetype syntax on regions of a buffer.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - SyntaxRange.vim autoload script
"
" Copyright: (C) 2012-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_SyntaxRange') || (v:version < 700)
    finish
endif
let g:loaded_SyntaxRange = 1

command! -bar -range                           SyntaxIgnore  call SyntaxRange#SyntaxIgnore(<line1>, <line2>)
if v:version < 703
command! -bar -range -nargs=1                  SyntaxInclude call SyntaxRange#SyntaxInclude(<line1>, <line2>, <q-args>)
else
command! -bar -range -nargs=1 -complete=syntax SyntaxInclude call SyntaxRange#SyntaxInclude(<line1>, <line2>, <q-args>)
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
