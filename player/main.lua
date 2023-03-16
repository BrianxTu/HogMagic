-- Setup
local DATA_FILE = "/data/playerdata.json"
registeredCommands = {}
playerData = {}
whitelistMode, whitelistTempTable = Config.WhitelistMode, {}

-- Functions
local function loadPlayerData(player)
    local data = LoadResourceData(_RESOURCE, DATA_FILE)
    if data then
        local pIdentifiers = {discord = player.discord_id, steam = player.steam_id, epic = player.epic_id}
        for i, v in ipairs(data) do
            local dIdentifiers = v.identifiers
            local matchFound = false
            for a, b in pairs(pIdentifiers) do
                if dIdentifiers[a] and dIdentifiers[a] == b then
                    playerData[player.connection] = data[i]
                    playerData[player.connection].lastPlayed = os.time()
                    matchFound = true
                    break
                end
            end
            if matchFound then
                for a, b in pairs(pIdentifiers) do
                    if not playerData[player.connection].identifiers[a] then
                        playerData[player.connection].identifiers[a] = b
                    end
                end
                break
            end
        end
        if not playerData[player.connection] then
            playerData[player.connection] = {
                lastPlayed = os.time(),
                identifiers = pIdentifiers,
                permissions = {}
            }
        end
        for i, v in pairs(Config.Privileged) do
            for a, b in pairs(v) do
                local pData = playerData[player.connection]
                if pData.identifiers[a] and pData.identifiers[a] == tostring(b) then
                    for _, c in pairs(v.permissions) do
                        if not pData.permissions[c] then
                            pData.permissions[c] = true
                        end
                    end
                end
            end
        end
        for i, v in pairs(Config.WhitelistedRoles) do
            if playerData[player.connection].permissions[v] then
                playerData[player.connection].whitelisted = true
            end
        end
        for i,v in pairs(whitelistTempTable) do
            for a, b in pairs(playerData[player.connection].identifiers) do
                if b == v then
                    playerData[player.connection].whitelisted = true
                    table.remove(whitelistTempTable, i)
                end
            end
        end
    end
end

local function savePlayerData(player)
    if playerData[player.connection] then
        local data = LoadResourceData(_RESOURCE, DATA_FILE)
        if data then
            local pIdentifiers = playerData[player.connection].identifiers
            local found = false
            for i, v in ipairs(data) do
                local dIdentifiers = v.identifiers
                local matchFound = false
                for a,b in pairs(pIdentifiers) do
                    if dIdentifiers[a] and dIdentifiers[a] == b then
                        matchFound = true
                        break
                    end
                end
                if matchFound then
                    data[i] = playerData[player.connection]
                    found = true
                    break
                end
            end
            if not found then
                table.insert(data, playerData[player.connection])
            end
            SaveResourceData(_RESOURCE, DATA_FILE, data)
            return true
        end
    end
    return false
end

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
            return
        end
    end
    cmd.callback(player, args)
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

 -- Event Functions
local function onJoin(player)
    loadPlayerData(player)
    if whitelistMode then
        if not playerData[player.connection].whitelisted then
            player:SendSystemMessage(string.format(Locale.Core.systemtag, Locale.Core.con_whitelist))
            player:Kick()
            return
        end
    end
    if playerData[player.connection].banned then
        player:SendSystemMessage(string.format(Locale.Core.systemtag, string.format(Locale.Core.ban_context,(playerData[player.connection].banreason or Locale.Core.banreason_desc))))
        player:Kick()
        return
    end
    if Config.SystemMessages.PlayerJoin then
        for pConId in pairs(playerData) do
            local getPlayer = server.player_manager:GetByConnectionId(pConId)
            if getPlayer ~= player then
                getPlayer:SendSystemMessage(string.format(Locale.Core.systemtag, string.format(Locale.Core.joined, player.name)))
            end
        end
    end
end

local function onLeave(player)
    savePlayerData(player)
    if Config.SystemMessages.PlayerLeft then
        for pConId in pairs(playerData) do
            local getPlayer = server.player_manager:GetByConnectionId(pConId)
            if getPlayer ~= player then
                getPlayer:SendSystemMessage(string.format(Locale.Core.systemtag, string.format(Locale.Core.left, player.name)))
            end
        end
    end
    playerData[player.connection] = nil
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
end

local function onShutdown()
    for i,v in pairs(playerData) do
        local fakePlayer = {connection = i}
        savePlayerData(fakePlayer)
        table.remove(playerData, i)
    end
end

local tipSync = 0
local function onUpdate(Delta)
    tipSync = tipSync+Delta
    if tipSync > Config.SystemTips.TipSync then
        tipSync = tipSync - Config.SystemTips.TipSync
        for pConId in pairs(playerData) do
            local messageIndex = math.random(1, #Locale.SystemTips)
            local message = Locale.SystemTips[messageIndex]
            local getPlayer = server.player_manager:GetByConnectionId(pConId)
            if getPlayer then
                getPlayer:SendSystemMessage(string.format(Locale.Core.tiptag, message))
            end
        end
    end
end
-- Events
RegisterForEvent("player_joined", onJoin)
RegisterForEvent("player_left", onLeave)
RegisterForEvent("player_chat", onChat)
RegisterForEvent("shutdown", onShutdown)
RegisterForEvent("update", onUpdate)

-- Exports
Exports("registerCommand", registerCommand)