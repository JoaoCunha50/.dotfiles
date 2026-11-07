require("manecasProgramations.set")
require("manecasProgramations.remap")
require("manecasProgramations.lazy_nvim")

local augroup = vim.api.nvim_create_augroup
local manecasGroup = augroup("manecasProgramations", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.hl.on_yank({
			higroup = "IncSearch",
			timeout = 150,
		})
	end,
})

autocmd({ "BufWritePre" }, {
	group = manecasGroup,
	pattern = "*",
	command = [[%s/\s\+$//e]],
})
