return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup({
			settings = {
				save_on_toggle = true,
				sync_on_ui_close = true,
				key = function()
					return vim.uv.cwd()
				end,
			},
		})

		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end, { desc = "Harpoon: Add file" })

		-- Toggle UI do harpoon (ver todos os ficheiros marcados)
		vim.keymap.set("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon: Toggle menu" })

		-- Navegar para ficheiros específicos (1-4)
		vim.keymap.set("n", "<M-1>", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon: Go to file 1" })
		vim.keymap.set("n", "<M-2>", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon: Go to file 2" })
		vim.keymap.set("n", "<M-3>", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon: Go to file 3" })
		vim.keymap.set("n", "<M-4>", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon: Go to file 4" })

		vim.keymap.set("n", "<C-S-P>", function()
			harpoon:list():prev()
		end, { desc = "Harpoon: Previous file" })
		vim.keymap.set("n", "<C-S-N>", function()
			harpoon:list():next()
		end, { desc = "Harpoon: Next file" })

		-- harpoon2 lists can have nil holes after removals, so walk 1..length instead of ipairs
		vim.keymap.set("n", "<leader>hf", function()
			local list = harpoon:list()
			local items = {}
			for i = 1, list:length() do
				local item = list:get(i)
				if item then
					table.insert(items, {
						text = item.value,
						file = item.value,
						pos = { item.context.row, item.context.col },
					})
				end
			end
			Snacks.picker({ title = "Harpoon", items = items, format = "file" })
		end, { desc = "Harpoon: picker" })
	end,
}
