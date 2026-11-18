return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"j-hui/fidget.nvim",
			"saghen/blink.cmp",
		},
		config = function()
			require("fidget").setup({})
			require("mason").setup()

			local apply_workspace_edit = vim.lsp.util.apply_workspace_edit
			vim.lsp.util.apply_workspace_edit = function(edit, encoding)
				-- Persist import updates/refactors, but never save pre-existing user edits.
				local modified = {}
				local function remember(uri)
					if uri:sub(1, 7) == "file://" then
						local buf = vim.uri_to_bufnr(uri)
						modified[buf] = vim.bo[buf].modified
					end
				end
				for uri in pairs(edit.changes or {}) do
					remember(uri)
				end
				for _, change in ipairs(edit.documentChanges or {}) do
					if change.textDocument then
						remember(change.textDocument.uri)
					end
				end

				apply_workspace_edit(edit, encoding)

				for buf, was_modified in pairs(modified) do
					if
						not was_modified
						and vim.api.nvim_buf_is_valid(buf)
						and vim.bo[buf].modified
						and vim.bo[buf].buftype == ""
						and vim.api.nvim_buf_get_name(buf) ~= ""
					then
						local ok, err = pcall(vim.api.nvim_buf_call, buf, function()
							vim.cmd("silent update")
						end)
						if not ok then
							vim.notify("Could not save LSP edits: " .. tostring(err), vim.log.levels.ERROR)
						end
					end
				end
			end

			vim.lsp.config("vtsls", {
				settings = {
					vtsls = {
						autoUseWorkspaceTsdk = true,
					},
					typescript = {
						tsdk = "node_modules/typescript/lib",
					},
				},
			})

			vim.lsp.config("eslint", {
				settings = {
					format = false,
				},
			})

			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"rust_analyzer",
					"gopls",
					"vtsls",
					"tailwindcss",
					"eslint",
                    "qmlls"
				},
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach-opts", { clear = true }),
				callback = function(e)
					local opts = { buffer = e.buf }

					vim.keymap.set("n", "gd", function()
						vim.lsp.buf.definition()
					end, opts)
					vim.keymap.set("n", "<leader>vws", function()
						vim.lsp.buf.workspace_symbol()
					end, opts)
					vim.keymap.set("n", "<leader>vd", function()
						vim.diagnostic.open_float()
					end, opts)
					vim.keymap.set("n", "<leader>vca", function()
						vim.lsp.buf.code_action()
					end, opts)
					vim.keymap.set("n", "<leader>vrr", function()
						vim.lsp.buf.references()
					end, opts)
					vim.keymap.set("n", "<leader>vrn", function()
						vim.lsp.buf.rename()
					end, opts)
					vim.keymap.set("i", "<C-h>", function()
						vim.lsp.buf.signature_help()
					end, opts)

					-- Toggle Inlay Hints
					vim.keymap.set("n", "<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = e.buf }))
					end, { buffer = e.buf, desc = "[T]oggle Inlay [H]ints" })

					-- Highlight references
					local client = vim.lsp.get_client_by_id(e.data.client_id)
					if client and client:supports_method("textDocument/documentHighlight", e.buf) then
						local group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = e.buf,
							group = group,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = e.buf,
							group = group,
							callback = vim.lsp.buf.clear_references,
						})
					end
				end,
			})
			vim.diagnostic.config({
				virtual_text = {
					spacing = 4,
					prefix = "●",
				},
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚",
						[vim.diagnostic.severity.WARN] = "󰀪",
						[vim.diagnostic.severity.HINT] = "󰌶",
						[vim.diagnostic.severity.INFO] = "",
					},
				},
				update_in_insert = false,
				underline = true,
				severity_sort = true,
				float = {
					-- Repeat <leader>vd to focus; <C-w>p returns to the code.
					focusable = true,
					style = "minimal",
					border = "none",
					max_width = 80,
					max_height = 16,
					source = "if_many",
					header = "",
					prefix = "",
				},
			})
		end,
	},
	{
		"saghen/blink.cmp",
		version = "v1.*",
		opts = {
			keymap = {
				preset = "default",
				["<CR>"] = { "accept", "fallback" },
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
			},
			appearance = { nerd_font_variant = "mono" },
			-- Give suggestions room without changing providers or completion keys.
			completion = {
				menu = {
					min_width = 40,
					border = "none",
					draw = {
						padding = { 2, 2 },
						gap = 2,
						columns = {
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "source_name" },
						},
						components = {
							label = { width = { min = 28, max = 48, fill = true } },
						},
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 250,
					window = { border = "none" },
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "lazydev" },
				providers = {
					lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
				},
			},
			signature = {
				enabled = true,
				window = { border = "none" },
			},
		},
	},
}
