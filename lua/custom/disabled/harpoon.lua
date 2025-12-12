return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "n--vim.lua/plenary.nvim",
    "n--vim.telescope/telescope.nvim",
  },
  config = function()
    local harpoon = require("harpoon")

    -- REQUIRED
    harpoon:setup()

    -- Helper functions

    local add_file = function()
      harpoon:list():append()
    end
    local toggle_menu = function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end
    local goto_file = function(i)
      return function()
        harpoon:list():select(i)
      end
    end
    local goto_prev = function()
      harpoon:list():prev()
    end
    local goto_next = function()
      harpoon:list():next()
    end

    local conf = require("telescope.config").values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require("telescope.pickers")
        .new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table({
            results = file_paths,
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        })
        :find()
    end

    local open_telescope = function()
      toggle_telescope(harpoon:list())
    end

    -- Basic keymaps

    vim.keymap.set("n", "<leader>ma", add_file, { desc = "Harpoon: Add file" })
    vim.keymap.set("n", "<leader>mh", toggle_menu, { desc = "Harpoon: Toggle menu" })

    -- Navigation

    vim.keymap.set("n", "<leader>1", goto_file(1), { desc = "Harpoon: File 1" })
    vim.keymap.set("n", "<leader>2", goto_file(2), { desc = "Harpoon: File 2" })
    vim.keymap.set("n", "<leader>3", goto_file(3), { desc = "Harpoon: File 3" })
    vim.keymap.set("n", "<leader>4", goto_file(4), { desc = "Harpoon: File 4" })

    -- Navigate prev/next

    vim.keymap.set("n", "<leader>mp", goto_prev, { desc = "Harpoon: Prev file" })
    vim.keymap.set("n", "<leader>mn", goto_next, { desc = "Harpoon: Next file" })

    -- Telescope integration

    vim.keymap.set("n", "<leader>mt", open_telescope, { desc = "Harpoon: Open in Telescope" })
  end,
}
