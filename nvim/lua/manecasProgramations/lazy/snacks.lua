return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = { enabled = true },
		input = { enabled = true },
		lazygit = { enabled = true },
		gitbrowse = { enabled = true },
		image = { enabled = true },
		notifier = { enabled = true },
		quickfile = { enabled = true },
		explorer = { enabled = true },
		zen = {
			toggles = { dim = false }, -- zen-mode.nvim didn't dim (no twilight)
			win = { wo = { wrap = false } },
		},
		picker = {
			enabled = true,
			sources = {
				explorer = {
					hidden = true, -- show dotfiles
					ignored = true, -- show gitignored files
					exclude = { "node_modules", ".git" },
					jump = { close = true }, -- close after opening a file
					layout = { layout = { width = 30, min_width = 30 } },
				},
			},
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("QuitPre", {
			group = vim.api.nvim_create_augroup("snacks-explorer-last-window", { clear = true }),
			callback = function()
				local wins = vim.api.nvim_tabpage_list_wins(0)
				-- the sidebar is a split (snacks_layout_box) holding floats (snacks_picker_*)
				local snacks_wins = vim.tbl_filter(function(win)
					return vim.bo[vim.api.nvim_win_get_buf(win)].filetype:match("^snacks_") ~= nil
				end, wins)
				local editor_wins = vim.tbl_filter(function(win)
					return vim.api.nvim_win_get_config(win).relative == "" and not vim.list_contains(snacks_wins, win)
				end, wins)
				-- picker:close() reshuffles focus and cancels the :q, so close the windows directly
				if #editor_wins == 1 and #snacks_wins > 0 then
					for _, win in ipairs(snacks_wins) do
						pcall(vim.api.nvim_win_close, win, true)
					end
				end
			end,
		})
	end,
	keys = {
		-- Git
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},
		{
			"<leader>gb",
			function()
				Snacks.gitbrowse()
			end,
			desc = "Git Browse",
		},

		-- Explorer
		{
			"<leader>b",
			function()
				Snacks.explorer()
			end,
			desc = "Toggle explorer",
		},

		-- Zen / undo history
		{
			"<leader>zz",
			function()
				Snacks.zen()
			end,
			desc = "Toggle zen mode",
		},
		{
			"<leader>u",
			function()
				Snacks.picker.undo()
			end,
			desc = "Undo history",
		},

		-- Fuzzy finders
		{
			"<C-p>",
			function()
				Snacks.picker.files({ hidden = true, exclude = { "node_modules" } })
			end,
			desc = "Find files",
		},
		{
			"<leader>pf",
			function()
				Snacks.picker.git_files()
			end,
			desc = "Git files",
		},

		-- Search words on entire project
		{
			"<leader>pws",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "Grep word",
		},
		{
			"<leader>pWs",
			function()
				Snacks.picker.grep_word({ search = vim.fn.expand("<cWORD>") })
			end,
			desc = "Grep WORD",
		},

		-- Project string search (live)
		{
			"<leader>ps",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
	},
}
