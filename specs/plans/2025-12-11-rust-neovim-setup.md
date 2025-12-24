# Rust Development Setup Implementation Plan

**Date**: 2025-12-11 22:16:37 EST
**Branch**: master
**Commit**: 4a8759d

## Overview

Implement a complete Rust development environment in Neovim by adding rustaceanvim, crates.nvim, DAP debugging support, and rustfmt integration to the existing kickstart.nvim configuration.

## Current State Analysis

The current Neovim configuration is based on kickstart.nvim and already includes:
- nvim-lspconfig with Mason for LSP management
- nvim-cmp with cmp-nvim-lsp for completion
- nvim-treesitter for syntax highlighting
- conform.nvim for formatting (lua only currently)
- telescope.nvim for fuzzy finding
- Custom plugins in `lua/custom/plugins/`

### Key Discoveries:
- `init.lua:1-1000` - Main kickstart configuration with LSP, completion, and formatting setup
- `lua/custom/plugins/init.lua:1-3` - Empty plugin loader (imports all files in custom/plugins/)
- `conform.nvim` is already configured at `init.lua:753-765` with format_on_save enabled
- Mason is set up at `init.lua:622-700` for installing LSPs and tools
- Plugin structure follows lazy.nvim pattern with separate files in `lua/custom/plugins/`

### Constraints:
- Must follow existing code style (double quotes, 2-space indentation per CLAUDE.md)
- Must integrate with existing Mason, nvim-cmp, and conform.nvim setups
- Plugin files should go in `lua/custom/plugins/` to match existing pattern

## Desired End State

After implementation:
1. Rust files open with full LSP support via rust-analyzer and rustaceanvim
2. Cargo.toml files show inline crate information and allow dependency management
3. Debugging Rust code works with breakpoints, stepping, and variable inspection
4. Rust code auto-formats with rustfmt on save
5. All necessary tools (rust-analyzer, codelldb, rustfmt) are installed
6. Rust syntax highlighting is enabled via treesitter

### Verification:
- Open a Rust file and see LSP features (completion, go-to-definition, diagnostics)
- Run `:RustLsp runnables` and see available targets
- Set breakpoint and debug a Rust program
- Save a Rust file and see it auto-format
- Open Cargo.toml and see crate version information

## What We're NOT Doing

- Not modifying the core kickstart.nvim files (`init.lua` core structure)
- Not adding alternative Rust plugins (rust-tools.nvim, vim-rust, etc.)
- Not configuring rust-analyzer manually (rustaceanvim handles it)
- Not adding project-specific Rust configurations
- Not setting up CI/CD or external build tools

## Implementation Approach

Follow the modular plugin pattern established in the codebase by creating separate plugin files in `lua/custom/plugins/`. Update conform.nvim directly in init.lua since it's already defined there. Install tools via Mason commands after plugins are configured.

## Phase 1: Install rustaceanvim

### Overview
Add the core Rust plugin that provides rust-analyzer integration, cargo commands, and test running capabilities.

### Changes Required:

#### 1. Create rustaceanvim Plugin File
**File**: `lua/custom/plugins/rust.lua`
**Changes**: Create new file with rustaceanvim configuration

```lua
return {
  "mrcjkb/rustaceanvim",
  version = "^5",
  lazy = false,
  ft = { "rust" },
  config = function()
    vim.g.rustaceanvim = {
      server = {
        on_attach = function(client, bufnr)
          -- Enable inlay hints for Rust files
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end,
      },
    }
  end,
}
```

#### 2. Install Rust Treesitter Parser
**Command**: `:TSInstall rust`
**Purpose**: Enable syntax highlighting for Rust files

### Success Criteria:

#### Automated Verification:
- [ ] Plugin file exists: `test -f lua/custom/plugins/rust.lua`
- [ ] Neovim starts without errors: `nvim --headless +quit`
- [ ] Rust parser installed: `nvim --headless +"TSInstall rust" +quit`

#### Manual Verification:
- [ ] Open a Rust file and verify LSP features work (`:LspInfo` shows rust-analyzer attached)
- [ ] Run `:RustLsp runnables` and see available commands
- [ ] Verify inlay hints appear in Rust code
- [ ] Test go-to-definition on a Rust function

**Implementation Note**: After completing this phase and all automated verification passes, test with a sample Rust file before proceeding.

---

## Phase 2: Add Cargo.toml Management

### Overview
Add crates.nvim for managing dependencies in Cargo.toml files with inline version information and completion.

### Changes Required:

#### 1. Create crates.nvim Plugin File
**File**: `lua/custom/plugins/crates.lua`
**Changes**: Create new file with crates.nvim configuration and nvim-cmp integration

```lua
return {
  "saecki/crates.nvim",
  event = { "BufRead Cargo.toml" },
  dependencies = {
    "hrsh7th/nvim-cmp",
  },
  config = function()
    require("crates").setup({
      completion = {
        cmp = {
          enabled = true,
        },
      },
    })

    -- Add crates completion source to nvim-cmp for Cargo.toml files
    local cmp = require("cmp")
    vim.api.nvim_create_autocmd("BufRead", {
      group = vim.api.nvim_create_augroup("CmpSourceCargo", { clear = true }),
      pattern = "Cargo.toml",
      callback = function()
        cmp.setup.buffer({ sources = { { name = "crates" } } })
      end,
    })
  end,
}
```

### Success Criteria:

#### Automated Verification:
- [ ] Plugin file exists: `test -f lua/custom/plugins/crates.lua`
- [ ] Neovim starts without errors: `nvim --headless +quit`

#### Manual Verification:
- [ ] Open a Cargo.toml file and see inline crate version information
- [ ] Type a crate name in dependencies and see completion suggestions
- [ ] Verify crate documentation appears for dependencies

**Implementation Note**: After completing this phase, test with a real Cargo.toml file to verify inline features work.

---

## Phase 3: Configure Debugging Support

### Overview
Add nvim-dap with codelldb adapter and UI plugins for debugging Rust applications with breakpoints and variable inspection.

### Changes Required:

#### 1. Create DAP Plugin File
**File**: `lua/custom/plugins/dap.lua`
**Changes**: Create new file with complete DAP configuration including UI and virtual text

```lua
return {
  -- Core DAP plugin
  {
    "mfussenegger/nvim-dap",
  },

  -- DAP UI for visual debugging interface
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()

      -- Automatically open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Keymaps for debugging
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>dt", dapui.toggle, { desc = "Debug: Toggle UI" })
    end,
  },

  -- Virtual text showing variable values during debugging
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-virtual-text").setup()
    end,
  },
}
```

#### 2. Update which-key Group Definitions
**File**: `init.lua`
**Location**: Around line 372 (in which-key.nvim config)
**Changes**: Add debug group to which-key spec

```lua
opts = {
  -- Define key groupings and mappings
  spec = {
    { "<leader>c", group = "[C]ode" },
    { "<leader>d", group = "[D]ocument" },
    { "<leader>r", group = "[R]ename" },
    { "<leader>s", group = "[S]earch" },
    { "<leader>w", group = "[W]orkspace" },
    { "<leader>d", group = "[D]ebug" },  -- Add this line
  },
},
```

### Success Criteria:

#### Automated Verification:
- [ ] Plugin file exists: `test -f lua/custom/plugins/dap.lua`
- [ ] Neovim starts without errors: `nvim --headless +quit`
- [ ] Keymaps are registered: `nvim --headless +"lua print(vim.inspect(vim.api.nvim_get_keymap('n')))" +quit | grep db`

#### Manual Verification:
- [ ] Open a Rust file and set a breakpoint with `<leader>db`
- [ ] Start debugging with `<leader>dc` and verify DAP UI opens
- [ ] Step through code with `<leader>di` and `<leader>do`
- [ ] Verify variable values appear as virtual text
- [ ] Verify DAP UI shows variables, stack trace, and breakpoints

**Implementation Note**: After automated tests pass, test debugging with a simple Rust program that has multiple functions and variables.

---

## Phase 4: Add rustfmt Formatting

### Overview
Configure conform.nvim to use rustfmt for automatic Rust code formatting on save.

### Changes Required:

#### 1. Update conform.nvim Configuration
**File**: `init.lua`
**Location**: Lines 753-765 (conform.nvim opts)
**Changes**: Add Rust to formatters_by_ft

```lua
{ -- Autoformat
  "stevearc/conform.nvim",
  opts = {
    notify_on_error = false,
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
    formatters_by_ft = {
      lua = { "stylua" },
      rust = { "rustfmt" },  -- Add this line
    },
  },
},
```

### Success Criteria:

#### Automated Verification:
- [ ] Configuration updated in init.lua
- [ ] Neovim starts without errors: `nvim --headless +quit`
- [ ] rustfmt is available: `which rustfmt` (after installation in Phase 5)

#### Manual Verification:
- [ ] Open a poorly formatted Rust file
- [ ] Save the file and verify it auto-formats
- [ ] Verify formatting matches Rust community standards

**Implementation Note**: This depends on rustfmt being installed in Phase 5.

---

## Phase 5: Install Required Tools

### Overview
Install all necessary external tools via Mason and rustup.

### Changes Required:

#### 1. Install rust-analyzer via Mason
**Command**: `:MasonInstall rust-analyzer`
**Purpose**: Rust Language Server for LSP features

#### 2. Install codelldb via Mason
**Command**: `:MasonInstall codelldb`
**Purpose**: Debug adapter for Rust debugging

#### 3. Install rustfmt via rustup
**Command**: `rustup component add rustfmt`
**Purpose**: Rust code formatter
**Note**: Run this in terminal, not Neovim

### Success Criteria:

#### Automated Verification:
- [ ] rust-analyzer installed: `test -d ~/.local/share/nvim/mason/packages/rust-analyzer`
- [ ] codelldb installed: `test -d ~/.local/share/nvim/mason/packages/codelldb`
- [ ] rustfmt available: `rustup component list | grep 'rustfmt.*installed'`

#### Manual Verification:
- [ ] Run `:Mason` and verify rust-analyzer shows as installed
- [ ] Run `:Mason` and verify codelldb shows as installed
- [ ] Run `rustfmt --version` in terminal and see version output

**Implementation Note**: After installation, restart Neovim to ensure all tools are recognized.

---

## Phase 6: End-to-End Verification

### Overview
Test the complete Rust development workflow to ensure all components work together.

### Test Scenarios:

#### 1. Create Test Rust Project
**Commands**:
```bash
cargo new test-rust-project
cd test-rust-project
```

#### 2. Test LSP Features
- Open `src/main.rs` in Neovim
- Verify completion works (type `std::` and see suggestions)
- Test go-to-definition (gd on a function)
- Check diagnostics appear for errors
- Run `:RustLsp runnables` and execute the program

#### 3. Test Cargo.toml Management
- Open `Cargo.toml`
- Add a dependency: `serde = ""`
- Verify inline version suggestions appear
- Verify completion works for crate names

#### 4. Test Debugging
- Add `dbg!` or breakpoint in code
- Set a breakpoint with `<leader>db`
- Start debugging with `<leader>dc`
- Step through code and inspect variables
- Verify DAP UI shows all debugging information

#### 5. Test Formatting
- Write poorly formatted Rust code
- Save the file
- Verify code auto-formats to Rust standards

### Success Criteria:

#### Automated Verification:
- [ ] Project compiles: `cargo build` (in test project)
- [ ] Tests pass: `cargo test` (in test project)
- [ ] Linter passes: `cargo clippy` (in test project)

#### Manual Verification:
- [ ] LSP features work (completion, go-to-def, diagnostics)
- [ ] `:RustLsp` commands are available and functional
- [ ] Cargo.toml shows crate information
- [ ] Debugging works end-to-end with breakpoints
- [ ] Code auto-formats on save
- [ ] No error messages in `:messages`
- [ ] `:checkhealth` shows no issues for Rust-related plugins

**Implementation Note**: This is the final verification phase. All previous phases must be complete and working.

---

## Testing Strategy

### Unit Tests:
Not applicable - this is configuration, not code.

### Integration Tests:
- Test each plugin independently after installation
- Verify plugins don't conflict with existing kickstart.nvim setup
- Test keymaps don't override existing bindings

### Manual Testing Steps:
1. Create a new Rust project with `cargo new`
2. Open the project in Neovim
3. Write a simple function with intentional errors
4. Verify LSP shows diagnostics
5. Fix errors and verify completion works
6. Add a dependency to Cargo.toml
7. Verify crates.nvim shows version info
8. Set a breakpoint and debug the program
9. Verify DAP UI works correctly
10. Save a poorly formatted file and verify auto-format

## Performance Considerations

- rustaceanvim is set to `lazy = false` but `ft = { "rust" }` so it only loads for Rust files
- crates.nvim uses `event = { "BufRead Cargo.toml" }` to lazy load only when needed
- DAP plugins load on-demand when debugging starts
- rust-analyzer may consume significant memory on large projects (this is expected)

## Migration Notes

Not applicable - this is a new setup, not a migration from existing Rust configuration.

## References

- Related research: `specs/research/2025-12-11-rust-neovim-setup.md`
- rustaceanvim docs: https://github.com/mrcjkb/rustaceanvim
- crates.nvim docs: https://github.com/Saecki/crates.nvim
- nvim-dap docs: https://github.com/mfussenegger/nvim-dap
- Existing plugin pattern: `lua/custom/plugins/neo-tree.lua`
- Existing plugin pattern: `lua/custom/plugins/harpoon.lua`
