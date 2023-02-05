" launch FZF

function! s:fze_put_files(line)
    put! = a:line | normal j
    return a:line
endfunction

function! s:fze_handler(lines)
    if len(a:lines) < 2 | return | endif

    let cmd = get({'ctrl-s': 'split',
                \ 'ctrl-v': 'vertical split ',
                \ 'ctrl-t': 'tabe'}, a:lines[0], 'e')

    " call system('rm /tmp/fze; touch /tmp/fze')
    " execute cmd escape('/tmp/fze', ' %#\')

    exec cmd .
                \(bufnr('__FZE__') != -1 ? '+b'.bufnr('__FZE__') : '__FZE__')

    setl filetype=fze
    setl fileformat=unix
    setl fileencoding=utf-8
    setl iskeyword=@,48-57,_
    setl noreadonly
    setl buftype=acwrite
    setl bufhidden=hide
    setl noswapfile
    setl nobuflisted
    setl nolist
    setl nonumber
    setl norelativenumber
    setl nowrap
    setl winfixwidth
    setl winfixheight
    setl textwidth=0
    setl nospell
    setl nofoldenable
    setl cursorline

    if(cmd == 'e')
        nnoremap <buffer> <c-c> <c-o>
    elseif(cmd == 'vertical split ')
        nnoremap <buffer> <c-c> <cmd>quit<cr>
    elseif(cmd == 'split ')
        nnoremap <buffer> <c-c> <cmd>quit<cr>
    endif
    augroup fze
        au!
        au BufWriteCmd         <buffer> call s:fze_execute()
        au BufHidden,BufUnload <buffer> call s:fze_revert_changes()
    augroup END

    let s:file_list = map(a:lines[1:], 's:fze_put_files(v:val)')
    command! -buffer FzeExec  call s:fze_execute()
    command! -buffer FzeRefresh  call s:fze_reset_files()
endfunction

function! s:fze_revert_changes()
    if &modified
        silent! earlier 1f
        set nomodified
    endif
endfunction

function! s:fze_reset_files()
	let s:file_list = getbufline(bufnr(""), 1, "$")
endfunction

function! s:fze_execute()
    let buffer_lines = getbufline(bufnr(""), 1, "$")
    let index = 0
    while index < len(s:file_list)
        let src_item  = s:file_list[index]
        let dest_item = buffer_lines[index]
        if( src_item !=# dest_item)
            call rename(src_item,dest_item)
            call setline(index + 1, printf("%s \t->\t %s" ,src_item, dest_item))
        endif
        let index = index + 1
    endwhile
endfunction

command! -nargs=* Fze call fzf#run({
            \ 'source':  'rg --files --no-ignore --hidden --follow --glob "!{.git,node_modules,vendor}/*" 2> /dev/null',
            \ 'sink*':    function('<sid>fze_handler'),
            \ 'options': '--ansi --expect=ctrl-t,ctrl-v,ctrl-s --multi --bind=ctrl-a:select-all,ctrl-d:deselect-all '
            \ })



