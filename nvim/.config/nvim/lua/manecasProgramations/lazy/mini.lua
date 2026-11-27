return {
    "echasnovski/mini.nvim",
    lazy = false,
    config = function()
        require('mini.surround').setup()

        require('mini.ai').setup({ n_lines = 500 })
    end,
}
