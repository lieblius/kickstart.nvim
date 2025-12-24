# Research: Best Rust Development Setup for Neovim (2025)

**Date**: 2025-12-11 22:16:37 EST
**Branch**: master
**Commit**: 4a8759d

## Research Question

What is the community consensus on the absolute best tooling and setup for using Neovim as the main editing experience for writing Rust code in 2025?

## Summary

The Rust community has standardized on **rustaceanvim** as the primary plugin for Rust development in Neovim as of 2025. This plugin replaced the now-archived rust-tools.nvim (archived January 2024) and provides deep integration with rust-analyzer, cargo commands, debugging, and test running. The recommended stack includes:

- **rustaceanvim** - Main Rust plugin with rust-analyzer integration
- **crates.nvim** - Cargo.toml dependency management
- **nvim-dap + codelldb** - Debugging support
- **rustfmt** (via conform.nvim) - Code formatting
- **nvim-cmp** - Completion (already configured in kickstart)
- **nvim-treesitter** - Syntax highlighting (already configured in kickstart)

This setup provides a complete IDE-like experience for Rust development with features like go-to-definition, code completion, inline type hints, debugging, test running, macro expansion, and dependency management.

## Detailed Findings

### Core Plugin: rustaceanvim

**What it is**: A heavily modified fork of rust-tools.nvim, actively maintained and designed specifically for rust-analyzer integration.

**Why it's the standard**:
- rust-tools.nvim was officially archived on January 3, 2024 with recommendation to switch to rustaceanvim
- Requires rust-analyzer >= 2025-01-20 (cutting edge compatibility)
- No longer depends on nvim-lspconfig (simplified architecture)
- Automatically configures rust-analyzer without manual setup
- Built-in inlay hints work with Neovim 0.10+ native support

**Key features**:
- Commands: `:RustLsp runnables`, `:RustLsp debuggables`, `:RustLsp expandMacro`, `:RustLsp explainError`, `:RustLsp openCargo`, `:RustLsp crateGraph`
- Automatic rust-analyzer configuration
- Integrated debugging via nvim-dap
- Test runner with individual test execution
- Cargo integration

**Installation**:
```lua
{
  'mrcjkb/rustaceanvim',
  version = '^5',
  lazy = false,
  ft = { 'rust' },
}
```

**Configuration approach**: Uses `vim.g.rustaceanvim` table instead of legacy `setup()` pattern.

### Dependency Management: crates.nvim

**What it is**: A Neovim plugin specifically for managing crates.io dependencies in Cargo.toml files.

**Features**:
- Inline display of available crate versions
- Update dependencies directly from editor
- Show crate documentation
- Integration with nvim-cmp for completion
- LSP-like features for Cargo.toml

**Installation**:
```lua
{
  'saecki/crates.nvim',
  event = { "BufRead Cargo.toml" },
  config = function()
    require('crates').setup({
      completion = {
        cmp = { enabled = true },
      },
    })
  end,
}
```

**Best practice**: Lazy load on Cargo.toml files only for performance.

### Debugging: nvim-dap + codelldb

**What they are**:
- nvim-dap: Debug Adapter Protocol client for Neovim
- codelldb: LLDB-based debug adapter specifically for Rust (and C/C++)

**Why codelldb**: Community consensus over alternatives like rust-gdb. Can be installed via Mason with `:MasonInstall codelldb`.

**Enhanced UI plugins**:
- **nvim-dap-ui**: Provides IDE-like debugging interface with variables, stack traces, breakpoints
- **nvim-dap-virtual-text**: Shows variable values inline as virtual text

**Integration with rustaceanvim**: rustaceanvim automatically configures DAP to debug individual tests, which is highly valued by the community.

**Key debugging commands**:
- Toggle breakpoint
- Continue execution
- Step into/over/out
- View variables and call stack

### Formatting: rustfmt

**What it is**: Official Rust formatter, part of the Rust toolchain.

**Installation**: `rustup component add rustfmt`

**Integration with conform.nvim**:
```lua
formatters_by_ft = {
  rust = { "rustfmt" },
}
```

**Best practice**: Use `lsp_format = "fallback"` to fall back to rust-analyzer's formatting if rustfmt isn't available.

### LSP Configuration: rust-analyzer

**What it is**: Official Rust Language Server providing IDE features.

**Key features provided**:
- Code completion
- Go to definition/references/implementation
- Refactoring support
- Code actions (auto-imports, trait implementations, etc.)
- Inline type hints
- Error diagnostics and explanations
- Symbol search

**Installation**: Via Mason with `:MasonInstall rust-analyzer`

**Configuration**: Automatically handled by rustaceanvim (no manual lspconfig setup needed).

**2025 update**: No longer need to set `rust-analyzer.check.features` separately - it defaults to `rust-analyzer.cargo.features`.

### Completion: nvim-cmp

**Status**: Already configured in kickstart.nvim setup with cmp-nvim-lsp.

**Integration**: Works seamlessly with rust-analyzer via rustaceanvim.

**Additional source**: crates.nvim provides completion source for Cargo.toml files.

### Syntax Highlighting: nvim-treesitter

**Status**: Already configured in kickstart.nvim setup.

**Required**: Rust parser must be installed with `:TSInstall rust`.

**Features**: Provides syntax highlighting, indentation, and code folding.

## Architecture Documentation

### Modern rustaceanvim Architecture

Unlike legacy rust-tools.nvim which required:
- Calling `require('rust-tools').setup {}`
- Manual nvim-lspconfig integration
- Separate inlay hints configuration

rustaceanvim uses:
- Configuration via `vim.g.rustaceanvim` global variable
- Automatic initialization before Neovim starts
- No nvim-lspconfig dependency
- Built-in Neovim 0.10+ inlay hints support
- Namespaced commands (`:RustLsp` prefix)

### Command Migration from rust-tools

Old rust-tools commands → New rustaceanvim commands:
- `:RustRunnables` → `:RustLsp runnables`
- `:RustDebuggables` → `:RustLsp debuggables`
- `:RustExpandMacro` → `:RustLsp expandMacro`

### Recommended Plugin Manager Setup

With lazy.nvim (current setup):
- Set `lazy = false` for rustaceanvim (needs to load early)
- Use `event = { "BufRead Cargo.toml" }` for crates.nvim
- Use `dependencies` for DAP UI plugins

## Installation Commands

Via Mason package manager:
```
:MasonInstall rust-analyzer codelldb
```

Via rustup (for rustfmt):
```
rustup component add rustfmt
```

## Code Examples

### Complete rustaceanvim Setup

```lua
{
  'mrcjkb/rustaceanvim',
  version = '^5',
  lazy = false,
  ft = { 'rust' },
  config = function()
    vim.g.rustaceanvim = {
      server = {
        on_attach = function(client, bufnr)
          -- Enable inlay hints
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end,
      },
    }
  end,
}
```

### Complete crates.nvim Setup

```lua
{
  'saecki/crates.nvim',
  event = { "BufRead Cargo.toml" },
  config = function()
    require('crates').setup({
      completion = {
        cmp = { enabled = true },
      },
    })

    -- Add crates source to nvim-cmp
    require('cmp').setup.buffer({
      sources = { { name = "crates" } }
    })
  end,
}
```

### Complete DAP Setup

```lua
{
  'rcarriga/nvim-dap-ui',
  dependencies = {
    'mfussenegger/nvim-dap',
    'nvim-neotest/nvim-nio'
  },
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    dapui.setup()

    -- Auto-open/close DAP UI
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    -- Keymaps
    vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debug: Continue' })
    vim.keymap.set('n', '<leader>dt', dapui.toggle, { desc = 'Debug: Toggle UI' })
  end,
}
```

### rustfmt Integration with conform.nvim

```lua
{
  "stevearc/conform.nvim",
  opts = {
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
    formatters_by_ft = {
      rust = { "rustfmt" },
    },
  },
}
```

## Why This is the 2025 Community Consensus

1. **Official archival of rust-tools**: On January 3, 2024, rust-tools.nvim maintainer archived the project and recommended rustaceanvim
2. **LazyVim adoption**: LazyVim's Rust extras now use rustaceanvim (discussed in LazyVim issues #1976 and #2113)
3. **Active maintenance**: rustaceanvim requires rust-analyzer >= 2025-01-20, showing it's actively maintained for latest versions
4. **Simplified architecture**: Removal of nvim-lspconfig dependency and setup() pattern makes it easier to use
5. **Built-in Neovim 0.10 features**: Uses native inlay hints rather than custom implementation
6. **codelldb preference**: Community guides consistently recommend codelldb over rust-gdb for debugging
7. **crates.nvim ubiquity**: Appears in all major Rust setup guides as the standard for Cargo.toml management

## Current Kickstart.nvim Integration Points

Your existing kickstart.nvim setup already includes:

✅ **nvim-lspconfig** - Used for other languages; rustaceanvim doesn't need it
✅ **Mason** - Already set up for installing LSPs and tools
✅ **nvim-cmp with cmp-nvim-lsp** - Perfect for Rust completion
✅ **nvim-treesitter** - Just needs `:TSInstall rust`
✅ **conform.nvim** - Just needs rust = { "rustfmt" } added
✅ **telescope.nvim** - Works with rustaceanvim for symbol search

Needs addition:
❌ **rustaceanvim** - Main Rust plugin
❌ **crates.nvim** - Cargo.toml management
❌ **nvim-dap + codelldb** - Debugging support
❌ **nvim-dap-ui** - Debug UI
❌ **nvim-dap-virtual-text** - Inline variable display during debugging

## External References

### Primary Sources

- [rustaceanvim GitHub Repository](https://github.com/mrcjkb/rustaceanvim) - Main plugin documentation
- [Migration from rust-tools.nvim Discussion](https://github.com/mrcjkb/rustaceanvim/discussions/122) - Official migration guide
- [LazyVim Rust Extras](https://www.lazyvim.org/extras/lang/rust) - Reference implementation
- [LazyVim Issue #2113](https://github.com/LazyVim/LazyVim/issues/2113) - rust-tools deprecation discussion
- [crates.nvim GitHub](https://github.com/Saecki/crates.nvim) - Dependency management plugin

### Comprehensive Guides

- [Rust and Neovim - A Thorough Guide and Walkthrough](https://rsdlt.github.io/posts/rust-nvim-ide-guide-walkthrough-development-debug/) - Complete 2025 setup guide
- [Debugging Rust with NeoVim](https://romangeber.com/blog/tech/nvim_rust_debugger) - DAP setup guide
- [Minimal Setup: Rust Debugger in Neovim](https://kurotych.com/posts/rust_neovim_debugger/) - Focused debugging tutorial
- [Neovim Rust debugging - more zeros than ones](https://morezerosthanones.com/posts/neovim_rust_debugging/) - Alternative debugging setup

### Tools and Specifications

- [nvim-dap GitHub](https://github.com/mfussenegger/nvim-dap) - Debug Adapter Protocol client
- [conform.nvim GitHub](https://github.com/stevearc/conform.nvim) - Formatter plugin
- [Best Practices for Rust-Analyzer Config](https://blog.kodezi.com/best-practices-for-rust-analyzer-config-expert-tips-for-developers/) - rust-analyzer optimization tips
- [Cargo Info in Neovim](https://cj.rs/blog/cargo-info-in-neovim/) - crates.nvim features (October 2024)

## Related Research

This is the first research document in this repository.

## Open Questions

None - this research is complete and actionable. The setup path is clear and well-documented by the community.
