" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
autoload/ReplaceWithRegister.vim	[[[1
168
" ReplaceWithRegister.vim: Replace text with the contents of a register.
"
" DEPENDENCIES:
"   - repeat.vim (vimscript #2136) autoload script (optional)
"   - visualrepeat.vim (vimscript #3848) autoload script (optional)
"
" Copyright: (C) 2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.30.005	06-Dec-2011	Retire visualrepeat#set_also(); use
"				visualrepeat#set() everywhere.
"   1.30.004	21-Oct-2011	Employ repeat.vim to have the expression
"				re-evaluated on repetition of the
"				operator-pending mapping.
"   1.30.003	30-Sep-2011	Avoid clobbering of expression register so that
"				a command repeat is able to re-evaluate the
"				expression.
"				Undo parallel <Plug>ReplaceWithRegisterRepeat...
"				mappings, as this is now handled by the enhanced
"				repeat.vim plugin.
"   1.30.002	27-Sep-2011	Adaptations for blockwise replace:
"				- If the register contains just a single line,
"				  temporarily duplicate the line to match the
"				  height of the blockwise selection.
"				- If the register contains multiple lines, paste
"				  as blockwise.
"   1.30.001	24-Sep-2011	Moved functions from plugin to separate autoload
"				script.
"				file creation

function! ReplaceWithRegister#SetRegister()
    let s:register = v:register
endfunction
function! ReplaceWithRegister#IsExprReg()
    return (s:register ==# '=')
endfunction

function! s:CorrectForRegtype( type, register, regType, pasteText )
    if a:type ==# 'visual' && visualmode() ==# "\<C-v>" || a:type[0] ==# "\<C-v>"
	" Adaptations for blockwise replace.
	let l:pasteLnum = len(split(a:pasteText, "\n"))
	if a:regType ==# 'v' || a:regType ==# 'V' && l:pasteLnum == 1
	    " If the register contains just a single line, temporarily duplicate
	    " the line to match the height of the blockwise selection.
	    let l:height = line("'>") - line("'<") + 1
	    if l:height > 1
		call setreg(a:register, join(repeat(split(a:pasteText, "\n"), l:height), "\n"), "\<C-v>")
		return 1
	    endif
	elseif a:regType ==# 'V' && l:pasteLnum > 1
	    " If the register contains multiple lines, paste as blockwise.
	    call setreg(a:register, '', "a\<C-v>")
	    return 1
	endif
    elseif a:regType ==# 'V' && a:pasteText =~# '\n$'
	" Our custom operator is characterwise, even in the
	" ReplaceWithRegisterLine variant, in order to be able to replace less
	" than entire lines (i.e. characterwise yanks).
	" So there's a mismatch when the replacement text is a linewise yank,
	" and the replacement would put an additional newline to the end.
	" To fix that, we temporarily remove the trailing newline character from
	" the register contents and set the register type to characterwise yank.
	call setreg(a:register, strpart(a:pasteText, 0, len(a:pasteText) - 1), 'v')

	return 1
    endif

    return 0
endfunction
function! s:ReplaceWithRegister( type )
    " With a put in visual mode, the selected text will be replaced with the
    " contents of the register. This works better than first deleting the
    " selection into the black-hole register and then doing the insert; as
    " "d" + "i/a" has issues at the end-of-the line (especially with blockwise
    " selections, where "v_o" can put the cursor at either end), and the "c"
    " commands has issues with multiple insertion on blockwise selection and
    " autoindenting.
    " With a put in visual mode, the previously selected text is put in the
    " unnamed register, so we need to save and restore that.
    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers.
    let l:save_reg = getreg('"')
    let l:save_regmode = getregtype('"')

    " Note: Must not use ""p; this somehow replaces the selection with itself?!
    let l:pasteCmd = (s:register ==# '"' ? 'p' : '"' . s:register . 'p')
    if s:register ==# '='
	" Cannot evaluate the expression register within a function; unscoped
	" variables do not refer to the global scope. Therefore, evaluation
	" happened earlier in the mappings.
	" To get the expression result into the buffer, we use the unnamed
	" register; this will be restored, anyway.
	call setreg('"', g:ReplaceWithRegister_expr)
	call s:CorrectForRegtype(a:type, '"', getregtype('"'), g:ReplaceWithRegister_expr)
	" Must not clean up the global temp variable to allow command
	" repetition.
	"unlet g:ReplaceWithRegister_expr
	let l:pasteCmd = 'p'
    endif
    try
	if a:type ==# 'visual'
	    execute 'normal! gv' . l:pasteCmd
	else
	    " Note: Need to use an "inclusive" selection to make `] include the
	    " last moved-over character.
	    let l:save_selection = &selection
	    set selection=inclusive
	    try
		execute 'normal! `[' . (a:type ==# 'line' ? 'V' : 'v') . '`]' . l:pasteCmd
	    finally
		let &selection = l:save_selection
	    endtry
	endif
    finally
	call setreg('"', l:save_reg, l:save_regmode)
	let &clipboard = l:save_clipboard
    endtry
endfunction
function! ReplaceWithRegister#Operator( type, ... )
    let l:pasteText = getreg(s:register, 1) " Expression evaluation inside function context may cause errors, therefore get unevaluated expression when s:register ==# '='.
    let l:regType = getregtype(s:register)
    let l:isCorrected = s:CorrectForRegtype(a:type, s:register, l:regType, l:pasteText)
    try
	call s:ReplaceWithRegister(a:type)
    finally
	if l:isCorrected
	    " Undo the temporary change of the register.
	    " Note: This doesn't cause trouble for the read-only registers :, .,
	    " %, # and =, because their regtype is always 'v'.
	    call setreg(s:register, l:pasteText, l:regType)
	endif
    endtry

    if a:0
	silent! call repeat#set(a:1)
    elseif s:register ==# '='
	" Employ repeat.vim to have the expression re-evaluated on repetition of
	" the operator-pending mapping.
	silent! call repeat#set("\<Plug>ReplaceWithRegisterExpressionSpecial")
    endif
    silent! call visualrepeat#set("\<Plug>ReplaceWithRegisterVisual")
endfunction
function! ReplaceWithRegister#OperatorExpression()
    call ReplaceWithRegister#SetRegister()
    set opfunc=ReplaceWithRegister#Operator

    let l:keys = 'g@'

    if ! &l:modifiable || &l:readonly
	" Probe for "Cannot make changes" error and readonly warning via a no-op
	" dummy modification.
	" In the case of a nomodifiable buffer, Vim will abort the normal mode
	" command chain, discard the g@, and thus not invoke the operatorfunc.
	let l:keys = ":call setline(1, getline(1))\<CR>" . l:keys
    endif

    if v:register ==# '='
	" Must evaluate the expression register outside of a function.
	let l:keys = ":let g:ReplaceWithRegister_expr = getreg('=')\<CR>" . l:keys
    endif

    return l:keys
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
plugin/ReplaceWithRegister.vim	[[[1
198
" ReplaceWithRegister.vim: Replace text with the contents of a register.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - ReplaceWithRegister.vim autoload script
"
" Copyright: (C) 2008-2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.31.021	28-Nov-2012	BUG: When repeat.vim is not installed, the grr
"				and v_gr mappings do nothing. Need to :execute
"				the :silent! call of repeat.vim to avoid that
"				the remainder of the command line is aborted
"				together with the call.
"   1.31.020	11-Sep-2012	Minor: Use current line for no-op modification
"				check.
"   1.30.019	21-Oct-2011	Employ repeat.vim to have the expression
"				re-evaluated on repetition of the
"				operator-pending mapping.
"				Pull <SID>Reselect into the main mapping (the
"				final <Esc> is important to "seal" the visual
"				selection and make it recallable via gv),
"				because it doesn't multiply the selection size
"				when [count] is given.
"   1.30.018	21-Oct-2011	BUG: <SID>Reselect swallows register repeat set
"				by repeat.vim. Don't re-use
"				<SID>ReplaceWithRegisterVisual and get rid of
"				it, and instead insert <SID>Reselect in the
"				middle of the expanded
"				<Plug>ReplaceWithRegisterVisual, after the
"				register handling, before the eventual function
"				invocation.
"   1.30.017	30-Sep-2011	Add register registration to enhanced repeat.vim
"				plugin, which also handles repetition when used
"				together with the expression register "=.
"				Undo parallel <Plug>ReplaceWithRegisterRepeat...
"				mappings, as this is now handled by the enhanced
"				repeat.vim plugin.
"				No need for <silent> in default mappings.
"   1.30.015	24-Sep-2011	ENH: Handling use of expression register "=.
"				BUG: v:register is not replaced during command
"				repetition, so repeat always used the unnamed
"				register. Added parallel
"				<Plug>ReplaceWithRegisterRepeat... mappings that
"				omit the <SID>SetRegister() and <SID>IsExprReg()
"				stuff and are registered for repetition instead
"				of the original mappings.
"				Moved functions from plugin to separate autoload
"				script. No need to pass <SID>-opfunc to
"				ReplaceWithRegister#OperatorExpression().
"   1.20.014	26-Apr-2011	BUG: ReplaceWithRegisterOperator didn't work
"				correctly with linewise motions (like "+"); need
"				to use a linewise visual selection in this case.
"   1.20.013	23-Apr-2011	BUG: Text duplicated from yanked previous lines
"				is inserted on a replacement of a visual
"				blockwise selection. Need a special case, which
"				actually is tricky because of the detection of
"				the end-of-the-line in combination with having
"				two cursor positions (via v_o) in a blockwise
"				selection. Instead of following down that road,
"				switch to a put in visual mode in combination
"				with a save and restore of the unnamed register.
"				This should handle all cases and doesn't require
"				the autoindent workaround, neither.
"   1.10.012	18-Mar-2011	The operator-pending mapping now also handles
"				'nomodifiable' and 'readonly' buffers without
"				function errors. Add checking and probing inside
"				s:ReplaceWithRegisterOperatorExpression().
"   1.10.011	17-Mar-2011	Add experimental support for repeating the
"				replacement also in visual mode through
"				visualrepeat.vim. Renamed vmap
"				<Plug>ReplaceWithRegisterOperator to
"				<Plug>ReplaceWithRegisterVisual for that.
"				A repeat in visual mode will now apply the
"				previous line and operator replacement to the
"				selection text. A repeat in normal mode will
"				apply the previous visual mode replacement at
"				the current cursor position, using the size of
"				the last visual selection.
"   1.03.010	07-Jan-2011	ENH: Better handling when buffer is
"				'nomodifiable' or 'readonly'. Using the trick of
"				prepending a no-op buffer modification before
"				invoking the functions. Using try...catch inside
"				s:ReplaceWithRegister() would break the needed
"				abort inside the :normal sequence of replacing
"				the selection, then inserting the register. The
"				disastrous result would be erroneous
"				interpretation of <C-O> as a normal mode
"				command!
"   1.02.009	25-Nov-2009	Replaced the <SID>Count workaround with
"				:map-expr and an intermediate
"				s:ReplaceWithRegisterOperatorExpression.
"   1.01.008	06-Oct-2009	Do not define "gr" mapping for select mode;
"				printable characters should start insert mode.
"   1.00.007	05-Jul-2009	Renamed from ingooperators.vim.
"				Replaced g:register with call to
"				s:SetRegister().
"	006	05-Mar-2009	BF: Besides 'autoindent', 'indentexpr' also
"				causes additional indent. Now completely turning
"				off all these things via the 'paste' option.
"	005	23-Feb-2009	BF: When replacing a complete line over an
"				indented line (with 'Vgr' or 'grr'), the old
"				indent was kept. Now temporarily turning off
"				'autoindent' to avoid that.
"	004	20-Feb-2009	BF: ReplaceWithRegisterOperator mapping didn't
"				work for "last line" G motion, because v:count1
"				defaulted to line 1. Now checking v:count and
"				mapping to <Nop> if no count was given.
"	003	01-Feb-2009	Allowing repeating via '.' by avoiding the
"				script error about undefined variable
"				g:register.
"				Put try...finally around temporary 'selection'
"				setting.
"				ENH: Now allowing [count] in front of
"				gr{motion} (see :help ingo-opfunc for details)
"				and grr (via repeat.vim).
"				Now correcting mismatch when replacement is
"				linewise by temporarily removing the trailing
"				newline.
"	002	15-Aug-2008	Added {Visual}gr and grr mappings.
"	001	11-Aug-2008	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_ReplaceWithRegister') || (v:version < 700)
    finish
endif
let g:loaded_ReplaceWithRegister = 1

let s:save_cpo = &cpo
set cpo&vim

" This mapping repeats naturally, because it just sets global things, and Vim is
" able to repeat the g@ on its own.
nnoremap <expr> <Plug>ReplaceWithRegisterOperator ReplaceWithRegister#OperatorExpression()
" But we need repeat.vim to get the expression register re-evaluated: When Vim's
" . command re-invokes 'opfunc', the expression isn't re-evaluated, an
" inconsistency with the other mappings. We creatively use repeat.vim to sneak
" in the expression evaluation then.
nnoremap <silent> <Plug>ReplaceWithRegisterExpressionSpecial :<C-u>let g:ReplaceWithRegister_expr = getreg('=')<Bar>execute 'normal!' v:count1 . '.'<CR>

" This mapping needs repeat.vim to be repeatable, because it consists of
" multiple steps (visual selection + 'c' command inside
" ReplaceWithRegister#Operator).
nnoremap <silent> <Plug>ReplaceWithRegisterLine
\ :<C-u>call setline('.', getline('.'))<Bar>
\execute 'silent! call repeat#setreg("\<lt>Plug>ReplaceWithRegisterLine", v:register)'<Bar>
\call ReplaceWithRegister#SetRegister()<Bar>
\if ReplaceWithRegister#IsExprReg()<Bar>
\    let g:ReplaceWithRegister_expr = getreg('=')<Bar>
\endif<Bar>
\execute 'normal! V' . v:count1 . "_\<lt>Esc>"<Bar>
\call ReplaceWithRegister#Operator('visual', "\<lt>Plug>ReplaceWithRegisterLine")<CR>

" Repeat not defined in visual mode, but enabled through visualrepeat.vim.
vnoremap <silent> <Plug>ReplaceWithRegisterVisual
\ :<C-u>call setline('.', getline('.'))<Bar>
\execute 'silent! call repeat#setreg("\<lt>Plug>ReplaceWithRegisterVisual", v:register)'<Bar>
\call ReplaceWithRegister#SetRegister()<Bar>
\if ReplaceWithRegister#IsExprReg()<Bar>
\    let g:ReplaceWithRegister_expr = getreg('=')<Bar>
\endif<Bar>
\call ReplaceWithRegister#Operator('visual', "\<lt>Plug>ReplaceWithRegisterVisual")<CR>

" A normal-mode repeat of the visual mapping is triggered by repeat.vim. It
" establishes a new selection at the cursor position, of the same mode and size
" as the last selection.
"   If [count] is given, the size is multiplied accordingly. This has the side
"   effect that a repeat with [count] will persist the expanded size, which is
"   different from what the normal-mode repeat does (it keeps the scope of the
"   original command).
" First of all, the register must be handled, though.
nnoremap <silent> <Plug>ReplaceWithRegisterVisual
\ :<C-u>call setline('.', getline('.'))<Bar>
\execute 'silent! call repeat#setreg("\<lt>Plug>ReplaceWithRegisterVisual", v:register)'<Bar>
\call ReplaceWithRegister#SetRegister()<Bar>
\if ReplaceWithRegister#IsExprReg()<Bar>
\    let g:ReplaceWithRegister_expr = getreg('=')<Bar>
\endif<Bar>
\execute 'normal!' v:count1 . 'v' . (visualmode() !=# 'V' && &selection ==# 'exclusive' ? ' ' : ''). "\<lt>Esc>"<Bar>
\call ReplaceWithRegister#Operator('visual', "\<lt>Plug>ReplaceWithRegisterVisual")<CR>


if ! hasmapto('<Plug>ReplaceWithRegisterOperator', 'n')
    nmap gr <Plug>ReplaceWithRegisterOperator
endif
if ! hasmapto('<Plug>ReplaceWithRegisterLine', 'n')
    nmap grr <Plug>ReplaceWithRegisterLine
endif
if ! hasmapto('<Plug>ReplaceWithRegisterVisual', 'x')
    xmap gr <Plug>ReplaceWithRegisterVisual
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
doc/ReplaceWithRegister.txt	[[[1
179
*ReplaceWithRegister.txt*   Replace text with the contents of a register.

		   REPLACE WITH REGISTER    by Ingo Karkat
						     *ReplaceWithRegister.vim*
description			|ReplaceWithRegister-description|
usage				|ReplaceWithRegister-usage|
installation			|ReplaceWithRegister-installation|
configuration			|ReplaceWithRegister-configuration|
limitations			|ReplaceWithRegister-limitations|
known problems			|ReplaceWithRegister-known-problems|
todo				|ReplaceWithRegister-todo|
history				|ReplaceWithRegister-history|

==============================================================================
DESCRIPTION				     *ReplaceWithRegister-description*

Replacing an existing text with the contents of a register is a very common
task during editing. One typically first deletes the existing text via the
|d|, |D| or |dd| commands, then pastes the register with |p| or |P|. Most of
the time, the unnamed register is involved, with the following pitfall: If you
forget to delete into the black-hole register ("_), the replacement text is
overwritten!

This plugin offers a two-in-one command that replaces text covered by a
{motion}, entire line(s) or the current selection with the contents of a
register; the old text is deleted into the black-hole register, i.e. it's
gone. (But of course, the command can be easily undone.)

The replacement mode (characters or entire lines) is determined by the
replacement command / selection, not by the register contents. This avoids
surprises like when the replacement text was a linewise yank, but the
replacement is characterwise: In this case, no additional newline is inserted.

RELATED WORKS								     *

- regreplop.vim (vimscript #2702) provides an alternative implementation of
  the same idea.
- operator-replace (vimscript #2782) provides replacement of {motion} only,
  depends on another library of the author, and does not have a default
  mapping.
- Luc Hermitte has an elegant minimalistic visual-mode mapping in
  http://code.google.com/p/lh-vim/source/browse/misc/trunk/macros/repl-visual-no-reg-overwrite.vim

==============================================================================
USAGE						   *ReplaceWithRegister-usage*

							     *gr* *grr* *v_gr*
["x][count]gr{motion}	Replace {motion} text with the contents of register x.
			Especially when using the unnamed register, this is
			quicker than "_d{motion}P or "_c{motion}<C-R>"
["x][count]grr		Replace [count] lines with the contents of register x.
			To replace from the cursor position to the end of the
			line use ["x]gr$
{Visual}["x]gr		Replace the selection with the contents of register x.

==============================================================================
INSTALLATION				    *ReplaceWithRegister-installation*

This script is packaged as a |vimball|. If you have the "gunzip" decompressor
in your PATH, simply edit the *.vmb.gz package in Vim; otherwise, decompress
the archive first, e.g. using WinZip. Inside Vim, install by sourcing the
vimball or via the |:UseVimball| command. >
    vim ReplaceWithRegister*.vmb.gz
    :so %
To uninstall, use the |:RmVimball| command.

DEPENDENCIES				    *ReplaceWithRegister-dependencies*

- Requires Vim 7.0 or higher.
- repeat.vim (vimscript #2136) plugin (optional)
  To support repetition with a register other than the default register, you
  need a plugin version later than the 1.0 version published on vim.org. You
  can download it from the repository at https://github.com/tpope/vim-repeat
- visualrepeat.vim (vimscript #3848) plugin (optional)

==============================================================================
CONFIGURATION				   *ReplaceWithRegister-configuration*

The default mappings override the (rarely used, but somewhat related) |gr|
command (replace virtual characters under the cursor with {char}).
If you want to use different mappings, map your keys to the
<Plug>ReplaceWithRegister... mapping targets _before_ sourcing the script
(e.g. in your |vimrc|): >
    nmap <Leader>r  <Plug>ReplaceWithRegisterOperator
    nmap <Leader>rr <Plug>ReplaceWithRegisterLine
    vmap <Leader>r  <Plug>ReplaceWithRegisterVisual
<
==============================================================================
LIMITATIONS				     *ReplaceWithRegister-limitations*

- The commands don't work on the readonly registers ":, "., "% and "#. "E384:
  Invalid register name" is printed.
- The commands don't work on the expression register "=. Nothing is pasted.
- The mode cannot be set for register "/; it will always be pasted
  characterwise. Implement a special case for glp?
- With :set selection=clipboard together with either "autoselect" (in the
  console) or a 'guioptions' setting that contains "a" (in the GUI), the
  mappings don't seem to work. This is because they all temporarily create a
  visual selection, whose contents are put into register *, which is the
  default register due to the 'selection' setting. Therefore, the replacement
  replaces itself. The same happens when you try to replace the visual
  selection via the built-in |v_p| command. Either don't use these settings in
  combination, or explicitly select the default register by prepending "" to
  the mappings.

KNOWN PROBLEMS				  *ReplaceWithRegister-known-problems*

TODO						    *ReplaceWithRegister-todo*

IDEAS						   *ReplaceWithRegister-ideas*

==============================================================================
HISTORY						 *ReplaceWithRegister-history*

1.31	28-Nov-2012
BUG: When repeat.vim is not installed, the grr and v_gr mappings do nothing.
Need to :execute the :silent! call of repeat.vim to avoid that the remainder
of the command line is aborted together with the call. Thanks for David
Kotchan for reporting this.

1.30	06-Dec-2011
- Adaptations for blockwise replace:
  - If the register contains just a single line, temporarily duplicate the
    line to match the height of the blockwise selection.
  - If the register contains multiple lines, paste as blockwise.
- BUG: v:register is not replaced during command repetition, so repeat always
  used the unnamed register. Add register registration to enhanced repeat.vim
  plugin, which also handles repetition when used together with the expression
  register "=. Requires a so far inofficial update to repeat.vim version 1.0
  (that hopefully makes it into upstream), which is available at
  https://github.com/inkarkat/vim-repeat/zipball/1.0ENH1
- Moved functions from plugin to separate autoload script.

1.20	26-Apr-2011
- BUG: ReplaceWithRegisterOperator didn't work correctly with linewise motions
  (like "+"); need to use a linewise visual selection in this case.
- BUG: Text duplicated from yanked previous lines is inserted on a replacement
  of a visual blockwise selection. Switch replacement mechanism to a put in
  visual mode in combination with a save and restore of the unnamed register.
  This should handle all cases and doesn't require the autoindent workaround,
  neither.

1.10	21-Apr-2011
- The operator-pending mapping now also handles 'nomodifiable' and 'readonly'
  buffers without function errors.
- Add experimental support for repeating the replacement also in visual mode
  through visualrepeat.vim. Renamed vmap <Plug>ReplaceWithRegisterOperator to
  <Plug>ReplaceWithRegisterVisual for that.
  *** PLEASE UPDATE YOUR CUSTOM MAPPINGS ***
  A repeat in visual mode will now apply the previous line and operator
  replacement to the selection text. A repeat in normal mode will apply the
  previous visual mode replacement at the current cursor position, using the
  size of the last visual selection.

1.03    07-Jan-2011
- ENH: Better handling when buffer is 'nomodifiable' or 'readonly'.
- Added separate help file and packaging the plugin as a vimball.

1.02    25-Nov-2009
Replaced the <SID>Count workaround with :map-expr and an intermediate
s:ReplaceWithRegisterOperatorExpression.

1.01    06-Oct-2009
Do not define "gr" mapping for select mode; printable characters should start
insert mode.

1.00	05-Jal-2009
First published version.

0.01	11-Aug-2008
Started development.

==============================================================================
Copyright: (C) 2008-2011 Ingo Karkat
The VIM LICENSE applies to this script; see |copyright|.

Maintainer:	Ingo Karkat <ingo@karkat.de>
==============================================================================
 vim:tw=78:ts=8:ft=help:norl:
