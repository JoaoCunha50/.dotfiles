return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "leoluz/nvim-dap-go",
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        local dap_signs = {
            DapBreakpoint = { text = "●", texthl = "DapBreakpoint" },
            DapBreakpointCondition = { text = "●", texthl = "DapBreakpointCondition" },
            DapLogPoint = { text = "◆", texthl = "DapLogPoint" },
            DapStopped = { text = "", texthl = "DapStopped" },
            DapBreakpointRejected = { text = "", texthl = "DapBreakpointRejected" },
        }

        for type, icon in pairs(dap_signs) do
            vim.fn.sign_define(type, { text = icon.text, texthl = icon.texthl, linehl = "", numhl = "" })
        end

        vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e06c75" })          -- Red
        vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#61afef" }) -- Blue
        vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#98c379" })            -- Green
        vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379" })             -- Green

        dapui.setup()

        require("dap-go").setup()

        -- Abrir e fechar a UI automaticamente
        dap.listeners.before.attach.dapui_config = function() dapui.open() end
        dap.listeners.before.launch.dapui_config = function() dapui.open() end
        dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
        dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

        -- 2. ATALHOS (Keymaps) --
        vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Breakpoint" })

        vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Start/Continue" })
        vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug: Step Into" })
        vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Debug: Step Over" })
        vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Debug: Step Out" })
    end,
}
