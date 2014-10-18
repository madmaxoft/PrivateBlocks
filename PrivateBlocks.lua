
-- PrivateBlocks.lua

-- Implements the main plugin entrypoint





--- The prefix used for console logging
PLUGIN_PREFIX = "PrivateBlocks: "

--- The name of the config file, stored next to the MCS executable
CONFIG_FILE = "PrivateBlocks.cfg"





function Initialize(a_Plugin)
	-- Initialize the config subsystem:
	initConfig()
	
	-- Initialize the storage subsystem:
	initStorage()
	
	-- Initialize commands:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	RegisterPluginInfoCommands()
	
	-- Initialize the player processing:
	initPlayerStates()
	
	return true
end




