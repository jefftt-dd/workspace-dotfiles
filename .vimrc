" Plugins using vim-plug
call plug#begin()

" languages support
" lsp
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/lsp_extensions.nvim'
Plug 'hrsh7th/cmp-nvim-lsp', { 'branch': 'main' }
Plug 'hrsh7th/cmp-buffer', { 'branch': 'main' }
Plug 'hrsh7th/cmp-path', { 'branch': 'main' }
Plug 'hrsh7th/cmp-cmdline', { 'branch': 'main' }
Plug 'hrsh7th/nvim-cmp', { 'branch': 'main' }
Plug 'ray-x/lsp_signature.nvim'

"rust
Plug 'rust-lang/rust.vim'
" go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries', 'for': 'go' }

" color schemes
Plug 'chriskempson/base16-vim'

" cool status bar
" tmux status bar integration
Plug 'edkolev/tmuxline.vim'

" tpope
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'

" FZF
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Always cd to root git dir of current buffer
" Plug 'airblade/vim-rooter'

" File Explorer
Plug 'preservim/nerdtree'

" Markdown
Plug 'img-paste-devs/img-paste.vim'


call plug#end()

" Fish doesn't play all that well with others
set shell=/bin/bash

" https://github.com/chriskempson/base16-vim
let base16colorspace=256
colorscheme base16-ashes

" full file path on status line
set statusline+=%F

lua << END
vim.lsp.set_log_level("error")
local lspconfig = require('lspconfig')
local cmp = require'cmp'
local on_attach = function(client, bufnr)

   -- Get signatures (and _only_ signatures) when in argument lists.
  require "lsp_signature".on_attach({
    doc_lines = 0,
    handler_opts = {
      border = "none"
    },
  })

  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '<C-p>', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', '<C-n>', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  buf_set_keymap('n', '<space>h', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)

  -- Forward to other plugins
  -- require'completion'.on_attach(client)
end

local servers = { "rust_analyzer" }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
    settings = {
      ["rust_analyzer"] = {
        -- server_path = "/Users/jeff.lai/code/ra-multiplex/target/release/ra-multiplex",
        cargo = {
          allFeatures = true,
          -- noDefaultFeatures = true,
          -- features = { "minimal" }
        }
      }
    }
  }
end

lspconfig.gopls.setup {
    root_dir = vim.fn.getcwd(),
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
    capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),

    settings = {
      gopls = {
        buildFlags = { "" },
        env = {
          -- GOPACKAGESDRIVER = '/Users/jeff.lai/go/src/github.com/DataDog/dd-source/tools/go/gopackagesdriver.sh'
        },
        directoryFilters = {
          "-bazel-bin",
          "-bazel-out",
          "-bazel-testlogs",
          "-bazel-mypkg",
        },
        completeUnimported = true,
        usePlaceholders = true,
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
        gofumpt = true,
      },
    },
  }


vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)

cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })
END

" https://github.com/nvim-lua/completion-nvim#configuration
" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect
" Avoid showing message extra message when using completion
set shortmess+=c
" imap <tab> <Plug>(completion_smart_tab)
" imap <s-tab> <Plug>(completion_smart_s_tab)

" fast switching between normal/insert modes
set timeoutlen=1000 ttimeoutlen=0

set hidden
set cmdheight=2

" Sane splits
set splitright
set splitbelow

autocmd BufReadPost *.rs setlocal filetype=rust

set ffs=unix

" make highlight matching brackets easier to read
hi MatchParen cterm=none ctermbg=red ctermfg=white

" make pop up menu easier to read
hi Pmenu ctermbg=grey
" hi PmenuSel ctermbg=white

" show whitespace
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<

" fzf
set rtp+=~/.fzf

" Set <Leader> to space for easier key combinations
let mapleader = "\<Space>"

" Save with ctrl + s
nnoremap <C-s> :w<CR>

" copy/paste to system clipboard with leader
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

" Since I use linux, I want this
let g:clipbrdDefaultReg = '+'

" Set clipbroard to system clipboard
" set clipboard=unnamedplus
" For mac:
set clipboard=unnamed

" toggle between show whitepace
" nmap <Leader>l :set list!<CR>

" Use rg for file name search
let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --glob "!.git" .'
nnoremap <Leader>n :FZF<CR>
" Global file content search
nnoremap <C-f> :Rg<CR>

" Open last buffer with space space
nnoremap <Leader><Leader> :b#<CR>

" Previous buffer
nnoremap <Leader>i :bp<CR>
" Next buffer
nnoremap <Leader>o :bn<CR>
" Show buffers
nmap <leader>; :Buffers<CR>
" List buffers
nnoremap <leader>; :Buffers<CR>

" Clear search highlight
nnoremap <C-h> :noh<CR>

" Go to start of outer {
nnoremap <C-l> [{

" When you insert a { and hit Enter,
" it inserts the closing bracket and places the cursor on a new line between the pair
" inoremap {<CR> {<CR>}<C-o>O

" Mis-caps
map :Q :q
map :W :w
map :Wq :wq

" Yank/Paste to a buffer. Useful for replacing multiple places
vmap Y "ay
nmap P "ap

" Necesary  for lots of cool vim things
set nocompatible

" This shows what you are typing as a command.
set showcmd

" Needed for Syntax Highlighting and stuff
filetype on " turn on file type detection
filetype plugin on
syntax enable
syntax on

" search visual selection with //
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Who wants an 8 character tab?  Not me!
set tabstop=2
set softtabstop=2
set shiftwidth=2
" Get rid of tabs altogether and replace with spaces
set expandtab
" 2 space indent for js, mark max column length
autocmd FileType javascript setlocal shiftwidth=2 softtabstop=2 tabstop=2 colorcolumn=120
" remove trailing whitespace on :w
autocmd BufWritePre * %s/\s\+$//e

" Automatically save file on :make
set autowrite

" Automatically read file with updates
set autoread

" Cool tab completion stuff
set wildmenu
set wildmode=list:longest,full

" Let backspace delete autoindents, eol (\n\r), and text that was inserted
" before the start of the INSERT mode session
set backspace=indent,eol,start

" Set relative line numbers and show the absolute current line number
set relativenumber
set number

" Incremental searching is sexy
set incsearch

" Highlight things that we find with the search
set hlsearch

" case insensitive search by default, switch to case sensitive by using
" capital letters
set ignorecase
set smartcase

" Always keep the cursor vertically centered
set scrolloff=999

" show the cursor position all the time
set ruler

" Automatically write when switching buffers
set confirm

" Do not redraw screen in the middle of a macro. Makes them complete faster.
set lazyredraw

" Persistent undo, even if you close and reopen Vim.
set undodir=$HOME/.vim/undo
set undofile

" Auto cd to current dir of file
let g:rooter_change_directory_for_non_project_files = 'current'

" No swap files
set noswapfile

" Restore cursor position to where it was before
augroup JumpCursorOnEdit
   au!
   autocmd BufReadPost *
            \ if expand("<afile>:p:h") !=? $TEMP |
            \   if line("'\"") > 1 && line("'\"") <= line("$") |
            \     let JumpCursorOnEdit_foo = line("'\"") |
            \     let b:doopenfold = 1 |
            \     if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
            \        let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1 |
            \        let b:doopenfold = 2 |
            \     endif |
            \     exe JumpCursorOnEdit_foo |
            \   endif |
            \ endif
   " Need to postpone using "zv" until after reading the modelines.
   autocmd BufWinEnter *
            \ if exists("b:doopenfold") |
            \   exe "normal zv" |
            \   if(b:doopenfold > 1) |
            \       exe  "+".1 |
            \   endif |
            \   unlet b:doopenfold |
            \ endif
augroup END

" Auto save whenever text is changed
" autocmd TextChanged,TextChangedI <buffer> silent write

" Toggle File Explorer on Ctrl-g
nnoremap <C-g> :NERDTreeToggle<CR>
" find file in dir tree
nnoremap <leader>g :NERDTreeFind<CR>
let NERDTreeShowHidden=1

" File explorer tree list view
let g:netrw_liststyle = 3
" Remove netrw banner
let g:netrw_banner = 0
" Open files in new tab
let g:netrw_browse_split = 3
" Width of explorer in terms of page percentage
let g:netrw_winsize = 25

" Allow JSX in normal JS files
let g:jsx_ext_required = 0

" FIXME: Format json with :JsonFormat
com! JsonFormat '<,'>!python -m json.tool

" Replace selection with base64 decoded string
:vnoremap <leader>64 c<c-r>=system('base64 --decode', @")<cr><esc>

" project level vimrc files: https://www.alexeyshmalko.com/2014/using-vim-as-c-cpp-ide/
set exrc
set secure

" https://github.com/img-paste-devs/img-paste.base16-vim
autocmd FileType markdown nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>

" Open markdown files with VSCode.
autocmd BufEnter *.md exe 'noremap <leader>m :!code %:p<CR>'



" -------------------------------------------------------------------------------------------------
" end coc.nvim default settings
" -------------------------------------------------------------------------------------------------

" For reference: sub to strip trailing whitespace
" % -> do on whole file
" s -> substution
" \s -> matches whitespace
" \+ -> matches 1 or more characters
" $ -> matches end of line
" e -> suppress error messages (no matches)
" :%s/\s\+$//e

" For reference: delete all blank lines
" :g -> global command (on whole file)
" ^ -> matches beginning of line
" $ -> matches end of line
" d -> delete all matches
" :g/^$/d
