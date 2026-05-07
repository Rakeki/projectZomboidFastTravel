# PZ Networking Skill

## Description
Guides multiplayer networking for PZ mods. Use when adding server/client communication or syncing data.

## Server/Client Split

Build 42+ requires explicit server/client code separation:
- `server/` - Runs on server only
- `client/` - Runs on client only
- `shared/` - Runs on both

## FastTravel Structure
```
shared/FastTravel/FastTravelDefinitions.lua  -- Shared definitions
client/FastTravel/FastTravelMain.lua         -- Client UI/logic
server/FastTravel/FastTravelServer.lua       -- Server logic
```

## Networking Basics

Send data from server to clients:
```lua
sendServerCommand(module, method, args, player)
```

Send data from client to server:
```lua
sendClientCommand(module, method, args)
```

Register handlers:
```lua
-- Server side
Events.OnClientCommand.Add(function(module, command, player, args)
    if module == "FastTravel" then
        -- Handle command
    end
end)

-- Client side
Events.OnServerCommand.Add(function(module, command, args)
    if module == "FastTravel" then
        -- Handle command
    end
end)
```

## MP Cooldown Example
```lua
FastTravel.Definitions.MpCooldownSeconds = 60
```
