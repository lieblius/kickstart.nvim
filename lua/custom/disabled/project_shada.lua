-- Function to find the root of the current Git repository
local function get_project_root()
  -- Find the .git directory walking upwards from the current buffer's directory or CWD
  local current_path = vim.api.nvim_buf_get_name(0) -- Get current buffer path
  local cwd = vim.fn.getcwd()
  local start_dir = (current_path and current_path ~= "") and vim.fn.fnamemodify(current_path, ":h") or cwd

  -- Search upwards for .git directory
  local git_dir = vim.fn.finddir(".git", start_dir .. ";")

  if git_dir ~= "" and vim.fn.isdirectory(git_dir) then
    -- Return the parent directory of .git (the project root)
    return vim.fn.fnamemodify(git_dir, ":h")
  end

  -- Fallback check just based on CWD if buffer path didn't work
  git_dir = vim.fn.finddir(".git", cwd .. ";")
  if git_dir ~= "" and vim.fn.isdirectory(git_dir) then
    return vim.fn.fnamemodify(git_dir, ":h")
  end

  return nil -- Not in a known Git project
end

-- Function to set the shada file path based on project context
local function set_shada_path()
  local data_path = vim.fn.stdpath("data")
  local global_shada_path = data_path .. "/shada/main.shada"
  local project_shada_base_dir = data_path .. "/shada/projects/"

  -- Ensure base shada directories exist
  if vim.fn.isdirectory(data_path .. "/shada") == 0 then
    vim.fn.mkdir(data_path .. "/shada", "p")
  end
  if vim.fn.isdirectory(project_shada_base_dir) == 0 then
    vim.fn.mkdir(project_shada_base_dir, "p")
  end

  local project_root = get_project_root()
  local target_shada_path

  if project_root then
    -- We are inside a Git project
    local project_name = vim.fn.fnamemodify(project_root, ":t") -- Get project directory name
    if project_name == "" or project_name == "/" then -- Handle edge case for root dir name
      project_name = "root_project" -- Or some other placeholder
    end
    target_shada_path = project_shada_base_dir .. project_name .. ".shada"
  else
    -- Not in a project, use the global shada file
    target_shada_path = global_shada_path
  end

  -- Only switch if the target path is different from the currently set path
  if vim.opt.shadafile:get() ~= target_shada_path then
    -- Write current shada state *before* changing the path
    -- Using 'wshada!' forces overwrite. Ensure this behavior is desired.
    vim.cmd("wshada!")
    vim.opt.shadafile = target_shada_path
    -- Notify the user about the change (useful for debugging)
    vim.notify("Shada set to: " .. target_shada_path, vim.log.levels.INFO)
    -- Optional: You could read the new shada state here if needed, but often
    -- Neovim handles this implicitly when the option changes.
    -- vim.cmd('rshada!')
  end
end

-- Autocommand Group for Shada Management
local shada_augroup = vim.api.nvim_create_augroup("ProjectShadaManagement", { clear = true })

-- Run on entering Neovim to set the initial path correctly
vim.api.nvim_create_autocmd("VimEnter", {
  group = shada_augroup,
  pattern = "*",
  callback = set_shada_path,
})

-- Run whenever the current directory changes
vim.api.nvim_create_autocmd("DirChanged", {
  group = shada_augroup,
  pattern = "*",
  callback = set_shada_path,
})

-- Also consider running when switching buffers, as DirChanged might not always fire
-- when jumping between files in different projects opened in the same session.
vim.api.nvim_create_autocmd("BufEnter", {
  group = shada_augroup,
  pattern = "*",
  callback = set_shada_path,
})

return {
  -- This is just a "plugin" for organization - it loads the code above
  -- and doesn't depend on any external plugins
}
