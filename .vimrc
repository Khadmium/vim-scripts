if has('win32') || has('win64')
    set runtimepath+=$HOME/_vim
endif

if has('gui_running')
    if(has('win32') || has('win64'))
        set guifont=Consolas:h11:cANSI
    endif
    if(has('gui_gtk2') || has('gui_gtk3'))
        set guifont=Ubuntu\ Mono\ Regular\ 13
    endif
endif
execute pathogen#infect('uplugs/{}')
execute pathogen#infect('bundle/{}')
Helptags

let g:NERDTreeDirArrowExpandable="+"
let g:NERDTreeDirArrowCollapsible="~"

filetype plugin on
set number	
set linebreak	
set showbreak=+++ 
set textwidth=100
set showmatch
set visualbell

set hlsearch	" Highlight all search results
set smartcase	" Enable smart-case search
set ignorecase	" Always case-insensitive
set incsearch	" Searches for strings incrementally

set autoindent	" Auto-indent new lines
set shiftwidth=4	" Number of auto-indent spaces
set smartindent	" Enable smart-indent
set autoindent
set smarttab	" Enable smart-tabs
set softtabstop=0	" Number of spaces per Tab
set expandtab
set tabstop=8
"" Advanced
set confirm	" Prompt confirmation dialogs
set ruler	" Show row and column ruler information

set undolevels=100	" Number of undo levels
set backspace=indent,eol,start	" Backspace behaviour
set laststatus=2
if v:version > 704 || v:version == 704 && has("patch775")
    set completeopt=noinsert,menuone,preview
else
    set completeopt=menuone,preview
endif

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = { 'mode': 'passive' }


let OmniCpp_DisplayMode = 1
let OmniCpp_MayCompleteScope = 0
let OmniCpp_MayCompleteArrow = 0
let OmniCpp_MayCompleteDot = 0

nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
function Vimrc_SetBracketsMapping()
    inoremap <buffer> {<CR>  {<CR>}<Esc>O
endfunction


autocmd Filetype c,cpp,cxx,cc,h,hpp,hxx,hh call Vimrc_SetBracketsMapping()
autocmd Filetype java call Vimrc_SetBracketsMapping()
autocmd Filetype scala call Vimrc_SetBracketsMapping()
autocmd Filetype cs call Vimrc_SetBracketsMapping()
autocmd Filetype js,jsx,ts,tsx call Vimrc_SetBracketsMapping()
autocmd Filetype go call Vimrc_SetBracketsMapping()
autocmd Filetype perl call Vimrc_SetBracketsMapping()
autocmd Filetype rust call Vimrc_SetBracketsMapping()

autocmd FileType java setlocal omnifunc=javacomplete#Complete
autocmd FileType c,cpp,cxx,cc,h,hpp,hxx,hh setlocal omnifunc=omni#cpp#complete#Main


autocmd InsertEnter * syn clear EOLWS | syn match EOLWS excludenl /\s\+\%#\@!$/
autocmd InsertLeave * syn clear EOLWS | syn match EOLWS excludenl /\s\+$/
highlight EOLWS ctermbg=red guibg=red

colorscheme badwolf
let g:ackprg = 'ag --vimgrep --smart-case'
let g:EclimCompletionMethod = 'completefunc'
let g:EclimFileTypeValidate = 0

set noswapfile
set nobackup
set nowritebackup

autocmd FileType netrw setl bufhidden=wipe

let g:ycm_filetype_whitelist = {'javascript': 1,
    \ 'typescript': 1,
    \ 'python': 1
    \}

set complete=.,w,b,k
let g:ycm_auto_trigger = 0

let g:Illuminate_ftblacklist = ['nerdtree', 'netrw']
let g:Illuminate_delay = 250
let g:Illuminate_highlightUnderCursor = 1
" hi CurrentWord ctermbg=53
" hi CurrentWordTwins ctermbg=237

hi illuminatedWord ctermbg=53
nnoremap <F2> :set wrap! wrap?<CR>
imap <F2> <C-O><F2>

nnoremap <F5> :Ack! -G'.*\.(cpp\|hpp)' ''<left>
imap <F5> <C-O><F5>

nnoremap <F6> :Ack! -G'.*\.ttcn3' ''<left>
imap <F6> <C-O><F6>

nnoremap <F4> :vimgrep // %<left><left><left>
imap <F4> <C-O><F4>

nnoremap <F3> :lvimgrep // %<left><left><left>
imap <F3> <C-O><F3>

nnoremap <F7> :IlluminationToggle<CR>
imap <F7> <C-O><F7>

command WNERDTree NERDTree | vertical resize 70
command WideWindow vertical resize 70

