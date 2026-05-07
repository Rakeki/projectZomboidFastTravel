# PZ Lua Modding Skill

## Description
Guides Lua scripting for Project Zomboid mods. Use when writing Lua code, using Lua API, or working with Kahlua.

## Lua API Basics

PZ uses Kahlua (Lua 5.1 implementation with Java interop).

## Module Pattern
```lua
FastTravel = FastTravel or {}
FastTravel.ModuleName = FastTravel.ModuleName or {}

-- Module code here
```

## Java Interop
Access Java objects and methods from Lua:
```lua
local cell = getCell()
local square = cell:getGridSquare(x, y, z)
```

## Common Lua Objects
- `getCell()` - Get current game cell
- `getPlayer()` - Get player object
- `Events` - Event system for hooking game events
- `luautils` - Utility functions

## FastTravel Example
```lua
function FastTravel.Definitions.findValidTeleportSquare(targetX, targetY, maxRadius)
    local cell = getCell()
    if not cell then return nil end

    local sq = cell:getGridSquare(targetX, targetY, 0)
    if sq then
        return sq
    end
    -- Search nearby squares
end
```

## Key Resources
- Lua 5.1 reference: https://www.lua.org/manual/5.1/
- PZ Lua objects: see wiki Lua_object page
- PZ Java objects: see wiki Java_object page
