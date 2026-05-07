require "ISUI/ISPanel"

FastTravelCountdownUI = ISPanel:derive("FastTravelCountdownUI")

function FastTravelCountdownUI:initialise()
    ISPanel.initialise(self)
    self:setAlwaysOnTop(true)
    self.javaObject:setIgnoreLossControl(true)
end

function FastTravelCountdownUI:createChildren()
    local btnW = 120
    local btnH = 30
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local cancelBtn = ISButton:new(
        (screenW - btnW) / 2,
        screenH / 2 + 60,
        btnW, btnH,
        getText("IGUI_Cancel"), nil, function()
            FastTravel.Main.cancelCountdown()
        end
    )
    cancelBtn:initialise()
    cancelBtn.backgroundColor = {r=0.6, g=0.15, b=0.15, a=0.9}
    cancelBtn.backgroundColorMouseOver = {r=0.8, g=0.2, b=0.2, a=1}
    cancelBtn.borderColor = {r=1, g=1, b=1, a=0.5}
    cancelBtn:setFont(UIFont.Medium)
    self:addChild(cancelBtn)
    self.cancelButton = cancelBtn
end

function FastTravelCountdownUI:prerender()
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()

    self:drawRect(0, 0, screenW, screenH, 0.5, 0, 0, 0)

    if FastTravel.Main.countdownEnd then
        local remaining = math.max(0, FastTravel.Main.countdownEnd - getTimeMillis())
        local seconds = math.ceil(remaining / 1000)

        local cx = screenW / 2
        local cy = screenH / 2 - 40

        self:drawTextCentre(tostring(seconds), cx, cy, 1, 1, 1, 1, UIFont.Large)

        if FastTravel.Main.countdownLabel then
            self:drawTextCentre(getText("FastTravel_CountdownTo") .. " " .. FastTravel.Main.countdownLabel, cx, cy + 30, 0.8, 0.8, 0.8, 1, UIFont.Medium)
        end
    end
end

function FastTravelCountdownUI:onKeyPressed(key)
    if key == Keyboard.KEY_ESCAPE then
        FastTravel.Main.cancelCountdown()
        return true
    end
    return false
end

function FastTravelCountdownUI:onMouseDown(x, y)
    return true
end

function FastTravelCountdownUI:onMouseUp(x, y)
    return true
end

function FastTravelCountdownUI:new(destinationName)
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local o = ISPanel.new(self, 0, 0, screenW, screenH)
    o.background = false
    o.destinationName = destinationName
    o:instantiate()
    o.javaObject:setConsumeMouseEvents(true)
    return o
end
