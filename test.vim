" Run this from a shell:
"  vim -S test.vim

let s:cpoptions_save = &cpoptions
set cpoptions&vim

set noswapfile
set noexpandtab
set shiftwidth=0

let failed_test_log = ""

try

source plugin/code_block_markers.vim

for [filetype, test_name, buffer_text, normal_mode_command, expected_buffer_text] in [
        \ ['c', 'function_without_arguments',
        \   ['void no_args'],
        \   "\<c-j>",
        \   ['void no_args()', '{', '', '}']
        \ ],
        \ ['cpp', 'add_closing_bracket',
        \   ['void f(int a'],
        \   "\<c-j>",
        \   ['void f(int a)', '{', '', '}']
        \ ],
        \ ['cpp', 'add_closing_bracket__opening_bracket_is_on_a_different_line',
        \   ['void f(int a', 'int b'],
        \   "\<c-j>",
        \   ['void f(int a', 'int b)', '{', '', '}']
        \ ],
        \ ['cpp', 'struct',
        \   ['struct S'],
        \   "\<c-k>",
        \   ['struct S', '{', '', '};']
        \ ],
        \ ['c', 'make_block_of_visual_selection',
        \   ['doit();'],
        \   "V\<c-k>",
        \   ['{', "\<tab>doit();", '}']
        \ ],
        \
        \
        \ ['cmake', 'if',
        \   ['if (0'],
        \   "\<c-j>",
        \   ['if (0)', '', 'endif()']
        \ ],
        \ ['cmake', 'else',
        \   ['if(0)', 'else()'],
        \   "\<c-k>",
        \   ['if(0)', 'else()', '', 'endif()']
        \ ],
        \ ['cmake', 'elseif',
        \   ['if(0)', 'elseif(1'],
        \   "\<c-j>",
        \   ['if(0)', 'elseif(1)', '', 'endif()']
        \ ],
        \ ['cmake', 'while',
        \   ['while (1)'],
        \   "\<c-k>",
        \   ['while (1)', '', 'endwhile()']
        \ ],
        \
        \
        \ ['sh', 'if',
        \   ['if [ -d "dir" ]'],
        \   "\<c-k>",
        \   ['if [ -d "dir" ]; then', '', 'fi']
        \ ],
        \ ['sh', 'if2',
        \   ['if [ -d "dir" ];  then'],
        \   "\<c-k>",
        \   ['if [ -d "dir" ];  then', '', 'fi']
        \ ],
        \ ['sh', 'for',
        \   ['#!/bin/sh', 'for i in hello world;  do'],
        \   "\<c-k>",
        \   ['#!/bin/sh', 'for i in hello world;  do', '', 'done']
        \ ],
        \ ['sh', 'case',
        \   ['#!/bin/sh', 'case $v in'],
        \   "\<c-k>",
        \   ['#!/bin/sh', 'case $v in', '', 'esac']
        \ ],
        \ ['sh', 'function_name_followed_by_brackets',
        \   ['#!/bin/sh', 'myfunction()'],
        \   "\<c-k>",
        \   ['#!/bin/sh', 'myfunction()', '{', '', '}']
        \ ],
        \
        \
        \ ['vim', 'slash_doesnt_always_indicate_a_continuation_line',
        \   ['for e in f("\n")'],
        \   "\<c-k>",
        \   ['for e in f("\n")', '', 'endfor']
        \ ],
        \ ['vim', 'augroup',
        \   ['augroup my_group'],
        \   "\<c-k>",
        \   ['augroup my_group', '', 'augroup END']
        \ ],
        \ ['vim', 'redir',
        \   ['redir => o'],
        \   "\<c-k>",
        \   ['redir => o', '', 'redir END']
        \ ]]

    execute 'set filetype='.filetype
    call setline(1, buffer_text)
    execute 'normal G'.normal_mode_command
    if expected_buffer_text !=# getline(1, "$")
        let failed_test_log .= test_name." (".filetype.") test failed\nBuffer:\n".join(getline(1,"$"),"\n")."\n\n"
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
