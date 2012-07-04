" SyntaxRange.vim: Define a different filetype syntax on regions of a buffer.
"
" DEPENDENCIES:
"
" Source:
"   http://vim.wikia.com/wiki/Different_syntax_highlighting_within_regions_of_a_file
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	05-Jul-2012	file creation

function! SyntaxRange#Include( startPattern, endPattern, filetype, ... )
"******************************************************************************
"* PURPOSE:
"   Define a syntax region from a:startPattern to a:endPattern that includes the
"   syntax for a:filetype.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Defines a syntax region synInclude{filetype} for the current buffer.
"* INPUTS:
"   a:startPattern  Regular expression that specifies the beginning of the
"		    region |:syn-start|.
"   a:endPattern    Regular expression that specifies the end of the region
"		    |:syn-end|.
"   a:filetype      The filetype syntax to use in the region.
"   a:matchGroup    Optional highlight group for the a:startPattern and
"		    a:endPattern matches themselves |:syn-matchgroup|.
"* RETURN VALUES:
"   None.
"******************************************************************************
    call SyntaxRange#IncludeEx(
    \   printf('%s keepend start="%s" end="%s" containedin=ALL',
    \       (a:0 ? 'matchgroup=' . a:1 : ''),
    \       a:startPattern,
    \       a:endPattern
    \   ),
    \   a:filetype
    \)
endfunction
function! SyntaxRange#IncludeEx( regionDefinition, filetype )
"******************************************************************************
"* PURPOSE:
"   Define a syntax region from a:regionDefinition that includes the syntax for
"   a:filetype.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Defines a syntax region synInclude{filetype} for the current buffer.
"* INPUTS:
"   a:regionDefinition  |:syn-region| definition with at least |:syn-start| and
"			|:syn-end|.
"   a:filetype      The filetype syntax to use in the region.
"* RETURN VALUES:
"   None.
"******************************************************************************
    let l:syntaxGroup = 'synInclude' . toupper(a:filetype[0]) . tolower(a:filetype[1:])

    if exists('b:current_syntax')
	let l:current_syntax = b:current_syntax
	" Remove current syntax definition, as some syntax files (e.g. cpp.vim)
	" do nothing if b:current_syntax is defined.
	unlet b:current_syntax
    endif

    execute printf('syntax include @%s syntax/%s.vim', l:syntaxGroup, a:filetype)

    if exists('l:current_syntax')
	let b:current_syntax = l:current_syntax
    else
	unlet b:current_syntax
    endif

    execute printf('syntax region %s %s contains=@%s',
    \   l:syntaxGroup,
    \   a:regionDefinition,
    \   l:syntaxGroup
    \)
endfunction


function! SyntaxRange#SyntaxIgnore( startLine, endLine )
    if a:startLine == a:endLine
	execute printf('syntax match synIgnoreLine /\%%%dl/', a:startLine)
    else
	execute printf('syntax match synIgnoreLine /\%%>%dl\%%<%dl/', (a:startLine - 1), (a:endLine + 1))
    endif
endfunction

function! SyntaxRange#SyntaxInclude( startLine, endLine, filetype )
    call SyntaxRange#Include(
    \   printf('\%%%dl', a:startLine),
    \   printf('\%%%dl', (a:endLine + 1)),
    \   a:filetype
    \)
endfunction



" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
