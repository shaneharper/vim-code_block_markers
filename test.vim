" Run this from a shell:
"  vim -S test.vim

set noswapfile
set noexpandtab

let failure_count = 0

try

let test_add_closing_bracket = ['cpp',
            \ ['void f(int a'],
            \ "\<c-j>",
            \ ['void f(int a)', '{', '', '}']]

let test_slash_doesnt_always_indicate_a_continuation_line = ['vim',
            \ ['for e in f("\n")'],
            \ "\<c-k>",
            \ ['for e in f("\n")', '', 'endfor']]

for [filetype, buffer, command, expected_buffer] in [test_add_closing_bracket, test_slash_doesnt_always_indicate_a_continuation_line]
    execute 'set filetype='.filetype
    call append(0, buffer)
    execute 'normal Gdd'.command
    if expected_buffer !=# getline(1, 99)
        let failure_count += 1
    endif
    bwipeout!
endfor

if failure_count == 0
    echomsg "Ok."
    set t_ti= t_te=  " (don't restore old text displayed in terminal on exit)
    messages
    quitall!
endif

echomsg string(failure_count)." failed."

catch
    echomsg v:exception
endtry
