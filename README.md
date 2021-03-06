SYNTAX RANGE
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

This plugin provides commands and functions to set up regions in the current
buffer that either use a syntax different from the buffer's 'filetype', or
completely ignore the syntax.

### SEE ALSO

- If you also want different buffer options (like indent settings, etc.) for
  each syntax region, the OnSyntaxChange.vim plugin ([vimscript #4085](http://www.vim.org/scripts/script.php?script_id=4085)) allows
  you to dynamically change the buffer options as you move through the buffer.

### RELATED WORKS

- If the highlighting doesn't work properly, you could alternatively edit the
  range(s) in a separate scratch buffer. Plugins like NrrwRgn ([vimscript #3075](http://www.vim.org/scripts/script.php?script_id=3075))
  provide commands to set these up, with automatic syncing back to the
  original buffer.

### SOURCE

- [The code to include a different syntax in a region is based on](http://vim.wikia.com/wiki/Different_syntax_highlighting_within_regions_of_a_file)

USAGE
------------------------------------------------------------------------------

    For quick, ad-hoc manipulation of the syntax withing a range of lines, the
    following commands are provided:

    :[range]SyntaxIgnore    Ignore the buffer's filetype syntax for the current
                            line / lines in [range]. (Top-level keywords will
                            still be highlighted.)
                            This can be a useful fix when some text fragments
                            confuse the syntax highlighting. (For example, when
                            buffer syntax set to an inlined here-document is
                            negatively affected by the foreign code surrounding
                            the here-document.)

    :[range]SyntaxInclude {filetype}
                            Use the {filetype} syntax for the current line / lines
                            in [range].

                            Line numbers in [range] are fixed; i.e. they do not
                            adapt to inserted / deleted lines. But when in a
                            range, the last line ($) is interpreted as "end of
                            file".

    For finer control and use in custom mappings or syntax tweaks, the following
    functions can be used. You'll find the details directly in the
    .vim/autoload/SyntaxRange.vim implementation file.

    SyntaxRange#Include( {startPattern}, {endPattern}, {filetype} [, {matchGroup} [, {contains}]] )
                            Use the {filetype} syntax for the region defined by
                            {startPattern} and {endPattern}. Optionally highlight
                            {startPattern} and {endPattern} itself with
                            {matchGroup}, and additionally allow {contains} groups
                            inside the region.
    SyntaxRange#IncludeEx( {regionDefinition}, {filetype} [, {contains}] )
                            Use the {filetype} syntax for the region defined by
                            {regionDefinition}. Additionally allow {contains}
                            groups inside the region.

### EXAMPLE

To highlight the text between the markers with C syntax:
```
    @begin=c@
    int i = 42;
    @end=c@
```

To do this statically, with fixed line numbers, for the first occurrence in
the file:

    :1;/@begin=c@/,/@end=c@/SyntaxInclude c

The dynamic version will apply to all occurrences, handles changes in the line
numbers, and also can make the markers themselves fade into the background:

    :call SyntaxRange#Include('@begin=c@', '@end=c@', 'c', 'NonText')

To highlight inline patches inside emails:

    :call SyntaxRange#IncludeEx('start="^changeset\|^Index: \|^diff \|^--- .*\%( ----\)\@<!$" skip="^[-+@       ]" end="^$"', 'diff')

To install this automatically for the "mail" filetype, put above line into a
script in ~/.vim/after/syntax/mail/SyntaxInclude.vim

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-SyntaxRange
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim SyntaxRange*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.022 or
  higher.

INTEGRATION
------------------------------------------------------------------------------

To automatically include a syntax in a certain {filetype}, you can put the
command into a script in

    ~/.vim/after/syntax/{filetype}/SyntaxInclude.vim

If you want to include a syntax in several (or even all) syntaxes, you can put
this into your vimrc:

    :autocmd Syntax * call SyntaxRange#Include(...)

If you have a filetype1 syntax that includes filetype2 and vice versa, you
will run into E169: Command too recursive. This can be solved by inclusion
guards around each invocation. In ~/.vim/after/syntax/filetype1.vim:

    let b:loaded_filetype1_syntax_includes = 1
    if !exists('b:loaded_filetype2_syntax_includes')
        call SyntaxRange#Include('...', '...', 'filetype2')
    endif
    ...
    unlet b:loaded_filetype1_syntax_includes

And the inverse in ~/.vim/after/syntax/filetype2.vim:

    let b:loaded_filetype2_syntax_includes = 1
    if !exists('b:loaded_filetype1_syntax_includes')
        call SyntaxRange#Include('...', '...', 'filetype1')
    endif
    ...
    unlet b:loaded_filetype2_syntax_includes

LIMITATIONS
------------------------------------------------------------------------------

- The original filetype's syntax may interfere with the syntax range, and vice
  versa. To define the range with high priority, the commands inject it with
  "containedin=ALL".

### CONTRIBUTING

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-SyntaxRange/issues or email (address below).

HISTORY
------------------------------------------------------------------------------

##### 1.04    RELEASEME
- Allow setting additional contains groups via an optional argument to
  SyntaxRange#Include\[Ex](). Thanks to Sergey Vlasov for sending a patch.
- Rename the re-inclusion guard from b:SyntaxInclude\_IncludedFiletypes (List)
  to b:SyntaxInclude\_Included (Dict). Handle buffer reload via :edit by making
  it dependent on b:changedtick as well.

##### 1.03    01-Jul-2017
- SyntaxRange#Include(): Escape double quotes in a:startPattern and
  a:endPattern; i.e. handle the patterns transparently. Found in tmsanrinsha's
  fork.
- ENH: Avoid to re-include same syntax file if multiple ranges are specified
  with :SyntaxInclude / if SyntaxRange#Include\[Ex]() is invoked multiple times
  per buffer. Found in tmsanrinsha's fork.

##### 1.02    23-Apr-2015
- Set main\_syntax to the buffer's syntax during :syntax include of the
  subordinate syntax script. Some scripts may make special arrangements when
  included. Suggested by OOO.
- Handle :.SyntaxInclude and :.SyntaxIgnore on folded lines correctly. Use
  ingo#range#NetStart/End().
- Add dependency to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)).

__You need to separately
  install ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.022 (or higher)!__

##### 1.01    21-Nov-2013
- Avoid "E108: No such variable: b:current\_syntax" when the (misbehaving)
included syntax doesn't set it. Reported by o2genum at
http://stackoverflow.com/a/16162412/813602.

##### 1.00    13-Aug-2012
- First published version.

##### 0.01    05-Jul-2012
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2012-2020 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
