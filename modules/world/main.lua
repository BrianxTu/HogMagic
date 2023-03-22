-- Variable Setup
local seasonTable = {2,2,4,4,4,1,1,1,3,3,3,2}
local seasonTypes = {[1] = "Summer", [2] = "Winter", [3] = "Fall", [4] = "Spring"}
local weatherTypes = {
    Clear = {"Clear", "LightClouds_01"},
    Rainy = {"LightRain_01", "Rainy", "FIG_07_Storm", "Stormy_01", "StormyLarge_01", "TestStormShort"},
    Overcast = {"Overcast_01", "Overcast_Heavy_01", "Overcast_Heavy_Winter_01", "Overcast_Windy_01", "Winter_Overcast_01", "Winter_Overcast_Windy_01", "Summer_Overcast_Heavy_01"},
    Misty = {"Misty_01", "MistyOvercast_01", "Winter_Misty_01"},
    Snowy = {"Snow_01", "Snow_Const", "SnowLight_01", "SnowShort"},
    Sanctuary = {"Sanctuary_Bog", "Sanctuary_Coastal", "Sanctuary_Forest", "Sanctuary_Grasslands"},
    Other = {"Announce", "Astronomy", "Default_PHY", "ForbiddenForest_01", "HighAltitudeOnly", "Intro_01", "MKT_Nov11", "TestWind"}
}

--
local world = server.world
local WorldData = {
    hour = world.hour,
    minute = world.minute,
    second = world.second,
    year = world.year,
    month = world.month,
    day = world.day,
    season = world.season,
    weather = world.weather,
}

local FreezeTime, FreezeWeather = Config.TimeControl.FreezeTime, Config.WeatherControl.FreezeWeather

-- Functions
local function daysInMonth(month, year)
    local days_in_month = {31,28,31,30,31,30,31,31,30,31,30,31}
    if month == 2 then
        return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0) and 29 or 28
    else
        return days_in_month[month]
    end
end

function syncWorld()
    for i,v in pairs(WorldData) do
        world[i] = v
    end
    world:RpcSet()
end

local function newWeather()
    local seasonIndex = seasonTable[WorldData.month]
    local season = seasonTypes[seasonIndex]
    local totalChance = 0
    for _, chance in pairs(Config.WeatherChances[season]) do
        if not (chance <= 0) then
            totalChance = totalChance + chance
        end
    end
    local randomChance = math.random(1, totalChance)
    local currentChance = 0
    local currentWeatherType = nil
    for weatherType, chance in pairs(Config.WeatherChances[season]) do
        if not (chance <= 0) then
            currentChance = currentChance + chance
            if randomChance <= currentChance then
                currentWeatherType = weatherType
                break
            end
        end
    end
    local weatherEffect = nil
    if weatherTypes[currentWeatherType] then
        local weatherTypeTable = weatherTypes[currentWeatherType]
        local numWeatherEffects = #weatherTypeTable
        local randomIndex = math.random(1, numWeatherEffects)
        weatherEffect = weatherTypeTable[randomIndex]
    end
    WorldData.season = seasonIndex
    WorldData.weather = weatherEffect
    syncWorld()
end

local function Initiate()
    local time = Config.TimeControl
    local weather = Config.WeatherControl
    if type(time.hour) == "number" and time.hour >= 0 and time.hour <= 23 then
        WorldData.hour = math.floor(time.hour)
    end
    if type(time.minute) == "number" and time.minute >= 0 and time.minute <= 59 then
        WorldData.minute = math.floor(time.minute)
    end
    if type(time.second) == "number" and time.second >= 0 and time.second <= 59 then
        WorldData.second = math.floor(time.second)
    end
    if type(time.year) == "number" and time.year >= 0 then
        WorldData.year = math.floor(time.year)
    end
    if type(time.month) == "number" and time.month >= 1 and time.month <= 12 then
        WorldData.month = math.floor(time.month)
    end
    if type(time.day) == "number" and time.day >= 1 and time.day <= 31 then
        WorldData.day = math.floor(time.day)
    end
    if type(weather.season) == "number" and seasonTypes[weather.season] then
        WorldData.season = math.floor(weather.season)
    end
    if type(weather.weather) == "string" then
        WorldData.weather = weather.weather
    end
    if Config.TimeControl.UseOSTime then
        local date = os.date("*t")
        WorldData.hour = tonumber(date.hour)
        WorldData.minute = tonumber(date.min)
        WorldData.second = tonumber(date.sec)
        WorldData.year = tonumber(date.year)
        WorldData.month = tonumber(date.month)
        WorldData.day = tonumber(date.day)
    end
end

local SyncTick, WeatherTick, SecondTick = 0, 0, 0
local function Update(Delta)
    SyncTick = SyncTick + Delta
    SecondTick = SecondTick + Delta
    WeatherTick = WeatherTick + Delta

    if not FreezeTime then
        if Config.TimeControl.UseOSTime then
            local date = os.date("*t")
            WorldData.hour = tonumber(date.hour)
            WorldData.minute = tonumber(date.min)
            WorldData.second = tonumber(date.sec)
            WorldData.year = tonumber(date.year)
            WorldData.month = tonumber(date.month)
            WorldData.day = tonumber(date.day)
        else
            if SecondTick > 1 then
                SecondTick = SecondTick - 1
                WorldData.second = WorldData.second + 1
            end
            if WorldData.second > 59 then
                WorldData.second = WorldData.second - 60
                WorldData.minute = WorldData.minute + 1
            end
            if WorldData.minute > 59 then
                WorldData.minute = WorldData.minute - 60
                WorldData.hour = WorldData.hour + 1
            end
            if WorldData.hour > 23 then
                WorldData.hour = 0
                WorldData.day = WorldData.day + 1
            end
            if WorldData.day > daysInMonth(WorldData.month, WorldData.year) then
                WorldData.day = 1
                WorldData.month = WorldData.month + 1
            end
            if WorldData.month > 12 then
                WorldData.month = 1
                WorldData.year = WorldData.year + 1
            end
        end
    end
    if not FreezeWeather then
        if WeatherTick > Config.Settings.WeatherTimer then
            WeatherTick = WeatherTick - Config.Settings.WeatherTimer
            newWeather()
        end
    end
    if SyncTick > Config.Settings.SyncTimer then
        SyncTick = SyncTick - Config.Settings.SyncTimer
        WorldData.minute = WorldData.minute + Config.Settings.MinutesPerSync
        syncWorld()
    end
end

-- Events
RegisterForEvent("init", Initiate)
RegisterForEvent("update", Update)

-- Additional Functions
function getWorldData()
    return WorldData
end
function getWeatherTypes()
    return weatherTypes
end

function setWorldData(DataTable)
    if type(DataTable) == "table" and DataTable ~= {} then
        for i,v in pairs(DataTable) do
            if WorldData[i] then
                WorldData[i] = v
                if i == "month" then
                    local seasonIndex = seasonTable[WorldData.month]
                    WorldData.season = seasonIndex
                end
            end
        end
        syncWorld()
    end
end

function fTime(state)
    if type(state) == "boolean" then
        FreezeTime = state
    else
        if FreezeTime then
            FreezeTime = false
        else
            FreezeTime = true
        end
    end
    return FreezeTime
end

function fWeather(state)
    if type(state) == "boolean" then
        FreezeWeather = state
    else
        if FreezeWeather then
            FreezeWeather = false
        else
            FreezeWeather = true
        end
    end
    return FreezeWeather
end