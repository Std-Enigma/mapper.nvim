---@class Mapper
local M = {}

--- The configuration as set by the user through the `setup()` function
M.config = require "mapper.config"

--- A placeholder variable used to queue section names to be registered by which-key
---@type table?
M.which_key_queue = nil

--- Execute a function when a specified plugin is loaded with Lazy.nvim, or immediately if already loaded
---@param plugins string|string[] the name of the plugin or a list of plugins to defer the function execution on. If a list is provided, only one needs to be loaded to execute the provided function
---@param load_op fun()|string|string[] the function to execute when the plugin is loaded, a plugin name to load, or a list of plugin names to load
local function on_load(plugins, load_op)
	local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
	if lazy_config_avail then
		if type(plugins) == "string" then
			plugins = { plugins }
		end
		if type(load_op) ~= "function" then
			local to_load = type(load_op) == "string" and { load_op } or load_op --[=[@as string[]]=]
			load_op = function()
				require("lazy").load({ plugins = to_load })
			end
		end

		for _, plugin in ipairs(plugins) do
			if vim.tbl_get(lazy_config.plugins, plugin, "_", "loaded") then
				vim.schedule(load_op)
				return
			end
		end
		vim.api.nvim_create_autocmd("User", {
			pattern = "LazyLoad",
			desc = ("A function to be ran when one of these plugins runs: %s"):format(vim.inspect(plugins)),
			callback = function(args)
				if vim.tbl_contains(plugins, args.data) then
					load_op()
					return true
				end
			end,
		})
	end
end

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
		on_load("which-key.nvim", M.which_key_register)
	end
end

--- Setup and configure mapper.nvim
---@param opts MapperOpts
---@see mapper.config
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts)

	-- mappings
	M.set_mappings(M.config.mappings)
end

return M
