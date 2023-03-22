party = {}
partyChat = {}

local function checkParty(player)
    for pCode, partyData in pairs(party) do
        for i, member in pairs(partyData.members) do
            if player == member then
                return pCode
            end
        end
    end
    return false
end

registerCommand("startparty", function(player, args)
    if checkParty(player) then player:SendSystemMessage("You are already in a party!") return end
    local pCode = ""
    repeat
        pCode = tostring(math.random(100000, 999999))
    until not party[pCode]
    party[pCode] = {leader = player, members = {player}}
    player:SendSystemMessage("Party started! Invite code: " .. pCode)
end)

registerCommand("joinparty", function(player, args)
    if checkParty(player) then player:SendSystemMessage("You are already in a party!") return end
    local pCode = tostring(args[1])
    if not pCode or not party[pCode] then
        player:SendSystemMessage("Invalid party code!")
        return
    end
    table.insert(party[pCode].members, player)
    player:SendSystemMessage("Joined party!")
    for _, member in pairs(party[pCode].members) do
        if member ~= player then
            member:SendSystemMessage(player.name .. " joined the party.")
        end
    end
end)

registerCommand("leaveparty", function(player, args)
    local inParty = checkParty(player)
    if inParty then
        local partyData = party[inParty]
        for i, member in ipairs(partyData.members) do
            if member == player then
                table.remove(partyData.members, i)
                player:SendSystemMessage("Left party.")
                for _, remaining in pairs(partyData.members) do
                    remaining:SendSystemMessage(player.name .. " left the party.")
                end
                if player == partyData.leader and #partyData.members > 0 then
                    partyData.leader = partyData.members[1]
                    partyData.leader:SendSystemMessage("You are now the party leader.")
                end
                if #partyData.members == 0 then
                    partyData.leader:SendSystemMessage("Party disbanded.")
                    party[inParty] = nil
                end
                return
            end
        end
    else
        player:SendSystemMessage("Not in a party.")
    end
end)

registerCommand({"gc", "groupchat"}, function(player, args)
    local partyId = checkParty(player)
    if partyChat[player.connection] then
            partyChat[player.connection] = nil
    else
        if partyId then
            partyChat[player.connection] = partyId
        else
            player:SendSystemMessage("Not in a party.")
        end
    end
end)