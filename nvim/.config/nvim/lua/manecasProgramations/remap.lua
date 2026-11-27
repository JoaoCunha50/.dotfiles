vim.g.mapleader = " "

vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>")
vim.keymap.set("n", "=ap", "ma=ap'a")

vim.keymap.set("n", "<M-o>", "o<ESC>", { desc = "Add line below" })

vim.keymap.set("n", "<M-O>", "O<ESC>", { desc = "Add line above" })

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Pesquisa (n / N) mantendo o cursor no meio
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste sem perder o buffer (preserva o que copiaste antes)
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Substituir a palavra onde estás (Search and Replace rápido)
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "<C-f>", function()
	local block = vim.env.REX_BLOCK
	if block and block ~= "" and vim.fn.executable("rex") == 1 then
		vim.fn.jobstart({ "rex", "do", "-s", block, "sessionizer" }, { detach = true })
		return
	end
	if vim.fn.executable("tmux") == 1 then
		vim.fn.jobstart({ "tmux", "neww", "tmux-sessionizer" }, { detach = true })
		return
	end
	vim.notify("sessionizer: no Rex block and no tmux", vim.log.levels.ERROR)
end, { desc = "sessionizer" })

-- Tornar o ficheiro executável (chmod +x)
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader>ts", function()
	vim.treesitter.stop()
	vim.defer_fn(function()
		vim.treesitter.start()
	end, 100)
end, { desc = "Restart Treesitter" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
