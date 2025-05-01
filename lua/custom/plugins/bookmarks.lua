return {
  "LintaoAmons/bookmarks.nvim",
  dependencies = {
    {"kkharji/sqlite.lua"},
    {"nvim-telescope/telescope.nvim"},
    {"stevearc/dressing.nvim"} -- optional: better UI
  },
  config = function()
    local opts = {
      -- Default configurations
      mappings = {
        -- Set the treeview keymap as needed
        keymap = {
          quit = { "q", "<ESC>" },
          refresh = "R",
          create_list = "a",
          level_up = "u",
          set_root = ".",
          set_active = "m",
          toggle = "o",
          move_up = "<localleader>k",
          move_down = "<localleader>j",
          delete = "D",
          rename = "r",
          goto = "g",
          cut = "x",
          copy = "c",
          paste = "p",
          show_info = "i",
          reverse = "t",
        }
      }
    }
    
    require("bookmarks").setup(opts)
    
    -- Set up custom keymaps
    vim.keymap.set({ "n", "v" }, "<leader>bm", "<cmd>BookmarksMark<cr>", { desc = "Bookmark current line" })
    vim.keymap.set({ "n", "v" }, "<leader>bo", "<cmd>BookmarksGoto<cr>", { desc = "Open bookmarks" })
    vim.keymap.set({ "n", "v" }, "<leader>bt", "<cmd>BookmarksTree<cr>", { desc = "Open bookmarks tree view" })
    vim.keymap.set({ "n", "v" }, "<leader>bi", "<cmd>BookmarksInfo<cr>", { desc = "Show bookmarks info" })
    vim.keymap.set({ "n", "v" }, "<leader>ba", "<cmd>BookmarksCommands<cr>", { desc = "List bookmark commands" })
    
    -- Navigation shortcuts
    vim.keymap.set({ "n", "v" }, "<leader>bn", "<cmd>BookmarksGotoNext<cr>", { desc = "Go to next bookmark" })
    vim.keymap.set({ "n", "v" }, "<leader>bp", "<cmd>BookmarksGotoPrev<cr>", { desc = "Go to previous bookmark" })
    vim.keymap.set({ "n", "v" }, "<leader>bN", "<cmd>BookmarksGotoNextInList<cr>", { desc = "Go to next bookmark in list" })
    vim.keymap.set({ "n", "v" }, "<leader>bP", "<cmd>BookmarksGotoPrevInList<cr>", { desc = "Go to previous bookmark in list" })
    
    -- Additional commands
    vim.keymap.set({ "n", "v" }, "<leader>bd", "<cmd>BookmarksDesc<cr>", { desc = "Add bookmark description" })
    vim.keymap.set({ "n", "v" }, "<leader>bg", "<cmd>BookmarksGrep<cr>", { desc = "Grep through bookmarked files" })
  end,
}
