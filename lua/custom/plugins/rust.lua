-- Rust language support (adapted from LazyVim extras/lang/rust)
-- Set vim.g.rust_diagnostics = "bacon-ls" to use bacon-ls instead of rust-analyzer for diagnostics

local diagnostics = vim.g.rust_diagnostics or "rust-analyzer"

return {
  -- Treesitter parsers for Rust
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "rust", "ron" })
    end,
  },

  -- Rustfmt formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        rust = { "rustfmt" },
      },
    },
  },

  -- Mason: ensure codelldb and bacon are installed
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "codelldb" })
      if diagnostics == "bacon-ls" then
        vim.list_extend(opts.ensure_installed, { "bacon" })
      end
    end,
  },

  -- Cargo.toml dependency management
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        crates = {
          enabled = true,
        },
      },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },

  -- Rust language server and tooling
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
    opts = {
      server = {
        load_vscode_settings = false, -- Don't read .vscode/settings.json (causes path duplication)
        on_attach = function(_, bufnr)
          -- Rust-specific keymaps
          vim.keymap.set("n", "<leader>cR", function()
            vim.cmd.RustLsp("codeAction")
          end, { desc = "Code Action", buffer = bufnr })
          vim.keymap.set("n", "<leader>dr", function()
            vim.cmd.RustLsp("debuggables")
          end, { desc = "Rust Debuggables", buffer = bufnr })
        end,
        default_settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            checkOnSave = diagnostics == "rust-analyzer",
            diagnostics = {
              enable = diagnostics == "rust-analyzer",
            },
            procMacro = {
              enable = true,
            },
            files = {
              exclude = {
                ".direnv",
                ".git",
                ".jj",
                ".github",
                ".gitlab",
                "bin",
                "node_modules",
                "target",
                "venv",
                ".venv",
              },
              watcher = "client",
            },
          },
        },
      },
      dap = {},
    },
    config = function(_, opts)
      -- Configure DAP adapter if Mason is available
      local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
      if mason_registry_ok and mason_registry.is_installed("codelldb") then
        local codelldb = vim.fn.exepath("codelldb")
        local uname = vim.loop.os_uname()
        local ext = uname.sysname == "Linux" and ".so" or ".dylib"
        local mason_path = vim.fn.stdpath("data") .. "/mason"
        local lib_path = mason_path .. "/packages/codelldb/extension/lldb/lib/liblldb" .. ext

        opts.dap = {
          adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, lib_path),
        }
      end

      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})

      -- Warn if rust-analyzer is not installed
      if vim.fn.executable("rust-analyzer") == 0 then
        vim.notify(
          "rust-analyzer not found in PATH, please install it.\nRun: rustup component add rust-analyzer",
          vim.log.levels.ERROR,
          { title = "rustaceanvim" }
        )
      end
    end,
  },

  -- Add bacon-ls support (optional alternative for faster diagnostics)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bacon_ls = {
          enabled = diagnostics == "bacon-ls",
        },
      },
    },
  },

  -- Neotest Rust adapter (optional, for test runner UI)
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = {
      adapters = {
        ["rustaceanvim.neotest"] = {},
      },
    },
  },
}
