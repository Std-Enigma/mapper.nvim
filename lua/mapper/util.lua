local M = {}

--- Execute a function when a specified plugin is loaded with Lazy.nvim, or immediately if already loaded
---@param plugins string|string[] the name of the plugin or a list of plugins to defer the function execution on. If a list is provided, only one needs to be loaded to execute the provided function
---@param load_op fun()|string|string[] the function to execute when the plugin is loaded, a plugin name to load, or a list of plugin names to load
function M.on_load(plugins, load_op)
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

---generate and return a mapping table from lazy.nvim config
---if nil is returned then no mapping table have been found
---@return table|nil generated map table
function M.lazy_mappings()
	local lazy_avail, lazy_config = pcall(require, "lazy.core.config")
	if not lazy_avail then return nil end

	local skip = { mode = true, lhs = true, rhs = true }
	local map_table = require("mapper").empty_map_table()
	for _, plugin in pairs(lazy_config.plugins) do -- loop over plugins
		local mappings = lazy_config.spec.plugins[plugin.name].mappings

		-- Dear developer if you are seeing this poorly written implementation
		-- I'm sorry I hurt your eyes :)
		if mappings then
			for _, mapping in pairs(mappings) do -- loop over plugin mappings
				local modes = mapping.mode or { "n" }
				modes = type(modes) == "string" and { modes } or modes
				local lhs = mapping[1] or mapping.lhs
				local rhs = mapping[2] or mapping.rhs
				for _, mode in pairs(modes) do -- set key mappings for each mode
					map_table[mode][lhs] = { rhs }
  				for key, value in pairs(mapping) do
    				if type(key) ~= "number" and not skip[key] then
      				map_table[mode][lhs][key] = value
    				end
  				end
				end
			end
		end
	end

	return map_table
end

return M
