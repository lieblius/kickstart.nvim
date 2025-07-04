--return {
--  "LintaoAmons/bookmarks.nvim", -- We'll use this as a dependency
--  dependencies = {
--    {"kkharji/sqlite.lua"},
--    {"nvim-telescope/telescope.nvim"},
--  },
--  config = function()
--    -- Create the mark_modes module
--    local mark_modes = {}
--
--    -- Current active mode (default to 'A')
--    mark_modes.current_mode = 'A'
--
--    -- Storage for our marks - a table of tables
--    -- Format: marks[mode][mark] = { filename, line, col }
--    mark_modes.marks = {}
--
--    -- Initialize all 26 modes (A-Z)
--    for i = 65, 90 do -- ASCII codes for A-Z
--      local mode = string.char(i)
--      mark_modes.marks[mode] = {}
--    end
--
--    -- Function to set the current mode
--    mark_modes.set_mode = function(mode)
--      if mode:match("^%u$") then -- Ensure it's an uppercase letter
--        mark_modes.current_mode = mode
--        vim.notify("Mark mode: " .. mode, vim.log.levels.INFO)
--      else
--        vim.notify("Invalid mode: " .. mode .. ". Use uppercase letters A-Z.", vim.log.levels.ERROR)
--      end
--    end
--
--    -- Function to set a mark in the current mode
--    mark_modes.set_mark = function(mark)
--      if not mark:match("^%l$") then -- Ensure it's a lowercase letter
--        vim.notify("Invalid mark: " .. mark .. ". Use lowercase letters a-z.", vim.log.levels.ERROR)
--        return
--      end
--
--      local mode = mark_modes.current_mode
--      local buf = vim.api.nvim_get_current_buf()
--      local filename = vim.api.nvim_buf_get_name(buf)
--      local pos = vim.api.nvim_win_get_cursor(0)
--
--      mark_modes.marks[mode][mark] = {
--        filename = filename,
--        line = pos[1],
--        col = pos[2],
--      }
--
--      vim.notify("Set mark '" .. mark .. "' in mode " .. mode, vim.log.levels.INFO)
--    end
--
--    -- Function to go to a mark in the current mode
--    mark_modes.goto_mark = function(mark)
--      if not mark:match("^%l$") then -- Ensure it's a lowercase letter
--        vim.notify("Invalid mark: " .. mark .. ". Use lowercase letters a-z.", vim.log.levels.ERROR)
--        return
--      end
--
--      local mode = mark_modes.current_mode
--      local mark_data = mark_modes.marks[mode][mark]
--
--      if not mark_data then
--        vim.notify("Mark '" .. mark .. "' not set in mode " .. mode, vim.log.levels.WARN)
--        return
--      end
--
--      -- If the mark is in a different file, open it
--      if mark_data.filename ~= vim.api.nvim_buf_get_name(0) then
--        vim.cmd("edit " .. vim.fn.fnameescape(mark_data.filename))
--      end
--
--      -- Go to the position
--      vim.api.nvim_win_set_cursor(0, {mark_data.line, mark_data.col})
--    end
--
--    -- Function to delete a mark in the current mode
--    mark_modes.delete_mark = function(mark)
--      if not mark:match("^%l$") then -- Ensure it's a lowercase letter
--        vim.notify("Invalid mark: " .. mark .. ". Use lowercase letters a-z.", vim.log.levels.ERROR)
--        return
--      end
--
--      local mode = mark_modes.current_mode
--      if mark_modes.marks[mode][mark] then
--        mark_modes.marks[mode][mark] = nil
--        vim.notify("Deleted mark '" .. mark .. "' in mode " .. mode, vim.log.levels.INFO)
--      else
--        vim.notify("Mark '" .. mark .. "' not set in mode " .. mode, vim.log.levels.WARN)
--      end
--    end
--
--    -- Function to list all marks in current mode
--    mark_modes.list_marks = function()
--      local mode = mark_modes.current_mode
--      local marks_list = {}
--
--      for mark, data in pairs(mark_modes.marks[mode]) do
--        if data then
--          table.insert(marks_list, {
--            mark = mark,
--            filename = vim.fn.fnamemodify(data.filename, ":~:."),
--            line = data.line,
--            col = data.col,
--          })
--        end
--      end
--
--      if #marks_list == 0 then
--        vim.notify("No marks set in mode " .. mode, vim.log.levels.INFO)
--        return
--      end
--
--      -- Sort by mark name
--      table.sort(marks_list, function(a, b) return a.mark < b.mark end)
--
--      -- Build display string
--      local display = "Marks in mode " .. mode .. ":\n"
--      for _, item in ipairs(marks_list) do
--        display = display .. string.format("  %s: %s:%d:%d\n",
--          item.mark, item.filename, item.line, item.col)
--      end
--
--      vim.notify(display, vim.log.levels.INFO)
--    end
--
--    -- Function to show the current mode
--    mark_modes.show_mode = function()
--      vim.notify("Current mark mode: " .. mark_modes.current_mode, vim.log.levels.INFO)
--    end
--
--    -- Function to handle all mark commands
--    mark_modes.command = function(arg)
--      if #arg == 0 then
--        -- Just 'm' without arguments shows current mode
--        mark_modes.show_mode()
--      elseif #arg == 1 then
--        local ch = arg:sub(1,1)
--        if ch:match("^%u$") then
--          -- Uppercase letter sets the mode
--          mark_modes.set_mode(ch)
--        elseif ch:match("^%l$") then
--          -- Lowercase letter sets a mark in current mode
--          mark_modes.set_mark(ch)
--        else
--          vim.notify("Invalid mark or mode: " .. ch, vim.log.levels.ERROR)
--        end
--      else
--        vim.notify("Invalid mark command", vim.log.levels.ERROR)
--      end
--    end
--
--    -- Save marks to a JSON file
--    mark_modes.save_marks = function()
--      local data_dir = vim.fn.stdpath('data')
--      local marks_file = data_dir .. '/mark_modes.json'
--
--      local file = io.open(marks_file, 'w')
--      if file then
--        file:write(vim.fn.json_encode({
--          current_mode = mark_modes.current_mode,
--          marks = mark_modes.marks
--        }))
--        file:close()
--        vim.notify("Marks saved", vim.log.levels.INFO)
--      else
--        vim.notify("Failed to save marks", vim.log.levels.ERROR)
--      end
--    end
--
--    -- Load marks from JSON file
--    mark_modes.load_marks = function()
--      local data_dir = vim.fn.stdpath('data')
--      local marks_file = data_dir .. '/mark_modes.json'
--
--      local file = io.open(marks_file, 'r')
--      if file then
--        local content = file:read('*all')
--        file:close()
--
--        if content and content ~= "" then
--          local data = vim.fn.json_decode(content)
--          if data and data.marks and data.current_mode then
--            mark_modes.current_mode = data.current_mode
--            mark_modes.marks = data.marks
--            vim.notify("Marks loaded", vim.log.levels.INFO)
--          else
--            vim.notify("Invalid marks data", vim.log.levels.WARN)
--          end
--        end
--      end
--    end
--
--    -- Set up commands and mappings
--
--    -- Command to use our custom mark system
--    vim.api.nvim_create_user_command('MarkMode', function(opts)
--      mark_modes.command(opts.args)
--    end, { nargs = '?' })
--
--    -- Command to go to a mark
--    vim.api.nvim_create_user_command('MarkGoto', function(opts)
--      mark_modes.goto_mark(opts.args)
--    end, { nargs = 1 })
--
--    -- Command to delete a mark
--    vim.api.nvim_create_user_command('MarkDelete', function(opts)
--      mark_modes.delete_mark(opts.args)
--    end, { nargs = 1 })
--
--    -- Command to list all marks in current mode
--    vim.api.nvim_create_user_command('MarkList', function()
--      mark_modes.list_marks()
--    end, {})
--
--    -- Command to save marks
--    vim.api.nvim_create_user_command('MarkSave', function()
--      mark_modes.save_marks()
--    end, {})
--
--    -- Command to load marks
--    vim.api.nvim_create_user_command('MarkLoad', function()
--      mark_modes.load_marks()
--    end, {})
--
--    -- Set up keymaps
--
--    -- Override the standard 'm' mapping for marks
--    vim.keymap.set('n', 'm', ':<C-u>MarkMode ', { silent = false, desc = "Set mark mode or mark" })
--
--    -- Add the backtick mapping to go to marks
--    vim.keymap.set('n', '`', function()
--      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(
--        ':MarkGoto ', true, false, true), 'n', false)
--    end, { desc = "Go to mark" })
--
--    -- Add the single quote mapping to go to marks (line only)
--    vim.keymap.set('n', "'", function()
--      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(
--        ':MarkGoto ', true, false, true), 'n', false)
--    end, { desc = "Go to mark (line only)" })
--
--    -- Add the 'dm' mapping to delete marks
--    vim.keymap.set('n', 'dm', function()
--      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(
--        ':MarkDelete ', true, false, true), 'n', false)
--    end, { desc = "Delete mark" })
--
--    -- List marks with 'm;'
--    vim.keymap.set('n', 'm;', ':MarkList<CR>', { silent = true, desc = "List marks in current mode" })
--
--    -- Save marks on exiting Vim
--    vim.api.nvim_create_autocmd("VimLeave", {
--      callback = function()
--        mark_modes.save_marks()
--      end,
--    })
--
--    -- Load marks on startup
--    vim.api.nvim_create_autocmd("VimEnter", {
--      callback = function()
--        mark_modes.load_marks()
--      end,
--    })
--
--    -- Return the module
--    _G.mark_modes = mark_modes
--
--    -- Initial notification
--    vim.defer_fn(function()
--      vim.notify("Mark modes plugin loaded. Current mode: " .. mark_modes.current_mode, vim.log.levels.INFO)
--    end, 1000)
--  end,
--}

