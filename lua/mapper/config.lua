---@alias MapperKeymappingCmd string|function

---@class MapperKeymapping: vim.api.keyset.keymap
---@field [1] MapperKeymappingCmd rhs of keymap
---@field name string? optional which-key mapping name

---@alias MapperKeymappings table<string,table<string,(MapperKeymapping|MapperKeymappingCmd|false)?>?>

---@class MapperOpts
---Configuration of vim mappings to create.
---The first key into the table is the vim map mode (`:h map-modes`), and the value is a table of entries to be passed to `vim.keymap.set` (`:h vim.keymap.set`):
---  - The key is the first parameter or the vim mode (only a single mode supported) and the value is a table of keymaps within that mode:
---    - The first element with no key in the table is the action (the 2nd parameter) and the rest of the keys/value pairs are options for the third parameter.
---Example:
--
---```lua
---mappings = {
---  -- map mode (:h map-modes)
---  n = {
---    -- use vimscript strings for mappings
---    ["<C-s>"] = { ":w!<cr>", desc = "Save File" },
---    -- navigate buffer tabs with `H` and `L`
---    L = {
---      function() vim.cmd("bnext") end,
---      desc = "Next buffer",
---    },
---    H = {
---      function() vim.cmd("bprevious") end,
---      desc = "Previous buffer",
---    },
---    -- tables with just a `desc` key will be registered with which-key if it's installed
---    -- this is useful for naming menus
---    ["<leader>b"] = { desc = "Buffers" },
---  }
---}
---```
---@field mappings MapperKeymappings?
---@field _map_sections table<string,{ desc: string?, name: string? }>?

---@type MapperOpts
return { mappings = {} }
