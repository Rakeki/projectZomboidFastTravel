require "ISUI/ISButton"
require "FastTravel/FastTravelDefinitions"

print("=== FastTravel Main Loaded ===")

FastTravel = FastTravel or {}
FastTravel.Main = FastTravel.Main or {}
FastTravel.Main.countdownLabel = nil
FastTravel.Main.countdownEnd = nil
FastTravel.Main.targetX = nil
FastTravel.Main.targetY = nil
FastTravel.Main.targetZ = nil
FastTravel.Main.dashboardButton = nil

local function onTick()
    if FastTravel.Main.countdownEnd and getGameTime():getTime() >= FastTravel.Main.countdownEnd then
        FastTravel.Main.countdownEnd = nil
        local player = getPlayer()
        if player and player:getVehicle() then
            local vehicle = player:getVehicle()
            local sq = getSquare(FastTravel.Main.targetX, FastTravel.Main.targetY, 0)
            if sq then
                vehicle:setX(FastTravel.Main.targetX)
                vehicle:setY(FastTravel.Main.targetY)
                vehicle:setSquare(sq)
                player:setX(FastTravel.Main.targetX + 0.5)
                player:setY(FastTravel.Main.targetY + 0.5)
                player:setSquare(sq)
                print("FastTravel: Teleported to destination")
            else
                print("FastTravel: No valid square found at destination")
            end
        end
        FastTravel.Main.targetX = nil
        FastTravel.Main.targetY = nil
        FastTravel.Main.targetZ = nil
    end

    local player = getPlayer()
    if player and player:getVehicle() and player:getVehicle():getDriver() == player then
        if not FastTravel.Main.dashboardButton then
            local buttonWidth = 120
            local buttonHeight = 25
            local x = (getCore():getScreenWidth() - buttonWidth) / 2
            local y = getCore():getScreenHeight() - 250
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

function startCountdown(targetX, targetY, targetZ, destinationName)
    FastTravel.Main.targetX = targetX
    FastTravel.Main.targetY = targetY
    FastTravel.Main.targetZ = targetZ or 0
    FastTravel.Main.countdownEnd = getGameTime():getTime() + FastTravel.Definitions.CountdownSeconds
    FastTravel.Main.countdownLabel = destinationName
    print("FastTravel: Starting countdown to " .. destinationName)
end

function openDestinationPanel()
    local player = getPlayer()
    if not player then return end
    local vehicle = player:getVehicle()
    if not vehicle or vehicle:getDriver() ~= player then
        print("FastTravel: Must be driver to open panel")
        return
    end
    local w = 500
    local h = 400
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

local function onTick()
    if FastTravel.Main.countdownEnd and getGameTime():getTime() >= FastTravel.Main.countdownEnd then
        FastTravel.Main.countdownEnd = nil
        local player = getPlayer()
        if player and player:getVehicle() then
            sendClientCommand("FastTravel", "Teleport", {
                targetX = FastTravel.Main.targetX,
                targetY = FastTravel.Main.targetY,
                targetZ = FastTravel.Main.targetZ or 0
            })
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
