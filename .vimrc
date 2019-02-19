if exists('g:local_vimrc_script')
    execute "source " . g:local_vimrc_script
    finish
endif

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

set shiftwidth=4	" Number of auto-indent spaces
set autoindent
set expandtab
set softtabstop=4
set tabstop=4
function! Vimrc_ApplyIndentationSettings() abort
    setlocal shiftwidth=4	" Number of auto-indent spaces
    setlocal autoindent
    setlocal expandtab
    setlocal softtabstop=4
    setlocal tabstop=4
endfunction
autocmd FileType ruby call Vimrc_ApplyIndentationSettings()

autocmd Filetype c,cpp,cxx,cc,h,hpp,hxx,hh setlocal cindent
autocmd Filetype java setlocal cindent
autocmd Filetype scala setlocal cindent
autocmd Filetype cs setlocal cindent
autocmd Filetype js,jsx,ts,tsx setlocal cindent
autocmd Filetype go setlocal cindent
autocmd Filetype perl setlocal cindent
autocmd Filetype rust setlocal cindent

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

let OmniCpp_DisplayMode = 1
let OmniCpp_MayCompleteScope = 0
let OmniCpp_MayCompleteArrow = 0
let OmniCpp_MayCompleteDot = 0

" let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_rails = 1

let g:ale_completion_enabled = 0
let g:ale_linters_explicit = 1
let g:ale_linters = {}
" ale liters: 
"
" ruby linters
let g:ale_linters['ruby'] = ['ruby']
let g:ale_ruby_ruby_executable = 'ruby'

let g:ale_sign_error = '!>'
let g:ale_sign_warning = '?>'

" errors signal only by signs - this 
" setting is useful You can easly delete signs
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 0
let g:ale_set_highlights = 0
let g:ale_set_signs = 1
let g:ale_echo_cursor = 0
let g:ale_virtualtext_cursor = 0
let g:ale_cursor_detail = 0
let g:ale_set_balloons = 0

function! s:Vimrc_AleCallbackEmptyFunction() abort
endfunction

let s:vimrc_AlePostLintFunction = function('s:Vimrc_AleCallbackEmptyFunction')

function! s:Vimrc_AleCallbackUnsetCWinOutput() abort
    let s:vimrc_AlePostLintFunction = function('s:Vimrc_AleCallbackEmptyFunction')
    let g:ale_set_quickfix = 0
endfunction

command ALELintPost call s:vimrc_AlePostLintFunction()

function! s:Vimrc_AleLintToCWin() abort
    let g:ale_set_quickfix = 1
    let s:vimrc_AlePostLintFunction = function('s:Vimrc_AleCallbackUnsetCWinOutput')
    ALELint
endfunction

function! s:Vimrc_AlePassiveMode() abort
    let g:ale_lint_on_text_changed = 0
    let g:ale_lint_on_insert_leave = 0
    let g:ale_lint_on_enter = 0
    let g:ale_lint_on_save = 0
    let g:ale_lint_on_filetype_changed = 0
endfunction

function! s:Vimrc_AleActiveMode() abort
    let g:ale_lint_on_text_changed = 0
    let g:ale_lint_on_insert_leave = 1
    let g:ale_lint_on_enter = 1
    let g:ale_lint_on_save = 1
    let g:ale_lint_on_filetype_changed = 1
endfunction

function! s:Vimrc_AleExplicitMode() abort
    let g:ale_lint_on_text_changed = 0
    let g:ale_lint_on_insert_leave = 0
    let g:ale_lint_on_enter = 1
    let g:ale_lint_on_save = 1
    let g:ale_lint_on_filetype_changed = 1
endfunction

command AlePassiveMode call s:Vimrc_AlePassiveMode()
command AleActiveMode call s:Vimrc_AleActiveMode()
command AleExplicitMode call s:Vimrc_AleExplicitMode()
command AleLint call s:Vimrc_AleLintToCWin()

call s:Vimrc_AlePassiveMode()

nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
function! s:Vimrc_SetBracketsMapping() abort
    inoremap <buffer> {<CR>  {<CR>}<Esc>O
endfunction

autocmd Filetype c,cpp,cxx,cc,h,hpp,hxx,hh call s:Vimrc_SetBracketsMapping()
autocmd Filetype java call s:Vimrc_SetBracketsMapping()
autocmd Filetype scala call s:Vimrc_SetBracketsMapping()
autocmd Filetype cs call s:Vimrc_SetBracketsMapping()
autocmd Filetype js,jsx,ts,tsx call s:Vimrc_SetBracketsMapping()
autocmd Filetype go call s:Vimrc_SetBracketsMapping()
autocmd Filetype perl call s:Vimrc_SetBracketsMapping()
autocmd Filetype rust call s:Vimrc_SetBracketsMapping()

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

let g:ycm_filetype_whitelist = {
    \ 'javascript': 1,
    \ 'typescript': 1,
    \ 'python': 1
    \}

set complete=.,w,b,k
let g:ycm_auto_trigger = 0

let g:Illuminate_ftblacklist = ['nerdtree', 'netrw']
let g:Illuminate_delay = 150
let g:Illuminate_highlightUnderCursor = 1
let g:Illuminate_reltime_delay = 0.1
let g:Illuminate_mode = 2


hi illuminatedWord ctermbg=53
nnoremap <F2> :set wrap! wrap?<CR>
imap <F2> <C-O><F2>

nnoremap <leader>sc :Ack! -G'.*\.(cpp\|hpp)' ''<left>

nnoremap <leader>st :Ack! -G'.*\.ttcn3' ''<left>

nnoremap <leader>sf :vimgrep // %<left><left><left>

nnoremap <leader>sF :lvimgrep // %<left><left><left>

nnoremap <F3> :IlluminationToggle<CR>
imap <F3> <C-O><F3>

nnoremap <F4> :let g:Illuminate_use_prefix_pattern = !get(g:, 'Illuminate_use_prefix_pattern', 0)<CR>

command WNERDTree NERDTree | vertical resize 70
command WideWindow vertical resize 70

