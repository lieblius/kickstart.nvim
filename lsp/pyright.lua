-- Pyright: intellisense only (diagnostics handled by ruff and mypy)
return {
  handlers = {
    ["textDocument/publishDiagnostics"] = function() end,
  },
  before_init = function(_, config)
    local venv_python = config.root_dir .. "/.venv/bin/python"
    if vim.fn.executable(venv_python) == 1 then
      config.settings = config.settings or {}
      config.settings.python = config.settings.python or {}
      config.settings.python.pythonPath = venv_python
    end
  end,
  settings = {
    pyright = {
      disableOrganizeImports = true,
    },
    python = {
      pythonPath = ".venv/bin/python",
    },
  },
}
