return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "VeryLazy",
    config = true,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = false,
    event = "VeryLazy",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
      highlight_headers = false,
      separator = "---",
      error_header = "> [!ERROR] Error",
    },
    -- See Commands section for default commands if you want to lazy load on them
    keys = {
      {
        "<leader>ccq",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
          end
        end,
        desc = "CopilotChat - Quick chat",
      },
      {
        "<leader>ccp",
        function()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
        end,
        desc = "CopilotChat - Prompt actions",
      },
      { "<leader>cce", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
      { "<leader>cct", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
      {
        "<leader>ccc",
        ":CopilotChatToggle<CR>",
        mode = { "n", "x" },
        desc = "CopilotChat",
      },
      {
        "<leader>ccf",
        "<cmd>CopilotChatFix<cr>",
        desc = "CopilotChat Fix",
      },
      { "<leader>ccd", "<cmd>CopilotChatDebugInfo<cr>", desc = "CopilotChat - Show debug information" },
      { "<leader>ccm", "<cmd>CopilotChatModels<cr>", desc = "CopilotChat - View and select models" },
      { "<leader>cca", "<cmd>CopilotChatAgents<cr>", desc = "CopilotChat - View and select agents" },
    },
  },
}
