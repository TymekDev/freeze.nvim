# freeze.nvim

A plugin wrapping [`freeze`](https://github.com/charmbracelet/freeze) into a `:Freeze` command.

## Requirements

- Neovim >= 0.10.0
- MacOS and `osascript`
- `freeze` >= [`578e9d0`](https://github.com/charmbracelet/freeze/commit/578e9d05c3196241fa3c49ce857f9f4c8ae6a77b) (for tokyonight themes)
- JetBrainsMono Nerd Font

> [!NOTE]
> These are specific requirements that work for me. I don't plan to work on lowering these requirements.

## Setup

### [lazy.nvim](https://github.com/folke/lazy.nvim)

_Annotations are optional._

```lua
---@module "freeze"
---@type LazySpec
{
  "TymekDev/freeze.nvim",
  cmd = "Freeze",
  ---@module "freeze"
  ---@type freeze.Options
  opts = {},
}
```

Once installed, you can run a health check with:

```vim
:Lazy load freeze.nvim | checkhealth freeze
```

> [!TIP]
> Use [lazydev.nvim](https://github.com/folke/lazydev.nvim) to get completions based on the annotations.

## Usage

- `:Freeze` command works either on a selection or on a range
- Use `:%Freeze` to screenshot an entire file
- Use `:Freeze` to screenshot the current line
- Provide an argument to change the theme: `:Freeze tokyonight_day`
  - Valid values are keys of `require("freeze.themes")`

## Options

> [!IMPORTANT]
> The goal is to create screenshots with a MacOS feel. That's why customization options are limited.

```lua
{
  config = "full",
  ["font.family"] = "JetBrainsMono Nerd Font",
  output = function()
    return vim.fn.tempname() .. ".png"
  end,
  theme = require("freeze.themes").tokyonight_storm,
}
```

## Motivation

There are a few plugins built around `freeze` already. However, the alternatives don't copy the PNG image into the clipboard properly. Namely, it cannot be pasted as an image (e.g. into a Slack message).

I already had the core implemented in [my dotfiles](https://github.com/TymekDev/dotfiles), so I decided to turn it into a standalone plugin.
