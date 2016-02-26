" Run this from a shell:
"  vim -S test.vim

let s:cpoptions_save = &cpoptions
set cpoptions&vim

set noswapfile
set noexpandtab

let failed_test_log = ""

try

for [test_name, filetype, buffer, normal_mode_command, expected_buffer] in [
        \ ['test_c_function_without_arguments', 'c',
        \   ['void no_args'],
        \   "\<c-j>",
        \   ['void no_args()', '{', '', '}']
        \ ],
        \
        \ ['test_add_closing_bracket', 'cpp',
        \   ['void f(int a'],
        \   "\<c-j>",
        \   ['void f(int a)', '{', '', '}']
        \ ],
        \
        \ ['test_add_closing_bracket__opening_bracket_is_on_a_different_line', 'cpp',
        \   ['void f(int a', 'int b'],
        \   "\<c-j>",
        \   ['void f(int a', 'int b)', '{', '', '}']
        \ ],
        \
        \ ['test_struct', 'cpp',
        \   ['struct S'],
        \   "\<c-k>",
        \   ['struct S', '{', '', '};']
        \ ],
        \
        \ ['test_slash_doesnt_always_indicate_a_continuation_line', 'vim',
        \   ['for e in f("\n")'],
        \   "\<c-k>",
        \   ['for e in f("\n")', '', 'endfor']
        \ ],
        \
        \ ['test_augroup', 'vim',
        \   ['augroup my_group'],
        \   "\<c-k>",
        \   ['augroup my_group', '', 'augroup END']
        \ ],
        \
        \ ['test_redir', 'vim',
        \   ['redir => o'],
        \   "\<c-k>",
        \   ['redir => o', '', 'redir END']
        \ ],
        \
        \ ['test_sh_if', 'sh',
        \   ['if [ -d "dir" ]'],
        \   "\<c-k>",
        \   ['if [ -d "dir" ]; then', '', 'fi']
        \ ],
        \
        \ ['test_sh_if2', 'sh',
        \   ['if [ -d "dir" ];  then'],
        \   "\<c-k>",
        \   ['if [ -d "dir" ];  then', '', 'fi']
        \ ],
        \
        \ ['test_sh_for', 'sh',
        \   ['#!/bin/sh', 'for i in hello world;  do'],
        \   "\<c-k>",
        \   ['#!/bin/sh', 'for i in hello world;  do', '', 'done']
        \ ]]

    execute 'set filetype='.filetype
    call append(0, buffer)
    execute 'normal Gdd'.normal_mode_command
    if expected_buffer !=# getline(1, 99)
        let failed_test_log .= test_name." failed\nBuffer:\n".join(getline(1,99),"\n")."\n\n"
    endif
    bwipeout!
endfor

if failed_test_log == ""
    let failed_test_log = "Ok."
endif

for l in split(failed_test_log, "\n")
    echomsg empty(l) ? ' ' : l
endfor

set t_ti= t_te=  " (don't restore old text displayed in terminal on exit)
quitall!

catch
    echomsg v:exception
endtry


let &cpoptions = s:cpoptions_save
