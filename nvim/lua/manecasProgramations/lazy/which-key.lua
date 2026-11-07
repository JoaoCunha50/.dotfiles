return {
	"folke/which-key.nvim",
	event = "VimEnter",
	opts = {
		delay = 0,
		icons = {
			mappings = true,
		},
		spec = {
			{ "<leader>p", group = "[P]roject search" },
			{ "<leader>v", group = "LSP" },
			{ "<leader>g", group = "[G]it" },
			{ "<leader>t", group = "[T]oggle / Trouble" },
			{ "<leader>h", group = "[H]arpoon" },
		},
	},
}
