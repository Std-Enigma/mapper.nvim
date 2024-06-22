# ⌨️ Mapper

An alternative solution to setup your neovim key mappings.

## ⚡️ Requirements

- Neovim >= 0.5.0

## 📦 Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "Std-Enigma/mapper.nvim",
  opts = function(_, opts) opts.mappings = require("mapper").empty_map_table() end, -- for setting up your mappings, refer to the usage section.
}
```

<!-- config:end -->

</details>

## 💡 API

**Mapper** provides a Lua API with key mapping functionality. This can be viewed with `:h mapper` or in the repository at [doc/api.md](doc/api.md)

## 🚀 Usage

### Lazy Plugin

<details><summary>Lazy</summary>
<!-- lazy:start -->

```lua
{
  "Std-Enigma/mapper.nvim",
  opts = {
    mappings = {
      -- map mode (:h map-modes)
      n = {
        ["<C-s>"] = { ":w!<cr>", desc = "Save File" }, -- use vimscript strings for mappings
        L = {
          function() vim.cmd.bnext() end, -- use lua functions for mappings
          desc = "Next buffer",
        },
        H = {
          function() vim.cmd.bprevious() end, -- use lua functions for mappings
          desc = "Previous buffer",
        },
        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        ["<leader>b"] = { desc = "Buffers" },
      },
    },
  },
}
```

<details><summary>Usage with other plugins</summary>

```lua
{
  "mrjones2014/smart-splits.nvim",
  dependencies = {
    {
      "Std-Enigma/mapper.nvim",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<C-H>"] = { function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" }
        maps.n["<C-J>"] = { function() require("smart-splits").move_cursor_down() end, desc = "Move to below split" }
        maps.n["<C-K>"] = { function() require("smart-splits").move_cursor_up() end, desc = "Move to above split" }
        maps.n["<C-L>"] = { function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" }
        maps.n["<C-Up>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" }
        maps.n["<C-Down>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" }
        maps.n["<C-Left>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" }
        maps.n["<C-Right>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" }
      end,
    },
  },
  opts = {},
}
```

</details>

<!-- lazy:end -->
</details>

### Lua API

<details><summary>API</summary>

<!-- api:start -->

You can setup your mappings like so with the api:

```lua
local mapper = require("mapper")
local mappings = mapper.empty_map_table()

-- tables with just a `desc` key will be registered with which-key if it's installed
-- this is useful for naming menus
mappings.n["<Leader>b"] = { desc = "Buffers" }
mappings.n["L"] = { function() vim.cmd.bnext() end, desc = "Next buffer" } -- use lua functions for mappings
mappings.n["H"] = { function() vim.cmd.bprevious() end, desc = "Previous buffer" } -- use lua functions for mappings
mappings.n["<C-S>"] = { "<Cmd>silent! update! | redraw<CR>", desc = "Force write" } -- use vimscript strings for mappings
maps.i["<C-S>"] = { "<Esc>" .. maps.n["<C-S>"][1], desc = maps.n["<C-S>"].desc } -- you can use already defined mappings properties since this is just a lua table

mapper.set_mappings(mappings)
```

<!-- api:end -->

</details>

## ⭐ Credits

This plugin is direct implementation of [AstroNvim](https://github.com/AstroNvim/AstroNvim) core utilities for setting up key mappings.

<div align="center" id="madewithlua">

[![Lua](https://img.shields.io/badge/Made%20with%20Lua-blue.svg?style=for-the-badge&logo=lua)](https://lua.org)

</div>
