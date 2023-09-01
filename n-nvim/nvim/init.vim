" ||---------------||
" ||               ||
" ||    Keymaps    ||
" ||               ||
" ||---------------||
vnoremap < <gv
vnoremap > >gv
nnoremap <silent> <Esc> :noh<CR><Esc>
nnoremap <silent> L :bnext<CR>
nnoremap <silent> H :bprevious<CR>

" move lines up and down
nnoremap <silent> <C-j> :m+<CR>==
nnoremap <silent> <C-k> :m-2<CR>==
vnoremap <silent> <C-j> :m'>+<CR>gv=gv
vnoremap <silent> <C-k> :m-2<CR>gv=gv

" ||---------------||
" ||               ||
" ||    Config     ||
" ||               ||
" ||---------------||
set nobackup
set cmdheight=1
set clipboard^=unnamed,unnamedplus
set completeopt=menuone,noselect
set conceallevel=0
set fileencoding=utf-8
set hlsearch
set ignorecase
set mouse=a
set pumheight=10
set noshowmode
set showtabline=2
set smartcase
set smartindent
set splitbelow
set splitright
set noswapfile
set timeoutlen=600
set undofile
set updatetime=300
set nowritebackup
set expandtab
set shiftwidth=4
set tabstop=4
set nocursorline
set number
set relativenumber
set numberwidth=4
set signcolumn=yes
set nowrap
set scrolloff=8
set sidescrolloff=8

" ||---------------||
" ||               ||
" ||    Plugins    ||
" ||               ||
" ||---------------||

" ============
" vim-surround
" ============

if exists("g:loaded_surround") || &cp || v:version < 700
    finish
endif
let g:loaded_surround = 1

" Input functions {{{1

function! s:getchar()
    let c = getchar()
    if c =~ '^\d\+$'
        let c = nr2char(c)
    endif
    return c
endfunction

function! s:inputtarget()
    let c = s:getchar()
    while c =~ '^\d\+$'
        let c .= s:getchar()
    endwhile
    if c == " "
        let c .= s:getchar()
    endif
    if c =~ "\<Esc>\|\<C-C>\|\0"
        return ""
    else
        return c
    endif
endfunction

function! s:inputreplacement()
    let c = s:getchar()
    if c == " "
        let c .= s:getchar()
    endif
    if c =~ "\<Esc>" || c =~ "\<C-C>"
        return ""
    else
        return c
    endif
endfunction

function! s:beep()
    exe "norm! \<Esc>"
    return ""
endfunction

function! s:redraw()
    redraw
    return ""
endfunction

" }}}1

" Wrapping functions {{{1

function! s:extractbefore(str)
    if a:str =~ '\r'
        return matchstr(a:str,'.*\ze\r')
    else
        return matchstr(a:str,'.*\ze\n')
    endif
endfunction

function! s:extractafter(str)
    if a:str =~ '\r'
        return matchstr(a:str,'\r\zs.*')
    else
        return matchstr(a:str,'\n\zs.*')
    endif
endfunction

function! s:fixindent(str,spc)
    let str = substitute(a:str,'\t',repeat(' ',&sw),'g')
    let spc = substitute(a:spc,'\t',repeat(' ',&sw),'g')
    let str = substitute(str,'\(\n\|\%^\).\@=','\1'.spc,'g')
    if ! &et
        let str = substitute(str,'\s\{'.&ts.'\}',"\t",'g')
    endif
    return str
endfunction

function! s:process(string)
    let i = 0
    for i in range(7)
        let repl_{i} = ''
        let m = matchstr(a:string,nr2char(i).'.\{-\}\ze'.nr2char(i))
        if m != ''
            let m = substitute(strpart(m,1),'\r.*','','')
            let repl_{i} = input(match(m,'\w\+$') >= 0 ? m.': ' : m)
        endif
    endfor
    let s = ""
    let i = 0
    while i < strlen(a:string)
        let char = strpart(a:string,i,1)
        if char2nr(char) < 8
            let next = stridx(a:string,char,i+1)
            if next == -1
                let s .= char
            else
                let insertion = repl_{char2nr(char)}
                let subs = strpart(a:string,i+1,next-i-1)
                let subs = matchstr(subs,'\r.*')
                while subs =~ '^\r.*\r'
                    let sub = matchstr(subs,"^\r\\zs[^\r]*\r[^\r]*")
                    let subs = strpart(subs,strlen(sub)+1)
                    let r = stridx(sub,"\r")
                    let insertion = substitute(insertion,strpart(sub,0,r),strpart(sub,r+1),'')
                endwhile
                let s .= insertion
                let i = next
            endif
        else
            let s .= char
        endif
        let i += 1
    endwhile
    return s
endfunction

function! s:wrap(string,char,type,removed,special)
    let keeper = a:string
    let newchar = a:char
    let s:input = ""
    let type = a:type
    let linemode = type ==# 'V' ? 1 : 0
    let before = ""
    let after  = ""
    if type ==# "V"
        let initspaces = matchstr(keeper,'\%^\s*')
    else
        let initspaces = matchstr(getline('.'),'\%^\s*')
    endif
    let pairs = "b()B{}r[]a<>"
    let extraspace = ""
    if newchar =~ '^ '
        let newchar = strpart(newchar,1)
        let extraspace = ' '
    endif
    let idx = stridx(pairs,newchar)
    if newchar == ' '
        let before = ''
        let after  = ''
    elseif exists("b:surround_".char2nr(newchar))
        let all    = s:process(b:surround_{char2nr(newchar)})
        let before = s:extractbefore(all)
        let after  =  s:extractafter(all)
    elseif exists("g:surround_".char2nr(newchar))
        let all    = s:process(g:surround_{char2nr(newchar)})
        let before = s:extractbefore(all)
        let after  =  s:extractafter(all)
    elseif newchar ==# "p"
        let before = "\n"
        let after  = "\n\n"
    elseif newchar ==# 's'
        let before = ' '
        let after  = ''
    elseif newchar ==# ':'
        let before = ':'
        let after = ''
    elseif newchar =~# "[tT\<C-T><]"
        let dounmapp = 0
        let dounmapb = 0
        if !maparg(">","c")
            let dounmapb = 1
            " Hide from AsNeeded
            exe "cn"."oremap > ><CR>"
        endif
        let default = ""
        if newchar ==# "T"
            if !exists("s:lastdel")
                let s:lastdel = ""
            endif
            let default = matchstr(s:lastdel,'<\zs.\{-\}\ze>')
        endif
        let tag = input("<",default)
        if dounmapb
            silent! cunmap >
        endif
        let s:input = tag
        if tag != ""
            let keepAttributes = ( match(tag, ">$") == -1 )
            let tag = substitute(tag,'>*$','','')
            let attributes = ""
            if keepAttributes
                let attributes = matchstr(a:removed, '<[^ \t\n]\+\zs\_.\{-\}\ze>')
            endif
            let s:input = tag . '>'
            if tag =~ '/$'
                let tag = substitute(tag, '/$', '', '')
                let before = '<'.tag.attributes.' />'
                let after = ''
            else
                let before = '<'.tag.attributes.'>'
                let after  = '</'.substitute(tag,' .*','','').'>'
            endif
            if newchar == "\<C-T>"
                if type ==# "v" || type ==# "V"
                    let before .= "\n\t"
                endif
                if type ==# "v"
                    let after  = "\n". after
                endif
            endif
        endif
    elseif newchar ==# 'l' || newchar == '\'
        " LaTeX
        let env = input('\begin{')
        if env != ""
            let s:input = env."\<CR>"
            let env = '{' . env
            let env .= s:closematch(env)
            echo '\begin'.env
            let before = '\begin'.env
            let after  = '\end'.matchstr(env,'[^}]*').'}'
        endif
    elseif newchar ==# 'f' || newchar ==# 'F'
        let fnc = input('function: ')
        if fnc != ""
            let s:input = fnc."\<CR>"
            let before = substitute(fnc,'($','','').'('
            let after  = ')'
            if newchar ==# 'F'
                let before .= ' '
                let after = ' ' . after
            endif
        endif
    elseif newchar ==# "\<C-F>"
        let fnc = input('function: ')
        let s:input = fnc."\<CR>"
        let before = '('.fnc.' '
        let after = ')'
    elseif idx >= 0
        let spc = (idx % 3) == 1 ? " " : ""
        let idx = idx / 3 * 3
        let before = strpart(pairs,idx+1,1) . spc
        let after  = spc . strpart(pairs,idx+2,1)
    elseif newchar == "\<C-[>" || newchar == "\<C-]>"
        let before = "{\n\t"
        let after  = "\n}"
    elseif newchar !~ '\a'
        let before = newchar
        let after  = newchar
    else
        let before = ''
        let after  = ''
    endif
    let after  = substitute(after ,'\n','\n'.initspaces,'g')
    if type ==# 'V' || (a:special && type ==# "v")
        let before = substitute(before,' \+$','','')
        let after  = substitute(after ,'^ \+','','')
        if after !~ '^\n'
            let after  = initspaces.after
        endif
        if keeper !~ '\n$' && after !~ '^\n'
            let keeper .= "\n"
        elseif keeper =~ '\n$' && after =~ '^\n'
            let after = strpart(after,1)
        endif
        if keeper !~ '^\n' && before !~ '\n\s*$'
            let before .= "\n"
            if a:special
                let before .= "\t"
            endif
        elseif keeper =~ '^\n' && before =~ '\n\s*$'
            let keeper = strcharpart(keeper,1)
        endif
        if type ==# 'V' && keeper =~ '\n\s*\n$'
            let keeper = strcharpart(keeper,0,strchars(keeper) - 1)
        endif
    endif
    if type ==# 'V'
        let before = initspaces.before
    endif
    if before =~ '\n\s*\%$'
        if type ==# 'v'
            let keeper = initspaces.keeper
        endif
        let padding = matchstr(before,'\n\zs\s\+\%$')
        let before  = substitute(before,'\n\s\+\%$','\n','')
        let keeper = s:fixindent(keeper,padding)
    endif
    if type ==# 'V'
        let keeper = before.keeper.after
    elseif type =~ "^\<C-V>"
        " Really we should be iterating over the buffer
        let repl = substitute(before,'[\\~]','\\&','g').'\1'.substitute(after,'[\\~]','\\&','g')
        let repl = substitute(repl,'\n',' ','g')
        let keeper = substitute(keeper."\n",'\(.\{-\}\)\(\n\)',repl.'\n','g')
        let keeper = substitute(keeper,'\n\%$','','')
    else
        let keeper = before.extraspace.keeper.extraspace.after
    endif
    return keeper
endfunction

function! s:wrapreg(reg,char,removed,special)
    let orig = getreg(a:reg)
    let type = substitute(getregtype(a:reg),'\d\+$','','')
    let new = s:wrap(orig,a:char,type,a:removed,a:special)
    call setreg(a:reg,new,type)
endfunction
" }}}1

function! s:insert(...) " {{{1
    " Optional argument causes the result to appear on 3 lines, not 1
    let linemode = a:0 ? a:1 : 0
    let char = s:inputreplacement()
    while char == "\<CR>" || char == "\<C-S>"
        " TODO: use total count for additional blank lines
        let linemode += 1
        let char = s:inputreplacement()
    endwhile
    if char == ""
        return ""
    endif
    let cb_save = &clipboard
    set clipboard-=unnamed clipboard-=unnamedplus
    let reg_save = @@
    call setreg('"',"\032",'v')
    call s:wrapreg('"',char,"",linemode)
    " If line mode is used and the surrounding consists solely of a suffix,
    " remove the initial newline.  This fits a use case of mine but is a
    " little inconsistent.  Is there anyone that would prefer the simpler
    " behavior of just inserting the newline?
    if linemode && match(getreg('"'),'^\n\s*\zs.*') == 0
        call setreg('"',matchstr(getreg('"'),'^\n\s*\zs.*'),getregtype('"'))
    endif
    " This can be used to append a placeholder to the end
    if exists("g:surround_insert_tail")
        call setreg('"',g:surround_insert_tail,"a".getregtype('"'))
    endif
    if &ve != 'all' && col('.') >= col('$')
        if &ve == 'insert'
            let extra_cols = virtcol('.') - virtcol('$')
            if extra_cols > 0
                let [regval,regtype] = [getreg('"',1,1),getregtype('"')]
                call setreg('"',join(map(range(extra_cols),'" "'),''),'v')
                norm! ""p
                call setreg('"',regval,regtype)
            endif
        endif
        norm! ""p
    else
        norm! ""P
    endif
    if linemode
        call s:reindent()
    endif
    norm! `]
    call search("\032",'bW')
    let @@ = reg_save
    let &clipboard = cb_save
    return "\<Del>"
endfunction " }}}1

function! s:reindent() abort " {{{1
    if get(b:, 'surround_indent', get(g:, 'surround_indent', 1)) && (!empty(&equalprg) || !empty(&indentexpr) || &cindent || &smartindent || &lisp)
        silent norm! '[=']
    endif
endfunction " }}}1

function! s:dosurround(...) " {{{1
    let sol_save = &startofline
    set startofline
    let scount = v:count1
    let char = (a:0 ? a:1 : s:inputtarget())
    let spc = ""
    if char =~ '^\d\+'
        let scount = scount * matchstr(char,'^\d\+')
        let char = substitute(char,'^\d\+','','')
    endif
    if char =~ '^ '
        let char = strpart(char,1)
        let spc = 1
    endif
    if char == 'a'
        let char = '>'
    endif
    if char == 'r'
        let char = ']'
    endif
    let newchar = ""
    if a:0 > 1
        let newchar = a:2
        if newchar == "\<Esc>" || newchar == "\<C-C>" || newchar == ""
            if !sol_save
                set nostartofline
            endif
            return s:beep()
        endif
    endif
    let cb_save = &clipboard
    set clipboard-=unnamed clipboard-=unnamedplus
    let append = ""
    let original = getreg('"')
    let otype = getregtype('"')
    call setreg('"',"")
    let strcount = (scount == 1 ? "" : scount)
    if char == '/'
        exe 'norm! '.strcount.'[/d'.strcount.']/'
    elseif char =~# '[[:punct:][:space:]]' && char !~# '[][(){}<>"''`]'
        exe 'norm! T'.char
        if getline('.')[col('.')-1] == char
            exe 'norm! l'
        endif
        exe 'norm! dt'.char
    else
        exe 'norm! d'.strcount.'i'.char
    endif
    let keeper = getreg('"')
    let okeeper = keeper " for reindent below
    if keeper == ""
        call setreg('"',original,otype)
        let &clipboard = cb_save
        if !sol_save
            set nostartofline
        endif
        return ""
    endif
    let oldline = getline('.')
    let oldlnum = line('.')
    if char ==# "p"
        call setreg('"','','V')
    elseif char ==# "s" || char ==# "w" || char ==# "W"
        " Do nothing
        call setreg('"','')
    elseif char =~ "[\"'`]"
        exe "norm! i \<Esc>d2i".char
        call setreg('"',substitute(getreg('"'),' ','',''))
    elseif char == '/'
        norm! "_x
        call setreg('"','/**/',"c")
        let keeper = substitute(substitute(keeper,'^/\*\s\=','',''),'\s\=\*$','','')
    elseif char =~# '[[:punct:][:space:]]' && char !~# '[][(){}<>]'
        exe 'norm! F'.char
        exe 'norm! df'.char
    else
        " One character backwards
        call search('\m.', 'bW')
        exe "norm! da".char
    endif
    let removed = getreg('"')
    let rem2 = substitute(removed,'\n.*','','')
    let oldhead = strpart(oldline,0,strlen(oldline)-strlen(rem2))
    let oldtail = strpart(oldline,  strlen(oldline)-strlen(rem2))
    let regtype = getregtype('"')
    if char =~# '[\[({<T]' || spc
        let keeper = substitute(keeper,'^\s\+','','')
        let keeper = substitute(keeper,'\s\+$','','')
    endif
    if col("']") == col("$") && virtcol('.') + 1 == virtcol('$')
        if oldhead =~# '^\s*$' && a:0 < 2
            let keeper = substitute(keeper,'\%^\n'.oldhead.'\(\s*.\{-\}\)\n\s*\%$','\1','')
        endif
        let pcmd = "p"
    else
        let pcmd = "P"
    endif
    if line('.') + 1 < oldlnum && regtype ==# "V"
        let pcmd = "p"
    endif
    call setreg('"',keeper,regtype)
    if newchar != ""
        let special = a:0 > 2 ? a:3 : 0
        call s:wrapreg('"',newchar,removed,special)
    endif
    silent exe 'norm! ""'.pcmd.'`['
    if removed =~ '\n' || okeeper =~ '\n' || getreg('"') =~ '\n'
        call s:reindent()
    endif
    if getline('.') =~ '^\s\+$' && keeper =~ '^\s*\n'
        silent norm! cc
    endif
    call setreg('"',original,otype)
    let s:lastdel = removed
    let &clipboard = cb_save
    if newchar == ""
        silent! call repeat#set("\<Plug>Dsurround".char,scount)
    else
        silent! call repeat#set("\<Plug>C".(a:0 > 2 && a:3 ? "S" : "s")."urround".char.newchar.s:input,scount)
    endif
    if !sol_save
        set nostartofline
    endif
endfunction " }}}1

function! s:changesurround(...) " {{{1
    let a = s:inputtarget()
    if a == ""
        return s:beep()
    endif
    let b = s:inputreplacement()
    if b == ""
        return s:beep()
    endif
    call s:dosurround(a,b,a:0 && a:1)
endfunction " }}}1

function! s:opfunc(type, ...) abort " {{{1
    if a:type ==# 'setup'
        let &opfunc = matchstr(expand('<sfile>'), '<SNR>\w\+$')
        return 'g@'
    endif
    let char = s:inputreplacement()
    if char == ""
        return s:beep()
    endif
    let reg = '"'
    let sel_save = &selection
    let &selection = "inclusive"
    let cb_save  = &clipboard
    set clipboard-=unnamed clipboard-=unnamedplus
    let reg_save = getreg(reg)
    let reg_type = getregtype(reg)
    let type = a:type
    if a:type == "char"
        silent exe 'norm! v`[o`]"'.reg.'y'
        let type = 'v'
    elseif a:type == "line"
        silent exe 'norm! `[V`]"'.reg.'y'
        let type = 'V'
    elseif a:type ==# "v" || a:type ==# "V" || a:type ==# "\<C-V>"
        let &selection = sel_save
        let ve = &virtualedit
        if !(a:0 && a:1)
            set virtualedit=
        endif
        silent exe 'norm! gv"'.reg.'y'
        let &virtualedit = ve
    elseif a:type =~ '^\d\+$'
        let type = 'v'
        silent exe 'norm! ^v'.a:type.'$h"'.reg.'y'
        if mode() ==# 'v'
            norm! v
            return s:beep()
        endif
    else
        let &selection = sel_save
        let &clipboard = cb_save
        return s:beep()
    endif
    let keeper = getreg(reg)
    if type ==# "v" && a:type !=# "v"
        let append = matchstr(keeper,'\_s\@<!\s*$')
        let keeper = substitute(keeper,'\_s\@<!\s*$','','')
    endif
    call setreg(reg,keeper,type)
    call s:wrapreg(reg,char,"",a:0 && a:1)
    if type ==# "v" && a:type !=# "v" && append != ""
        call setreg(reg,append,"ac")
    endif
    silent exe 'norm! gv'.(reg == '"' ? '' : '"' . reg).'p`['
    if type ==# 'V' || (getreg(reg) =~ '\n' && type ==# 'v')
        call s:reindent()
    endif
    call setreg(reg,reg_save,reg_type)
    let &selection = sel_save
    let &clipboard = cb_save
    if a:type =~ '^\d\+$'
        silent! call repeat#set("\<Plug>Y".(a:0 && a:1 ? "S" : "s")."surround".char.s:input,a:type)
    else
        silent! call repeat#set("\<Plug>SurroundRepeat".char.s:input)
    endif
endfunction

function! s:opfunc2(...) abort
    if !a:0 || a:1 ==# 'setup'
        let &opfunc = matchstr(expand('<sfile>'), '<SNR>\w\+$')
        return 'g@'
    endif
    call s:opfunc(a:1, 1)
endfunction " }}}1

function! s:closematch(str) " {{{1
    " Close an open (, {, [, or < on the command line.
    let tail = matchstr(a:str,'.[^\[\](){}<>]*$')
    if tail =~ '^\[.\+'
        return "]"
    elseif tail =~ '^(.\+'
        return ")"
    elseif tail =~ '^{.\+'
        return "}"
    elseif tail =~ '^<.+'
        return ">"
    else
        return ""
    endif
endfunction " }}}1

nnoremap <silent> <Plug>SurroundRepeat .
nnoremap <silent> <Plug>Dsurround  :<C-U>call <SID>dosurround(<SID>inputtarget())<CR>
nnoremap <silent> <Plug>Csurround  :<C-U>call <SID>changesurround()<CR>
nnoremap <silent> <Plug>CSurround  :<C-U>call <SID>changesurround(1)<CR>
nnoremap <expr>   <Plug>Yssurround '^'.v:count1.<SID>opfunc('setup').'g_'
nnoremap <expr>   <Plug>YSsurround <SID>opfunc2('setup').'_'
nnoremap <expr>   <Plug>Ysurround  <SID>opfunc('setup')
nnoremap <expr>   <Plug>YSurround  <SID>opfunc2('setup')
vnoremap <silent> <Plug>VSurround  :<C-U>call <SID>opfunc(visualmode(),visualmode() ==# 'V' ? 1 : 0)<CR>
vnoremap <silent> <Plug>VgSurround :<C-U>call <SID>opfunc(visualmode(),visualmode() ==# 'V' ? 0 : 1)<CR>
inoremap <silent> <Plug>Isurround  <C-R>=<SID>insert()<CR>
inoremap <silent> <Plug>ISurround  <C-R>=<SID>insert(1)<CR>

if !exists("g:surround_no_mappings") || ! g:surround_no_mappings
    nmap ds  <Plug>Dsurround
    nmap cs  <Plug>Csurround
    nmap cS  <Plug>CSurround
    nmap ys  <Plug>Ysurround
    nmap yS  <Plug>YSurround
    nmap yss <Plug>Yssurround
    nmap ySs <Plug>YSsurround
    nmap ySS <Plug>YSsurround
    xmap S   <Plug>VSurround
    xmap gS  <Plug>VgSurround
    if !exists("g:surround_no_insert_mappings") || ! g:surround_no_insert_mappings
        if !hasmapto("<Plug>Isurround","i") && "" == mapcheck("<C-S>","i")
            imap    <C-S> <Plug>Isurround
        endif
        imap      <C-G>s <Plug>Isurround
        imap      <C-G>S <Plug>ISurround
    endif
endif

" ==============
" vim-commentary
" ==============

if exists("g:loaded_commentary") || v:version < 703
    finish
endif
let g:loaded_commentary = 1

function! s:surroundings() abort
    return split(get(b:, 'commentary_format', substitute(substitute(substitute(
                \ &commentstring, '^$', '%s', ''), '\S\zs%s',' %s', '') ,'%s\ze\S', '%s ', '')), '%s', 1)
endfunction

function! s:strip_white_space(l,r,line) abort
    let [l, r] = [a:l, a:r]
    if l[-1:] ==# ' ' && stridx(a:line,l) == -1 && stridx(a:line,l[0:-2]) == 0
        let l = l[:-2]
    endif
    if r[0] ==# ' ' && (' ' . a:line)[-strlen(r)-1:] != r && a:line[-strlen(r):] == r[1:]
        let r = r[1:]
    endif
    return [l, r]
endfunction

function! s:go(...) abort
    if !a:0
        let &operatorfunc = matchstr(expand('<sfile>'), '[^. ]*$')
        return 'g@'
    elseif a:0 > 1
        let [lnum1, lnum2] = [a:1, a:2]
    else
        let [lnum1, lnum2] = [line("'["), line("']")]
    endif

    let [l, r] = s:surroundings()
    let uncomment = 2
    let force_uncomment = a:0 > 2 && a:3
    for lnum in range(lnum1,lnum2)
        let line = matchstr(getline(lnum),'\S.*\s\@<!')
        let [l, r] = s:strip_white_space(l,r,line)
        if len(line) && (stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
            let uncomment = 0
        endif
    endfor

    if get(b:, 'commentary_startofline')
        let indent = '^'
    else
        let indent = '^\s*'
    endif

    let lines = []
    for lnum in range(lnum1,lnum2)
        let line = getline(lnum)
        if strlen(r) > 2 && l.r !~# '\\'
            let line = substitute(line,
                        \'\M' . substitute(l, '\ze\S\s*$', '\\zs\\d\\*\\ze', '') . '\|' . substitute(r, '\S\zs', '\\zs\\d\\*\\ze', ''),
                        \'\=substitute(submatch(0)+1-uncomment,"^0$\\|^-\\d*$","","")','g')
        endif
        if force_uncomment
            if line =~ '^\s*' . l
                let line = substitute(line,'\S.*\s\@<!','\=submatch(0)[strlen(l):-strlen(r)-1]','')
            endif
        elseif uncomment
            let line = substitute(line,'\S.*\s\@<!','\=submatch(0)[strlen(l):-strlen(r)-1]','')
        else
            let line = substitute(line,'^\%('.matchstr(getline(lnum1),indent).'\|\s*\)\zs.*\S\@<=','\=l.submatch(0).r','')
        endif
        call add(lines, line)
    endfor
    call setline(lnum1, lines)
    let modelines = &modelines
    try
        set modelines=0
        silent doautocmd User CommentaryPost
    finally
        let &modelines = modelines
    endtry
    return ''
endfunction

function! s:textobject(inner) abort
    let [l, r] = s:surroundings()
    let lnums = [line('.')+1, line('.')-2]
    for [index, dir, bound, line] in [[0, -1, 1, ''], [1, 1, line('$'), '']]
        while lnums[index] != bound && line ==# '' || !(stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
            let lnums[index] += dir
            let line = matchstr(getline(lnums[index]+dir),'\S.*\s\@<!')
            let [l, r] = s:strip_white_space(l,r,line)
        endwhile
    endfor
    while (a:inner || lnums[1] != line('$')) && empty(getline(lnums[0]))
        let lnums[0] += 1
    endwhile
    while a:inner && empty(getline(lnums[1]))
        let lnums[1] -= 1
    endwhile
    if lnums[0] <= lnums[1]
        execute 'normal! 'lnums[0].'GV'.lnums[1].'G'
    endif
endfunction

command! -range -bar -bang Commentary call s:go(<line1>,<line2>,<bang>0)
xnoremap <expr>   <Plug>Commentary     <SID>go()
nnoremap <expr>   <Plug>Commentary     <SID>go()
nnoremap <expr>   <Plug>CommentaryLine <SID>go() . '_'
onoremap <silent> <Plug>Commentary        :<C-U>call <SID>textobject(get(v:, 'operator', '') ==# 'c')<CR>
nnoremap <silent> <Plug>ChangeCommentary c:<C-U>call <SID>textobject(1)<CR>
nmap <silent> <Plug>CommentaryUndo :echoerr "Change your <Plug>CommentaryUndo map to <Plug>Commentary<Plug>Commentary"<CR>

if !hasmapto('<Plug>Commentary') || maparg('gc','n') ==# ''
    xmap gc  <Plug>Commentary
    nmap gc  <Plug>Commentary
    omap gc  <Plug>Commentary
    nmap gcc <Plug>CommentaryLine
    nmap gcu <Plug>Commentary<Plug>Commentary
endif

" ===========
" vim-abolish
" ===========

" Initialization {{{1

if exists("g:loaded_abolish") || &cp || v:version < 700
    finish
endif
let g:loaded_abolish = 1

if !exists("g:abolish_save_file")
    if isdirectory(expand("~/.vim"))
        let g:abolish_save_file = expand("~/.vim/after/plugin/abolish.vim")
    elseif isdirectory(expand("~/vimfiles")) || has("win32")
        let g:abolish_save_file = expand("~/vimfiles/after/plugin/abolish.vim")
    else
        let g:abolish_save_file = expand("~/.vim/after/plugin/abolish.vim")
    endif
endif

" }}}1
" Utility functions {{{1

function! s:function(name) abort
    return function(substitute(a:name,'^s:',matchstr(expand('<sfile>'), '.*\zs<SNR>\d\+_'),''))
endfunction

function! s:send(self,func,...)
    if type(a:func) == type('') || type(a:func) == type(0)
        let l:Func = get(a:self,a:func,'')
    else
        let l:Func = a:func
    endif
    let s = type(a:self) == type({}) ? a:self : {}
    if type(Func) == type(function('tr'))
        return call(Func,a:000,s)
    elseif type(Func) == type({}) && has_key(Func,'apply')
        return call(Func.apply,a:000,Func)
    elseif type(Func) == type({}) && has_key(Func,'call')
        return call(Func.call,a:000,s)
    elseif type(Func) == type('') && Func == '' && has_key(s,'function missing')
        return call('s:send',[s,'function missing',a:func] + a:000)
    else
        return Func
    endif
endfunction

let s:object = {}
function! s:object.clone(...)
    let sub = deepcopy(self)
    return a:0 ? extend(sub,a:1) : sub
endfunction

if !exists("g:Abolish")
    let Abolish = {}
endif
call extend(Abolish, s:object, 'force')
call extend(Abolish, {'Coercions': {}}, 'keep')

function! s:throw(msg)
    let v:errmsg = a:msg
    throw "Abolish: ".a:msg
endfunction

function! s:words()
    let words = []
    let lnum = line('w0')
    while lnum <= line('w$')
        let line = getline(lnum)
        let col = 0
        while match(line,'\<\k\k\+\>',col) != -1
            let words += [matchstr(line,'\<\k\k\+\>',col)]
            let col = matchend(line,'\<\k\k\+\>',col)
        endwhile
        let lnum += 1
    endwhile
    return words
endfunction

function! s:extractopts(list,opts)
    let i = 0
    while i < len(a:list)
        if a:list[i] =~ '^-[^=]' && has_key(a:opts,matchstr(a:list[i],'-\zs[^=]*'))
            let key   = matchstr(a:list[i],'-\zs[^=]*')
            let value = matchstr(a:list[i],'=\zs.*')
            if type(get(a:opts,key)) == type([])
                let a:opts[key] += [value]
            elseif type(get(a:opts,key)) == type(0)
                let a:opts[key] = 1
            else
                let a:opts[key] = value
            endif
        else
            let i += 1
            continue
        endif
        call remove(a:list,i)
    endwhile
    return a:opts
endfunction

" }}}1
" Dictionary creation {{{1

function! s:mixedcase(word)
    return substitute(s:camelcase(a:word),'^.','\u&','')
endfunction

function! s:camelcase(word)
    let word = substitute(a:word, '-', '_', 'g')
    if word !~# '_' && word =~# '\l'
        return substitute(word,'^.','\l&','')
    else
        return substitute(word,'\C\(_\)\=\(.\)','\=submatch(1)==""?tolower(submatch(2)) : toupper(submatch(2))','g')
    endif
endfunction

function! s:snakecase(word)
    let word = substitute(a:word,'::','/','g')
    let word = substitute(word,'\(\u\+\)\(\u\l\)','\1_\2','g')
    let word = substitute(word,'\(\l\|\d\)\(\u\)','\1_\2','g')
    let word = substitute(word,'[.-]','_','g')
    let word = tolower(word)
    return word
endfunction

function! s:uppercase(word)
    return toupper(s:snakecase(a:word))
endfunction

function! s:dashcase(word)
    return substitute(s:snakecase(a:word),'_','-','g')
endfunction

function! s:spacecase(word)
    return substitute(s:snakecase(a:word),'_',' ','g')
endfunction

function! s:dotcase(word)
    return substitute(s:snakecase(a:word),'_','.','g')
endfunction

call extend(Abolish, {
            \ 'camelcase':  s:function('s:camelcase'),
            \ 'mixedcase':  s:function('s:mixedcase'),
            \ 'snakecase':  s:function('s:snakecase'),
            \ 'uppercase':  s:function('s:uppercase'),
            \ 'dashcase':   s:function('s:dashcase'),
            \ 'dotcase':    s:function('s:dotcase'),
            \ 'spacecase':  s:function('s:spacecase'),
            \ }, 'keep')

function! s:create_dictionary(lhs,rhs,opts)
    let dictionary = {}
    let i = 0
    let expanded = s:expand_braces({a:lhs : a:rhs})
    for [lhs,rhs] in items(expanded)
        if get(a:opts,'case',1)
            let dictionary[s:mixedcase(lhs)] = s:mixedcase(rhs)
            let dictionary[tolower(lhs)] = tolower(rhs)
            let dictionary[toupper(lhs)] = toupper(rhs)
        endif
        let dictionary[lhs] = rhs
    endfor
    let i += 1
    return dictionary
endfunction

function! s:expand_braces(dict)
    let new_dict = {}
    for [key,val] in items(a:dict)
        if key =~ '{.*}'
            let redo = 1
            let [all,kbefore,kmiddle,kafter;crap] = matchlist(key,'\(.\{-\}\){\(.\{-\}\)}\(.*\)')
            let [all,vbefore,vmiddle,vafter;crap] = matchlist(val,'\(.\{-\}\){\(.\{-\}\)}\(.*\)') + ["","","",""]
            if all == ""
                let [vbefore,vmiddle,vafter] = [val, ",", ""]
            endif
            let targets      = split(kmiddle,',',1)
            let replacements = split(vmiddle,',',1)
            if replacements == [""]
                let replacements = targets
            endif
            for i in range(0,len(targets)-1)
                let new_dict[kbefore.targets[i].kafter] = vbefore.replacements[i%len(replacements)].vafter
            endfor
        else
            let new_dict[key] = val
        endif
    endfor
    if exists("redo")
        return s:expand_braces(new_dict)
    else
        return new_dict
    endif
endfunction

" }}}1
" Abolish Dispatcher {{{1

function! s:SubComplete(A,L,P)
    if a:A =~ '^[/?]\k\+$'
        let char = strpart(a:A,0,1)
        return join(map(s:words(),'char . v:val'),"\n")
    elseif a:A =~# '^\k\+$'
        return join(s:words(),"\n")
    endif
endfunction

function! s:Complete(A,L,P)
    " Vim bug: :Abolish -<Tab> calls this function with a:A equal to 0
    if a:A =~# '^[^/?-]' && type(a:A) != type(0)
        return join(s:words(),"\n")
    elseif a:L =~# '^\w\+\s\+\%(-\w*\)\=$'
        return "-search\n-substitute\n-delete\n-buffer\n-cmdline\n"
    elseif a:L =~# ' -\%(search\|substitute\)\>'
        return "-flags="
    else
        return "-buffer\n-cmdline"
    endif
endfunction

let s:commands = {}
let s:commands.abstract = s:object.clone()

function! s:commands.abstract.dispatch(bang,line1,line2,count,args)
    return self.clone().go(a:bang,a:line1,a:line2,a:count,a:args)
endfunction

function! s:commands.abstract.go(bang,line1,line2,count,args)
    let self.bang = a:bang
    let self.line1 = a:line1
    let self.line2 = a:line2
    let self.count = a:count
    return self.process(a:bang,a:line1,a:line2,a:count,a:args)
endfunction

function! s:dispatcher(bang,line1,line2,count,args)
    let i = 0
    let args = copy(a:args)
    let command = s:commands.abbrev
    while i < len(args)
        if args[i] =~# '^-\w\+$' && has_key(s:commands,matchstr(args[i],'-\zs.*'))
            let command = s:commands[matchstr(args[i],'-\zs.*')]
            call remove(args,i)
            break
        endif
        let i += 1
    endwhile
    try
        return command.dispatch(a:bang,a:line1,a:line2,a:count,args)
    catch /^Abolish: /
        echohl ErrorMsg
        echo   v:errmsg
        echohl NONE
        return ""
    endtry
endfunction

" }}}1
" Subvert Dispatcher {{{1

function! s:subvert_dispatcher(bang,line1,line2,count,args)
    try
        return s:parse_subvert(a:bang,a:line1,a:line2,a:count,a:args)
    catch /^Subvert: /
        echohl ErrorMsg
        echo   v:errmsg
        echohl NONE
        return ""
    endtry
endfunction

function! s:parse_subvert(bang,line1,line2,count,args)
    if a:args =~ '^\%(\w\|$\)'
        let args = (a:bang ? "!" : "").a:args
    else
        let args = a:args
    endif
    let separator = '\v((\\)@<!(\\\\)*\\)@<!' . matchstr(args,'^.')
    let split = split(args,separator,1)[1:]
    if a:count || split == [""]
        return s:parse_substitute(a:bang,a:line1,a:line2,a:count,split)
    elseif len(split) == 1
        return s:find_command(separator,"",split[0])
    elseif len(split) == 2 && split[1] =~# '^[A-Za-z]*n[A-Za-z]*$'
        return s:parse_substitute(a:bang,a:line1,a:line2,a:count,[split[0],"",split[1]])
    elseif len(split) == 2 && split[1] =~# '^[A-Za-z]*\%([+-]\d\+\)\=$'
        return s:find_command(separator,split[1],split[0])
    elseif len(split) >= 2 && split[1] =~# '^[A-Za-z]* '
        let flags = matchstr(split[1],'^[A-Za-z]*')
        let rest = matchstr(join(split[1:],separator),' \zs.*')
        return s:grep_command(rest,a:bang,flags,split[0])
    elseif len(split) >= 2 && separator == ' '
        return s:grep_command(join(split[1:],' '),a:bang,"",split[0])
    else
        return s:parse_substitute(a:bang,a:line1,a:line2,a:count,split)
    endif
endfunction

function! s:normalize_options(flags)
    if type(a:flags) == type({})
        let opts = a:flags
        let flags = get(a:flags,"flags","")
    else
        let opts = {}
        let flags = a:flags
    endif
    if flags =~# 'w'
        let opts.boundaries = 2
    elseif flags =~# 'v'
        let opts.boundaries = 1
    elseif !has_key(opts,'boundaries')
        let opts.boundaries = 0
    endif
    let opts.case = (flags !~# 'I' ? get(opts,'case',1) : 0)
    let opts.flags = substitute(flags,'\C[avIiw]','','g')
    return opts
endfunction

" }}}1
" Searching {{{1

function! s:subesc(pattern)
    return substitute(a:pattern,'[][\\/.*+?~%()&]','\\&','g')
endfunction

function! s:sort(a,b)
    if a:a ==? a:b
        return a:a == a:b ? 0 : a:a > a:b ? 1 : -1
    elseif strlen(a:a) == strlen(a:b)
        return a:a >? a:b ? 1 : -1
    else
        return strlen(a:a) < strlen(a:b) ? 1 : -1
    endif
endfunction

function! s:pattern(dict,boundaries)
    if a:boundaries == 2
        let a = '<'
        let b = '>'
    elseif a:boundaries
        let a = '%(<|_@<=|[[:lower:]]@<=[[:upper:]]@=)'
        let b =  '%(>|_@=|[[:lower:]]@<=[[:upper:]]@=)'
    else
        let a = ''
        let b = ''
    endif
    return '\v\C'.a.'%('.join(map(sort(keys(a:dict),function('s:sort')),'s:subesc(v:val)'),'|').')'.b
endfunction

function! s:egrep_pattern(dict,boundaries)
    if a:boundaries == 2
        let a = '\<'
        let b = '\>'
    elseif a:boundaries
        let a = '(\<\|_)'
        let b = '(\>\|_\|[[:upper:]][[:lower:]])'
    else
        let a = ''
        let b = ''
    endif
    return a.'('.join(map(sort(keys(a:dict),function('s:sort')),'s:subesc(v:val)'),'\|').')'.b
endfunction

function! s:c()
    call histdel('search',-1)
    return ""
endfunction

function! s:find_command(cmd,flags,word)
    let opts = s:normalize_options(a:flags)
    let dict = s:create_dictionary(a:word,"",opts)
    " This is tricky.  If we use :/pattern, the search drops us at the
    " beginning of the line, and we can't use position flags (e.g., /foo/e).
    " If we use :norm /pattern, we leave ourselves vulnerable to "press enter"
    " prompts (even with :silent).
    let cmd = (a:cmd =~ '[?!]' ? '?' : '/')
    let @/ = s:pattern(dict,opts.boundaries)
    if opts.flags == "" || !search(@/,'n')
        return "norm! ".cmd."\<CR>"
    elseif opts.flags =~ ';[/?]\@!'
        call s:throw("E386: Expected '?' or '/' after ';'")
    else
        return "exe 'norm! ".cmd.cmd.opts.flags."\<CR>'|call histdel('search',-1)"
        return ""
    endif
endfunction

function! s:grep_command(args,bang,flags,word)
    let opts = s:normalize_options(a:flags)
    let dict = s:create_dictionary(a:word,"",opts)
    if &grepprg == "internal"
        let lhs = "'".s:pattern(dict,opts.boundaries)."'"
    elseif &grepprg =~# '^rg\|^ag'
        let lhs = "'".s:egrep_pattern(dict,opts.boundaries)."'"
    else
        let lhs = "-E '".s:egrep_pattern(dict,opts.boundaries)."'"
    endif
    return "grep".(a:bang ? "!" : "")." ".lhs." ".a:args
endfunction

let s:commands.search = s:commands.abstract.clone()
let s:commands.search.options = {"word": 0, "variable": 0, "flags": ""}

function! s:commands.search.process(bang,line1,line2,count,args)
    call s:extractopts(a:args,self.options)
    if self.options.word
        let self.options.flags .= "w"
    elseif self.options.variable
        let self.options.flags .= "v"
    endif
    let opts = s:normalize_options(self.options)
    if len(a:args) > 1
        return s:grep_command(join(a:args[1:]," "),a:bang,opts,a:args[0])
    elseif len(a:args) == 1
        return s:find_command(a:bang ? "!" : " ",opts,a:args[0])
    else
        call s:throw("E471: Argument required")
    endif
endfunction

" }}}1
" Substitution {{{1

function! Abolished()
    return get(g:abolish_last_dict,submatch(0),submatch(0))
endfunction

function! s:substitute_command(cmd,bad,good,flags)
    let opts = s:normalize_options(a:flags)
    let dict = s:create_dictionary(a:bad,a:good,opts)
    let lhs = s:pattern(dict,opts.boundaries)
    let g:abolish_last_dict = dict
    return a:cmd.'/'.lhs.'/\=Abolished()'."/".opts.flags
endfunction

function! s:parse_substitute(bang,line1,line2,count,args)
    if get(a:args,0,'') =~ '^[/?'']'
        let separator = matchstr(a:args[0],'^.')
        let args = split(join(a:args,' '),separator,1)
        call remove(args,0)
    else
        let args = a:args
    endif
    if len(args) < 2
        call s:throw("E471: Argument required")
    elseif len(args) > 3
        call s:throw("E488: Trailing characters")
    endif
    let [bad,good,flags] = (args + [""])[0:2]
    if a:count == 0
        let cmd = "substitute"
    else
        let cmd = a:line1.",".a:line2."substitute"
    endif
    return s:substitute_command(cmd,bad,good,flags)
endfunction

let s:commands.substitute = s:commands.abstract.clone()
let s:commands.substitute.options = {"word": 0, "variable": 0, "flags": "g"}

function! s:commands.substitute.process(bang,line1,line2,count,args)
    call s:extractopts(a:args,self.options)
    if self.options.word
        let self.options.flags .= "w"
    elseif self.options.variable
        let self.options.flags .= "v"
    endif
    let opts = s:normalize_options(self.options)
    if len(a:args) <= 1
        call s:throw("E471: Argument required")
    else
        let good = join(a:args[1:],"")
        let cmd = a:bang ? "." : "%"
        return s:substitute_command(cmd,a:args[0],good,self.options)
    endif
endfunction

" }}}1
" Abbreviations {{{1

function! s:badgood(args)
    let words = filter(copy(a:args),'v:val !~ "^-"')
    call filter(a:args,'v:val =~ "^-"')
    if empty(words)
        call s:throw("E471: Argument required")
    elseif !empty(a:args)
        call s:throw("Unknown argument: ".a:args[0])
    endif
    let [bad; words] = words
    return [bad, join(words," ")]
endfunction

function! s:abbreviate_from_dict(cmd,dict)
    for [lhs,rhs] in items(a:dict)
        exe a:cmd lhs rhs
    endfor
endfunction

let s:commands.abbrev     = s:commands.abstract.clone()
let s:commands.abbrev.options = {"buffer":0,"cmdline":0,"delete":0}
function! s:commands.abbrev.process(bang,line1,line2,count,args)
    let args = copy(a:args)
    call s:extractopts(a:args,self.options)
    if self.options.delete
        let cmd = "unabbrev"
        let good = ""
    else
        let cmd = "noreabbrev"
    endif
    if !self.options.cmdline
        let cmd = "i" . cmd
    endif
    if self.options.delete
        let cmd = "silent! ".cmd
    endif
    if self.options.buffer
        let cmd = cmd . " <buffer>"
    endif
    let [bad, good] = s:badgood(a:args)
    if substitute(bad, '[{},]', '', 'g') !~# '^\k*$'
        call s:throw("E474: Invalid argument (not a keyword: ".string(bad).")")
    endif
    if !self.options.delete && good == ""
        call s:throw("E471: Argument required".a:args[0])
    endif
    let dict = s:create_dictionary(bad,good,self.options)
    call s:abbreviate_from_dict(cmd,dict)
    if a:bang
        let i = 0
        let str = "Abolish ".join(args," ")
        let file = g:abolish_save_file
        if !isdirectory(fnamemodify(file,':h'))
            call mkdir(fnamemodify(file,':h'),'p')
        endif

        if filereadable(file)
            let old = readfile(file)
        else
            let old = ["\" Exit if :Abolish isn't available.","if !exists(':Abolish')","    finish","endif",""]
        endif
        call writefile(old + [str],file)
    endif
    return ""
endfunction

let s:commands.delete   = s:commands.abbrev.clone()
let s:commands.delete.options.delete = 1

" }}}1
" Maps {{{1

function! s:unknown_coercion(letter,word)
    return a:word
endfunction

call extend(Abolish.Coercions, {
            \ 'c': Abolish.camelcase,
            \ 'm': Abolish.mixedcase,
            \ 'p': Abolish.mixedcase,
            \ 's': Abolish.snakecase,
            \ '_': Abolish.snakecase,
            \ 'u': Abolish.uppercase,
            \ 'U': Abolish.uppercase,
            \ '-': Abolish.dashcase,
            \ 'k': Abolish.dashcase,
            \ '.': Abolish.dotcase,
            \ ' ': Abolish.spacecase,
            \ "function missing": s:function("s:unknown_coercion")
            \}, "keep")

function! s:coerce(type) abort
    if a:type !~# '^\%(line\|char\|block\)'
        let s:transformation = a:type
        let &opfunc = matchstr(expand('<sfile>'), '<SNR>\w*')
        return 'g@'
    endif
    let selection = &selection
    let clipboard = &clipboard
    try
        set selection=inclusive clipboard-=unnamed clipboard-=unnamedplus
        let regbody = getreg('"')
        let regtype = getregtype('"')
        let c = v:count1
        let begin = getcurpos()
        while c > 0
            let c -= 1
            if a:type ==# 'line'
                let move = "'[V']"
            elseif a:type ==# 'block'
                let move = "`[\<C-V>`]"
            else
                let move = "`[v`]"
            endif
            silent exe 'normal!' move.'y'
            let word = @@
            let @@ = s:send(g:Abolish.Coercions,s:transformation,word)
            if word !=# @@
                let changed = 1
                exe 'normal!' move.'p'
            endif
        endwhile
        call setreg('"',regbody,regtype)
        call setpos("'[",begin)
        call setpos(".",begin)
    finally
        let &selection = selection
        let &clipboard = clipboard
    endtry
endfunction

nnoremap <expr> <Plug>(abolish-coerce) <SID>coerce(nr2char(getchar()))
vnoremap <expr> <Plug>(abolish-coerce) <SID>coerce(nr2char(getchar()))
nnoremap <expr> <Plug>(abolish-coerce-word) <SID>coerce(nr2char(getchar())).'iw'

" }}}1

if !exists("g:abolish_no_mappings") || ! g:abolish_no_mappings
    nmap cr  <Plug>(abolish-coerce-word)
endif

command! -nargs=+ -bang -bar -range=0 -complete=custom,s:Complete Abolish
            \ :exec s:dispatcher(<bang>0,<line1>,<line2>,<count>,[<f-args>])
command! -nargs=1 -bang -bar -range=0 -complete=custom,s:SubComplete Subvert
            \ :exec s:subvert_dispatcher(<bang>0,<line1>,<line2>,<count>,<q-args>)
if exists(':S') != 2
    command -nargs=1 -bang -bar -range=0 -complete=custom,s:SubComplete S
                \ :exec s:subvert_dispatcher(<bang>0,<line1>,<line2>,<count>,<q-args>)
endif

" ||---------------||
" ||               ||
" ||     Theme     ||
" ||               ||
" ||---------------||
if has('termguicolors')
    set termguicolors

    set background=dark
    hi clear

    syntax on
    if exists('syntax on')
        syntax reset
    endif

    set t_Co=256

    let s:rosewater = "#F5E0DC"
    let s:flamingo = "#F2CDCD"
    let s:pink = "#F5C2E7"
    let s:mauve = "#CBA6F7"
    let s:red = "#F38BA8"
    let s:maroon = "#EBA0AC"
    let s:peach = "#FAB387"
    let s:yellow = "#F9E2AF"
    let s:green = "#A6E3A1"
    let s:teal = "#94E2D5"
    let s:sky = "#89DCEB"
    let s:sapphire = "#74C7EC"
    let s:blue = "#89B4FA"
    let s:lavender = "#B4BEFE"

    let s:text = "#CDD6F4"
    let s:subtext1 = "#BAC2DE"
    let s:subtext0 = "#A6ADC8"
    let s:overlay2 = "#9399B2"
    let s:overlay1 = "#7F849C"
    let s:overlay0 = "#6C7086"
    let s:surface2 = "#585B70"
    let s:surface1 = "#45475A"
    let s:surface0 = "#313244"

    let s:base = "#1E1E2E"
    let s:mantle = "#181825"
    let s:crust = "#11111B"

    function! s:hi(group, guisp, guifg, guibg, gui, cterm)
        let cmd = ""
        if a:guisp != ""
            let cmd = cmd . " guisp=" . a:guisp
        endif
        if a:guifg != ""
            let cmd = cmd . " guifg=" . a:guifg
        endif
        if a:guibg != ""
            let cmd = cmd . " guibg=" . a:guibg
        endif
        if a:gui != ""
            let cmd = cmd . " gui=" . a:gui
        endif
        if a:cterm != ""
            let cmd = cmd . " cterm=" . a:cterm
        endif
        if cmd != ""
            exec "hi " . a:group . cmd
        endif
    endfunction

    call s:hi("Normal", "NONE", s:text, s:base, "NONE", "NONE")
    call s:hi("Visual", "NONE", "NONE", s:surface1,"bold", "bold")
    call s:hi("Conceal", "NONE", s:overlay1, "NONE", "NONE", "NONE")
    call s:hi("ColorColumn", "NONE", "NONE", s:surface0, "NONE", "NONE")
    call s:hi("Cursor", "NONE", s:base, s:text, "NONE", "NONE")
    call s:hi("lCursor", "NONE", s:base, s:text, "NONE", "NONE")
    call s:hi("CursorIM", "NONE", s:base, s:text, "NONE", "NONE")
    call s:hi("CursorColumn", "NONE", "NONE", s:mantle, "NONE", "NONE")
    call s:hi("CursorLine", "NONE", "NONE", s:surface0, "NONE", "NONE")
    call s:hi("Directory", "NONE", s:blue, "NONE", "NONE", "NONE")
    call s:hi("DiffAdd", "NONE", s:base, s:green, "NONE", "NONE")
    call s:hi("DiffChange", "NONE", s:base, s:yellow, "NONE", "NONE")
    call s:hi("DiffDelete", "NONE", s:base, s:red, "NONE", "NONE")
    call s:hi("DiffText", "NONE", s:base, s:blue, "NONE", "NONE")
    call s:hi("EndOfBuffer", "NONE", "NONE", "NONE", "NONE", "NONE")
    call s:hi("ErrorMsg", "NONE", s:red, "NONE", "bolditalic"    , "bold,italic")
    call s:hi("VertSplit", "NONE", s:crust, "NONE", "NONE", "NONE")
    call s:hi("Folded", "NONE", s:blue, s:surface1, "NONE", "NONE")
    call s:hi("FoldColumn", "NONE", s:overlay0, s:base, "NONE", "NONE")
    call s:hi("SignColumn", "NONE", s:surface1, s:base, "NONE", "NONE")
    call s:hi("IncSearch", "NONE", s:surface1, s:pink, "NONE", "NONE")
    call s:hi("CursorLineNR", "NONE", s:lavender, "NONE", "NONE", "NONE")
    call s:hi("LineNr", "NONE", s:surface1, "NONE", "NONE", "NONE")
    call s:hi("MatchParen", "NONE", s:peach, "NONE", "bold", "bold")
    call s:hi("ModeMsg", "NONE", s:text, "NONE", "bold", "bold")
    call s:hi("MoreMsg", "NONE", s:blue, "NONE", "NONE", "NONE")
    call s:hi("NonText", "NONE", s:overlay0, "NONE", "NONE", "NONE")
    call s:hi("Pmenu", "NONE", s:overlay2, s:surface0, "NONE", "NONE")
    call s:hi("PmenuSel", "NONE", s:text, s:surface1, "bold", "bold")
    call s:hi("PmenuSbar", "NONE", "NONE", s:surface1, "NONE", "NONE")
    call s:hi("PmenuThumb", "NONE", "NONE", s:overlay0, "NONE", "NONE")
    call s:hi("Question", "NONE", s:blue, "NONE", "NONE", "NONE")
    call s:hi("QuickFixLine", "NONE", "NONE", s:surface1, "bold", "bold")
    call s:hi("Search", "NONE", s:pink, s:surface1, "bold", "bold")
    call s:hi("SpecialKey", "NONE", s:subtext0, "NONE", "NONE", "NONE")
    call s:hi("SpellBad", s:red, "NONE", "NONE", "underline", "underline")
    call s:hi("SpellCap", s:yellow, "NONE", "NONE", "underline", "underline")
    call s:hi("SpellLocal", s:blue, "NONE", "NONE", "underline", "underline")
    call s:hi("SpellRare", s:green, "NONE", "NONE", "underline", "underline")
    call s:hi("StatusLine", "NONE", s:text, s:mantle, "NONE", "NONE")
    call s:hi("StatusLineNC", "NONE", s:surface1, s:mantle, "NONE", "NONE")
    call s:hi("TabLine", "NONE", s:surface1, s:mantle, "NONE", "NONE")
    call s:hi("TabLineFill", "NONE", "NONE", s:mantle, "NONE", "NONE")
    call s:hi("TabLineSel", "NONE", s:green, s:surface1, "NONE", "NONE")
    call s:hi("Title", "NONE", s:blue, "NONE", "bold", "bold")
    call s:hi("VisualNOS", "NONE", "NONE", s:surface1, "bold", "bold")
    call s:hi("WarningMsg", "NONE", s:yellow, "NONE", "NONE", "NONE")
    call s:hi("WildMenu", "NONE", "NONE", s:overlay0, "NONE", "NONE")
    call s:hi("Comment", "NONE", s:surface2, "NONE", "NONE", "NONE")
    call s:hi("Constant", "NONE", s:peach, "NONE", "NONE", "NONE")
    call s:hi("Identifier", "NONE", s:flamingo, "NONE", "NONE", "NONE")
    call s:hi("Statement", "NONE", s:mauve, "NONE", "NONE", "NONE")
    call s:hi("PreProc", "NONE", s:pink, "NONE", "NONE", "NONE")
    call s:hi("Type", "NONE", s:blue, "NONE", "NONE", "NONE")
    call s:hi("Special", "NONE", s:pink, "NONE", "NONE", "NONE")
    call s:hi("Underlined", "NONE", s:text, s:base, "underline", "underline")
    call s:hi("Error", "NONE", s:red, "NONE", "NONE", "NONE")
    call s:hi("Todo", "NONE", s:base, s:yellow, "bold", "bold")

    call s:hi("String", "NONE", s:green, "NONE", "NONE", "NONE")
    call s:hi("Character", "NONE", s:teal, "NONE", "NONE", "NONE")
    call s:hi("Number", "NONE", s:peach, "NONE", "NONE", "NONE")
    call s:hi("Boolean", "NONE", s:peach, "NONE", "NONE", "NONE")
    call s:hi("Float", "NONE", s:peach, "NONE", "NONE", "NONE")
    call s:hi("Function", "NONE", s:blue, "NONE", "NONE", "NONE")
    call s:hi("Conditional", "NONE", s:red, "NONE", "NONE", "NONE")
    call s:hi("Repeat", "NONE", s:red, "NONE", "NONE", "NONE")
    call s:hi("Label", "NONE", s:peach, "NONE", "NONE", "NONE")
    call s:hi("Operator", "NONE", s:sky, "NONE", "NONE", "NONE")
    call s:hi("Keyword", "NONE", s:pink, "NONE", "NONE", "NONE")
    call s:hi("Include", "NONE", s:pink, "NONE", "NONE", "NONE")
    call s:hi("StorageClass", "NONE", s:yellow, "NONE", "NONE", "NONE")
    call s:hi("Structure", "NONE", s:yellow, "NONE", "NONE", "NONE")
    call s:hi("Typedef", "NONE", s:yellow, "NONE", "NONE", "NONE")
    call s:hi("debugPC", "NONE", "NONE", s:crust, "NONE", "NONE")
    call s:hi("debugBreakpoint", "NONE", s:overlay0, s:base, "NONE", "NONE")

    hi link Define PreProc
    hi link Macro PreProc
    hi link PreCondit PreProc
    hi link SpecialChar Special
    hi link Tag Special
    hi link Delimiter Special
    hi link SpecialComment Special
    hi link Debug Special
    hi link Exception Error
    hi link StatusLineTerm StatusLine
    hi link StatusLineTermNC StatusLineNC
    hi link Terminal Normal
    hi link Ignore Comment
endif
