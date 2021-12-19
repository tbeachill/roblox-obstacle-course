# Roblox Obstacle Course
An obstacle course created for the metaverse "Roblox".

## Directories
### Client
 - `Sound.lua` contains the code for playing sounds.
 - `DoubleJump.client.lua` contains the code for double jumping.
 - `Effects.lua` module that contains visual and audio effects.
 - `init.client.lua` loads the module scripts.

### Server
 - `Chat.lua` module for interacting with the chat.
 - `Data.lua` contains all player variables and deals with saving and loading from the Roblox servers.
 - `Initialise.lua` contains code that is run when a player first joins the game.
 - `Monetisation.lua` module for the in-game shop.
 - `PartFunctions.lua` module to control the behaviour of named groups of parts.
 - `Physics.lua` sets up the physical interactions within the game.
 - `VIPArea.lua` contains code for interactions in the VIP area.
 - `init.server.lua` Loads each of the server modules.

### Shared
 - `ShopItems` is the directory where shop items are kept ready to be copied when a player makes a purchase.

### Gui
 - Contains assets and code for the user-interface. Includes the buttons, a shop interface, a notice if a player goes in the wrong direction and stage announcements.
