vim.opt.autoread = true
vim.opt.showmode = false
vim.opt.cmdheight = 0

-- Keep split boundaries blank, including the explorer/code separator.
vim.opt.fillchars = {
    eob = " ",
    vert = " ",
    horiz = " ",
    vertleft = " ",
    vertright = " ",
    verthoriz = " ",
    horizup = " ",
    horizdown = " ",
}

vim.opt.nu = true
vim.opt.relativenumber = false

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.smoothscroll = true
vim.opt.updatetime = 50

vim.o.inccommand = "split"
