
-- Commands.lua

-- Implements the handlers for the in-game commands





function handlePBAddFriend(a_Split, a_Player)
	-- Check params:
	local friendName = a_Split[4]
	if not(friendName) then
		a_Player:SendMessage("Usage: /privateblocks friend add <name>")
		return true
	end
	if (friendName == a_Player:GetName()) then
		a_Player:SendMessage("You cannot add yourself as a friend")
		return true
	end
	
	-- Get the friend's UUID:
	local friendUUID
	if (cRoot:Get():GetServer():ShouldAuthenticate()) then
		friendUUID = cMojangAPI:GetUUIDFromPlayerName(friendName, true)
		if (not(friendUUID) or (friendUUID == "")) then
			-- UUID not available in the cache
			a_Player:SendMessage(string.format(
				"Player %s hasn't been to this server yet. They need to connect first before you can add them as a friend", friendName
			))
			return true
		end
	else
		friendUUID = cClientHandle:GenerateOfflineUUID(friendName)
	end
	
	-- Add the friend in the DB:
	local res, msg = g_Storage:addFriend(a_Player:GetUUID(), friendUUID)
	if not(res) then
		a_Player:SendMessage(string.format(
			"Failed to add %s as a friend, the database reports error %s",
			friendName, msg or "<unknown error>"
		))
		return true
	end
	
	a_Player:SendMessage(string.format("Player %s added as a friend.", friendName))
	return true
end





function handlePBListFriends(a_Split, a_Player)
	-- Get all friends' UUIDs from the DB:
	local friendUUIDs, msg = g_Storage:getAllFriends(a_Player:GetUUID())
	if not(friendUUIDs) then
		a_Player:SendMessage(string.format(
			"Failed to get a list of friends from the database: %s",
			msg or "<unknown error>"
		))
		return true
	end
	
	-- Convert each UUID to playername:
	local friendNames = {}
	for _, uuid in ipairs(friendUUIDs) do
		local name = cMojangAPI:GetPlayerNameFromUUID(uuid, false)
		if (name and (name ~= "")) then
			table.insert(friendNames, name)
		end
	end
	table.sort(friendNames)
	
	-- Send result to player:
	if not(friendNames[1]) then
		a_Player:SendMessage("You haven't allowed any friends to change your blocks")
	else
		a_Player:SendMessage(string.format(
			"You have allowed the following friends to change your blocks: %s",
			table.concat(friendNames, ", ")
		))
	end
	return true
end





function handlePBRemoveFriend(a_Split, a_Player)
	-- Check params:
	local friendName = a_Split[4]
	if not(friendName) then
		a_Player:SendMessage("Usage: /privateblocks friend remove <name>")
		return true
	end

	-- Get the friend's UUID:
	local friendUUID
	if (cRoot:Get():GetServer():ShouldAuthenticate()) then
		friendUUID = cMojangAPI:GetUUIDFromPlayerName(friendName, true)
		if (not(friendUUID) or (friendUUID == "")) then
			-- UUID not available in the cache
			a_Player:SendMessage(string.format(
				"Player %s hasn't been to this server yet, so you cannot have them as a friend", friendName
			))
			return true
		end
	else
		friendUUID = cClientHandle:GenerateOfflineUUID(friendName)
	end
	
	-- Remove from the DB:
	local res, msg = g_Storage:removeFriend(a_Player:GetUUID(), friendUUID)
	if not(res) then
		a_Player:SendMessage(string.format(
			"Failed to remove %s from your friends, the database reports error %s",
			friendName, msg or "<unknown error>"
		))
		return true
	end
	
	a_Player:SendMessage(string.format("Player %s is no longer your friend.", friendName))
	return true
end




