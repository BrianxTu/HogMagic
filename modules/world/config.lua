Config = {}

Config.Settings = {
    SyncTimer = 0,                  -- How long before before the server forces a sync (Seconds)
    WeatherTimer = 300,             -- How long before the server changes the weather (Seconds)
    MinutesPerSync = 0,             -- Every sync adds the given number to minutes
}

Config.TimeControl = {
    FreezeTime = false,             -- Forces the Time & Date to freeze
    UseOSTime = false,              -- if you want to use OS time (ignores all time settings below)
    hour = false,                   -- Must be between 1 & 23
    minute = false,                 -- Must be between 1 & 59
    second = false,                 -- Must be between 1 & 59
    year = false,                   -- Anything 4 digits long
    month = false,                  -- Must be between 1 & 12
    day = false,                    -- Must be between 1 & 31 (Even if feburary has 28 days, it will be corrected automatically)
}

Config.WeatherControl = {
    FreezeWeather = false,          -- Forces the Weather to freeze
    season = false,                 -- Must be between 1 & 4  (see "world.lua" for more information)
    weather = false,                -- Must be valid Weather System (see "world.lua" for more information)
}

Config.TimePresets = {
    ["morning"] = {6,30,0},
    ["noon"] = {12,30,0},
    ["night"] = {21,30,0},
}

Config.WeatherChances = {
    Summer = {
        Clear = 50,
        Rainy = 10,
        Overcast = 20,
        Misty = 5,
        Snowy = 0,
        Sanctuary = 0,
        Other = 0,
    },
    Winter = {
        Clear = 10,
        Rainy = 5,
        Overcast = 30,
        Misty = 20,
        Snowy = 35,
        Sanctuary = 0,
        Other = 0,
    },
    Fall = {
        Clear = 20,
        Rainy = 40,
        Overcast = 15,
        Misty = 10,
        Snowy = 0,
        Sanctuary = 0,
        Other = 0,
    },
    Spring = {
        Clear = 30,
        Rainy = 30,
        Overcast = 20,
        Misty = 10,
        Snowy = 0,
        Sanctuary = 0,
        Other = 0,
    }
}