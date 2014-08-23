
if exists('g:loaded_SearchDestroy') && g:loaded_SearchDestroy
    finish
endif

let g:loaded_SearchDestroy = 1
set cpo&vim

if !hasmapto('<Plug>SearchDestroy')
  map <unique> <Leader>sr <Plug>SearchDestroy
endif

map <silent> <unique> <script> <Plug>SearchDestroy
 \ :call search_destroy#SearchDestroy()<CR>

function! search_destroy#SearchDestroy()
    let selection = s:GetSelection()
    let split_selection = split(selection)

    let txt = search_destroy#GetInput()

    if len(split_selection) > 1
        call search_destroy#ReplaceWord(selection, txt)
    else
        call search_destroy#ReplaceInSelection(selection, txt)
    endif

endfunction

function! s:GetSelection()
    try
        let x_old = @x
        "yank current visual selection to reg x
        normal gv"xy"
        return @x
    finally
        let @x = x_old
    endtry
endfunction

function! search_destroy#ReplaceWord(word, txt)
    exec %s/a:word/a:txt/g
endfunction

function! search_destroy#ReplaceInSelection(selection, text)
    exec %s/%Va:word/a:txt/g
endfunction

function! search_destroy#GetInput()
    let curline = getline('.')
    call inputsave()
    let new_txt = input('Replace with: ')
    call inputrestore()
    return new_txt
endfunction
