

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
    map <unique> <Leader>sa <Plug>SearchAllVim
    map <unique> <Leader>sl <Plug>SearchDestroyLast
endif

if g:searchdestroy_default_mappings
    vmap <silent> <unique> <script> <Plug>SearchDestroyVisual
               \ :call searchdestroy#SearchDestroyVisual()<CR>

    nmap <silent> <unique> <script> <Plug>SearchDestroyNormal
                \ :call searchdestroy#SearchDestroyNormal()<CR>

    map <silent> <unique> <script> <Plug>SearchDestroyArgs
                \ :call searchdestroy#SearchDestroyArgs()<CR>

    map <silent> <unique> <script> <Plug>SearchAllVim
                \ :call searchdestroy#SearchAllVim()<CR>

    map <silent> <unique> <script> <Plug>SearchDestroyLast
                \ :call searchdestroy#SearchDestroyLast()<CR>
endif

let s:stop_execution = 0

" =========================================================
"   SearchDestroy main functions
" =========================================================

" Handle Visual mode mapping
function! searchdestroy#SearchDestroyVisual () range
    let selection = s:GetSelection()

    if selection =~ " "
        let old = searchdestroy#GetInput("Replace: ")
        if s:stop_execution == 1
            return
        else
            let new = searchdestroy#GetInput("With: ")
            if s:stop_execution == 1
                return
            else
                '<,'>call searchdestroy#ReplaceInRange(old, new)
            endif
        endif
    else
        call searchdestroy#ReplaceWord(selection)
    endif
endfunction

" Handle normal mode mapping
function! searchdestroy#SearchDestroyNormal()
    let repl = ['%s/','/','/g<left><left>']
    let oldRegex = s:GetNormalSelection()
    let newRegex = ''
    call searchdestroy#outCommand(repl, oldRegex, newRegex)
endfunction

function! searchdestroy#SearchDestroyArgs()
    let s:old = searchdestroy#GetInput("Replace: ")
    if s:stop_execution == 1
        return
    else
        let s:new = searchdestroy#GetInput("With: ")
        if s:stop_execution == 1
            return
        else
            execute 'argdo %s/'.s:old.'/'.s:new .'/ge'
        endif
    endif
endfunction

function! searchdestroy#SearchDestroyLast()
    let s:new = searchdestroy#GetInput("Replace Width: ")
    if s:stop_execution == 1
        return
    else
        execute '%s//'.s:new.'/g'
    endif
endfunction

function! searchdestroy#SearchAllVim()
    let s:search_regex = searchdestroy#GetInput("Search Regex: ")
    if s:stop_execution == 1
        return
    else
        let s:ft = searchdestroy#GetFTExtension()
        execute "noautocmd vim ".s:search_regex." **/*.".s:ft." | cw"
    endif
endfunction

" =========================================================
"   SearchDestroy script functions
" =========================================================

function! searchdestroy#GetInput(prompt)
    let new_txt = input(a:prompt)
    if empty(new_txt)
        let s:stop_execution = 1
        echo "No input. Exiting"
    else
        let new_txt = substitute(new_txt,"^\\s\\+\\|\\s\\+$","","g")
        return new_txt
    endif
endfunction

function! searchdestroy#GetFTExtension()
    let ft = expand("%:e")
    return ft
endfunction

function! searchdestroy#ReplaceWord(word)
    let text = searchdestroy#GetInput("Replace with: ")
    if s:stop_execution == 1
        return
    else
        execute '%s/'.a:word.'/'.text.'/g'
    endif
endfunction

function! searchdestroy#ReplaceInRange(old, new) range
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

function! searchdestroy#outCommand(repl, oldRegex, newRegex)
    let s:output = a:repl[0] . a:oldRegex . a:repl[1] . a:newRegex . a:repl[2]
    return output
endfunction
