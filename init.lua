--[[Globalize]]
_G._PATH = io.popen("cd"):read("*l")

--[[Required]]
--socket = require("library/socket")
--ltn12 = require("library/ltn12")
--mime = require("library/mime")
--ssl = require("library/ssl")
--url = require("library/socket/url")
--headers = require("library/socket/headers")
--http = require("library/socket/http")
--tp = require("library/socket/tp")
--ftp = require("library/socket/ftp")
--smtp = require("library/socket/smtp") -- courtine issue
--https = require("library/ssl/https")

require("library/dkjson")
require("library/string")
require("setup")

--[[File Validation]]
local function fileExists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local function readFile(path)
    local file = io.open(path, "r")
    if file then
        local contents = file:read("*a")
        file:close()
        return contents
    end
    return nil
end

local function writeFile(path, data)
    local file = io.open(path, "w+")
    if file then
        file:write(data)
        file:close()
        return true
    end
    return false
end

--[[Exports]]
local exports = {}

local exportsMt = {
    __index = function(self, resourceName)
        if type(resourceName) ~= "string" then
            return error("Exports must be indexed with a string value")
        end
        if not exports[resourceName] then
            return error(string.format("No exports defined for %s. Are you sure this resource has been started?"), resourceName)
        end
        return setmetatable({}, {
            __index = function(self, exportName)
                if type(exportName) ~= "string" then
                    return error("Exports methods must be indexed with a string value")
                end
                return exports[resourceName][exportName]
            end
        })
    end,
    __call = function(self, exportName, fn)
        if type(exportName) ~= "string" then
            return error("Export definition requires string as the first argument")
        elseif type(fn) ~= "function" then
            return error("Export definition requires function as the second argument")
        end
        exports[self._RESOURCE] = exports[self._RESOURCE] or {}
        exports[self._RESOURCE][exportName] = fn
    end
}

--[[Localization]]
local locales = {}

local function translate(self, labelName)
    if not locales[self._RESOURCE] then
        locales[self._RESOURCE] = LoadResourceData(self._RESOURCE, "locales/" .. Core.Language .. ".json")
    end
    return locales[self._RESOURCE][labelName]
end

local localesMt = {
    __index = translate,
    __call = translate
}

--[[Resource Loader]]
local loadResource
local loadedResources = {}
local loadResourceMt = {
    __call = function(self, resourceName, options, reload)
        return loadResource(self._g, resourceName, options or {}, reload)
    end
}

local function createEnvironment(resourceName, version)
    local _g = {}

    _g._RESOURCE    = resourceName
    _g._VERSION     = version
    _g.LoadResource = setmetatable({ _g = _g }, loadResourceMt)
    _g.Exports      = setmetatable({ _RESOURCE = resourceName }, exportsMt)
    _g.Locale       = setmetatable({ _RESOURCE = resourceName }, localesMt)

    local env = {}

    env._G = _G
    env._ENV = setmetatable(env, {
        __index = function(self, k)
            if _g[k] == nil then
                return _G[k]
            end

            return _g[k]
        end,

        __newindex = _g
    })

    return env
end

local function loadScript(code, filePath, environment, ...)
    local _,fn,err = pcall(load, code, filePath, 'bt', environment)

    if err then
        return false,err
    end

    if type(fn) ~= "function" then
        return false
    end

    local res,ret = pcall(fn, ...)

    if not res then
        return false,ret
    end

    return ret
end

local function handleReturn(_g, resourceName, options, globalTable)
    if not next(globalTable) then
        return nil
    end

    if options.injectGlobal then
        _g[resourceName] = globalTable
    else
        return globalTable
    end
end

loadResource = function(_g, resourceName, options, reload)
    local version = options.version or "root"

    if not reload and loadedResources[resourceName] and loadedResources[resourceName][version] then
        return handleReturn(_g, resourceName, options, loadedResources[resourceName][version])
    end

    options = options or {}

    local versionPath = options.version and ("/" .. options.version) or ""
    local resourcePath = _PATH .. "/modules/" .. resourceName .. versionPath
    local entryFilePath = resourcePath .. "/manifest.json"

    if not fileExists(entryFilePath) then
        return error("module does not contain manifest.json entry file: " .. resourceName)
    end

    local entryFileContent = readFile(entryFilePath)

    if type(entryFileContent) ~= "string" then
        return error("module has invalid manifest.json entry file: " .. resourceName)
    end

    local resourceDef = json.decode(entryFileContent)

    if type(resourceDef) ~= "table" then
        return error("module has invalid manifest.json entry file content: " .. resourceName)
    end

    local env = options.env or createEnvironment(resourceName, options.version or "default")

    local globalTable = {}

    for _,fileName in ipairs(resourceDef) do
        local filePath = resourcePath .. "/" .. fileName .. ".lua"

        if not fileExists(filePath) then
            return error("defined file does not exist: " .. filePath)
        end

        local code = readFile(filePath)

        if not code then
            return error("invalid file content for: " .. filePath)
        end

        local res,err = loadScript(code, filePath, env)

        if err then
            return error(err)
        end

        if type(res) == "table" then
            for k,v in pairs(res) do
                globalTable[k] = v
            end
        elseif type(res) == "function" then
            globalTable[fileName] = res
        end
    end

    loadedResources[resourceName] = loadedResources[resourceName] or {}
    loadedResources[resourceName][version] = globalTable

    return handleReturn(_g, resourceName, options, globalTable)
end

--[[Native Event Handler]]
local VALID_EVENTS = {
    init = true,
    update = true,
    shutdown = true,
    player_joined = true,
    player_left = true,
    player_chat = true,
}

local nativeEventListeners = {}
local nativeForEvent = registerForEvent
registerForEvent = nil

function RegisterForEvent(eventName, listenerFunc)
    if type(eventName) ~= "string" then
        error("RegisterForEvent requires a string as the first argument.")
    end
    eventName = eventName:lower()
    if not VALID_EVENTS[eventName] then
        error("Event is not valid.")
    end
    if type(listenerFunc) ~= "function" then
        error("RegisterForEvent requires a function as the second argument.")
    end

    if not nativeEventListeners[eventName] then
        nativeEventListeners[eventName] = {}
        nativeForEvent(eventName, function(...)
            local chatState = false
            for _, listener in ipairs(nativeEventListeners[eventName]) do
                if eventName == "player_chat" then
                    if listener(...) then
                        chatState = true
                    end
                else
                    listener(...)
                end
            end
            if eventName == "player_chat" then
                return chatState
            end
        end)
    end
    table.insert(nativeEventListeners[eventName], listenerFunc)
end

--[[File Loader]]
function LoadResourceFile(resourceName, filePath)
    if type(resourceName) ~= "string" then
        return error("LoadResourceFile requires a string [resourceName] as the first argument.")
    end
    if type(filePath) ~= "string" then
        return error("LoadResourceFile requires a string [filePath] as the second argument.")
    end
    local path = _PATH .. "/modules/" .. resourceName .. "/" .. filePath
    if not fileExists(path) then
        return ""
    end
    local content = readFile(path)
    if type(content) ~= "string" then
        return error("invalid data file content: " .. path)
    end
    return content
end

function SaveResourceFile(resourceName, filePath, content)
    if type(resourceName) ~= "string" then
        return error("SaveResourceFile requires a string [resourceName] as the first argument.")
    end
    if type(filePath) ~= "string" then
        return error("SaveResourceFile requires a string [filePath] as the second argument.")
    end
    if type(content) ~= "string" then
        return error("SaveResourceFile requires a string [content] as the third argument.")
    end
    local path = _PATH .. "/modules/" .. resourceName .. "/" .. filePath
    local result = writeFile(path, content)
    if not result then
        return error("failed writing data to file: " .. path)
    end
end

--[[Data File Loader]]
function LoadResourceData(resourceName, filePath)
    if type(resourceName) ~= "string" then
        return error("LoadResourceData requires a string as the first argument.")
    end
    if type(filePath) ~= "string" then
        return error("LoadResourceData requires a string as the second argument.")
    end
    local content = LoadResourceFile(resourceName, filePath)
    if not content then
        return {}
    end
    return json.decode(content)
end

function SaveResourceData(resourceName, filePath, data)
    if type(resourceName) ~= "string" then
        return error("SaveResourceData requires a string as the first argument.")
    end
    if type(filePath) ~= "string" then
        return error("SaveResourceData requires a string as the second argument.")
    end
    if type(data) ~= "table" then
        return error("SaveResourceData requires a table as the third argument.")
    end
    local content = json.encode(data, { indent = true })
    SaveResourceFile(resourceName, filePath, content)
end

--[[Resource Initialization]]
for _,resourceDef in ipairs(Core.Modules) do
    loadResource(_G, resourceDef.name, resourceDef.options or {})
end