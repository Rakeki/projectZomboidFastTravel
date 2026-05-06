require "ISUI/ISPanel"

FastTravelDestinationPanel = ISPanel:derive("FastTravelDestinationPanel")

function FastTravelDestinationPanel:initialise()
    ISPanel.initialise(self)
    self:setVisible(true)
    self.moveWithMouse = true
    self.markers = {}
end

function FastTravelDestinationPanel:onKeyPressed(key)
    if key == Keyboard.KEY_ESCAPE then
        self:removeFromUIManager()
        return true
    end
    return false
end

function FastTravelDestinationPanel:create()
    self.markers = {}

    print("FastTravel: Creating destination panel")

    local safehouse = FastTravel.Definitions.getSafehouse()
    if safehouse then
        print("FastTravel: Adding safehouse marker")
        table.insert(self.markers, {
            name = getText("FastTravel_SafeHouse"),
            x = self:mapToWorldX(safehouse:getX()),
            y = self:mapToWorldY(safehouse:getY()),
            worldX = safehouse:getX(),
            worldY = safehouse:getY(),
            color = {r=0, g=1, b=0, a=1},
        })
    end

    local cities = FastTravel.Definitions.getDiscoveredCities()
    print("FastTravel: Found " .. #cities .. " discovered cities")
    for _, city in ipairs(cities) do
        print("FastTravel: Adding city - " .. city.name)
        table.insert(self.markers, {
            name = city.name,
            x = self:mapToWorldX(city.teleportX),
            y = self:mapToWorldY(city.teleportY),
            worldX = city.teleportX,
            worldY = city.teleportY,
            color = {r=1, g=0.8, b=0.2, a=1},
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
    local minX = 1500
    local maxX = 2100
    return margin + (worldX - minX) / (maxX - minX) * mapWidth
end

function FastTravelDestinationPanel:mapToWorldY(worldY)
    local margin = 40
    local mapHeight = self:getHeight() - margin * 2 - 10
    local minY = 1400
    local maxY = 2000
    return margin + (maxY - worldY) / (maxY - minY) * mapHeight
end

function FastTravelDestinationPanel:drawMarker(mx, my, color)
    local size = 8
    self:drawRect(mx - size, my - 1, size * 2, 2, color.a, color.r, color.g, color.b)
    self:drawRect(mx - 1, my - size, 2, size * 2, color.a, color.r, color.g, color.b)
end

function FastTravelDestinationPanel:prerender()
    if #self.markers == 0 then
        self:create()
    end

    self:drawRectBorder(0, 0, self:getWidth(), self:getHeight(), 1, 0.5, 0.5, 0.5)
    self:drawRect(1, 1, self:getWidth() - 2, self:getHeight() - 2, 0.9, 0.05, 0.08, 0.12)

    -- Title bar background
    self:drawRect(0, 0, self:getWidth(), 30, 1, 0.15, 0.18, 0.22)
    self:drawTextCentre(getText("FastTravel_DestinationTitle"), self:getWidth() / 2, 12, 1, 1, 1, 1, UIFont.Medium)

    for _, marker in ipairs(self.markers) do
        self:drawMarker(marker.x, marker.y, marker.color)
        self:drawTextCentre(marker.name, marker.x, marker.y + 14, 1, 1, 1, 1, UIFont.Small)
    end

    self:drawText(getText("FastTravel_ClickMarker"), 10, self:getHeight() - 22, 0.6, 0.6, 0.6, 1, UIFont.Small)
end

function FastTravelDestinationPanel:onMouseUp(x, y, button)
    if button == 0 then
        for _, marker in ipairs(self.markers) do
            local dx = x - marker.x
            local dy = y - marker.y
            if math.sqrt(dx * dx + dy * dy) < 16 then
                self:removeFromUIManager()
                FastTravel.Main.startCountdown(marker.worldX, marker.worldY, 0, marker.name)
                return
            end
        end
    end
    ISPanel.onMouseUp(self, x, y, button)
end

function FastTravelDestinationPanel:new(x, y, width, height, vehicle)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.vehicle = vehicle
    return o
end
