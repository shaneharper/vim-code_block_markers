" vim-code_block_markers
" Author: Shane Harper <shane@shaneharper.net>

let s:cpoptions_save = &cpoptions
set cpoptions&vim


" XXX Check if insert mode mappings work when Vim's insertmode option is set.


if exists("g:loaded_code_block_markers_plugin") | finish | endif
let g:loaded_code_block_markers_plugin = 1


function s:set_normal_and_insert_mode_mapping(filetypes, keys, normal_mode_command)
    execute 'autocmd FileType' a:filetypes 'inoremap <buffer>' a:keys '<Esc>'.a:normal_mode_command
    execute 'autocmd FileType' a:filetypes 'noremap <buffer>' a:keys a:normal_mode_command
endfunction


" C/C++/C# block mappings ------------------------------------------------- {{{

" Ctrl-k : insert {}s (Mnemonic: 'k'urly)
" (I wanted to use Shift-<CR> but unfortunately it's not possible to map Shift-<CR> differently to <CR> when running Vim in a terminal window.)
" Note: '{' isn't mapped because sometimes we want to have {}s on the one line.
call s:set_normal_and_insert_mode_mapping('c,cpp,cs', '<c-k>', ':call <SID>add_curly_brackets_and_semicolon_if_required_for_C_language_block()<CR>O')

autocmd FileType c,cpp,cs vnoremap <buffer> <c-k> >`<O{<Esc>`>o}<Esc>
" XXX ^ nice to add a ';' after the '}' if line before first line of visual selection is the start of a struct/class/enum/union.
" XXX XXX ^ nice to check if selected text is already indented, if so don't indent with '>'
" XXX To do: insert #endif after #if, #ifdef, #ifndef.

" Ctrl-j : insert {}s after a line that needs to contain ()s. '(' is only added if not already present. ')' is always added.
" Ctrl-j can be used at the top of a function definition, or for an 'if', 'for', or 'while' block.
" (Mnemonic: 'j' is beside 'k' on a Qwerty keyboard, and this is similar to Ctrl-k)
" XXX Ctrl-j could act like Ctrl-k (i.e. not add parentheses) if the line already has parentheses! (Then there wouldn't be a need for two mappings: Ctrl-k could do it all: add '(', ')' as required and then insert {}s. For Vimscript, only worry about parentheses after "function", not "if", "for" or "while".)
call s:set_normal_and_insert_mode_mapping('c,cpp,cs', '<c-j>', ':call <SID>add_parentheses()<CR>o{<CR>}<Esc>O')
" XXX Ctrl-j after the start of a struct/class/... def'n could function as ctrl-k does and also insert the start of a constructor signature.

" jj : continue insertion past end of current block (Mnemonic: 'j' moves down in normal mode.)
autocmd FileType c,cpp,cs inoremap <buffer> jj <Esc>]}A<CR>


function s:add_curly_brackets_and_semicolon_if_required_for_C_language_block()
    " xxx There may be some minor problems with this for C# code.
    let initial_line_text = getline('.')

    execute "normal!" (initial_line_text =~ '^\s*$' ? 'i' : 'o')."{\<CR>}"

    let is_a_record_definition = (initial_line_text =~# '\(\<class\>\|\<enum\>\|\<struct\>\|\<union\>\)'
                                                     \ .'[^)]*$')  " [small HACK] Filter out lines containing a ')', e.g. 'struct S* fn()' and 'if (struct S* v = fn())'
    let is_an_assignment = (initial_line_text =~# '=$')  " Assume "struct initialization", e.g. MyStruct m = { 1,3,3 };
    let is_an_assignment = is_an_assignment || (initial_line_text =~# '= \[.*\]\(.*\)$')  " Assume lambda definition (XXX incorrect for a lambda that's defined as the default value of a function argument in the function's signature - check to see if there is an unmatched '('.)
    if (is_a_record_definition && &filetype != 'cs') || is_an_assignment
        normal! a;
    endif
endfunction

" }}}


" CMake block mappings ---------------------------------------------------- {{{
call s:set_normal_and_insert_mode_mapping('cmake', '<c-k>', ':call <SID>insert_cmakelists_block_end_keyword()<CR>O')
autocmd FileType cmake inoremap <buffer> <c-j> )<Esc>:call <SID>insert_cmakelists_block_end_keyword()<CR>O
autocmd FileType cmake nnoremap <buffer> <c-j> :exec 'normal A)'<bar>call <SID>insert_cmakelists_block_end_keyword()<CR>O

autocmd FileType cmake inoremap <buffer> jj <Esc>:call <SID>move_to_end_of_cmakelists_block()<CR>o


function s:insert_cmakelists_block_end_keyword()
    if getline('.') =~# '^\s*\(if\|elseif\|else\)\>'
        normal oendif()
    elseif getline('.') =~# '^\s*while\>'
        normal oendwhile()
    endif
endfunction

function s:move_to_end_of_cmakelists_block()
    call search('\<endif()\|endwhile()')
endfunction

" }}}


" DOS batch block mappings ------------------------------------------------ {{{
call s:set_normal_and_insert_mode_mapping('dosbatch', '<c-k>', 'A (<CR>)<Esc>ko')  " Note: '(' must appear on the same line as the end of an IF condition - "^\n(" won't work.

" }}}


" Shell script block mappings --------------------------------------------- {{{
" xxx csh/tcsh not supported.
call s:set_normal_and_insert_mode_mapping('sh,zsh', '<c-k>', ':call <SID>insert_shell_script_block_start_and_end_keywords()<CR>O')

autocmd FileType sh,zsh inoremap <buffer> jj <Esc>:call <SID>move_to_end_of_shell_script_block()<CR>o


function s:insert_shell_script_block_start_and_end_keywords()
    if getline('.') =~# '^\s*if\>'
        if getline('.') !~# ';\s*then'
            if getline('.') !~# ';\s*$'
                normal A;
            endif
            normal A then
        endif
        normal ofi
        normal <<
    elseif getline('.') =~# '^\s*\(function\|\w*()\)'
        normal o{
        normal o}
        normal <<
    elseif getline('.') =~# '^\s*case\>'
        normal oesac
    else
        if getline('.') !~# ';\s*do\>'
            normal A; do
        endif
        normal odone
    endif
endfunction

function s:move_to_end_of_shell_script_block()
    call search('\<fi\|\<done\|^}')
endfunction

" }}}


" Vim script block mappings ----------------------------------------------- {{{
call s:set_normal_and_insert_mode_mapping('vim', '<c-k>', ':call <SID>insert_vim_end_of_block_keyword()<CR>O')
call s:set_normal_and_insert_mode_mapping('vim', '<c-j>', ':call <SID>add_parentheses()<CR>:call <SID>insert_vim_end_of_block_keyword()<CR>O')

autocmd FileType vim inoremap <buffer> jj <Esc>:call search('\<end')<CR>o


function s:insert_vim_end_of_block_keyword()
    " XXX this is incorrect when there are multiple commands on one line, e.g. "let a = s:fn() | if a == 42"
    let block_type = substitute(substitute(getline(s:start_line_number_of_vim_command_under_cursor()),
                        \ " *", "", ""), "[ !].*", "", "")      " First remove leading whitespace, then remove text (including "!" in "function!") following the command name.
    if block_type ==# 'augroup'
        normal! oaugroup END
        " XXX add "autocmd!" as first line of block (iff <C-j>, not <C-k> used)?
    elseif block_type ==# 'redir'
        normal! oredir END
    else
        if block_type =~# '^catch\|finally'
            let block_type = 'try'
        elseif block_type =~# '^else\|elseif'
            let block_type = 'if'
        endif
        execute "normal! oend".block_type
    endif
endfunction


function s:start_line_number_of_vim_command_under_cursor()
    let r = line('.')
    while r > 0 && getline(r) =~# '^\s*\\'  " (while r is a continuation line)
        let r -= 1
    endwhile
    return r
endfunction

" }}}


" Utility functions ------------------------------------------------------- {{{
function s:add_parentheses() " '(' isn't added if already present. ')' is always added.
    normal A)
    if searchpair('(', '', ')', 'bnW',
            \ 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\\|comment"',
            \ max([line('.')-40, 1])) <= 0  " XXX ^ should ignore more than just string and comment?
        normal i(
    endif
endfunction

" }}}


let &cpoptions = s:cpoptions_save

" vim:set foldmethod=marker:
