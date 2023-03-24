# HogMagic - (Ministry of Mods)

This is a resource to handle containerization and cross-resource communication for LUA mods in HogWarp.
This is a division of [Ministry of Magic](https://github.com/meta-hub/ministry-of-mods) by BrianTU#0001 under the name "HogMagic"

## Special Thanks
Eliakoh#7680 <@161623718811009024> for compiling the mysql.dll (otherwise no mysql)
InternalErrorX#6942 "WindWakerX" <@442214351647014912> for current animations for emotes

# Usage

## For Users

- Clone this repository into your `HogWarpServer/plugins/` directory.
- Check `setup.lua` to setup languages, setup mysql and modules that you would like loaded.
- move **ONLY** `lua54.dll` in `dependencies` to the same folder `HogWarpServer.exe` is located at.
- Start your server and observe the console. If no errors are present; the resource should now be running.

## For Developers

### Creating a Module

- Add a new folder to the `modules/` directory.
- Ensure the folder name is somewhat descriptive of what your resource intends to do.
- At the root of your modules directory, add a `manifest.json` file.
- Inside the `manifest.json` file, create an array of file paths to load (excluding `.lua`).
- The load order will be the same as listed in your `manifest.json` file.

### Native Events

You can catch native events by calling `RegisterForEvent` instead of `registerForEvent`.
Example:

```lua
RegisterForEvent("init", function()
    print(_RESOURCE .. " (Version: " .. _VERSION .. ") started.")
end)
```

### Exports

A simple exports system has been provided to allow cross-resource communication without the use of `require`.
Exports are synchronous.

Exports Example:
```lua
-- To call the `FreezeWeather` export defined in the `world` module:
Exports.world.FreezeWeather(true)

-- To define an export:
Exports("foo", function()
    return "bar"
end)
```

### Using a Module

To load another module into your resource, two primary methods have been provided.
Both of these methods use the `LoadResource` function, which is able to be referenced in all modules.
The first method retrieves a local reference to the module:

```lua
local myModule = LoadResource("myModule")
```

The second method injects a global (to your resources environment) reference of the resource.
This method will use the resource name as the definition.

```lua
LoadResource("myModule", { injectGlobal = true })
```

We can now access this resources functions as defined within the resource:

```lua
myModule.foo()
```

### Loading & Saving Data

The `LoadResourceData` function has been provided to load json data files.
The `SaveResourceData` function has been provided to save a table as json.
You can load and save data files from any resource.

```lua
-- This example will load the file `modules/myModule/data/myData.json` into a table.
local myData = LoadResourceData("myModule", "data/myData.json")

-- This example will save the example table into the file `modules/myModule/data/myData.json`.
local exampleTable = { foo = "bar" }

SaveResourceData("myModule", "data/myData.json", exampleTable)
```

### Loading & Saving Files

The `LoadResourceFile` function has been provided to load a string from file.
The `SaveResourceFile` function has been provided to save a string into a file.
You can load and save resource files from any resource.

```lua
-- This example will load the file `data/version.txt`.
local version = LoadResourceFile("myModule", "data/version.txt")

-- This example will save the example string into the file `modules/myModule/data/version.txt`.
local exampleString = "1.0.0"

SaveResourceFile("myModule", "data/version.txt", exampleString)
```

### Versioning

Backward and forward compatibility can be maintained through the use of versioning within modules.
To update your module to a newer release (in this example, version "1.0.0"), follow the example directory layout:

```
myModule /
    resource.json
    main.lua

    1.0.0 /
        main.lua
```

Given the above example structure (all files in root directory, main.lua is the only script), developers can load the new version of your resource like so:

```lua
local myModule = LoadResource("myModule", { version = "1.0.0" })
```

The file structure and version names are arbitrary. The following example would also work:

```
myModule /
    resource.json

    bar /
        main.lua

    foo /
        bar /
            main.lua
```

Load version "foo":

```lua
local myModule = LoadResource("myModule", { version = "foo" })
```