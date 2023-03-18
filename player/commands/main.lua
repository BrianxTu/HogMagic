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
    if #args == 0 or args[1] == nil then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.provide_target))
        return
    end
    local target = findPlayer(args[1])
    if not target then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.invalid_target))
        return
    end
    table.remove(args, 1)
    if #args == 0 or args[1] == nil then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.provide_reason))
        return
    end
    local reason = table.concat(args, " ")
    if player == target then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.kick_yourself))
    else
        target:SendSystemMessage(string.format(Locale.Core.systemtag, string.format(Locale.Commands.kick_context, reason)))
        target:Kick()
    end
end, {"admin", "mod"})

registerCommand("ban", function(player, args)
    if #args == 0 or args[1] == nil then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.provide_target))
        return
    end
    local target = findPlayer(args[1])
    if not target then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.invalid_target))
        return
    end
    table.remove(args, 1)
    if #args == 0 or args[1] == nil then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.provide_reason))
        return
    end
    local reason = table.concat(args, " ")
    if player == target then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.ban_yourself))
    else
        target:SendSystemMessage(string.format(Locale.Core.systemtag, string.format(Locale.Commands.ban_context, reason)))
        playerData[target.connection].banned = true
        playerData[target.connection].banreason = reason
        target:Kick()
    end
end, {"admin", "mod"})

registerCommand("getpos", function(player, args)
    local target
    if #args == 0 or args[1] == nil then
        target = player
    else
        target = findPlayer(args[1])
    end
    if target then
        target:SendSystemMessage("X: " .. target.time_point.movement.position.x .. " Y: ".. target.time_point.movement.position.y .. " Z: " .. target.time_point.movement.position.z)
    else
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.invalid_target))
    end
end, {"admin", "mod"})

registerCommand({"pm", "dm", "whisper"}, function (player, args)
    if #args == 0 or args[1] == nil then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.provide_target))
        return
    end
    local target = findPlayer(args[1])
    if not target then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.invalid_target))
        return
    end
    table.remove(args, 1)
    if #args == 0 or args[1] == nil then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.provide_message))
        return
    end
    local message = table.concat(args, " ")
    if player == target then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.whisper_yourself))
    else
        target:SendSystemMessage(string.format(Locale.Core.whispertag, player.name, message))
    end
end)

registerCommand({"dc", "quit"}, function (player, args)
    player:Kick()
end)

registerCommand("announce", function(player, args)
    if #args == 0 or args[1] == nil then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.provide_message))
        return
    end
    local message = table.concat(args, " ")
    for pConId in pairs(playerData) do
        local getPlayer = server.player_manager:GetByConnectionId(pConId)
        if getPlayer then
            getPlayer:SendSystemMessage(string.format(Locale.Core.announcetag, message))
        end
    end
end, {"admin", "mod"})

registerCommand({"wl", "whitelist"}, function(player, args)
    if #args == 0 or args[1] == nil then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.provide_function))
        return
    end
    local func = args[1]
    table.remove(args, 1)
    if #args == 0 or args[1] == nil then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.provide_target))
        return
    end
    local target = findPlayer(args[1])
    if not target then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.invalid_target))
        return
    end
    if func:lower() == "on" then
        whitelistMode = true
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.wl_enabled))
    elseif func:lower() == "off" then
        whitelistMode = false
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.wl_disabled))
    elseif func:lower() == "add" then
        playerData[target.connection].whitelisted = true
        player:SendSystemMessage(string.format(Locale.Core.systemtag, string.format(Locale.Commands.wl_add_executor, target.name)))
        target:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.wl_add_target))
    elseif func:lower() == "remove" then
        playerData[target.connection].whitelisted = nil
        player:SendSystemMessage(string.format(Locale.Core.systemtag, string.format(Locale.Commands.wl_remove_executor, target.name)))
        target:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.wl_remove_target))
    else
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.invalid_function))
    end
end, {"admin", "mod"})

registerCommand({"setp", "setpermission"}, function(player, args)
    if #args == 0 or args[1] == nil then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.provide_target))
        return
    end
    local target = findPlayer(args[1])
    table.remove(args, 1)
    if not target then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.invalid_target))
        return
    end
    if #args == 0 or args[1] == nil then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.provide_function))
        return
    end
    local func = args[1]:lower()
    table.remove(args, 1)

    if func == "add" then
        local permission = args[1]:lower()
        playerData[target.connection].permissions[permission] = true
        player:SendSystemMessage(string.format(Locale.Core.systemtag, string.format(Locale.Commands.perm_add_executor, target.name, permission)))
        target:SendSystemMessage(string.format(Locale.Core.systemtag, string.format(Locale.Commands.perm_add_target, permission)))
    elseif func == "remove" then
        local permission = args[1]:lower()
        playerData[target.connection].permissions[permission] = nil
        player:SendSystemMessage(string.format(Locale.Core.systemtag, string.format(Locale.Commands.perm_remove_executor, target.name, permission)))
        target:SendSystemMessage(string.format(Locale.Core.systemtag, string.format(Locale.Commands.perm_remove_target, permission)))
    else
        player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Commands.invalid_function))
    end
end, {"admin", "mod"})

registerCommand("help", function (player, args)
    local pData = playerData[player.connection]
    local pPermissions = pData.permissions
    local buildHelp = {}
    local finalBuildHelp = {Locale.Commands.help_header}
    local buildHelpSet = {}

    for cmdName, data in pairs(registeredCommands) do
        if data.permissions then
            for i,v in pairs(data.permissions) do
                if pPermissions[v] and not buildHelpSet[cmdName] then
                    table.insert(buildHelp, cmdName)
                    buildHelpSet[cmdName] = true
                end
            end
        elseif not buildHelpSet[cmdName] then
            table.insert(buildHelp, cmdName)
            buildHelpSet[cmdName] = true
        end
    end
    table.insert(finalBuildHelp, table.concat(buildHelp, ", "))
    player:SendSystemMessage(table.concat(finalBuildHelp, "</>\n<server>"))
end)