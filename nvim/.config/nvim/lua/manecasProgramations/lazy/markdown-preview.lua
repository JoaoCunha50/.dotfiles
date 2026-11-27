return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    ft = { "markdown" },
    keys = {
        {
            "<leader>mp",
            ft = "markdown",
            "<cmd>RenderMarkdown toggle<cr>",
            desc = "Toggle Markdown Preview",
        },
    },
    opts = {},
}
