function ChangeTheme(color)
    color = color or "rose-pine"
    vim.cmd.colorscheme(color)
end

return {
    {
        "folke/tokyonight.nvim",
        lazy = true,
        config = function()
            require("tokyonight").setup({
                style = "night",
                transparent = false,
                terminal_colors = true,
                styles = {
                    comments = { italic = false },
                    keywords = { italic = false },
                    sidebars = "dark",
                    floats = "dark",
                },
            })
            -- ChangeTheme("tokyonight-night")
        end,
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = true,
        priority = 1000,
        config = function()
            require("rose-pine").setup({
                variant = "main",
                dark_variant = "main",
                dim_inactive_windows = false,
                extend_background_behind_borders = true,
                styles = {
                    bold = true,
                    italic = false,
                    transparency = false,
                },
            })
            -- ChangeTheme("rose-pine")
        end,
    },
    {
        "vague2k/vague.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("vague").setup({
                transparent = false,
                style = {
                    comments = "italic",
                    keywords = "none",
                    functions = "none",
                    strings = "none",
                    variables = "none",
                },
            })
            -- ChangeTheme("vague")
        end,
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha",
                transparent_background = false,
                term_colors = true,
                no_italic = false,
                no_bold = false,
                styles = {
                    comments = { "italic" },
                    keywords = { "italic" },
                    functions = {},
                    variables = {},
                    booleans = { "bold", "italic" },
                },
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    treesitter = true,
                },
            })

            ChangeTheme("catppuccin")
        end,
    },
}
