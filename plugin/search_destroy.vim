

" Check if plugin is already loaded, and handle keymappings
if exists('g:loaded_SearchDestroy') && g:loaded_SearchDestroy
    finish
endif

if !exists('g:searchdestroy_default_mappings')
    let g:searchdestroy_default_mappings = 1
endif

let g:loaded_SearchDestroy = 1
set cpo&vim

if !hasmapto('<Plug>SearchDestroy') && g:searchdestroy_default_mappings
    vmap <unique> <Leader>sd <Plug>SearchDestroyVisual
    nmap <unique> <Leader>sd <Plug>SearchDestroyNormal
    map <unique> <Leader>sda <Plug>SearchDestroyArgs
    map <unique> <Leader>ssa <Plug>SearchAllVim
endif

if g:searchdestroy_default_mappings
    vmap <silent> <unique> <script> <Plug>SearchDestroyVisual
               \ :call search_destroy#SearchDestroyVisual()<CR>

    nmap <silent> <unique> <script> <Plug>SearchDestroyNormal
                \ :call search_destroy#SearchDestroyNormal()<CR>

    map <silent> <unique> <script> <Plug>SearchDestroyArgs
                \ :call search_destroy#SearchDestroyArgs()<CR>

    map <silent> <unique> <script> <Plug>SearchAllVim
                \ :call search_destroy#SearchAllVim()<CR>
endif

let s:stop_execution = 0

" =========================================================
"   SearchDestroy main functions
" =========================================================

" Handle Visual mode mapping
function! search_destroy#SearchDestroyVisual () range
    let selection = s:GetSelection()

    if selection =~ " "
        let old = search_destroy#GetInput("Replace: ")
        if s:stop_execution == 1
            return
        else
            let new = search_destroy#GetInput("With: ")
            if s:stop_execution == 1
                return
            else
                '<,'>call search_destroy#ReplaceInRange(old, new)
            endif
        endif
    else
        call search_destroy#ReplaceWord(selection)
    endif
endfunction

" Handle normal mode mapping
function! search_destroy#SearchDestroyNormal()
    let old = s:GetNormalSelection()
    call search_destroy#ReplaceWord(old)
endfunction

function! search_destroy#SearchDestroyArgs()
    let old = search_destroy#GetInput("Replace: ")
    if s:stop_execution == 1
        return
    else
        let new = search_destroy#GetInput("With: ")
        if s:stop_execution == 1
            return
        else
            argdo '%s/'.l:old.'/'.l:new.'/g'
        endif
    endif
endfunction

function! search_destroy#SearchAllVim()
    let search_regex = search_destroy#GetInput("Search Regex: ")
    if s:stop_execution == 1
        return
    else
        let s:ft = s:GetFTExtension()
        if s:stop_execution == 1
            return
        else
            vim search_regex . "**/." . s:ft . "| cw"
        endif
    endif
endfunction

" =========================================================
"   SearchDestroy script functions
" =========================================================

function! search_destroy#GetInput(prompt)
    let new_txt = input(a:prompt)
    if empty(new_txt)
        let s:stop_execution = 1
        echo "No input. Exiting"
    else
        let new_txt = substitute(new_txt,"^\\s\\+\\|\\s\\+$","","g")
        return new_txt
    endif
endfunction

function! s:GetFTExsention()
    return expand("%:e")
endfunction

function! search_destroy#ReplaceWord(word)
    let text = search_destroy#GetInput("Replace with: ")
    if s:stop_execution == 1
        return
    else
        execute '%s/'.a:word.'/'.text.'/g'
    endif
endfunction

function! search_destroy#ReplaceInRange(old, new) range
    let rpl = "'<,'>"
    execute rpl.'s/\%V'.a:old.'/'.a:new.'/g'
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

function! s:GetNormalSelection()
    try
        let x_old = @x
        "yank current visual selection to reg x
        normal viw
        normal gv"xy"
        return @x
    finally
        let @x = x_old
    endtry
endfunction

