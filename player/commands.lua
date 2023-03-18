registeredCommands = {}

local function checkPerm(player, reqPerms)
    local pData = playerData[player.connection]
    local pPermissions = pData.permissions
    if type(reqPerms) == "string" then
        reqPerms = {reqPerms}
    end
    for _,rPerm in pairs(reqPerms) do
        if pPermissions[rPerm] then
            return true
        end
    end
    return false
end

local function onCommand(player, cmdName, args)
    local cmd = registeredCommands[cmdName:lower()]
    if cmd.permissions then
        if not checkPerm(player, cmd.permissions) then
            player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Core.lack_perm))
            return true
        end
    end
    cmd.callback(player, args)
    return true
end

function registerCommand(cmdNames, callback, permissions)
    if type(cmdNames) == "string" then
        cmdNames = {cmdNames}
    end
    for _, cmdName in ipairs(cmdNames) do
        if cmdName ~= "" then
            cmdName = cmdName:lower()
            registeredCommands[cmdName] = {
                callback = callback,
                permissions = permissions
            }
        end
    end
end

local function onChat(player, message)
    if Config.ProfanityFilter then
        local isProfanity = false
        local ProfanityList = Locale.Profanity
        if ProfanityList ~= nil and ProfanityList ~= {} then
            for i,v in pairs(ProfanityList) do
                if message:find(v) then
                    isProfanity = true
                    break
                end
            end
            if isProfanity then
                local isWhitelisted = false
                for _,v in pairs(Config.WhitelistProfanityRoles) do
                    isWhitelisted = checkPerm(player, v)
                    if isWhitelisted then break end
                end
                if not isWhitelisted then
                    player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Core.profanity_warn))
                    return true
                end
            end
        end
    end

    local isCommand = message:sub(0, 1) == Config.CommandPrefix and #message > #Config.CommandPrefix
    if isCommand then
        local args = message:splitT(" ")
        local cmdName = args[1]:sub(2)
        table.remove(args, 1)
        local cmd = registeredCommands[cmdName:lower()]
        if not cmd then
            player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Core.invalid_com))
            return true
        end
        onCommand(player, cmdName, args)
        return true
    end

    if partyChat[player.connection] then
        for _,member in pairs(party[partyChat[player.connection]].members) do
            --if player ~= member then
                member:SendSystemMessage("</><slytherin>[PARTY] "..player.name..":</><default> "..message.."</><server>")
            --end
        end
        return true
    end
end

-- Events
RegisterForEvent("player_chat", onChat)

-- Exports
Exports("registerCommand", registerCommand)