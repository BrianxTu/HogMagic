# Player Module

This is the module for all Player related items. Written by BrianTU#0001

## Setup

Simply head to the Config.lua and moidify the options as seen fit

## Developers/Owners

If you want to change the permission to a command, simply go to the commands file and look for "admin" or "mod" and add to the {table} or simply replace the table with "yourRole"

Example
```lua
Exports.player.registerCommand("cmdName", function(Player, args)

end, {"admin", "mod"})
```

