# PZ Mod Structure Skill

## Description
Guides creation of proper Project Zomboid mod folder structure. Use when creating new mods or organizing mod files.

## Mod Structure

Standard PZ mod structure:
```
mods/
  YourMod/
    mod.info          # Required mod metadata
    42/               # Build 42+ folder
      media/
        lua/
          shared/     # Code loaded by both client and server
          client/     # Client-side only code
          server/     # Server-side only code
        scripts/      # Item/recipe definitions (optional)
    media/            # Build 41 and earlier (if supporting both)
```

## FastTravel Mod Example
```
FastTravel/
  mod.info
  42/
    media/lua/
      shared/FastTravel/FastTravelDefinitions.lua
      client/FastTravel/FastTravelMain.lua
      client/FastTravel/FastTravelDestinationPanel.lua
      server/FastTravel/FastTravelServer.lua
```

## Key Points
- Build 42+ uses `42/` prefix folder
- Lua code goes in `media/lua/` subdirectories
- `shared/` code runs on both client and server
- `client/` code only runs on client
- `server/` code only runs on server
- Use folder matching mod name (e.g., `FastTravel/`) inside lua folders
