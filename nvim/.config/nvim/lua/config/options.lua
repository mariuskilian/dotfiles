-- Left column and similar settings
vim.opt.number = true -- Make line numbers default
vim.opt.relativenumber = true -- set relative numbered lines
vim.opt.numberwidth = 4 -- set number column width to 2 {default 4}
vim.opt.statuscolumn = "%=%{v:relnum?v:relnum:v:lnum} " -- Make current line number right-aligned
vim.opt.signcolumn = 'yes' -- Keep signcolumn on by default
vim.opt.wrap = false -- display lines as one long line
vim.opt.scrolloff = 10 -- minimal number of screen lines to keep above and below the cursor
vim.opt.sidescrolloff = 8 -- minimal number of screen columns either side of cursor if wrap is `false`

-- Tab spacing/behavior
vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.shiftwidth = 4 -- the number of spaces inserted for each indentation
vim.opt.tabstop = 4 -- insert n spaces for a tab
vim.opt.softtabstop = 4 -- Number of spaces that a tab counts for while performing editing operations
vim.opt.smartindent = true -- make indenting smarter again
vim.opt.breakindent = true -- Enable break indent

-- General behaviors
vim.g.loaded_netrw = 1 -- disable netrw
vim.g.loaded_netrwPlugin = 1 -- disable netrw
vim.opt.backup = false -- disable backup file creation
vim.opt.clipboard = 'unnamedplus' -- Sync clipboard between OS and Neovim.
vim.opt.conceallevel = 0 -- so that `` is visible in markdown files
vim.opt.fileencoding = 'utf-8' -- the encoding written to a file
vim.opt.mouse = 'a' -- Enable mouse mode
vim.opt.showmode = false -- we don't need to see things like -- INSERT -- anymore
vim.opt.splitbelow = true -- force all horizontal splits to go below current window
vim.opt.splitright = true -- force all vertical splits to go to the right of current window
vim.opt.termguicolors = true -- set termguicolors to enable highlight groups
vim.opt.timeoutlen = 1000 -- time to wait for a mapped sequence to complete (in milliseconds)
vim.opt.undofile = true -- Save undo history
vim.opt.updatetime = 100 -- Decrease update time
vim.opt.writebackup = false -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
vim.opt.cursorline = true -- highlight the current line

-- Searching behaviors
vim.opt.hlsearch = false -- Set highlight on search
vim.opt.ignorecase = true -- Case-insensitive searching UNLESS \C or capital in search
vim.opt.smartcase = true -- smart case

-- Others
vim.o.completeopt = 'menuone,noselect' -- Set completeopt to have a better completion experience
vim.o.whichwrap = 'bs<>[]hl' -- which "horizontal" keys are allowed to travel to prev/next line
vim.o.linebreak = true -- companion to wrap don't split words
vim.o.swapfile = false -- creates a swapfile
vim.o.showtabline = 1 -- show if there are at least two tabs
vim.o.backspace = 'indent,eol,start' -- allow backspace on
vim.o.pumheight = 10 -- pop up menu height
vim.o.cmdheight = 1 -- more space in the neovim command line for displaying messages
vim.opt.shortmess:append 'c' -- don't give |ins-completion-menu| messages
vim.opt.iskeyword:append '-' -- hyphenated words recognized by searches
vim.opt.formatoptions:remove { 'c', 'r', 'o' } -- don't insert the current comment leader automatically for auto-wrapping comments using 'textwidth', hitting <Enter> in insert mode, or hitting 'o' or 'O' in normal mode.
vim.opt.runtimepath:remove '/usr/share/vim/vimfiles' -- separate vim plugins from neovim in case vim still in use
