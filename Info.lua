
-- Info.lua

-- Implements the g_PluginInfo standard plugin description





g_PluginInfo =
{
	Name = "PrivateBlocks",
	Date = "2014-10-17",
	Description =
[[
Auto-protects each block that each player places or breaks.
]],

	Commands =
	{
		["/privateblocks"] =
		{
			Subcommands =
			{
				addfriend =
				{
					HelpString = "Adds a friend to the list of people who can interact with your blocks",
					Permission = "privateblocks.user.addfriend",
					Handler = handlePBAddFriend,
					ParameterCombinations =
					{
						{
							Params = "Player",
							HelpString = "Adds Player to the list of people who can interact with your blocks",
						},
					},
				},  -- addfriend
				
				lsfriends =
				{
					HelpString = "Lists all people you have allowed to interact with your blocks",
					Permission = "privateblocks.user.lsfriends",
					Alias = "listfriends",
					Handler = handlePBLsFriends,
				},  -- lsfriends
				
				rmfriend =
				{
					HelpString = "Adds a friend to the list of people who can interact with your blocks",
					Permission = "privateblocks.user.rmfriend",
					Alias = "removefriend",
					Handler = handlePBRmFriend,
					ParameterCombinations =
					{
						{
							Params = "Player",
							HelpString = "Removes Player from the list of people who can interact with your blocks",
						},
					},
				},  -- rmfriend
			},  -- Subcommands
		},  -- "/privateblocks"
	},  -- Commands
	
	Permissions =
	{
		["privateblocks.admin.override"] =
		{
			Description = "Place and dig blocks regardless of their ownership",
			RecommendedGroups = "admins, mods",
		},
	},  -- Permissions
}




