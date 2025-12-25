-- Ruff: linting (reads config from pyproject.toml)
return {
  cmd_env = { RUFF_TRACE = "messages" },
  init_options = {
    settings = {
      logLevel = "error",
    },
  },
}
