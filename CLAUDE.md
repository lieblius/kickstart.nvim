# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands
- Format Lua code: `stylua <file.lua>`
- Lint Markdown: Uses `markdownlint` through nvim-lint
- Install plugins: `:Lazy` in Neovim to manage plugins
- Update plugins: `:Lazy update` in Neovim

## Code Style Guidelines

### Formatting
- Indentation: 2 spaces for Lua (defined in .stylua.toml)
- Line width: 160 characters maximum
- Line endings: Unix style (LF)
- Quote style: Prefer single quotes when possible

### Naming Conventions
- Functions: Use camelCase for function names
- Variables: Use snake_case for local variables
- Constants: Use UPPER_SNAKE_CASE for constants

### Error Handling
- Use pcall for protected calls that might fail
- Provide meaningful error messages

### Import Style
- Use require() for importing modules
- Group imports by type (core modules, plugins, local modules)

### Plugin Development
- Follow lazy.nvim pattern for plugin definitions
- Keep plugin configurations in separate files under lua/custom/plugins/

### Documentation
- Use --[[ ]] for multi-line comments
- Document function parameters and return values