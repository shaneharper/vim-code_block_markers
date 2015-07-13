" Run this from a shell:
"  vim -S test.vim

set noswapfile
set noexpandtab

let failed_tests = []

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
        \ ['test_slash_doesnt_always_indicate_a_continuation_line', 'vim',
        \   ['for e in f("\n")'],
        \   "\<c-k>",
        \   ['for e in f("\n")', '', 'endfor']
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
        let failed_tests += [test_name]
    endif
    bwipeout!
endfor

echomsg failed_tests == [] ? "Ok." : join(failed_tests, ", ")." failed."
set t_ti= t_te=  " (don't restore old text displayed in terminal on exit)
messages
quitall!


catch
    echomsg v:exception
endtry
