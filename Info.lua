
-- Info.lua

-- Implements the g_PluginInfo standard plugin description





g_PluginInfo =
{
	Name = "PrivateBlocks",
	Date = "2014-10-17",
	SourceLocation = "https://github.com/madmaxoft/PrivateBlocks",
	Description =
[[
Auto-protects each block that each player places or breaks.

Each block that a player builds is automatically added to their list of protected blocks, thus prohibiting
other players from breaking the block. Players can additionally define friends who are able to break their
blocks. The server admins and moderators (when given the proper permissions) can always break all blocks.

Note that friendship is a one-way relationship - declaring someone a friend only means they can break your
blocks, it doesn't allow you to break your blocks (because if it did, friending an admin would be a
hackdoor).
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
					HelpString = "Removes a former friend from the list of people who can interact with your blocks",
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
		["privateblocks.user.addfriend"] =
		{
			Description = "Add a friend so that they can break my blocks",
			RecommendedGroups = "default",
		},
		["privateblocks.user.lsfriends"] =
		{
			Description = "List people who can break my blocks",
			RecommendedGroups = "default",
		},
		["privateblocks.user.rmfriend"] =
		{
			Description = "Remove a former friend so that they cannot break my blocks anymore",
			RecommendedGroups = "default",
		},
	},  -- Permissions
}




