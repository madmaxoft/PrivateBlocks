
-- Config.lua

-- Implements the plugin's configuration storage and its loading





--- Storage for all the configuration settings
--[[
Members that are expected to be present:
- disabledWorlds - dictionary of worldname -> true for each world that is explicitly disabled
- worlds - dictionary of worldname -> true for each world that is enabled
--]]
g_Config = {}





--- Checks the config if it has all the needed keys, inserts defaults for missing ones
local function verifyConfig()
	-- Process an array of disabled world names into a dict for easier lookup:
	local disabledWorlds = g_Config.disabledWorlds or {}
	local isWorldDisabled = {}
	for _, name in ipairs(disabledWorlds) do
		isWorldDisabled[name] = true
	end
	g_Config.disabledWorlds = isWorldDisabled

	-- Get the list of enabled worlds by subtracting the DisabledWorlds from all worlds:
	g_Config.worlds = {}
	cRoot:Get():ForEachWorld(
		function (a_CBWorld)
			local name = a_CBWorld:GetName()
			if not(isWorldDisabled[name]) then
				g_Config.worlds[name] = true
			end
		end
	)
end





--- Hook to be called when a new world is created
-- Adds the world to the list of active worlds, unless explicitly disabled
local function addNewWorld(a_World)
	local name = a_World:GetName()
	if (g_Config.disabledWorlds[name]) then
		return
	end
	g_Config.worlds[name] = true
end





--- Loads the configuration; 
local function loadConfig()
	if not(cFile:IsFile(CONFIG_FILE)) then
		-- No file to read from, bail out with a log message
		-- But first copy our example file to the folder, to let the admin know the format:
		local pluginFolder = cPluginManager:Get():GetCurrentPlugin():GetLocalFolder()
		local exampleFile = CONFIG_FILE:gsub(".cfg", ".example.cfg")
		if (cFile:Copy(pluginFolder .. "/example.cfg", exampleFile)) then
			LOGWARNING(PLUGIN_PREFIX .. "The config file '" .. CONFIG_FILE .. "' doesn't exist. Defaults will be used. An example configuration file '" .. exampleFile .. "' has been created for you; rename it and edit it to your liking.")
		else
			LOGWARNING(PLUGIN_PREFIX .. "The config file '" .. CONFIG_FILE .. "' doesn't exist. Defaults will be used.")
		end
		return
	end
	
	-- Load and compile the config file:
	local cfg, err = loadfile(CONFIG_FILE)
	if (cfg == nil) then
		LOGWARNING(PLUGIN_PREFIX .. "Cannot load config: " .. err)
		return
	end
	
	-- Execute the loaded file in a sandbox:
	-- This is Lua-5.1-specific and won't work in Lua 5.2!
	local sandbox = {}
	setfenv(cfg, sandbox)
	local isSuccess
	isSuccess, err = pcall(cfg)
	if not(isSuccess) then
		LOGWARNING(PLUGIN_PREFIX .. "Cannot load config: " .. err)
		return
	end
	
	-- Retrieve the values we want from the sandbox:
	g_Config = sandbox.config
	if (g_Config == nil) then
		LOGWARNING(PLUGIN_PREFIX .. "config not found in the config file '" .. CONFIG_FILE .. "'. Using defaults.")
		g_Config = {}  -- Defaults will be inserted by verifyConfig()
	end
end





--- Initializes the config subsystem
function initConfig()
	-- Load the config files:
	loadConfig()
	
	-- Check validity:
	verifyConfig()
	
	-- Add a hook to account for newly created worlds:
	cPluginManager:AddHook(cPluginManager.HOOK_WORLD_STARTED, addNewWorld)
end




