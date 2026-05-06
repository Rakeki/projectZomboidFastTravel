FastTravel = FastTravel or {}
FastTravel.Definitions = FastTravel.Definitions or {}

FastTravel.Definitions.CHUNK_SIZE = 10

FastTravel.Definitions.Cities = {
    {
        name = "Riverside",
        teleportX = 1700,
        teleportY = 1620,
    },
    {
        name = "Rosewood",
        teleportX = 1620,
        teleportY = 1860,
    },
    {
        name = "Muldraugh",
        teleportX = 1790,
        teleportY = 1570,
    },
    {
        name = "West Point",
        teleportX = 1750,
        teleportY = 1820,
    },
    {
        name = "Louisville",
        teleportX = 2000,
        teleportY = 1480,
    },
}

FastTravel.Definitions.CountdownSeconds = 5
FastTravel.Definitions.MpCooldownSeconds = 60

function FastTravel.Definitions.isCityDiscovered(cityDef)
    return true
end

function FastTravel.Definitions.getSafehouse()
    return nil
end

function FastTravel.Definitions.findValidTeleportSquare(targetX, targetY, maxRadius)
    maxRadius = maxRadius or 50

    local sq = getSquare(targetX, targetY, 0)
    if sq then
        return sq
    end

    print("FastTravel: No square at exact coords (" .. targetX .. ", " .. targetY .. "), trying nearby...")
    for radius = 1, maxRadius do
        for dx = -radius, radius do
            for dy = -radius, radius do
                if math.abs(dx) == radius or math.abs(dy) == radius then
                    local checkX = targetX + dx
                    local checkY = targetY + dy
                    local checkSq = getSquare(checkX, checkY, 0)
                    if checkSq then
                        print("FastTravel: Found valid square at (" .. checkX .. ", " .. checkY .. ")")
                        return checkSq
                    end
                end
            end
        end
    end

    print("FastTravel: No valid teleport square found within radius " .. maxRadius)
    return nil
end

function FastTravel.Definitions.getDiscoveredCities()
    local discovered = {}
    for _, city in ipairs(FastTravel.Definitions.Cities) do
        if FastTravel.Definitions.isCityDiscovered(city) then
            table.insert(discovered, city)
        end
    end
    return discovered
end
