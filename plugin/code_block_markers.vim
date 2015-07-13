" vim-code_block_markers
" Author: Shane Harper <shane@shaneharper.net>

if exists("g:loaded_code_block_markers_plugin") | finish | endif
let g:loaded_code_block_markers_plugin = 1


" C/C++ block mappings ---------------------------------------------------- {{{

" Ctrl-k : insert {}s (Mnemonic: 'k'urly)
" (I wanted to use Shift-<CR> but unfortunately it's not possible to map Shift-<CR> differently to <CR> when running Vim in a terminal window.)
" Note: '{' isn't mapped because sometimes we want to have {}s on the one line.
autocmd FileType c,cpp inoremap <buffer> <c-k> <Esc>:call <SID>add_curly_brackets_and_semicolon_if_required()<CR>O
autocmd FileType c,cpp nnoremap <buffer> <c-k> :call <SID>add_curly_brackets_and_semicolon_if_required()<CR>O
autocmd FileType c,cpp vnoremap <buffer> <c-k> >`<O{<Esc>`>o}<Esc>
" XXX ^ nice to add a ';' after the '}' if line before first line of visual selection is the start of a struct/class/enum/union.
" XXX XXX ^ nice to check if selected text is already indented, if so don't indent with '>'
" XXX To do: insert #endif after #if, #ifdef, #ifndef.

" Ctrl-j : insert {}s after a line that needs to contain ()s. '(' is only added if not already present. ')' is always added.
" Ctrl-j can be used at the top of a function definition, or for an 'if', 'for', or 'while' block.
" (Mnemonic: 'j' is beside 'k' on a Qwerty keyboard, and this is similar to Ctrl-k)
" XXX Ctrl-j could act like Ctrl-k (i.e. not add parentheses) if the line already has parentheses! (Then there wouldn't be a need for two mappings: Ctrl-k could do it all: add '(', ')' as required and then insert {}s. For Vimscript, only worry about parentheses after "function", not "if", "for" or "while".)
autocmd FileType c,cpp inoremap <buffer> <c-j> <Esc>:call <SID>add_parentheses()<CR>o{<CR>}<Esc>O
autocmd FileType c,cpp nnoremap <buffer> <c-j> :call <SID>add_parentheses()<CR>o{<CR>}<Esc>O
" XXX Ctrl-j after the start of a struct/class/... def'n could function as ctrl-k does and also insert the start of a constructor signature.

" jj : continue insertion past end of current block (Mnemonic: 'j' moves down in normal mode.)
autocmd FileType c,cpp inoremap <buffer> jj <Esc>]}A<CR>


function s:add_curly_brackets_and_semicolon_if_required()
    let initial_line_text = getline('.')

    execute "normal! o{\<CR>}"

    let is_a_record_definition = (initial_line_text =~# '\(\<class\>\|\<enum\>\|\<struct\>\|\<union\>\)'
                                                     \ .'[^)]*$')  " [small HACK] Filter out lines contains a ')', e.g. 'struct S* fn()' and 'if (struct S* v = fn())'
    let is_an_assignment = (initial_line_text =~# '=$')  " Assume "struct initialization", e.g. MyStruct m = { 1,3,3 };
    let is_an_assignment = is_an_assignment || (initial_line_text =~# '= \[.*\]\(.*\)$')  " Assume lambda definition (XXX incorrect for a lambda that's defined as the default value of a function argument in the function's signature - check to see if there is an unmatched '('.)
    if is_a_record_definition || is_an_assignment
        normal! a;
    endif
endfunction


function s:add_parentheses() " '(' isn't added if already present. ')' is always added.
    normal A)
    let c = getcurpos()
    normal %
    if (c == getcurpos())
        normal i(
    endif
endfunction

" }}}


" Vimscript block mappings ------------------------------------------------ {{{
autocmd FileType vim inoremap <buffer> <c-k> <Esc>:call <SID>insert_vim_end_of_block_keyword()<CR>O
autocmd FileType vim nnoremap <buffer> <c-k> :call <SID>insert_vim_end_of_block_keyword()<CR>O

autocmd FileType vim inoremap <buffer> <c-j> <Esc>:call <SID>add_parentheses()<CR>:call <SID>insert_vim_end_of_block_keyword()<CR>O
autocmd FileType vim nnoremap <buffer> <c-j> :call <SID>add_parentheses()<CR>:call <SID>insert_vim_end_of_block_keyword()<CR>O

autocmd FileType vim inoremap <buffer> jj <Esc>:call search('\<end')<CR>o


function s:insert_vim_end_of_block_keyword()
    " XXX this is incorrect when there are multiple commands on one line, e.g. "let a = s:fn() | if a == 42"
    let block_type = substitute(substitute(getline(s:start_line_number_of_vim_command_under_cursor()),
                        \ " *", "", ""), "[ !].*", "", "")      " First remove leading whitespace, then remove text (including "!" in "function!") following the command name.
    if block_type =~# 'catch\|finally'
        let block_type = 'try'
    endif
    if block_type =~# 'else\|elseif'
        let block_type = 'if'
    endif
    execute "normal! oend".block_type
endfunction


function s:start_line_number_of_vim_command_under_cursor()
    let r = line('.')
    while r > 0 && getline(r) =~# '^\s*\\'  " (while r is a continuation line)
        let r -= 1
    endwhile
    return r
endfunction

" }}}


" Shell script block mappings --------------------------------------------- {{{
autocmd FileType sh inoremap <buffer> <c-k> <Esc>:call <SID>insert_shell_script_block_start_and_end_keywords()<CR>O
autocmd FileType sh nnoremap <buffer> <c-k> :call <SID>insert_shell_script_block_start_and_end_keywords()<CR>O

autocmd FileType sh inoremap <buffer> jj <Esc>:call <SID>move_to_end_of_shell_script_block()<CR>o


function s:insert_shell_script_block_start_and_end_keywords()
    if getline('.') =~# '^\s*if'
        if getline('.') !~# ';\s*then'
            normal A; then
        endif
        normal ofi
    elseif getline('.') =~# '^\s*function'
        normal o{
        normal o}
    else
        if getline('.') !~# ';\s*do'
            normal A; do
        endif
        normal odone
    endif
endfunction

function s:move_to_end_of_shell_script_block()
    call search('\<fi\|\<done\|^}')
endfunction

" }}}


" vim:set foldmethod=marker:
