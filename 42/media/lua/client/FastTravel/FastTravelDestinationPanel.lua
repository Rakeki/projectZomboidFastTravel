require "ISUI/ISPanel"

FastTravelDestinationPanel = ISPanel:derive("FastTravelDestinationPanel")

function FastTravelDestinationPanel:initialise()
    ISPanel.initialise(self)
    self:setVisible(true)
    self.moveWithMouse = true
    self.markers = {}
    self.mapTexture = getTexture("media/textures/fasttravel_map.png")
    if not self.mapTexture then
        print("FastTravel: Failed to load map.png texture")
    end
    self:createMarkers()
end

function FastTravelDestinationPanel:onMouseDown(x, y)
    return true
end

function FastTravelDestinationPanel:onKeyPressed(key)
    if key == Keyboard.KEY_ESCAPE then
        self:removeFromUIManager()
        return true
    end
    return false
end

function FastTravelDestinationPanel:createMarkers()
    self.markers = {}

    print("FastTravel: Creating destination panel")

    local safehouse = FastTravel.Definitions.getSafehouse()
    if safehouse and safehouse.getX then
        print("FastTravel: Adding safehouse marker")
        local sx = safehouse:getX()
        local sy = safehouse:getY()
        table.insert(self.markers, {
            name = getText("FastTravel_SafeHouse"),
            x = self:mapToWorldX(sx),
            y = self:mapToWorldY(sy),
            worldX = sx,
            worldY = sy,
            color = {r=0, g=1, b=0, a=1},
            discovered = true,
        })
    end

    for _, city in ipairs(FastTravel.Definitions.Cities) do
        local discovered = FastTravel.Definitions.isCityDiscovered(city)
        print("FastTravel: City " .. city.name .. " discovered: " .. tostring(discovered))
        table.insert(self.markers, {
            name = city.name,
            x = self:mapToWorldX(city.teleportX),
            y = self:mapToWorldY(city.teleportY),
            worldX = city.teleportX,
            worldY = city.teleportY,
            color = discovered and {r=1, g=0.8, b=0.2, a=1} or {r=0.5, g=0.5, b=0.5, a=1},
            discovered = discovered,
        })
    end

    local closeButton = ISButton:new(self.width - 60, self.height - 30, 50, 20, "Close", self, function()
        self:removeFromUIManager()
    end)
    closeButton:initialise()
    closeButton.backgroundColor = {r=0.5, g=0.2, b=0.2, a=0.9}
    closeButton.borderColor = {r=1, g=1, b=1, a=0.5}
    self:addChild(closeButton)
end

function FastTravelDestinationPanel:mapToWorldX(worldX)
    local margin = 50
    local mapWidth = self:getWidth() - margin * 2
    local minX = 6000
    local maxX = 13000
    return margin + ((worldX - minX) / (maxX - minX)) * mapWidth
end

function FastTravelDestinationPanel:mapToWorldY(worldY)
    local margin = 40
    local mapHeight = self:getHeight() - margin * 2 - 30
    local minY = 1000   -- Louisville is at ~1800 (north)
    local maxY = 13000  -- Rosewood is at ~11578 (south)
    -- Lower worldY = north = top of screen
    return margin + ((worldY - minY) / (maxY - minY)) * mapHeight
end

function FastTravelDestinationPanel:drawMarker(mx, my, color)
    local size = 8
    self:drawRect(mx - size, my - 1, size * 2, 2, color.a, color.r, color.g, color.b)
    self:drawRect(mx - 1, my - size, 2, size * 2, color.a, color.r, color.g, color.b)
end

function FastTravelDestinationPanel:prerender()
    self:drawRectBorder(0, 0, self:getWidth(), self:getHeight(), 1, 0.5, 0.5, 0.5)
    self:drawRect(1, 1, self:getWidth() - 2, self:getHeight() - 2, 0.9, 0.05, 0.08, 0.12)

    -- Title bar background
    self:drawRect(0, 0, self:getWidth(), 30, 1, 0.15, 0.18, 0.22)
    self:drawTextCentre(getText("FastTravel_DestinationTitle"), self:getWidth() / 2, 12, 1, 1, 1, 1, UIFont.Medium)

    -- Draw map background image
    local mapX = 50
    local mapY = 40
    local mapW = self:getWidth() - 100
    local mapH = self:getHeight() - 80
    if self.mapTexture then
        self:drawTextureScaled(self.mapTexture, mapX, mapY, mapW, mapH, 1, 1, 1, 1)
    else
        self:drawRect(mapX, mapY, mapW, mapH, 0.3, 0.1, 0.15, 0.1)
    end

    -- Draw markers on top of the map
    for _, marker in ipairs(self.markers) do
        self:drawMarker(marker.x, marker.y, marker.color)
        self:drawTextCentre(marker.name, marker.x, marker.y + 14, 1, 1, 1, 1, UIFont.Small)
    end

    self:drawText(getText("FastTravel_ClickMarker"), 10, self:getHeight() - 22, 0.6, 0.6, 0.6, 1, UIFont.Small)
end

function FastTravelDestinationPanel:onMouseUp(x, y)
    print("FastTravel: Click at (" .. x .. ", " .. y .. ")")
    for _, marker in ipairs(self.markers) do
        local dx = x - marker.x
        local dy = y - marker.y
        local dist = math.sqrt(dx * dx + dy * dy)
        print("FastTravel: Distance to " .. marker.name .. ": " .. dist)
        if dist < 16 then
            if not marker.discovered then
                print("FastTravel: City not discovered yet")
                return
            end
            print("FastTravel: Teleporting to " .. marker.name)
            self:removeFromUIManager()
            FastTravel.Main.startCountdown(marker.worldX, marker.worldY, 0, marker.name)
            return
        end
    end
    ISPanel.onMouseUp(self, x, y)
end

function FastTravelDestinationPanel:new(x, y, width, height, vehicle)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.vehicle = vehicle
    return o
end
