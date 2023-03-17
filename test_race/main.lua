RaceData = {}
local SyncTime = 0

local function onUpdate(Delta)
    SyncTime = SyncTime + Delta
    if SyncTime > 1 then
        SyncTime = SyncTime - 1
        for raceName, data in pairs(RaceData) do
            if data.startdelay > 0 then
                data.startdelay = data.startdelay - 1
                if data.startdelay <= 0 then
                    for _, racer in ipairs(data.racers) do
                        racer:SendSystemMessage("The race has started!")
                        data.starttime = os.clock()
                    end
                else
                    for _, alert in pairs(data.startingalert) do
                        if alert == data.startdelay then
                            for _, racer in ipairs(data.racers) do
                                racer:SendSystemMessage("Race starting in " .. tostring(math.ceil(data.startdelay)) .. " seconds...")
                            end
                        end
                    end
                end
            end
        end
    end
    for raceName, data in pairs(RaceData) do
        if data.startdelay <= 0 then
            data.maxtime =  data.maxtime - Delta
            for i, racer in ipairs(data.racers) do
                local currentPosition = racer.time_point.movement.position
                local playerPos = {currentPosition.x, currentPosition.y, currentPosition.z}
                local nextCheckpoint = data.checkpoints[data.progress[racer.connection]]
                local distanceToCheckpoint = math.sqrt((nextCheckpoint[1] - playerPos[1])^2 + (nextCheckpoint[2] - playerPos[2])^2 + (nextCheckpoint[3] - playerPos[3])^2)
                if distanceToCheckpoint/100 <= data.maxdistance then
                    if data.progress[racer.connection] == #data.checkpoints then
                        table.insert(data.finished, racer)
                        table.remove(data.racers, i)
                        data.progress[racer.connection] = os.clock()
                        racer:SendSystemMessage("You finished the race!")
                    else
                        racer:SendSystemMessage("Checkpoint " .. tostring(data.progress[racer.connection]) .. " reached!")
                        data.progress[racer.connection] = data.progress[racer.connection] + 1
                    end
                end
            end
            if #data.racers == 0 or data.maxtime <= 0 then
                for i, racer in ipairs(data.finished) do
                    racer:SendSystemMessage("The race is over!")
                end
                local buildMessage = {string.format("</><hufflepuff>Results for %s:", raceName)}
                for i, racer in ipairs(data.finished) do
                    local time = data.progress[racer.connection] - data.starttime
                    local seconds = math.floor(time)
                    local milliseconds = math.floor((time - seconds) * 1000)
                    local minutes = math.floor(seconds / 60)
                    seconds = seconds % 60
                    local formatted_time = string.format("%02d:%02d:%02d", minutes, seconds, milliseconds)
                    table.insert(buildMessage, "["..i.."] "..racer.name.." ("..formatted_time..")")
                end
                for i, racer in ipairs(data.racers) do
                    table.insert(buildMessage, "[DNF] "..racer.name)
                end
                for i, racer in ipairs(data.racers) do
                    racer:SendSystemMessage(table.concat(buildMessage, "</>\n<server>"))
                end
                for i, racer in ipairs(data.finished) do
                    racer:SendSystemMessage(table.concat(buildMessage, "</>\n<server>"))
                end
                RaceData[raceName] = nil
            end
        end
    end
end

local function onLeave(player)
    for raceName,data in pairs(RaceData) do
        for i,v in ipairs(data.racers) do
            if v == player then
                table.remove(data.racers, i)
                data.progress[player.connection] = nil
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
                if #data.racers == 0 and #data.finished == 0 then
                    RaceData[raceName] = nil
                end
                return
            end
        end
    end
end

RegisterForEvent("update", onUpdate)
RegisterForEvent("player_left", onLeave)