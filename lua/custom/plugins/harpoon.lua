return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    local harpoon = require 'harpoon'

    -- REQUIRED
    harpoon:setup()

    -- Basic keymaps
    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():append()
    end, { desc = 'Harpoon: Add file' })
    vim.keymap.set('n', '<leader>h', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Harpoon: Toggle menu' })

    -- Navigation
    vim.keymap.set('n', '<leader>1', function()
      harpoon:list():select(1)
    end, { desc = 'Harpoon: File 1' })
    vim.keymap.set('n', '<leader>2', function()
      harpoon:list():select(2)
    end, { desc = 'Harpoon: File 2' })
    vim.keymap.set('n', '<leader>3', function()
      harpoon:list():select(3)
    end, { desc = 'Harpoon: File 3' })
    vim.keymap.set('n', '<leader>4', function()
      harpoon:list():select(4)
    end, { desc = 'Harpoon: File 4' })

    -- Navigate prev/next
    vim.keymap.set('n', '<leader>p', function()
      harpoon:list():prev()
    end, { desc = 'Harpoon: Prev file' })
    vim.keymap.set('n', '<leader>n', function()
      harpoon:list():next()
    end, { desc = 'Harpoon: Next file' })
  end,
}
