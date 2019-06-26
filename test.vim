" Run this from a shell:
"  vim -S test.vim

let s:cpoptions_save = &cpoptions
set cpoptions&vim

set noswapfile
set noexpandtab
set shiftwidth=0

let s:failed_test_log = ""

try

function s:test(tests)
    for [test_name, buffer_text, normal_mode_command, expected_buffer_text] in a:tests
        call setline(1, split(buffer_text, "\n"))
        execute 'normal G'.normal_mode_command
        if expected_buffer_text !=# getline(1, "$")
            let s:failed_test_log .= test_name." (".&filetype.") test failed\nBuffer:\n".join(getline(1,"$"),"\n")."\n\n"
        endif
        normal ggdG
    endfor
endfunction

source plugin/code_block_markers.vim

set filetype=c  " {{{1
call s:test([
        \ ['function_without_arguments',
        \   'void no_args',
        \   "\<c-j>",
        \   ['void no_args()', '{', '', '}']
        \ ],
        \ ['function_without_arguments - insert mode',
        \   'void no_args',
        \   "i\<c-j>",
        \   ['void no_args()', '{', '', '}']
        \ ],
        \ ['make_block_of_visual_selection',
        \   'doit();',
        \   "V\<c-k>",
        \   ['{', "\<tab>doit();", '}']
        \ ]])
" }}}1

set filetype=cmake  " {{{1
call s:test([
        \ ['if',
        \   'if (0',
        \   "\<c-j>",
        \   ['if (0)', '', 'endif()']
        \ ],
        \ ['else',
        \   "if(0)\nelse()",
        \   "\<c-k>",
        \   ['if(0)', 'else()', '', 'endif()']
        \ ],
        \ ['elseif',
        \   "if(0)\nelseif(1",
        \   "\<c-j>",
        \   ['if(0)', 'elseif(1)', '', 'endif()']
        \ ],
        \ ['while',
        \   'while (1)',
        \   "\<c-k>",
        \   ['while (1)', '', 'endwhile()']
        \ ]])
" }}}1

set filetype=cpp  " {{{1
call s:test([
        \ ['add_closing_bracket',
        \   'void f(int a',
        \   "\<c-j>",
        \   ['void f(int a)', '{', '', '}']
        \ ],
        \ ['add_closing_bracket__opening_bracket_is_on_a_different_line',
        \   "void f(int a\nint b",
        \   "\<c-j>",
        \   ['void f(int a', 'int b)', '{', '', '}']
        \ ],
        \ ['struct',
        \   'struct S',
        \   "\<c-k>",
        \   ['struct S', '{', '', '};']
        \ ],
        \ ['struct - insert mode',
        \   'struct S',
        \   "i\<c-k>",
        \   ['struct S', '{', '', '};']
        \ ]])
" }}}1

set filetype=cs  " (c-sharp)  {{{1
call s:test([
        \ ['struct',
        \   'struct S',
        \   "\<c-k>",
        \   ['struct S', '{', '', '}']
        \ ]])
" }}}1

set filetype=dosbatch  " {{{1
call s:test([
        \ ['if',
        \   'IF ERRORLEVEL 1',
        \   "\<c-k>",
        \   ['IF ERRORLEVEL 1 (', '', ')']
        \ ],
        \ ['for',
        \   'FOR /F "delims=" %%a IN (''dir /b *.bat'') DO',
        \   "\<c-k>",
        \   ['FOR /F "delims=" %%a IN (''dir /b *.bat'') DO (', '', ')']
        \ ]])
" }}}1

set filetype=sh  " {{{1
" See: filetype=zsh
call s:test([
        \ ['if',
        \   'if [ -d "dir" ]',
        \   "\<c-k>",
        \   ['if [ -d "dir" ]; then', '', 'fi']
        \ ],
        \ ['if2',
        \   'if [ -d "dir" ];  then',
        \   "\<c-k>",
        \   ['if [ -d "dir" ];  then', '', 'fi']
        \ ],
        \ ['if__add_then_fi',
        \   'if [ -d "dir" ];',
        \   "\<c-k>",
        \   ['if [ -d "dir" ]; then', '', 'fi']
        \ ],
        \ ['if__add_semicolon_then_fi',
        \   'if [ -d "dir" ]',
        \   "\<c-k>",
        \   ['if [ -d "dir" ]; then', '', 'fi']
        \ ]])
" XXX    \ ['if__add_closing_square_bracket',
"        \   'if [ -d "dir"',
"        \   "\<c-k>",
"        \   ['if [ -d "dir" ]; then', '', 'fi']
"        \ ], " XXX Also add test: Add "]]" to match "[[".

call s:test([
        \ ['for',
        \   "#!/bin/sh\nfor i in hello world;  do",
        \   "\<c-k>",
        \   ['#!/bin/sh', 'for i in hello world;  do', '', 'done']
        \ ],
        \ ['case',
        \   "#!/bin/sh\ncase $v in",
        \   "\<c-k>",
        \   ['#!/bin/sh', 'case $v in', '', 'esac']
        \ ],
        \ ['function',
        \   "#!/bin/sh\nfunction f",
        \   "\<c-k>",
        \   ['#!/bin/sh', 'function f', '{', '', '}']
        \ ],
        \ ['function_name_followed_by_brackets',
        \   "#!/bin/sh\nmyfunction()",
        \   "\<c-k>",
        \   ['#!/bin/sh', 'myfunction()', '{', '', '}']
        \ ]])
" }}}1

set filetype=vim  " {{{1
call s:test([
        \ ['slash_doesnt_always_indicate_a_continuation_line',
        \   'for e in f("\n")',
        \   "\<c-k>",
        \   ['for e in f("\n")', '', 'endfor']
        \ ],
        \ ['augroup',
        \   'augroup my_group',
        \   "\<c-k>",
        \   ['augroup my_group', '', 'augroup END']
        \ ],
        \ ['redir',
        \   'redir => o',
        \   "\<c-k>",
        \   ['redir => o', '', 'redir END']
        \ ]])
" }}}1

set filetype=zsh  " {{{1
" See: filetype=sh
call s:test([
        \ ['if',
        \   'if [ -d "dir" ]',
        \   "\<c-k>",
        \   ['if [ -d "dir" ]; then', '', 'fi']
        \ ]])
" }}}1

if s:failed_test_log == ""
    let s:failed_test_log = "Ok."
endif

for l in split(s:failed_test_log, "\n")
    echomsg empty(l) ? ' ' : l
endfor

set t_ti= t_te=  " (don't restore old text displayed in terminal on exit)
quitall!

catch
    echomsg v:exception
endtry


let &cpoptions = s:cpoptions_save

" vim:set foldmethod=marker:
