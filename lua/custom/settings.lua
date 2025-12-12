-- Custom settings and keymaps
-- This file contains personal preferences that override kickstart defaults

-- Enable Nerd Font icons
vim.g.have_nerd_font = true

-- Show relative line numbers (distance from cursor)
vim.opt.relativenumber = true

-- Center screen after half-page jumps
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up and center" })

-- Separate vim and system clipboard for better control
-- Remove auto-sync to system clipboard
vim.opt.clipboard = ""

-- System clipboard operations (explicit with <leader>)
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste from system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>P", [["+P]], { desc = "Paste from system clipboard (before)" })

-- Delete without yanking (black hole register)
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
