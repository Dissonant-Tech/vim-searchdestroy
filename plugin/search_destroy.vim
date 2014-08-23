

" Check if plugin is already loaded, and handle keymappings
if exists('g:loaded_SearchDestroy') && g:loaded_SearchDestroy
    finish
endif

let g:loaded_SearchDestroy = 1
set cpo&vim

if !hasmapto('<Plug>SearchDestroy')
  vmap <unique> <Leader>sd <Plug>SearchDestroyVisual 
  nmap <unique> <Leader>sd <Plug>SearchDestroyNormal 
endif

vmap <silent> <unique> <script> <Plug>SearchDestroyVisual 
 \ :call search_destroy#SearchDestroyVisual ()<CR>

nmap <silent> <unique> <script> <Plug>SearchDestroyNormal
 \ :call search_destroy#SearchDestroyNormal()<CR>


" Handle Visual mode mapping
function! search_destroy#SearchDestroyVisual () range
    let selection = s:GetSelection()

    if selection =~ " "
        let old = search_destroy#GetInput("Replace: ")
        let new = search_destroy#GetInput("With: ")
        '<,'>call search_destroy#ReplaceInRange(old, new)
    else
        call search_destroy#ReplaceWord(selection)
    endif
endfunction

" Handle normal mode mapping
function! search_destroy#SearchDestroyNormal()
     let word  = search_destroy#GetInput("Replace With: ")
    execute '%s/\<' . expand('<cword>') . '\>/' . word '/g'
endfunction

function! search_destroy#ReplaceWord(word)
    let text = search_destroy#GetInput("Replace with: ")
    execute '%s/' . a:word . '/' . text . '/g'
endfunction

function! search_destroy#ReplaceInRange(old, new) range
        let rpl = "'<,'>"
        execute rpl . 's/\%V' . a:old . '/' . a:new . '/g'
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

function! search_destroy#GetInput(prompt)
    let new_txt = input(a:prompt)
    return new_txt
endfunction
