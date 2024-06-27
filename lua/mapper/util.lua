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

return M
