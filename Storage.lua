
-- Storage.lua

-- Implements the Storage that saves and loads the data in the DB





g_Storage = {}





--- Adds the specified friend for the specified player
-- Returns true on success, nil and error message on failure
function g_Storage:addFriend(a_PlayerUuid, a_FriendUuid)
	-- Check the params:
	assert(type(a_PlayerUuid) == "string")
	assert(type(a_FriendUuid) == "string")
	
	-- Insert into DB:
	return self.DB:executeStatement(
		"INSERT INTO Friends(Player, Friend) VALUES (?, ?)",
		{ a_PlayerUuid, a_FriendUuid }
	)
end





--- Adds a new protected block for the specified player
-- Returns true on success, nil and error message on failure
function g_Storage:addProtectedBlock(a_WorldName, a_BlockX, a_BlockY, a_BlockZ, a_PlayerUuid)
	-- Check params:
	assert(type(a_WorldName) == "string")
	assert(type(a_BlockX) == "number")
	assert(type(a_BlockY) == "number")
	assert(type(a_BlockZ) == "number")
	assert(type(a_PlayerUuid) == "string")
	
	-- Insert into the DB:
	return self.DB:executeStatement(
		"INSERT INTO Blocks(World, X, Y, Z, Player) VALUES (?, ?, ?, ?, ?)",
		{ a_WorldName, a_BlockX, a_BlockY, a_BlockZ, a_PlayerUuid }
	)
end





--- Claims the specified block by the specified player.
-- If the block has already been claimed, changes the ownership to the new player
-- Returns true on success, nil and error message on failure
function g_Storage:claimBlock(a_WorldName, a_BlockX, a_BlockY, a_BlockZ, a_PlayerUuid)
	-- Check the params:
	assert(type(a_WorldName) == "string")
	assert(type(a_BlockX) == "number")
	assert(type(a_BlockY) == "number")
	assert(type(a_BlockZ) == "number")
	assert(type(a_PlayerUuid) == "string")
	
	-- Change the DB inside a transaction:
	return self.DB:transaction(function()
		-- Check if the block is already claimed:
		local rowID
		local isSuccess, err = self.DB:executeStatement(
			"SELECT rowid FROM Blocks WHERE (World = ?) AND (X = ?) AND (Y = ?) AND (Z = ?)",
			{ a_WorldName, a_BlockX, a_BlockY, a_BlockZ },
			function (a_Values)
				rowID = a_Values["rowid"]
			end
		)
		if not(isSuccess) then
			return nil, err
		end
		
		-- "Upsert" - update / insert the row in the DB:
		if (rowID) then
			-- The block is already claimed, change the ownership (assumes that the player has already been permission-checked):
			return self.DB:executeStatement(
				"UPDATE Blocks SET Player = ?, DateTime = ? WHERE ROWID = ?",
				{ a_PlayerUuid, rowID, os.time() }
			)
		else
			-- The block is not in the DB, add it:
			return self.DB:executeStatement(
				"INSERT INTO Blocks (World, X, Y, Z, Player, DateTime) VALUES (?, ?, ?, ?, ?, ?)",
				{ a_WorldName, a_BlockX, a_BlockY, a_BlockZ, a_PlayerUuid, os.time() }
			)
		end
	end)
end





--- Returns an array of all players that have added a_PlayerUuid as their friend
-- Returns nil and error message on failure
function g_Storage:getAllAllowed(a_PlayerUuid)
	-- Check the params:
	assert(type(a_PlayerUuid) == "string")
	
	-- Query the DB:
	local res = {}
	local isSuccess, err = self.DB:executeStatement(
		"SELECT Player FROM Friends WHERE Friend = ?",
		{ a_PlayerUuid },
		function (a_Values)
			table.insert(res, a_Values["Player"])
		end
	)
	if not(isSuccess) then
		return nil, err
	end
	
	return res
end





--- Returns an array of all friends of the specified player
-- Returns nil and error message on failure
function g_Storage:getAllFriends(a_PlayerUuid)
	-- Check the params:
	assert(type(a_PlayerUuid) == "string")
	
	-- Query the DB:
	local res = {}
	local isSuccess, err = self.DB:executeStatement(
		"SELECT Friend FROM Friends WHERE Player = ?",
		{ a_PlayerUuid },
		function (a_Values)
			table.insert(res, a_Values["Friend"])
		end
	)
	if not(isSuccess) then
		return nil, err
	end
	
	return res
end





--- Returns an array of all the protected blocks in the specified range ( [x - range, x + range], ...)
-- Each array item is a table with x, y, z, owner members
function g_Storage:getProtectedBlocks(a_WorldName, a_BlockX, a_BlockY, a_BlockZ, a_Range)
	-- Check the params:
	assert(type(a_WorldName) == "string")
	assert(type(a_BlockX) == "number")
	assert(type(a_BlockY) == "number")
	assert(type(a_BlockZ) == "number")
	assert(type(a_Range) == "number")

	-- Get the range coords:
	local maxX = a_BlockX + a_Range
	local minX = a_BlockX - a_Range
	local maxY = a_BlockY + a_Range
	local minY = a_BlockY - a_Range
	local maxZ = a_BlockZ + a_Range
	local minZ = a_BlockZ - a_Range
	
	-- Query the DB:
	local res = {}
	local n = 1  -- table.insert is slow for repeated adds, we use a counter instead
	local isSuccess, err = self.DB:executeStatement(
		"SELECT X, Y, Z, Player FROM Blocks WHERE (World = ?) AND (X >= ?) AND (X <= ?) AND (Y >= ?) AND (Y <= ?) AND (Z >= ?) AND (Z <= ?)",
		{ a_WorldName, minX, maxX, minY, maxY, minZ, maxZ },
		function (a_Values)
			res[n] = { x = a_Values["X"], y = a_Values["Y"], z = a_Values["Z"], owner = a_Values["Player"] }
			n = n + 1
		end
	)
	if not(isSuccess) then
		return nil, err
	end
	
	return res
end





--- Removes the specified friend from the specified player
-- Returns true on success, nil and error message on failure
function g_Storage:removeFriend(a_PlayerUuid, a_FriendUuid)
	-- Check the params:
	assert(type(a_PlayerUuid) == "string")
	assert(type(a_FriendUuid) == "string")
	
	-- Remove from DB:
	return self.DB:executeStatement(
		"INSERT INTO Friends(Player, Friend) VALUES (?, ?)",
		{ a_PlayerUuid, a_FriendUuid }
	)
end





--- Initializes the storage, opens the DB
-- Throws on error
function initStorage()
	-- Open the DB:
	local err
	g_Storage.DB, err = newSQLiteDB("PrivateBlocks.sqlite")
	if not(g_Storage.DB) then
		LOGWARNING("Cannot initialize ProtectedBlocks DB: " .. (err or "<unspecified error>"))
		error(err or "<unknown error>")
	end
	
	-- Define the needed structure:
	local blocksColumns =
	{
		"World",
		"X",
		"Y",
		"Z",
		"Player",
		"DateTime",
	}
	local friendsColumns =
	{
		"Player",
		"Friend",
	}
	
	-- Check / create structure:
	if (
		not(g_Storage.DB:createDBTable("Blocks",  blocksColumns)) or
		not(g_Storage.DB:createDBTable("Friends", friendsColumns))
	) then
		LOGWARNING("Cannot initialize the PrivateBlocks DB")
		error("Coiny economy DB failure")
	end
end




