Auto-protects each block that each player places or breaks.

Each block that a player builds is automatically added to their list of protected blocks, thus prohibiting other players from breaking the block. Players can additionally define friends who are able to break their blocks. The server admins and moderators (when given the proper permissions) can always break all blocks.

Note that friendship is a one-way relationship - declaring someone a friend only means they can break your blocks, it doesn't allow you to break your blocks (because if it did, friending an admin would be a hackdoor). 

# Commands

### General
| Command | Permission | Description |
| ------- | ---------- | ----------- |
|/privateblocks friend add | privateblocks.user.addfriend | Adds a friend to the list of people who can interact with your blocks|
|/privateblocks friend list | privateblocks.user.lsfriends | Lists all people you have allowed to interact with your blocks|
|/privateblocks friend remove | privateblocks.user.rmfriend | Removes a former friend from the list of people who can interact with your blocks|



# Permissions
| Permissions | Description | Commands | Recommended groups |
| ----------- | ----------- | -------- | ------------------ |
| privateblocks.admin.override | Place and dig blocks regardless of their ownership |  | admins, mods |
| privateblocks.user.addfriend | Add a friend so that they can break my blocks | `/privateblocks friend add` | default |
| privateblocks.user.lsfriends | List people who can break my blocks | `/privateblocks friend list` | default |
| privateblocks.user.rmfriend | Remove a former friend so that they cannot break my blocks anymore | `/privateblocks friend remove` | default |
