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

local function onTick()
    if FastTravel.Main.countdownEnd and getTimeMillis() >= FastTravel.Main.countdownEnd then
        FastTravel.Main.countdownEnd = nil
        if FastTravel.Main.countdownUI then
            FastTravel.Main.countdownUI:removeFromUIManager()
            FastTravel.Main.countdownUI = nil
        end
        local player = getPlayer()
        if player then
            local vehicle = player:getVehicle()
            if vehicle then
                local tx = FastTravel.Main.targetX
                local ty = FastTravel.Main.targetY
                player:teleportTo(tx + 0.5, ty + 0.5, 0)
                vehicle:setX(tx)
                vehicle:setY(ty)
                print("FastTravel: Teleported to destination (" .. tx .. ", " .. ty .. ")")
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
