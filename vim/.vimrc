execute pathogen#infect()
syntax enable
set background=dark
colorscheme solarized





set nocompatible
set encoding=utf8
set fileencoding=utf8
set showmatch
set ignorecase
set ruler                  " display cursor's line/column
set showmode               " display the command state
" ignore the ignorecase option if the user went to the trouble of
" entering uppercase characters.
set smartcase
" incremental search - shows what was found
set incsearch
" highlights what it found
set hlsearch
" show status line
set laststatus=2
" Background is dark for our terminals and for the console
:au VimEnter pico* set tw=72
:au VimEnter pico* set wrap

syntax on
"set list
"set listchars=tab:>-,trail:%,extends:@

set cursorline
au ColorScheme * highlight CursorLine   term=underline guibg=NONE cterm=underline gui=underline

au BufEnter *.cpp,*.c,*.cc,*.C,*.h,*.java,*.pl set cindent
au BufNewFile,BufRead *.html,*.htm,*.shtml,*.jinja,*.stm set ft=jinja

" tab handling
set nocompatible
set tabstop=2
set shiftwidth=2
set expandtab

" some mappings
map <F2> :%s/^V^M//g# Convert DOS textfile to UNIX
map <F3> :!bash # Run bash 
map <F5> :w# Write to file 
map <F6> :e # Edit file (type in file name) 
map <F7> :make # Run make in current directory 
map <F8> :w<CR>:!aspell -d en_GB -e -c %<CR>:e<CR>
map <F9> :w<CR>:!aspell -d de_DE -e -c %<CR>:e<CR>
map <F12> :q!# Quit without saving 
map  !}fmt -72

set nocompatible
filetype plugin indent on

" avoid .swp files
set nobackup
set backupdir=/tmp/
set directory=/tmp/
set undodir=~/tmp/
