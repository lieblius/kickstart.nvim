return {
  "chentoast/marks.nvim",
  event = "VeryLazy",
  config = function()
    require("marks").setup({
      -- Show marks in the sign column
      default_mappings = true,
      -- Show builtin marks
      builtin_marks = { ".", "<", ">", "^" },
      -- Allow cycling through marks
      cyclic = true,
      -- How often to update signs (lower values may affect performance)
      refresh_interval = 250,
      -- Sign priorities for different mark types
      sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
      -- Customize bookmark appearance
      bookmark_0 = {
        sign = "⚑",
        virt_text = "",
        annotate = false,
      },
      -- Custom mappings
      mappings = {
        set_next = "m,",
        toggle = "m;",
        next = "m]",
        prev = "m[",
        preview = "m:",
        set_bookmark0 = "m0",
        -- Add other mappings as needed
      }
    })
  end,
}