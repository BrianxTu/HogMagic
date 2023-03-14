local serverMSG = "</><gryffindor>[SERVER]: </><default>"

local function findPlayer(target)
    for pConId in pairs(playerData) do
        local getPlayer = server.player_manager:GetByConnectionId(pConId)
        if type(target) == "number" then
            if target == getPlayer.id then
                return getPlayer
            end
        elseif type(target) == "string" then
            if target:lower() == getPlayer.name:lower() then
                return getPlayer
            end
        end
    end
end

registerCommand("kick", function(player, args)
    if args == {} or args[1] == nil then
        player:SendSystemMessage(serverMSG .. "Provide a target!")
        return
    end
    local target = findPlayer(args[1])
    if not target then
        player:SendSystemMessage(serverMSG .. "Player not found!")
        return
    end
    table.remove(args, 1)
    if args == {} or args[1] == nil then
        player:SendSystemMessage(serverMSG .. "Provide a reason!")
        return
    end
    local reason = table.concat(args, " ")
    if player == target then
        player:SendSystemMessage(serverMSG .. "You can't kick yourself!")
    else
        target:SendSystemMessage(serverMSG .. "You have been kicked for - " .. reason)
        target:Kick()
    end
end, {"admin", "mod"})

registerCommand("ban", function(player, args)
    if args == {} or args[1] == nil then
        player:SendSystemMessage(serverMSG .. "Provide a target!")
        return
    end
    local target = findPlayer(args[1])
    if not target then
        player:SendSystemMessage(serverMSG .. "Player not found!")
        return
    end
    table.remove(args, 1)
    if args == {} or args[1] == nil then
        player:SendSystemMessage(serverMSG .. "Provide a reason!")
        return
    end
    local reason = table.concat(args, " ")
    if player == target then
        player:SendSystemMessage(serverMSG .. "You can't ban yourself!")
    else
        target:SendSystemMessage(serverMSG .. "You have been kicked for - " .. reason)
        playerData[target.connection].banned = true
        playerData[target.connection].banreason = reason
        target:Kick()
    end
end, {"admin", "mod"})

registerCommand("getpos", function(player, args)
    local target
    if args == {} or args[1] == nil then
        target = player
    else
        target = findPlayer(args[1])
    end
    if target then
        target:SendSystemMessage("X: " .. target.time_point.movement.position.x .. " Y: ".. target.time_point.movement.position.y .. " Z: " .. target.time_point.movement.position.z)
    end
end, {"admin", "mod"})

registerCommand({"pm", "dm", "whisper"}, function (player, args)
    if args == {} or args[1] == nil then
        player:SendSystemMessage(serverMSG .. "Provide a target!")
        return
    end
    local target = findPlayer(args[1])
    if not target then
        player:SendSystemMessage(serverMSG .. "Player not found!")
        return
    end
    table.remove(args, 1)
    if args == {} or args[1] == nil then
        player:SendSystemMessage(serverMSG .. "Provide a message!")
        return
    end
    local message = table.concat(args, " ")
    if player == target then
        player:SendSystemMessage(serverMSG .. "You can't send yourself a message!")
        target:SendSystemMessage("</><ravenclaw>[" .. player.name .. " whispered]: </><default>" .. message)
    else
        target:SendSystemMessage("</><ravenclaw>[" .. player.name .. " whispered]: </><default>" .. message)
    end
end)

registerCommand({"dc", "quit"}, function (player, args)
    player:Kick()
end)

registerCommand("announce", function(player, args)
    if args == {} or args[1] == nil then
        player:SendSystemMessage(serverMSG .. "Provide a message!")
        return
    end
    local message = table.concat(args, " ")
    for pConId in pairs(playerData) do
        local getPlayer = server.player_manager:GetByConnectionId(pConId)
        getPlayer:SendSystemMessage("</><hufflepuff>[ANNOUNCEMENT]: </><default>" .. message)
    end
end, {"admin", "mod"})

registerCommand({"wl", "whitelist"}, function(player, args)
    if args == {} or args[1] == nil then
        player:SendSystemMessage(serverMSG .. "Provide a function!")
        return
    end
    local func = args[1]
    table.remove(args, 1)
    if args == {} or args[1] == nil then
        player:SendSystemMessage(serverMSG .. "Provide a target!")
        return
    end
    local target = findPlayer(args[1])
    if func:lower() == "on" then
        whitelistMode = true
        player:SendSystemMessage(serverMSG .. "Whitelist has been enabled!")
    elseif func:lower() == "off" then
        whitelistMode = false
        player:SendSystemMessage(serverMSG .. "Whitelist has been disabled!")
    elseif func:lower() == "add" then
        if not target then
            if tonumber(args[1]) then
                table.insert(whitelistTempTable, args[1])
            else
                player:SendSystemMessage(serverMSG .. "Player not found!")
                return
            end
        end
        playerData[target.connection].whitelisted = true
        player:SendSystemMessage(serverMSG .. target.name .. " has been whitelisted")
        target:SendSystemMessage(serverMSG .. "You have been whitelisted")
    elseif func:lower() == "remove" then
        if not target then
            player:SendSystemMessage(serverMSG .. "Player not found!")
            return
        end
        playerData[target.connection].whitelisted = nil
        player:SendSystemMessage(serverMSG .. target.name .. " has been removed from the whitelist")
        target:SendSystemMessage(serverMSG .. "You have been removed from the whitelist")
    else
        player:SendSystemMessage(serverMSG .. "Invalid function!")
    end
end, {"admin", "mod"})

registerCommand({"setp", "setpermission"}, function(player, args)
    if args == {} or args[1] == nil then
        player:SendSystemMessage(serverMSG .. "Provide a target!")
        return
    end
    local target = findPlayer(args[1])
    table.remove(args, 1)
    if args == {} or args[1] == nil then
        player:SendSystemMessage(serverMSG .. "Provide a function!")
        return
    end
    local func = args[1]:lower()
    table.remove(args, 1)
    if not target then
        player:SendSystemMessage(serverMSG .. "Player not found!")
        return
    end
    if func == "add" then
        local permission = args[1]:lower()
        playerData[target.connection].permissions[permission] = true
        player:SendSystemMessage(serverMSG .. target.name .. " has received the permission " .. permission)
    elseif func == "remove" then
        local permission = args[1]:lower()
        playerData[target.connection].permissions[permission] = nil
        player:SendSystemMessage(serverMSG .. target.name .. " has lost the permission " .. permission)
    end
end, {"admin", "mod"})