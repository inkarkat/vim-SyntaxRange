" SyntaxRange.vim: Define a different filetype syntax on regions of a buffer.
"
" DEPENDENCIES:
"   - ingo/range.vim autoload script
"
" Source:
"   http://vim.wikia.com/wiki/Different_syntax_highlighting_within_regions_of_a_file
"
" Copyright: (C) 2012-2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.02.003	30-Mar-2015	Handle :.SyntaxInclude and :.SyntaxIgnore on
"				folded lines correctly. Use
"				ingo#range#NetStart/End().
"				Set main_syntax to the buffer's syntax during
"				:syntax include of the subordinate syntax
"				script. Some scripts may make special
"				arrangements when included. Suggested by OOO.
"   1.01.002	23-Apr-2013	Avoid "E108: No such variable: b:current_syntax"
"				when the (misbehaving) included syntax doesn't
"				set it. Reported by o2genum at
"				http://stackoverflow.com/a/16162412/813602.
"   1.00.001	05-Jul-2012	file creation
let s:save_cpo = &cpo
set cpo&vim

function! SyntaxRange#Include( startPattern, endPattern, filetype, ... )
"******************************************************************************
"* PURPOSE:
"   Define a syntax region from a:startPattern to a:endPattern that includes the
"   syntax for a:filetype. For the common case, this automatically ensures that
"   a contained match does not extend beyond a:endPattern (though contained
"   syntax items with |:syn-extend| break that), and that the patterns are also
"   matched inside all existing (also contained) syntax items.
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
"   a:filetype. Use this extended function when you have multiple start- or end
"   patterns, skip patterns, want to specify match offsets, control the
"   containment, etc.
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

    if ! exists('g:main_syntax') && ! empty(&l:syntax)
	let g:main_syntax = &l:syntax
	let l:hasSetMainSyntax = 1
    endif

    execute printf('syntax include @%s syntax/%s.vim', l:syntaxGroup, a:filetype)

    if exists('l:hasSetMainSyntax')
	unlet! g:main_syntax
    endif

    if exists('l:current_syntax')
	let b:current_syntax = l:current_syntax
    else
	unlet! b:current_syntax
    endif

    execute printf('syntax region %s %s contains=@%s',
    \   l:syntaxGroup,
    \   a:regionDefinition,
    \   l:syntaxGroup
    \)
endfunction


function! SyntaxRange#SyntaxIgnore( startLnum, endLnum )
    let [l:startLnum, l:endLnum] = [ingo#range#NetStart(a:startLnum), ingo#range#NetEnd(a:endLnum)]
    if l:startLnum == l:endLnum
	execute printf('syntax match synIgnoreLine /\%%%dl/', l:startLnum)
    elseif l:startLnum < l:endLnum && l:endLnum == line('$')
	execute printf('syntax match synIgnoreLine /\%%>%dl/', (l:startLnum - 1))
    else
	execute printf('syntax match synIgnoreLine /\%%>%dl\%%<%dl/', (l:startLnum - 1), (l:endLnum + 1))
    endif
endfunction

function! SyntaxRange#SyntaxInclude( startLnum, endLnum, filetype )
    let [l:startLnum, l:endLnum] = [ingo#range#NetStart(a:startLnum), ingo#range#NetEnd(a:endLnum)]
    call SyntaxRange#Include(
    \   printf('\%%%dl', l:startLnum),
    \   (l:startLnum < l:endLnum && l:endLnum == line('$') ?
    \       '\%$' :
    \       printf('\%%%dl', (l:endLnum + 1))
    \   ),
    \   a:filetype
    \)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
