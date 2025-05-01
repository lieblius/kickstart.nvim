return {
  {
    'ruifm/gitlinker.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('gitlinker').setup {
        opts = {
          mappings = '<leader>gy',
        },
      }
    end,
  },
  {
    'kawre/leetcode.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
    },
    opts = {
      lang = 'python3',
    },
  },
  {
    'yetone/avante.nvim',
    enabled = true,
    event = 'VeryLazy',
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      -- add any opts here
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = 'make',
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
      'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
      'zbirenbaum/copilot.lua', -- for providers='copilot'
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante', 'copilot-chat' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  },
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'VeryLazy',
    config = true,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    enabled = false,
    event = 'VeryLazy',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
      { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
    },
    build = 'make tiktoken', -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
      highlight_headers = false,
      separator = '---',
      error_header = '> [!ERROR] Error',
    },
    -- See Commands section for default commands if you want to lazy load on them
    keys = {
      {
        '<leader>ccq',
        function()
          local input = vim.fn.input 'Quick Chat: '
          if input ~= '' then
            require('CopilotChat').ask(input, { selection = require('CopilotChat.select').buffer })
          end
        end,
        desc = 'CopilotChat - Quick chat',
      },
      {
        '<leader>ccp',
        function()
          local actions = require 'CopilotChat.actions'
          require('CopilotChat.integrations.telescope').pick(actions.prompt_actions())
        end,
        desc = 'CopilotChat - Prompt actions',
      },
      { '<leader>cce', '<cmd>CopilotChatExplain<cr>', desc = 'CopilotChat - Explain code' },
      { '<leader>cct', '<cmd>CopilotChatTests<cr>', desc = 'CopilotChat - Generate tests' },
      {
        '<leader>ccc',
        ':CopilotChatToggle<CR>',
        mode = { 'n', 'x' },
        desc = 'CopilotChat',
      },
      {
        '<leader>ccf',
        '<cmd>CopilotChatFix<cr>',
        desc = 'CopilotChat Fix',
      },
      { '<leader>ccd', '<cmd>CopilotChatDebugInfo<cr>', desc = 'CopilotChat - Show debug information' },
      { '<leader>ccm', '<cmd>CopilotChatModels<cr>', desc = 'CopilotChat - View and select models' },
      { '<leader>cca', '<cmd>CopilotChatAgents<cr>', desc = 'CopilotChat - View and select agents' },
    },
  },
}
