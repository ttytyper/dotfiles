" Do not use ~/.viminfo
set viminfofile=NONE

" Syntax highlighting enabled
syntax on

" Line numbering
set number " Precede each line with its line number
set ruler  " Show line and column number in statusbar
" Subdued line number coloring
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE


" Searching
set hlsearch   " Highlight search results
set ignorecase " Enable case-insensitive searching
set smartcase  " .. but become case sensitive if specifically searching with upper case

" Mouse enabled
set mouse=a

" Styling
set termguicolors
