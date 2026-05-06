FastTravel = FastTravel or {}
FastTravel.Server = FastTravel.Server or {}

print("FastTravel Server Loaded")

local function onClientCommand(module, command, player, args)
    if module ~= "FastTravel" then return end
    print("FastTravel: Received client command: " .. command)

    if command == "Teleport" then
        local targetX = args.targetX
        local targetY = args.targetY

        if not targetX or not targetY then
            print("FastTravel: Invalid teleport coordinates")
            return
        end

        local vehicle = player:getVehicle()
        if not vehicle then
            print("FastTravel: Player not in vehicle")
            return
        end

        print("FastTravel: Teleport request from " .. player:getUsername() .. " to " .. targetX .. ", " .. targetY)
    end
end

Events.OnClientCommand.Add(onClientCommand)
