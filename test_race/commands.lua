Exports.player.registerCommand("startrace", function(player, args)
    if #args == 0 or args[1] == nil then
        player:SendSystemMessage(Locale.Commands.provide_rname)
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
                minplayers = validRace.minplayers or nil,
                racers = {player},
                checkpoints = validRace.checkpoints,
                progress = {[player.connection] = 1},
                finished = {},
            }
            player:SendSystemMessage(string.format(Locale.Commands.start_notify,calledRace,(validRace.minplayers or "1")))
        else
            player:SendSystemMessage(Locale.Commands.race_already)
        end
    else
        player:SendSystemMessage(Locale.Commands.rnot_exist)
    end
end)

Exports.player.registerCommand("joinrace", function(player, args)
    if #args == 0 or args[1] == nil then
        player:SendSystemMessage(Locale.Commands.provide_rname)
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
                player:SendSystemMessage(Locale.Commands.alreadyin)
                return
            end
        end
        if not data.starttime then
            table.insert(RaceData[calledRace].racers, player)
            RaceData[calledRace].progress[player.connection] = 1
            player:SendSystemMessage(string.format(Locale.Commands.joined_race, calledRace))
        else
            player:SendSystemMessage(Locale.Commands.race_already)
        end
    else
        player:SendSystemMessage(Locale.Commands.rnot_started)
    end
end)

Exports.player.registerCommand("leaverace", function(player, args)
    for raceName,data in pairs(RaceData) do
        for i,v in ipairs(data.racers) do
            if v == player then
                table.remove(data.racers, i)
                data.progress[player.connection] = nil
                player:SendSystemMessage(string.format(Locale.Commands.left_race, raceName))
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
                player:SendSystemMessage(string.format(Locale.Commands.left_race, raceName))
                if #data.racers == 0 and #data.finished == 0 then
                    RaceData[raceName] = nil
                end
                return
            end
        end
    end
    player:SendSystemMessage(Locale.Commands.notin)
end)

Exports.player.registerCommand("racetimes", function(player, args)
    if #args == 0 or args[1] == nil then
        player:SendSystemMessage(Locale.Commands.provide_rname)
        return
    end
    local calledRace = args[1]:lower()
    table.remove(args, 1)
    local validRace = nil
    for i,v in pairs(Config.RaceSetup) do
        if i:lower() == calledRace then
            validRace = i
            break
        end
    end
    if validRace then
        local amount = tonumber(args[1]) or (Config.RaceTimesDefault)
        if amount > Config.RaceTimesMax then
            player:SendSystemMessage(Locale.Commands.tomany_times)
            return
        end
        local data = LoadResourceData(_RESOURCE, "/data/racedata.json")
        local times = {}
        for time, racers in pairs(data[calledRace]) do
            local minutes, seconds, milliseconds = time:match("(%d+):(%d+).(%d+)")
            local totalMilliseconds = tonumber(minutes) * 60000 + tonumber(seconds) * 1000 + tonumber(milliseconds)
            table.insert(times, {time = totalMilliseconds, formatted = time, racers = racers})
        end
        table.sort(times, function(a, b) return a.time < b.time end)

        local buildMessage = {string.format(Locale.Commands.toptimes, amount, calledRace)}
        for i = 1, amount, 1 do
            local timeData = times[i]
            if timeData then
                local timeStr = timeData.formatted
                local racersStr = table.concat(timeData.racers, ", ")
                table.insert(buildMessage, timeStr .. " - " .. racersStr)
            end
        end
        player:SendSystemMessage(table.concat(buildMessage, "</>\n<server>"))
    else
        player:SendSystemMessage(Locale.Commands.rnot_exist)
    end
end)