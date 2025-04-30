return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
    { '3rd/image.nvim', opts = {} }, -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  lazy = false, -- neo-tree will lazily load itself
  ---@module "neo-tree"
  ---@type neotree.Config?
  opts = {},
  config = function(_, opts)
    require('neo-tree').setup(opts)
    vim.keymap.set('n', '<leader>t', '<cmd>Neotree toggle<CR>', { desc = 'Toggle Neo-tree' })
  end,
}
