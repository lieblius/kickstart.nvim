# Rust Development in Neovim - Complete Guide

This guide covers everything you need to know about using your Neovim setup for Rust development.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Core LSP Features](#core-lsp-features)
3. [Running and Testing Code](#running-and-testing-code)
4. [Debugging](#debugging)
5. [Managing Dependencies (Cargo.toml)](#managing-dependencies-cargotoml)
6. [Advanced Features](#advanced-features)
7. [Keybindings Reference](#keybindings-reference)
8. [Configuration](#configuration)

---

## Quick Start

### Opening a Rust Project

1. Open any `.rs` file: `nvim src/main.rs`
2. rustaceanvim automatically starts rust-analyzer LSP
3. You'll see:
   - Inlay hints (type annotations, parameter names)
   - Diagnostics (errors/warnings with squiggly lines)
   - Virtual text at line ends showing types

### First Steps

Try these immediately:
- **Hover documentation:** Press `K` over a function/type
- **Go to definition:** Press `gd` on a function/variable
- **Auto-complete:** Start typing `std::` in insert mode
- **Run your code:** `:RustLsp runnables` then select target

---

## Core LSP Features

These are standard Neovim LSP features that work automatically with rust-analyzer:

### Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `gd` | Go to Definition | Jump to where something is defined |
| `grr` | Go to References | Find all uses of this symbol |
| `gri` | Go to Implementation | Jump to implementation |
| `grt` | Go to Type Definition | Jump to type definition |
| `gO` | Document Symbols | Fuzzy find symbols in current file |
| `gW` | Workspace Symbols | Fuzzy find symbols in entire project |

### Code Actions

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>cR` | Rust Code Action | Rust-specific grouped code actions |
| `gra` | Generic Code Action | Standard LSP code actions |

**Common Code Actions:**
- Auto-import items
- Implement missing trait methods
- Add derive macros
- Fill match arms
- Extract variables/functions
- Inline variables/functions

### Renaming

| Keybinding | Action | Description |
|------------|--------|-------------|
| `grn` | Rename Symbol | Rename across entire project |

### Hover & Documentation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `K` | Hover Documentation | Show docs/type info |

### Diagnostics

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>q` | Quickfix List | Open all diagnostics |
| `<leader>sd` | Search Diagnostics | Fuzzy find diagnostics via Telescope |

---

## Running and Testing Code

### :RustLsp runnables

**What it does:** Shows a menu of all runnable targets (main, tests, examples, benchmarks)

**Usage:**
```vim
:RustLsp runnables
```

**Example workflow:**
1. `:RustLsp runnables`
2. Select target from menu (e.g., "cargo run")
3. Code executes in terminal window
4. `:RustLsp! runnables` repeats the last selection

**With arguments:**
```vim
:RustLsp runnables -- --nocapture
```
Passes `--nocapture` to the test/binary

### :RustLsp testables

**What it does:** Like `runnables` but filters to show only tests

**Usage:**
```vim
:RustLsp testables
```

**Example workflow:**
1. Write a test function
2. `:RustLsp testables`
3. Select which test to run
4. See output in terminal

### :RustLsp run

**What it does:** Automatically runs the target at your cursor position (no menu)

**Usage:**
```vim
:RustLsp run
```

**Example:**
- Put cursor in `fn main()` → `:RustLsp run` executes main
- Put cursor in `#[test] fn my_test()` → `:RustLsp run` runs that test

---

## Debugging

Full visual debugger with breakpoints, stepping, and variable inspection.

### Setting Up a Debug Session

**Step 1: Set a Breakpoint**
```vim
<leader>db
```
Place cursor on a line and press `<leader>db` (space-d-b). You'll see a breakpoint icon appear.

**Step 2: Start Debugging**

**Option A: Debug menu**
```vim
<leader>dr
```
Shows menu of debuggable targets (similar to runnables)

**Option B: Continue (starts if not running)**
```vim
<leader>dc
```
Starts debugging or continues if paused

**Step 3: Debug Interface Opens**

The DAP UI automatically opens with 4 panels:
- **Scopes:** Local variables and their values
- **Breakpoints:** List of all breakpoints
- **Stacks:** Call stack trace
- **Console:** REPL for evaluating expressions

### Debugging Keybindings

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>db` | Toggle Breakpoint | Set/remove breakpoint on current line |
| `<leader>dB` | Conditional Breakpoint | Set breakpoint with condition |
| `<leader>dc` | Continue | Start debugging or continue to next breakpoint |
| `<leader>di` | Step Into | Step into function calls |
| `<leader>dO` | Step Over | Execute current line, skip over functions |
| `<leader>do` | Step Out | Step out of current function |
| `<leader>dC` | Run to Cursor | Continue execution until cursor line |
| `<leader>du` | Toggle UI | Show/hide debug UI panels |
| `<leader>de` | Eval Expression | Evaluate expression under cursor (normal/visual) |
| `<leader>dt` | Terminate | Stop debugging session |
| `<leader>dl` | Run Last | Repeat last debug configuration |
| `<leader>dp` | Pause | Pause execution |
| `<leader>dw` | Widgets | Show debug widgets (hover over variables) |

### Stack Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>dk` | Up Stack | Move up in call stack |
| `<leader>dj` | Down Stack | Move down in call stack |

### Virtual Text During Debugging

When paused at a breakpoint, you'll see variable values displayed inline as virtual text next to the code. This is provided by nvim-dap-virtual-text.

### Example Debug Workflow

```rust
fn factorial(n: u32) -> u32 {
    if n == 0 {  // <-- Set breakpoint here with <leader>db
        1
    } else {
        n * factorial(n - 1)
    }
}

fn main() {
    let result = factorial(5);
    println!("{}", result);
}
```

1. Put cursor on `if n == 0` line
2. Press `<leader>db` (set breakpoint)
3. Press `<leader>dr` and select "cargo run"
4. Debugger starts, pauses at breakpoint
5. Press `<leader>di` to step into recursive call
6. Watch variables change in Scopes panel
7. Press `<leader>dc` to continue execution
8. Press `<leader>dt` to stop when done

---

## Managing Dependencies (Cargo.toml)

The crates.nvim plugin provides rich features when editing Cargo.toml files.

### What You See Automatically

When you open a Cargo.toml file:

**Virtual Text:** At the end of each dependency line, you'll see:
- Latest compatible version (blue text)
- Upgrade available indicator (yellow text)
- Error messages if crate not found (red text)

**Example:**
```toml
[dependencies]
serde = "1.0"         # Latest: 1.0.215
tokio = "1.35"        # Upgrade: 1.41.2
some_crate = "1.0"    # No match
```

### Inline Information Popups

**Show Crate Details:**
```vim
:Crates show_popup
```
Or press `K` on a crate name.

**Shows:**
- Description
- Downloads count
- Last updated date
- Homepage, repository, documentation links
- Categories and keywords

**Show Available Versions:**
```vim
:Crates show_versions_popup
```
Or press `K` on a version string.

**Shows:**
- All versions (latest at top)
- Pre-release versions marked with icon
- Yanked versions marked (deprecated)
- Version dates

**Show Available Features:**
```vim
:Crates show_features_popup
```
Or press `K` on the features array.

**Shows:**
- All available features
- Which features are enabled
- Which are transitively enabled

### Updating Dependencies

**Update Single Crate (patch version):**
```vim
:Crates update_crate
```
Cursor on dependency line → updates to latest patch (e.g., 1.0.200 → 1.0.215)

**Upgrade Single Crate (any version):**
```vim
:Crates upgrade_crate
```
Cursor on dependency line → upgrades to latest (e.g., 1.35 → 1.41)

**Update All Crates:**
```vim
:Crates update_all_crates
```

**Upgrade All Crates:**
```vim
:Crates upgrade_all_crates
```

### Completion in Cargo.toml

**Crate Names:**
Start typing in dependencies section:
```toml
[dependencies]
ser<TAB>
```
Shows completion menu with crate names from crates.io

**Versions:**
Type or edit a version:
```toml
serde = "1<TAB>
```
Shows all available versions

**Features:**
In features array:
```toml
tokio = { version = "1.0", features = ["<TAB>"] }
```
Shows all available features for that crate

### Code Actions

Press `gra` (or your code action key) on a dependency line:

**Available actions:**
- Update crate (to latest patch)
- Upgrade crate (to latest version)
- Expand to inline table
- Extract into table syntax
- Use git source
- Open documentation
- Open crates.io page

### Opening Links

```vim
:Crates open_documentation    " Opens docs.rs
:Crates open_repository       " Opens GitHub/GitLab
:Crates open_cratesio        " Opens crates.io page
:Crates open_homepage        " Opens homepage
```

### Refreshing Crate Data

If crates.io data seems stale:
```vim
:Crates update    " Refresh from crates.io
:Crates reload    " Clear cache and reload
```

---

## Advanced Features

### Macro Expansion

**What it does:** Shows how Rust macros expand

**Usage:**
```vim
:RustLsp expandMacro
```

**Example:**
Put cursor on `println!("hello")` → `:RustLsp expandMacro` shows the full expansion

### View Internal Representations

**MIR (Mid-level Intermediate Representation):**
```vim
:RustLsp view mir
```

**HIR (High-level Intermediate Representation):**
```vim
:RustLsp view hir
```

**Syntax Tree:**
```vim
:RustLsp syntaxTree
```

### Explain Compiler Errors

```vim
:RustLsp explainError
```
Shows rustc's detailed explanation for the error under cursor (like `rustc --explain E0308`)

**Cycle through errors:**
```vim
:RustLsp explainError cycle
```

### Render Diagnostics

```vim
:RustLsp renderDiagnostic
```
Shows diagnostic exactly as it appears during `cargo build` with colors

### Structural Search & Replace

```vim
:RustLsp ssr $pattern
```

**Example:**
```vim
:RustLsp ssr foo($a, $b) ==>> bar($b, $a)
```
Swaps all `foo(x, y)` calls to `bar(y, x)`

### Navigation Helpers

```vim
:RustLsp openCargo        " Jump to Cargo.toml
:RustLsp openDocs         " Open docs.rs for symbol under cursor
:RustLsp parentModule     " Jump to parent module
```

### Workspace Management

```vim
:RustLsp reloadWorkspace     " Reload after Cargo.toml changes
:RustLsp rebuildProcMacros   " Rebuild procedural macros
```

### Build Control

```vim
:RustLsp flyCheck run      " Run cargo check in background
:RustLsp flyCheck clear    " Clear diagnostics
:RustLsp flyCheck cancel   " Cancel running check
```

### Dependency Graph

```vim
:RustLsp crateGraph
```
Creates a visual graph of your crate dependencies (requires graphviz `dot` installed)

---

## Keybindings Reference

### Custom Keybindings (Your Config)

These are specific to your setup:

| Keybinding | Mode | Command | Description |
|------------|------|---------|-------------|
| `<leader>cR` | n | `:RustLsp codeAction` | Rust-specific code actions |
| `<leader>dr` | n | `:RustLsp debuggables` | Open debug target menu |

### LSP Keybindings (Kickstart Standard)

From kickstart's LSP setup:

| Keybinding | Mode | Action | Description |
|------------|------|--------|-------------|
| `grn` | n | Rename | Rename symbol |
| `gra` | n/x | Code Action | Generic code actions |
| `grr` | n | References | Find references |
| `gri` | n | Implementation | Go to implementation |
| `grd` | n | Definition | Go to definition |
| `grD` | n | Declaration | Go to declaration |
| `gO` | n | Document Symbols | Fuzzy find symbols |
| `gW` | n | Workspace Symbols | Fuzzy find in workspace |
| `grt` | n | Type Definition | Go to type definition |
| `K` | n | Hover | Show documentation |
| `<leader>th` | n | Toggle Inlay Hints | Show/hide type hints |

### Debug Keybindings (DAP)

All debugging keybindings start with `<leader>d`:

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>db` | Toggle Breakpoint | Set/remove breakpoint |
| `<leader>dB` | Conditional Breakpoint | Breakpoint with condition |
| `<leader>dc` | Continue | Start/continue debugging |
| `<leader>di` | Step Into | Step into function |
| `<leader>dO` | Step Over | Execute line without entering functions |
| `<leader>do` | Step Out | Exit current function |
| `<leader>dC` | Run to Cursor | Continue to cursor line |
| `<leader>dt` | Terminate | Stop debugging |
| `<leader>du` | Toggle UI | Show/hide debug panels |
| `<leader>de` | Eval | Evaluate expression under cursor |
| `<leader>dl` | Run Last | Repeat last debug config |
| `<leader>dk` | Stack Up | Move up in call stack |
| `<leader>dj` | Stack Down | Move down in call stack |
| `<leader>dp` | Pause | Pause execution |
| `<leader>dw` | Widgets | Show debug widgets |

### Custom Clipboard Keybindings (Your Config)

| Keybinding | Mode | Action | Description |
|------------|------|--------|-------------|
| `<leader>y` | n/v | Yank to System | Copy to system clipboard |
| `<leader>Y` | n | Yank Line to System | Copy line to system clipboard |
| `<leader>p` | n/v | Paste from System | Paste from system clipboard |
| `<leader>P` | n/v | Paste Before | Paste from system before cursor |
| `<leader>d` | n/v | Delete (no yank) | Delete without copying |

### Screen Control (Your Config)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<C-d>` | Half Page Down + Center | Jump down and center screen |
| `<C-u>` | Half Page Up + Center | Jump up and center screen |

---

## Running and Testing Code

### Understanding Runnables

When you run `:RustLsp runnables`, you'll see a menu like:

```
cargo run
cargo test
cargo test my_test -- --exact
cargo test my_module::
cargo bench
```

Select one and it executes in a terminal window.

### Running Specific Tests

**Option 1: Cursor-based**
```vim
" Put cursor in test function
:RustLsp run
```

**Option 2: Menu**
```vim
:RustLsp testables
" Select from test menu
```

**Option 3: Pass Arguments**
```vim
:RustLsp runnables -- --nocapture
" Shows println! output in tests
```

### Repeat Last Run

```vim
:RustLsp! runnables
" Immediately runs last selection (no menu)
```

---

## Debugging

### Basic Debug Workflow

**1. Set Breakpoints**
```vim
<leader>db    " Toggle breakpoint on current line
```

**2. Start Debugging**
```vim
<leader>dr    " Show debug menu, select target
```
Or
```vim
<leader>dc    " Start/continue execution
```

**3. Stepping Through Code**
```vim
<leader>di    " Step into function
<leader>dO    " Step over line
<leader>do    " Step out of function
```

**4. Inspect Variables**

Variables automatically appear in the Scopes panel. You can also:
```vim
<leader>de    " Eval expression under cursor
<leader>dw    " Show variable widget
```

**5. End Session**
```vim
<leader>dt    " Terminate debugger
```

### Understanding the Debug UI

When debugging starts, you'll see 4 panels:

**Left Panel - Scopes:**
```
Locals:
  n: 5
  result: 120
```
Shows all variables in current scope with values

**Left Panel - Stacks:**
```
factorial (src/main.rs:15)
main (src/main.rs:20)
```
The call stack - click to jump to frame

**Bottom Panel - Breakpoints:**
```
src/main.rs:15
src/lib.rs:42
```
All your breakpoints

**Bottom Panel - Console:**
```
> print result
120
```
REPL for evaluating expressions

### Conditional Breakpoints

```vim
<leader>dB
```
Prompts for condition: `n == 3`

Breakpoint only triggers when condition is true.

### Evaluating Expressions

**Method 1: Visual selection**
1. Select expression in visual mode
2. Press `<leader>de`
3. See result in popup

**Method 2: Cursor**
1. Put cursor on variable
2. Press `<leader>de`
3. See current value

### Run to Cursor

```vim
<leader>dC
```
Continues execution until reaching the line your cursor is on (temporary breakpoint)

---

## Managing Dependencies (Cargo.toml)

### Visual Features

When you open Cargo.toml, you automatically see:

**Virtual Text at line ends:**
```toml
serde = "1.0"              Latest: 1.0.215
tokio = "1.35.0"          Upgrade: 1.41.2
rand = "0.8"               Latest: 0.8.5
```

**Color coding:**
- Blue: Latest compatible version
- Yellow: Upgrade available
- Red: No match / error

### Adding New Dependencies

**Method 1: Type and complete**
```toml
[dependencies]
ser<TAB>
```
Completion menu appears after 3 characters with crates from crates.io

**Method 2: Use cargo command**
```bash
cargo add serde
```
Then open Cargo.toml in nvim to see inline info

### Viewing Crate Information

**Hover on crate name:**
```vim
K    " on 'serde' line
```

**See popup with:**
- Description: "A serialization/deserialization framework"
- Downloads: 500,000,000+
- Last updated: 2024-12-01
- Homepage, repository, docs links
- Categories: encoding, serialization
- Keywords: serde, serialization

**Hover on version:**
```vim
K    " on '1.0' part
```

**See all versions:**
```
 1.0.215 (2024-11-01)
 1.0.214 (2024-10-15)
 1.0.213 (2024-09-20)
  1.0.0-rc.1 (2023-05-10)  [pre-release]
  0.9.5 (2019-01-01)  [yanked]
```

### Working with Features

**View available features:**
```toml
tokio = { version = "1.0", features = [] }
              " Put cursor here and press K
```

**See popup:**
```
  macros
  rt-multi-thread
  sync
 fs (enabled)
 net (enabled)
```

**Add feature via completion:**
```toml
tokio = { version = "1.0", features = ["<TAB>"] }
```

### Updating Dependencies

**Single crate:**
```vim
:Crates upgrade_crate    " Cursor on dependency line
```

**Visual selection:**
```vim
" Select multiple dependency lines in visual mode
:Crates upgrade_crates
```

**All at once:**
```vim
:Crates upgrade_all_crates
```

### Code Actions in Cargo.toml

Press `gra` on a dependency line:

**Available actions:**
- Update crate (patch version)
- Upgrade crate (latest version)
- Expand plain crate to inline table
- Extract crate into table
- Open documentation
- Open crates.io

### Refactoring Dependency Format

**Expand plain to inline table:**
```toml
serde = "1.0"
```
→ `:Crates expand_plain_crate_to_inline_table` →
```toml
serde = { version = "1.0" }
```

**Extract to table:**
```toml
serde = { version = "1.0", features = ["derive"] }
```
→ `:Crates extract_crate_into_table` →
```toml
[dependencies.serde]
version = "1.0"
features = ["derive"]
```

### Opening Crate Documentation

```vim
:Crates open_documentation    " Opens docs.rs
:Crates open_repository       " Opens GitHub
:Crates open_cratesio        " Opens crates.io page
```

Or use code actions (`gra`) and select "open documentation"

---

## Advanced Features

### Structural Search & Replace

**Find and replace patterns:**
```vim
:RustLsp ssr
```

**Example 1 - Swap arguments:**
```vim
:RustLsp ssr foo($a, $b) ==>> foo($b, $a)
```
Changes all `foo(x, y)` to `foo(y, x)`

**Example 2 - Add error handling:**
```vim
:RustLsp ssr $var.unwrap() ==>> $var.expect("failed")
```

**Example 3 - Convert to method:**
```vim
:RustLsp ssr std::mem::replace(&mut $a, $b) ==>> $a.replace($b)
```

**Visual mode:**
Select code in visual mode, then `:RustLsp ssr` to search only in selection

### Workspace Symbols

**Search all symbols:**
```vim
:RustLsp workspaceSymbol MyStruct
```
Or use kickstart's telescope: `<leader>sg` then type

**Include dependencies:**
```vim
:RustLsp! workspaceSymbol MyTrait
```
The `!` searches dependencies too (slower)

### Join Lines Intelligently

```vim
:RustLsp joinLines
```

**Example:**
```rust
let x = if condition {
    value1
} else {
    value2
};
```
→ `:RustLsp joinLines` →
```rust
let x = if condition { value1 } else { value2 };
```

Respects Rust syntax rules (adds/removes braces appropriately)

### Move Items

```vim
:RustLsp moveItem up
:RustLsp moveItem down
```

**Example:**
```rust
fn second_fn() {}
fn first_fn() {}
```
Cursor on `second_fn` → `:RustLsp moveItem up` →
```rust
fn first_fn() {}
fn second_fn() {}
```

### Rebuild Procedural Macros

If proc macros aren't working:
```vim
:RustLsp rebuildProcMacros
```

### Reload Workspace

After editing Cargo.toml:
```vim
:RustLsp reloadWorkspace
```
Tells rust-analyzer to re-read workspace configuration

### Related Diagnostics

```vim
:RustLsp relatedDiagnostics
```
Jumps to related diagnostics (helpful for error chains)

---

## Configuration

### Optional: Use bacon-ls for Faster Diagnostics

Add to your settings file (lua/custom/settings.lua):

```lua
-- Use bacon-ls instead of rust-analyzer for diagnostics
-- (rust-analyzer still provides all other features)
vim.g.rust_diagnostics = "bacon-ls"
```

Then restart nvim. Mason will auto-install bacon.

**Why:** bacon-ls is faster for diagnostics on large projects. rust-analyzer still provides completion, go-to-def, etc.

### Disable VSCode Settings

Your config already includes:
```lua
load_vscode_settings = false
```

This prevents rustaceanvim from reading `.vscode/settings.json` which can cause conflicts in shared repos.

### View Current Configuration

```vim
:lua print(vim.inspect(vim.g.rustaceanvim))
```

Shows your complete rustaceanvim configuration

### Check rust-analyzer Status

```vim
:RustAnalyzer restart    " Restart LSP
:RustLsp logFile         " View rust-analyzer logs
:checkhealth rustaceanvim  " Check health
```

---

## Common Workflows

### Workflow 1: Implementing a New Feature

1. Create new function
2. Start typing → completion appears
3. See type errors with diagnostics
4. Press `gra` → "Implement missing trait methods"
5. Press `K` on unfamiliar functions for docs
6. `:RustLsp runnables` → run tests
7. `<leader>f` → auto-format
8. Done!

### Workflow 2: Fixing a Bug

1. See error in diagnostics
2. `:RustLsp explainError` → understand error
3. `gd` → jump to definition
4. `grr` → find all references
5. Fix code
6. `:RustLsp testables` → run related tests
7. Set breakpoint with `<leader>db` if needed
8. `<leader>dr` → debug the test

### Workflow 3: Adding Dependencies

1. Open Cargo.toml
2. Type crate name, use `<TAB>` completion
3. See latest version in virtual text
4. Press `K` on crate name → view description
5. `:Crates show_features_popup` → see available features
6. Add features to array
7. Save file
8. `:RustLsp reloadWorkspace`

### Workflow 4: Debugging a Complex Issue

1. Set breakpoints on suspicious lines: `<leader>db`
2. Start debugging: `<leader>dr` → select test
3. When paused, inspect Scopes panel for variable values
4. Step through: `<leader>di` (into) or `<leader>dO` (over)
5. Evaluate expressions: select code, `<leader>de`
6. Check call stack in Stacks panel
7. Continue: `<leader>dc`
8. Stop: `<leader>dt`

### Workflow 5: Exploring Unfamiliar Code

1. Open file
2. `gO` → fuzzy find symbols in file
3. `gd` → jump to definition
4. `grr` → see how it's used
5. `K` → read documentation
6. `:RustLsp expandMacro` → understand macro
7. `:RustLsp parentModule` → see context

---

## Troubleshooting

### rust-analyzer not working

**Check if running:**
```vim
:LspInfo
```
Should show `rust_analyzer` attached

**Restart it:**
```vim
:RustAnalyzer restart
```

**Check logs:**
```vim
:RustLsp logFile
```

### Completion not working

**Check LSP is attached:**
```vim
:LspInfo
```

**Check completion plugin:**
```vim
:checkhealth blink.cmp
```

### Cargo.toml features not showing

**Reload crate data:**
```vim
:Crates reload
```

**Check plugin loaded:**
```vim
:checkhealth crates
```

### Debugging not working

**Check codelldb installed:**
```vim
:Mason
```
Look for "codelldb" - should be installed

**Check DAP status:**
```vim
:checkhealth dap
```

### Formatting not working

**Check rustfmt installed:**
```bash
rustup component add rustfmt
rustfmt --version
```

**Format manually:**
```vim
<leader>f
```

---

## Tips & Tricks

### Tip 1: Use Telescope for Symbols
Instead of `:RustLsp workspaceSymbol`, use:
```vim
<leader>sg    " Search by grep
<leader>sf    " Search files
```
Telescope is often faster and more familiar

### Tip 2: Repeat Last Runnable
```vim
:RustLsp! runnables
```
The `!` repeats your last selection - saves time during test-driven development

### Tip 3: View Type on Hover
Press `K` on any variable/function to see its type and documentation instantly

### Tip 4: Quick Fix with Code Actions
When you see a diagnostic, try `gra` - rust-analyzer often suggests automatic fixes

### Tip 5: Use Inlay Hints Sparingly
Toggle them off if they're cluttered:
```vim
<leader>th
```

### Tip 6: Explore with expandMacro
Don't understand a macro? Put cursor on it and `:RustLsp expandMacro`

### Tip 7: Use Virtual Text for Dependencies
Don't manually check crates.io - just open Cargo.toml and see versions inline

### Tip 8: Debug Individual Tests
Put cursor in test function, press `<leader>dr`, select that specific test to debug

---

## What You Have Installed

Your setup includes the complete LazyVim Rust + DAP stack:

**Plugins:**
- **rustaceanvim** - Rust LSP integration with rust-analyzer
- **crates.nvim** - Cargo.toml dependency management
- **nvim-dap** - Debug Adapter Protocol core
- **nvim-dap-ui** - Visual debugging interface
- **nvim-dap-virtual-text** - Inline variable values during debugging
- **mason-nvim-dap** - Auto-installs debuggers via Mason

**Tools (auto-installed via Mason):**
- **codelldb** - LLDB-based debugger for Rust
- **bacon** - Fast background checker (if you enable bacon-ls)

**Formatters:**
- **rustfmt** - Official Rust formatter (install via `rustup component add rustfmt`)

**Treesitter Parsers:**
- **rust** - Rust syntax highlighting
- **ron** - Rusty Object Notation syntax

---

## Learn More

**In Neovim:**
```vim
:help rustaceanvim         " rustaceanvim documentation
:help dap                  " DAP documentation
:help lsp                  " LSP documentation
```

**Online Resources:**
- rustaceanvim: https://github.com/mrcjkb/rustaceanvim
- crates.nvim: https://github.com/Saecki/crates.nvim
- nvim-dap: https://github.com/mfussenegger/nvim-dap
- rust-analyzer: https://rust-analyzer.github.io/

**Quick Reference:**
- All `:RustLsp` commands: `:RustLsp <TAB>` (shows autocomplete)
- All `:Crates` commands: `:Crates <TAB>`
- Your keybindings: `<leader>` then wait - which-key shows options
