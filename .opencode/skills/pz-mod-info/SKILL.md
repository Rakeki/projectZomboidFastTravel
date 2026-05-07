# PZ mod.info Skill

## Description
Guides creation of mod.info files for Project Zomboid mods. Use when creating or editing mod.info.

## mod.info Format

Required fields:
```
name=Mod Name
id=mod_id_lowercase
description=Mod description here
modversion=42
```

Optional fields:
```
poster=poster.png
icon=icon.png
url=https://steamcommunity.com/sharedfiles/filedetails/?id=123456
```

## FastTravel Example
```
name=Fast Travel
id=FastTravel
description=Adds a fast travel button to vehicle dashboards. Teleport to your safe house or discovered cities.
modversion=42
```

## Notes
- `id` must be unique, no spaces
- `modversion` should match target build (41 or 42)
- Place in mod root directory (not in 42/ folder)
