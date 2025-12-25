-- Python development setup
-- LSP: pyright (intellisense) + ruff (linting)
-- Type checking: mypy with Django support

local function get_mypy_cmd()
  local venv = vim.fn.getcwd() .. "/.venv/bin/mypy"
  if vim.fn.executable(venv) == 1 then
    return venv
  end
  return "mypy"
end

local function get_gdal_library_path()
  local handle = io.popen("ls /opt/homebrew/lib/libgdal.dylib 2>/dev/null")
  if handle then
    local result = handle:read("*a"):gsub("%s+", "")
    handle:close()
    if result ~= "" then
      return result
    end
  end
  return nil
end

local function get_mypy_env()
  local env = {
    DATABASE_URL = "sqlite:///dev.db",
    DJANGO_SECRET_KEY = "nvim-dev-key",
    ENVIRONMENT = "local",
  }
  local gdal_path = get_gdal_library_path()
  if gdal_path then
    env.GDAL_LIBRARY_PATH = gdal_path
  end
  return env
end

local function run_mypy()
  local cmd = get_mypy_cmd()
  if vim.fn.executable(cmd) == 0 then
    vim.notify("mypy not found: " .. cmd, vim.log.levels.ERROR)
    return
  end

  local file = vim.fn.expand("%:p")
  vim.notify("Running mypy...", vim.log.levels.INFO)

  vim.fn.jobstart({ cmd, file }, {
    cwd = vim.fn.getcwd(),
    env = get_mypy_env(),
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if not data or #data == 0 or (data[1] == "" and #data == 1) then
        return
      end
      local diagnostics = {}
      local bufnr = vim.fn.bufnr(file)
      local current = nil
      for _, line in ipairs(data) do
        local f, lnum, severity, msg = line:match("([^:]+):(%d+): (%a+): (.+)")
        if f and lnum and severity and msg then
          if current then
            table.insert(diagnostics, current)
          end
          current = {
            bufnr = bufnr,
            lnum = tonumber(lnum) - 1,
            col = 0,
            severity = severity == "error" and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
            message = msg,
            source = "mypy",
          }
        elseif current and line ~= "" and not line:match("^%s") and not line:match("^Found %d+") then
          current.message = current.message .. " " .. line
        end
      end
      if current then
        table.insert(diagnostics, current)
      end
      vim.schedule(function()
        local ns = vim.api.nvim_create_namespace("mypy")
        vim.diagnostic.set(ns, bufnr, diagnostics)
        if #diagnostics > 0 then
          vim.notify("mypy: " .. #diagnostics .. " issue(s)", vim.log.levels.WARN)
        else
          vim.notify("mypy: no issues", vim.log.levels.INFO)
        end
      end)
    end,
    on_stderr = function(_, data)
      if data and #data > 0 and data[1] ~= "" then
        vim.schedule(function()
          vim.notify("mypy error: " .. table.concat(data, "\n"), vim.log.levels.ERROR)
        end)
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        vim.schedule(function()
          vim.notify("mypy: no issues", vim.log.levels.INFO)
        end)
      end
    end,
  })
end

return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.lsp.enable("pyright")
      vim.lsp.enable("ruff")
      vim.lsp.enable("basedpyright", false)

      -- Use pyright for hover instead of ruff
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("python-ruff-hover-disable", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end
        end,
      })

      vim.keymap.set("n", "<leader>ml", run_mypy, { desc = "[M]ypy [L]int" })
    end,
  },
}
