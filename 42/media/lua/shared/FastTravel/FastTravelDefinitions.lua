FastTravel = FastTravel or {}
FastTravel.Definitions = FastTravel.Definitions or {}

FastTravel.Definitions.CHUNK_SIZE = 10

FastTravel.Definitions.Cities = {
    {
        name = "Riverside",
        teleportX = 6435,
        teleportY = 5282,
    },
    {
        name = "Rosewood",
        teleportX = 8105,
        teleportY = 11578,
    },
    {
        name = "Muldraugh",
        teleportX = 10593,
        teleportY = 9738,
    },
    {
        name = "West Point",
        teleportX = 11920,
        teleportY = 6900,
    },
    {
        name = "Louisville",
        teleportX = 12500,
        teleportY = 1800,
    },
}

FastTravel.Definitions.CountdownSeconds = 5
FastTravel.Definitions.MpCooldownSeconds = 60
FastTravel.Definitions.DiscoveryRadius = 500

function FastTravel.Definitions.isCityDiscovered(cityDef)
    -- Check modData (previously discovered)
    local discovered = FastTravel.Definitions.getDiscoveredCitiesData()
    if discovered then
        for _, name in ipairs(discovered) do
            if name == cityDef.name then
                return true
            end
        end
    end
    -- Also check proximity (simplified discovery)
    return FastTravel.Definitions.isAreaExplored(cityDef.teleportX, cityDef.teleportY)
end

function FastTravel.Definitions.getDiscoveredCitiesData()
    local player = getPlayer()
    if not player then return nil end
    local modData = player:getModData()
    if not modData.FastTravelDiscovered then
        modData.FastTravelDiscovered = {}
    end
    return modData.FastTravelDiscovered
end

function FastTravel.Definitions.discoverCity(cityDef)
    local discovered = FastTravel.Definitions.getDiscoveredCitiesData()
    if not discovered then return end
    for _, name in ipairs(discovered) do
        if name == cityDef.name then
            return
        end
    end
    table.insert(discovered, cityDef.name)
    print("FastTravel: Discovered city - " .. cityDef.name)
end

function FastTravel.Definitions.checkAndDiscoverCurrentLocation()
    local player = getPlayer()
    if not player then return end
    local px = player:getX()
    local py = player:getY()
    if not px or not py then return end

    for _, city in ipairs(FastTravel.Definitions.Cities) do
        local dx = px - city.teleportX
        local dy = py - city.teleportY
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist < FastTravel.Definitions.DiscoveryRadius then
            FastTravel.Definitions.discoverCity(city)
        end
    end
end

function FastTravel.Definitions.isAreaExplored(worldX, worldY, radius)
    -- Simplified: check if player has discovered this area via proximity
    -- PZ 42 doesn't expose WorldMapData API to Lua in single-player
    if not getPlayer or type(getPlayer) ~= "function" then return false end
    local player = getPlayer()
    if not player then return false end
    if not player.getX or not player.getY then return false end

    local px = player:getX()
    local py = player:getY()
    if not px or not py then return false end

    local dx = px - worldX
    local dy = py - worldY
    radius = radius or FastTravel.Definitions.DiscoveryRadius
    return (dx*dx + dy*dy) < (radius*radius)
end

function FastTravel.Definitions.getSafehouse()
    local player = getPlayer()
    if not player then return nil end

    -- Check modData for saved safehouse position (single-player or fallback)
    local modData = player:getModData()
    if modData.FastTravelSafehouseX then
        return { getX = function() return modData.FastTravelSafehouseX end, getY = function() return modData.FastTravelSafehouseY end }
    end

    -- Try getSafehouse() with pcall (multiplayer safehouse)
    local ok, safehouse = pcall(function() return player:getSafehouse() end)
    if ok and safehouse and safehouse.getX then
        return safehouse
    end

    return nil
end

function FastTravel.Definitions.setSafehouse(x, y)
    local player = getPlayer()
    if not player then return end
    local modData = player:getModData()
    modData.FastTravelSafehouseX = x
    modData.FastTravelSafehouseY = y
    print("FastTravel: Safehouse set to " .. x .. ", " .. y)
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
