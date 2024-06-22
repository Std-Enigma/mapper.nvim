# Lua API

mapper.nvim API documentation

## mapper

This module can be loaded with `local mapper = require "mapper"`

### config


```lua
MapperOpts
```

 The configuration as set by the user through the `setup()` function


### empty_map_table


```lua
function mapper.empty_map_table()
  -> table<string, table>
```

 Get an empty table of mappings with a key for each map mode

*return* — a table with entries for each map mode


### set_mappings


```lua
function mapper.set_mappings(map_table: table<string, table<string, (string|function|MapperKeymapping|false)?>?>, base?: vim.api.keyset.keymap)
```

 Table based API for setting keybindings

*param* `map_table` — A nested table where the first key is the vim mode, the second key is the key to map, and the value is the function to set the mapping to

*param* `base` — A base set of options to set on every keybinding


### which_key_queue


```lua
nil
```

 A placeholder variable used to queue section names to be registered by which-key

### which_key_register


```lua
function mapper.which_key_register()
```

 Register queued which-key mappings

