
-- PlayerState.lua

-- Implements the cPlayerState class representing the state of one player
--[[
The state stores all the protected blocks in the immediate vicinity of a player.
--]]





--- The range around each player which doesn't require reloading the neighborhood
local RANGE = 16

--- The potential reach of the player, added to RANGE when loading the neighborhood
local REACH = 6

--- The class representing the playerstate:
local cPlayerState = {}
cPlayerState.__index = cPlayerState

--- A map of EntityId -> cPlayerState for the online players:
local g_PlayerStates = {}





--- Returns true if the player is allowed to interact with the specified block
function cPlayerState:canInteractWithBlock(a_BlockX, a_BlockY, a_BlockZ)
	-- Check each block in the loaded neighborhood:
	for _, block in ipairs(self.blocks) do
		if ((block.x == a_BlockX) and (block.y == a_BlockY) and (block.z == a_BlockZ)) then
			-- This is a protected block, check the owner:
			if (self.allowed[block.owner]) then
				-- We are a friend of the owner, allow:
				return true
			end
			-- We are not a friend of the owner, disallow:
			return false
		end
	end
	
	-- The block is not protected, allow:
	return true
end





function cPlayerState:initialize(a_Player)
	-- Set the basic properties of the state:
	self.playerID = a_Player:GetUniqueID()
	self.neighborhood = cCuboid()
	self.world = a_Player:GetWorld():GetName()

	-- Reload the neighborhood:
	self:reloadNeighborhood(a_Player:GetPosition())
	
	-- Get the array of friends, convert it into a map for easier lookup:
	self.uuid = a_Player:GetUUID()
	self.allowed = {}
	local allowed = g_Storage:getAllAllowed(self.uuid)
	for _, uuid in ipairs(allowed) do
		self.allowed[uuid] = true
	end
	self.allowed[self.uuid] = true
end





--- Reloads the neighborhood at the specified center point
function cPlayerState:reloadNeighborhood(a_NewPos)
	local x = a_NewPos.x
	local y = a_NewPos.y
	local z = a_NewPos.z
	self.blocks = g_Storage:getProtectedBlocks(self.world, x, y, z, RANGE + REACH)
	self.neighborhood:Assign(x - RANGE, y - RANGE, z - RANGE, x + RANGE, y + RANGE, z + RANGE)
end






--- Creates a new player state for the specified player ID, and stores it in g_PlayerStates
local function newPlayerState(a_Player)
	-- Create a new instance:
	local state = {}
	setmetatable(state, cPlayerState)
	state:initialize(a_Player)
	
	-- Set the state in the global map:
	g_PlayerStates[a_Player:GetUniqueID()] = state
	
	return state
end





--- Returns a player state for the specified player
function getPlayerState(a_Player)
	return g_PlayerStates[a_Player:GetUniqueID()] or newPlayerState(a_Player)
end





--- Callback for HOOK_PLAYER_BREAKING_BLOCK.
-- Checks if the block can be broken
local function onPlayerBreakingBlock(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_BlockType, a_BlockMeta)
	-- If the player has an admin permission, let them dig anywhere:
	if (a_Player:HasPermission("privateblocks.admin.override")) then
		return false;
	end

	-- Check the neighborhood:
	local state = getPlayerState(a_Player)
	if (state:canInteractWithBlock(a_BlockX, a_BlockY, a_BlockZ)) then
		return false
	end
	
	-- Not allowed, send an error message and replace the block:
	a_Player:SendMessageFailure("This block is protected")
	return true
end





--- Handler for HOOK_PLAYER_MOVING
-- Updates the loaded neighborhood, if needed
local function onPlayerMoving(a_Player, a_OldPosition, a_NewPosition)
	-- If the player has moved out of the loaded neighborhood, reload:
	local state = getPlayerState(a_Player)
	if not(state.neighborhood:IsInside(a_NewPosition)) then
		state:reloadNeighborhood(a_NewPosition)
	end
end





--- Handler for HOOK_PLAYER_PLACING_BLOCK.
-- Checks if the block can be placed here and if so, protects it.
local function onPlayerPlacingBlock(a_Player, a_BlockX, a_BlockY, a_BlockZ)
	-- Check if the block is available:
	local state = getPlayerState(a_Player)
	if not(state:canInteractWithBlock(a_BlockX, a_BlockY, a_BlockZ)) then
		-- The block is owned by someone who hasn't friended us; check the override permission:
		if not(a_Player:HasPermission("privateblocks.admin.override")) then
			a_Player:SendMessageFailure("This place is protected")
			return true
		end
	end
	
	-- Claim the block:
	g_Storage:claimBlock(a_Player:GetWorld():GetName(), a_BlockX, a_BlockY, a_BlockZ, a_Player:GetUUID())
end





--- Initializes the player state handling
function initPlayerStates()
	-- If reloading, initialize the state for each already present player:
	cRoot:Get():ForEachPlayer(getPlayerState)
	
	-- Add the hooks required for operation:
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_BREAKING_BLOCK, onPlayerBreakingBlock)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_MOVING,         onPlayerMoving)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_PLACING_BLOCK,  onPlayerPlacingBlock)
end



