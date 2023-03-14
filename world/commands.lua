local serverMSG = "</><gryffindor>[SERVER]: </><default>"

Exports.player.registerCommand({"fw", "freezeweather"}, function (player, args)
    local state = fWeather()
    if state then
        player:SendSystemMessage(serverMSG .. "Weather is now frozen!")
    else
        player:SendSystemMessage(serverMSG .. "Weather is now unfrozen!")
    end
end, {"admin", "mod"})

Exports.player.registerCommand({"ft", "freezetime"}, function (player, args)
    local state = fTime()
    if state then
        player:SendSystemMessage(serverMSG .. "Time is now frozen!")
    else
        player:SendSystemMessage(serverMSG .. "Time is now unfrozen!")
    end
end, {"admin", "mod"})

Exports.player.registerCommand({"sw", "setweather"}, function (player, args)
    local wthr = args[1]
    if not tonumber(wthr) then
        local check = false
        for i,v in pairs(getWeatherTypes()) do
            if i:lower() == wthr:lower() then
                local index = math.random(1, #v)
                local system = v[index]
                setWorldData({weather = system})
                return
            else
                for _,system in pairs(v) do
                    if system:lower() == wthr:lower() then
                        setWorldData({weather = system})
                        return
                    end
                end
            end
        end
        if check then
            player:SendSystemMessage(serverMSG .. "Invalid weather information")
        end
    else
        player:SendSystemMessage(serverMSG .. "Invalid weather information")
    end
end, {"admin", "mod"})

Exports.player.registerCommand({"st", "settime"}, function (player, args)
    local hr, mn, sc
    local ignore = false
    if tonumber(args[1]) then
        local setNumber = tonumber(args[1])
        if setNumber >= 0 and setNumber <= 23 then
            hr = tonumber(args[1])
        else
            player:SendSystemMessage(serverMSG .. "Hours cannot be more than 23 or less than 0")
            return
        end
    elseif Config.TimePresets[args[1]] then
        local preset = Config.TimePresets[args[1]]
        hr, mn, sc = preset[1], preset[2], preset[3]
        ignore = true
    else
        player:SendSystemMessage(serverMSG .. "Invalid time information")
        return
    end
    if not ignore and args[2] ~= nil and tonumber(args[2]) then
        local setNumber = tonumber(args[2])
        if setNumber >= 0 and setNumber <= 59 then
            mn = tonumber(args[2])
        else
            player:SendSystemMessage(serverMSG .. "Minutes cannot be more than 59 or less than 0")
            return
        end
    end
    if not ignore and args[3] ~= nil and tonumber(args[3]) then
        local setNumber = tonumber(args[3])
        if setNumber >= 0 and setNumber <= 59 then
            sc = tonumber(args[3])
        else
            player:SendSystemMessage(serverMSG .. "Seconds cannot be more than 59 or less than 0")
            return
        end
    end

    local timeTable = {
        hour = hr,
        minute = mn,
        second = sc
    }
    setWorldData(timeTable)
end, {"admin", "mod"})

Exports.player.registerCommand({"sd", "setdate"}, function (player, args)
    local mn, dy, yr
    if tonumber(args[1]) then
        local setNumber = tonumber(args[1])
        if setNumber >= 1 and setNumber <= 12 then
            mn = tonumber(args[1])
        else
            player:SendSystemMessage(serverMSG .. "Months cannot be more than 12 or less than 1")
            return
        end
    else
        player:SendSystemMessage(serverMSG .. "Invalid weather information")
        return
    end
    if args[2] ~= nil and tonumber(args[2]) then
        local setNumber = tonumber(args[2])
        if setNumber >= 1 and setNumber <= 31 then
            dy = tonumber(args[2])
        else
            player:SendSystemMessage(serverMSG .. "Days cannot be more than 31 or less than 1")
            return
        end
    end
    if args[3] ~= nil and tonumber(args[3]) then
        local setNumber = tonumber(args[3])
        if setNumber >= 0 then
            yr = tonumber(args[3])
        else
            player:SendSystemMessage(serverMSG .. "Years cannot be less than 0")
            return
        end
    end

    local timeTable = {
        month = mn,
        day = dy,
        year = yr
    }
    setWorldData(timeTable)
end, {"admin", "mod"})