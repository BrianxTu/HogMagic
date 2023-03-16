Exports.player.registerCommand("startrace", function(player, args)
    if args == {} or args[1] == nil then
        player:SendSystemMessage("Provide a race name!")
        return
    end
    local calledRace = args[1]:lower()
    local validRace = nil
    for i,v in pairs(Config.RaceSetup) do
        if i:lower() == calledRace then
            validRace = v
            break
        end
    end

    if validRace then
        if not RaceData[calledRace] then
            RaceData[calledRace] = {
                startdelay = validRace.startdelay,
                maxtime = validRace.maxtime,
                maxdistance = validRace.maxdistance,
                startingalert = validRace.startingalert,
                racers = {player},
                checkpoints = validRace.checkpoints,
                progress = {[player.connection] = 1},
                finished = {},
            }
            player:SendSystemMessage("You started the race " .. calledRace)
        else
            player:SendSystemMessage("Race is already in progress")
        end
    else
        player:SendSystemMessage("Race does not exist")
    end
end)

Exports.player.registerCommand("joinrace", function(player, args)
    if args == {} or args[1] == nil then
        player:SendSystemMessage("Provide a race name!")
        return
    end
    local calledRace = args[1]:lower()
    if RaceData[calledRace] then
        local inRace = false
        for raceName,data in pairs(RaceData) do
            for i,v in pairs(data.racers) do
                if v == player then
                    inRace = true
                    break
                end
            end
            for i,v in pairs(data.finished) do
                if v == player then
                    inRace = true
                    break
                end
            end
            if inRace then
                player:SendSystemMessage("You are already in a race!")
                return
            end
        end
        table.insert(RaceData[calledRace].racers, player)
        RaceData[calledRace].progress[player.connection] = 1

        player:SendSystemMessage("You have joined the race: " .. calledRace)
    else
        player:SendSystemMessage("Race does not exist or has not started")
    end
end)

Exports.player.registerCommand("leaverace", function(player, args)
    for raceName,data in pairs(RaceData) do
        for i,v in ipairs(data.racers) do
            if v == player then
                table.remove(data.racers, i)
                data.progress[player.connection] = nil
                player:SendSystemMessage("You have left the race: " .. raceName)
                if #data.racers == 0 and #data.finished == 0 then
                    RaceData[raceName] = nil
                end
                return
            end
        end
        for i,v in ipairs(data.finished) do
            if v == player then
                table.remove(data.racers, i)
                data.progress[player.connection] = nil
                player:SendSystemMessage("You have left the race: " .. raceName)
                if #data.racers == 0 and #data.finished == 0 then
                    RaceData[raceName] = nil
                end
                return
            end
        end
    end
    player:SendSystemMessage("You are not in a race")
end)