"" Mute bell ringing for WSL


"" General Settings
" opening only for vim style
set nocompatible

" character code = UTF-8
set fenc=utf-8

" no backup files
set nobackup

" no swap files
set noswapfile

" if editting file is editted by other, the new file is reread.
set autoread

" if buffer is being editted, permit other new files opening
set hidden

" typing command showing
set showcmd


"" Appearances
" showing line numbers
set number

" remarking cursoring line
set cursorline

" remarking cursorling column
set cursorcolumn

" smartindent
set smartindent

" peeping noise visible
set visualbell

" Showing matching brackets
set showmatch

" always showing status line
set laststatus=2

" completing command
set wildmode=list:longest


"" space/Tab visualizing
" showing space/Tab
set list
set listchars=tab:»-,trail:-,space:･,eol:↲,extends:»,precedes:«,nbsp:%
hi NonText ctermfg=DarkGray
hi SpecialKey ctermfg=DarkGray

" converting Tab to space
set expandtab

"tab characters = 4 (except line head)
set tabstop=4

"tab characters = 4 (line head)
set shiftwidth=4


"" Searching
" small letter searching only showing capital letter words
set ignorecase

" capital letter searching only showing capital letter words
set smartcase

" searching in order
set incsearch

" end next searching beginning
set wrapscan

" highlight searching words
set hlsearch

" exiting searching when pressing Esc
nmap <Esc><Esc> :nohlsearch<CR><Esc>


"" Clipboard linking
set clipboard=unnamedplus
