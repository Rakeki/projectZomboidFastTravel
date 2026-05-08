require "ISUI/ISButton"
require "FastTravel/FastTravelDefinitions"
require "FastTravel/FastTravelDestinationPanel"
require "FastTravel/FastTravelCountdownUI"

print("=== FastTravel Main Loaded ===")

FastTravel = FastTravel or {}
FastTravel.Main = FastTravel.Main or {}
FastTravel.Main.countdownEnd = nil
FastTravel.Main.targetX = nil
FastTravel.Main.targetY = nil
FastTravel.Main.targetZ = nil
FastTravel.Main.dashboardButton = nil
FastTravel.Main.countdownUI = nil

function getTimeMillis()
    return getGameTime():getCalender():getTimeInMillis()
end

function startCountdown(targetX, targetY, targetZ, destinationName)
    FastTravel.Main.targetX = targetX
    FastTravel.Main.targetY = targetY
    FastTravel.Main.targetZ = targetZ or 0
    FastTravel.Main.countdownEnd = getTimeMillis() + FastTravel.Definitions.CountdownSeconds * 1000
    FastTravel.Main.countdownLabel = destinationName

    local ui = FastTravelCountdownUI:new(destinationName)
    ui:initialise()
    ui:addToUIManager()
    FastTravel.Main.countdownUI = ui

    print("FastTravel: Starting countdown to " .. destinationName)
end

function cancelCountdown()
    FastTravel.Main.countdownEnd = nil
    FastTravel.Main.targetX = nil
    FastTravel.Main.targetY = nil
    FastTravel.Main.targetZ = nil
    FastTravel.Main.countdownLabel = nil
    if FastTravel.Main.countdownUI then
        FastTravel.Main.countdownUI:removeFromUIManager()
        FastTravel.Main.countdownUI = nil
    end
    print("FastTravel: Countdown cancelled")
end

function openDestinationPanel()
    local player = getPlayer()
    if not player then return end
    local vehicle = player:getVehicle()
    if not vehicle or vehicle:getDriver() ~= player then
        print("FastTravel: Must be driver to open panel")
        return
    end
    local w = 700
    local h = 600
    local x = (getCore():getScreenWidth() - w) / 2
    local y = (getCore():getScreenHeight() - h) / 2
    local panel = FastTravelDestinationPanel:new(x, y, w, h, vehicle)
    panel:initialise()
    panel:addToUIManager()
end

local function updateButton()
    local player = getPlayer()
    if player and player:getVehicle() and player:getVehicle():getDriver() == player then
        if not FastTravel.Main.dashboardButton then
            local buttonWidth = 120
            local buttonHeight = 25
            local x = (getCore():getScreenWidth() - buttonWidth) / 2
            local y = getCore():getScreenHeight() - 150
            local button = ISButton:new(x, y, buttonWidth, buttonHeight, "Fast Travel", nil, openDestinationPanel)
            button:initialise()
            button:addToUIManager()
            FastTravel.Main.dashboardButton = button
        end
    else
        if FastTravel.Main.dashboardButton then
            FastTravel.Main.dashboardButton:removeFromUIManager()
            FastTravel.Main.dashboardButton = nil
        end
    end
end

local ROAD_KEYWORDS = { "road", "sidewalk", "parking", "tarmac", "gravel", "drive", "asphalt" }

local function isRoadSquare(x, y)
    local sq = getSquare(x, y, 0)
    if not sq then return false end
    local ok1, water = pcall(function() return sq:isWater() end)
    if ok1 and water then return false end
    local ok2, floor = pcall(function() return sq:getFloor() end)
    if ok2 and floor then
        local ok3, tex = pcall(function() return floor:getTexture() end)
        if ok3 and tex then
            local ok4, name = pcall(function() return tex:getName() end)
            if ok4 and name then
                local n = name:lower()
                for _, kw in ipairs(ROAD_KEYWORDS) do
                    if n:find(kw, 1, true) then return true end
                end
            end
        end
    end
    return false
end

local function trySpawnVehicle(scriptName, x, y)
    local v = addVehicle(scriptName, x, y, 0)
    if v then
        local ok, script = pcall(function() return v:getScript() end)
        if ok and script then return v end
    end
    return nil
end

local function spawnOnNearestRoad(scriptName, tx, ty, maxRadius)
    for r = 1, 30 do
        for dx = -r, r do
            for dy = -r, r do
                if math.abs(dx) == r or math.abs(dy) == r then
                    local nx, ny = tx + dx, ty + dy
                    if isRoadSquare(nx, ny) then
                        local v = trySpawnVehicle(scriptName, nx, ny)
                        if v then return v, nx, ny end
                    end
                end
            end
        end
    end
    for d = 35, maxRadius, 5 do
        for _, dir in ipairs({{1,0},{-1,0},{0,1},{0,-1},{1,1},{-1,1},{1,-1},{-1,-1}}) do
            local nx, ny = tx + dir[1] * d, ty + dir[2] * d
            if isRoadSquare(nx, ny) then
                local v = trySpawnVehicle(scriptName, nx, ny)
                if v then return v, nx, ny end
            end
        end
    end
    return nil, tx, ty
end

local function onTick()
    if FastTravel.Main.countdownEnd and getTimeMillis() >= FastTravel.Main.countdownEnd then
        FastTravel.Main.countdownEnd = nil
        if FastTravel.Main.countdownUI then
            FastTravel.Main.countdownUI:removeFromUIManager()
            FastTravel.Main.countdownUI = nil
        end
        local player = getPlayer()
        if player then
            local tx = FastTravel.Main.targetX
            local ty = FastTravel.Main.targetY
            local vehicle = player:getVehicle()
            if vehicle then
                local scriptName = vehicle:getScript():getFullName()
                local seat = vehicle:getSeat(player)

                vehicle:exit(player)
                vehicle:setCharacterPosition(player, seat, "outside")
                vehicle:permanentlyRemove()

                player:teleportTo(tx + 0.5, ty + 0.5, 0)

                local newVehicle, spawnX, spawnY = spawnOnNearestRoad(scriptName, tx, ty, 500)
                if not newVehicle then
                    newVehicle, spawnX, spawnY = trySpawnVehicle(scriptName, tx, ty), tx, ty
                end
                if newVehicle then
                    if spawnX ~= tx or spawnY ~= ty then
                        player:teleportTo(spawnX + 0.5, spawnY + 0.5, 0)
                    end
                    newVehicle:enter(seat, player)
                    newVehicle:setCharacterPosition(player, seat, "inside")
                    print("FastTravel: Teleported with vehicle to (" .. spawnX .. ", " .. spawnY .. ")")
                else
                    print("FastTravel: Teleported to (" .. tx .. ", " .. ty .. ") - no valid vehicle spawn found")
                end
            else
                player:teleportTo(tx + 0.5, ty + 0.5, 0)
                print("FastTravel: Teleported without vehicle")
            end
        end
        FastTravel.Main.targetX = nil
        FastTravel.Main.targetY = nil
        FastTravel.Main.targetZ = nil
    end
    updateButton()
end

local function onGameStart()
    print("FastTravel: Game started")
end

Events.OnGameStart.Add(onGameStart)
Events.OnTick.Add(onTick)

FastTravel.Main.startCountdown = startCountdown
FastTravel.Main.openDestinationPanel = openDestinationPanel
FastTravel.Main.cancelCountdown = cancelCountdown

local function onKeyKeepPressed(key)
    if key == Keyboard.KEY_H then
        local player = getPlayer()
        if not player then return end
        if not player:getVehicle() then return end

        local x = math.floor(player:getX())
        local y = math.floor(player:getY())
        FastTravel.Definitions.setSafehouse(x, y)
        player:Say("Safehouse set to " .. x .. ", " .. y)
    end
end

Events.OnKeyKeepPressed.Add(onKeyKeepPressed)
