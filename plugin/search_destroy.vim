

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
               \ :call SearchDestroy#SearchDestroyVisual()<CR>

    nmap <silent> <unique> <script> <Plug>SearchDestroyNormal
                \ :call SearchDestroy#SearchDestroyNormal()<CR>

    map <silent> <unique> <script> <Plug>SearchDestroyArgs
                \ :call SearchDestroy#SearchDestroyArgs()<CR>

    map <silent> <unique> <script> <Plug>SearchAllVim
                \ :call SearchDestroy#SearchAllVim()<CR>
endif

let s:stop_execution = 0

" =========================================================
"   SearchDestroy main functions
" =========================================================

" Handle Visual mode mapping
function! SearchDestroy#SearchDestroyVisual () range
    let selection = s:GetSelection()

    if selection =~ " "
        let old = SearchDestroy#GetInput("Replace: ")
        if s:stop_execution == 1
            return
        else
            let new = SearchDestroy#GetInput("With: ")
            if s:stop_execution == 1
                return
            else
                '<,'>call SearchDestroy#ReplaceInRange(old, new)
            endif
        endif
    else
        call SearchDestroy#ReplaceWord(selection)
    endif
endfunction

" Handle normal mode mapping
function! SearchDestroy#SearchDestroyNormal()
    let old = s:GetNormalSelection()
    call SearchDestroy#ReplaceWord(old)
endfunction

function! SearchDestroy#SearchDestroyArgs()
    let s:old = SearchDestroy#GetInput("Replace: ")
    if s:stop_execution == 1
        return
    else
        let s:new = SearchDestroy#GetInput("With: ")
        if s:stop_execution == 1
            return
        else
            execute 'argdo %s/'.s:old.'/'.s:new .'/ge'
        endif
    endif
endfunction

function! SearchDestroy#SearchAllVim()
    let s:search_regex = SearchDestroy#GetInput("Search Regex: ")
    if s:stop_execution == 1
        return
    else
        let s:ft = SearchDestroy#GetFTExtension()
        execute "noautocmd vim ".s:search_regex." **/*.".s:ft." | cw"
    endif
endfunction

" =========================================================
"   SearchDestroy script functions
" =========================================================

function! SearchDestroy#GetInput(prompt)
    let new_txt = input(a:prompt)
    if empty(new_txt)
        let s:stop_execution = 1
        echo "No input. Exiting"
    else
        let new_txt = substitute(new_txt,"^\\s\\+\\|\\s\\+$","","g")
        return new_txt
    endif
endfunction

function! SearchDestroy#GetFTExtension()
    let ft = expand("%:e")
    return ft
endfunction

function! SearchDestroy#ReplaceWord(word)
    let text = SearchDestroy#GetInput("Replace with: ")
    if s:stop_execution == 1
        return
    else
        execute '%s/'.a:word.'/'.text.'/g'
    endif
endfunction

function! SearchDestroy#ReplaceInRange(old, new) range
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

