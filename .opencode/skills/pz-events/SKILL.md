# PZ Events Skill

## Description
Guides usage of PZ Lua events system. Use when hooking into game events or triggering custom events.

## Common Events

### Game Lifecycle
- `OnGameStart` - Game fully loaded
- `OnLoad` - Map/mod loaded
- `OnCreatePlayer` - Player created

### Player Events
- `OnPlayerUpdate` - Player tick
- `OnPlayerDeath` - Player died

### UI Events
- `OnPostUIDraw` - After UI rendered

## Event Usage

Add event handler:
```lua
local function onGameStart()
    print("FastTravel: Game started")
end

Events.OnGameStart.Add(onGameStart)
```

Remove event handler:
```lua
Events.OnGameStart.Remove(onGameStart)
```

## FastTravel Example
```lua
local function onGameStart()
    print("FastTravel: Game started")
end

Events.OnGameStart.Add(onGameStart)
```

## Custom Events
Create custom event table:
```lua
FastTravel.Events = {}
FastTravel.Events.OnTeleport = {}
```

Trigger custom event:
```lua
triggerEvent("OnFastTravelTeleport", player, destination)
```
