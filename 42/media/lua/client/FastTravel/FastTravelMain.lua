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

local function trySpawnVehicle(scriptName, x, y)
    local v = addVehicle(scriptName, x, y, 0)
    if v then
        local ok, script = pcall(function() return v:getScript() end)
        if ok and script then return v end
    end
    return nil
end

local function findVehicleSpawn(scriptName, tx, ty, maxRadius)
    local v = trySpawnVehicle(scriptName, tx, ty)
    if v then return v, tx, ty end
    for r = 1, maxRadius do
        for dx = -r, r do
            for dy = -r, r do
                if math.abs(dx) == r or math.abs(dy) == r then
                    local sq = getSquare(tx + dx, ty + dy, 0)
                    if sq then
                        local fail, isWater = pcall(function() return sq:isWater() end)
                        if fail and isWater then break end
                    end
                    v = trySpawnVehicle(scriptName, tx + dx, ty + dy)
                    if v then return v, tx + dx, ty + dy end
                end
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

                local newVehicle, spawnX, spawnY = findVehicleSpawn(scriptName, tx, ty, 30)
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
