---@class Mapper
local M = {}

--- The configuration as set by the user through the `setup()` function
M.config = require "mapper.config"

--- A placeholder variable used to queue section names to be registered by which-key
---@type table?
M.which_key_queue = nil

--- Register queued which-key mappings
function M.which_key_register()
	if M.which_key_queue then
		local wk_avail, wk = pcall(require, "which-key")
		if wk_avail then
			for mode, registration in pairs(M.which_key_queue) do
				wk.register(registration, { mode = mode })
			end
			M.which_key_queue = nil
		end
	end
end

--- Get an empty table of mappings with a key for each map mode
---@return table<string,table> # a table with entries for each map mode
function M.empty_map_table()
	local maps = {}
	for _, mode in ipairs({ "", "n", "v", "x", "s", "o", "!", "i", "l", "c", "t" }) do
		maps[mode] = {}
	end
	if vim.fn.has("nvim-0.10.0") == 1 then
		for _, abbr_mode in ipairs({ "ia", "ca", "!a" }) do
			maps[abbr_mode] = {}
		end
	end
	return maps
end

--- Table based API for setting keybindings
---@param map_table MapperKeymappings A nested table where the first key is the vim mode, the second key is the key to map, and the value is the function to set the mapping to
---@param base? vim.api.keyset.keymap A base set of options to set on every keybinding
function M.set_mappings(map_table, base)
	local was_no_which_key_queue = not M.which_key_queue
	-- iterate over the first keys for each mode
	for mode, maps in pairs(map_table) do
		-- iterate over each keybinding set in the current mode
		for keymap, options in pairs(maps) do
			-- build the options for the command accordingly
			if options then
				local cmd
				local keymap_opts = base or {}
				if type(options) == "string" or type(options) == "function" then
					cmd = options
				else
					cmd = options[1]
					keymap_opts = vim.tbl_deep_extend("force", keymap_opts, options)
					keymap_opts[1] = nil
				end
				if not cmd or keymap_opts.name then -- if which-key mapping, queue it
					if not keymap_opts.name then
						keymap_opts.name = keymap_opts.desc
					end
					if not M.which_key_queue then
						M.which_key_queue = {}
					end
					if not M.which_key_queue[mode] then
						M.which_key_queue[mode] = {}
					end
					M.which_key_queue[mode][keymap] = keymap_opts
				else -- if not which-key mapping, set it
					vim.keymap.set(mode, keymap, cmd, keymap_opts)
				end
			end
		end
	end
	if was_no_which_key_queue and M.which_key_queue then
		local util = require "mapper.util"
		util.on_load("which-key.nvim", M.which_key_register)
	end
end

--- Setup and configure mapper.nvim
---@param opts MapperOpts
---@see mapper.config
function M.setup(opts)
	M.config.mappings = M.empty_map_table()
	M.config = vim.tbl_deep_extend("force", M.config, opts)

	local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
	if lazy_config_avail then
  	for _, plugin in pairs(lazy_config.plugins) do
    	local plugin_mappings = lazy_config.spec.plugins[plugin.name].mappings or {}
    	M.config.mappings = vim.tbl_deep_extend("force", M.config.mappings, plugin_mappings)
  	end
	end

	-- mappings
	M.set_mappings(M.config.mappings)
end

return M
