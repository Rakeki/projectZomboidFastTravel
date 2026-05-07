# PZ Translations Skill

## Description
Guides creation of translation files for PZ mods. Use when adding multi-language support.

## Translation File Structure

Location: `shared/Translate/[LANG]/[ModID]_[LANG].txt`

Example from FastTravel:
```
shared/Translate/EN/FastTravel_EN.txt
```

## Translation Format
```
UI_FastTravel_Title=Fast Travel
UI_FastTravel_Destination=Destination
UI_FastTravel_Teleport=Teleport
```

## Available Languages
- EN (English)
- FR (French)
- DE (German)
- ES (Spanish)
- IT (Italian)
- RU (Russian)
- etc.

## Usage in Lua
```lua
local text = getText("UI_FastTravel_Title")
```

## FastTravel Example
File: `shared/Translate/EN/FastTravel_EN.txt`
Content: Translations for FastTravel mod UI strings.
