return {
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "+" },
					change = { text = "*" },
					delete = { text = "-" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
			})

			-- Atalho para ver o diff da linha atual numa janela flutuante
			vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})

			-- Atalho para fazer "blame" na linha (quem escreveu isto?)
			vim.keymap.set("n", "gb", ":Gitsigns toggle_current_line_blame<CR>", {})

			vim.keymap.set("n", "<leader>gd", ":Gitsigns diffthis<CR>", { desc = "Git diff this file" })

			vim.keymap.set("n", "<leader>gD", function()
				require("gitsigns").diffthis("~")
			end, { desc = "Git diff against HEAD" })
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "auto",
					icons_enabled = true,
					globalstatus = true,
					section_separators = { left = "", right = "" },
					component_separators = { left = "|", right = "|" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = {
						"encoding",
						"fileformat",
						"filetype",
					},
					lualine_z = { "location" },
				},
			})
		end,
	},
}
