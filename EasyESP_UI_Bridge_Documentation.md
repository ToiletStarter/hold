# EasyESP UI Bridge

## What it is
EasyESP_UI_Bridge is the optional helper that makes EasyESP and EasyUi work together faster.

It does not replace either system.
It only:
- mounts `esp.cfg` into the UI store
- builds a default ESP control layout
- adds bridge helper state like preset/profile/theme/config name
- gives you one object that can sync, apply, save, load, and detach
- prevents duplicate bridge attachments

---

## Basic setup

```lua
local UI = require(path.To.EasyUi)
local ESP = require(path.To.EasyESP)
local Bridge = require(path.To.EasyESP_UI_Bridge)

local ui = UI.new({
    Title = "EasyStack",
    Theme = "pastel",
    MenuKey = Enum.KeyCode.RightShift,
})

local esp = ESP.new()
esp:on(true)
esp:start()

local link = Bridge.Attach(ui, esp)
```

---

## What `Attach` does

```lua
local link = Bridge.Attach(ui, esp, opt)
```

It:
- detaches any older bridge first
- mounts `esp.cfg` into the UI under a prefix
- builds default bridge windows or a custom schema
- returns a link object

Returned object:

```lua
{
    ui = ui,
    esp = esp,
    prefix = "esp",
    windows = { ... },
    unsub = { ... },
    sync = function() ... end,
    applyTheme = function() ... end,
    applySetup = function() ... end,
    save = function(name) ... end,
    load = function(name) ... end,
    detach = function() ... end,
}
```

---

## Default setup

The default prefix is `esp`.
That means bridge widget paths look like:

- `esp.box.on`
- `esp.target.fov`
- `esp.radar.on`
- `esp.world.on`

Default bridge helper paths:

- `bridge.esp`
- `bridge.theme`
- `bridge.accent`
- `bridge.profile`
- `bridge.pack`
- `bridge.preset`
- `bridge.cfgName`

---

## Custom prefix

```lua
Bridge.Attach(ui, esp, {
    prefix = "mainesp",
})
```

Then paths become:

- `mainesp.box.on`
- `mainesp.target.fov`
- `mainesp.radar.on`

---

## Default windows

The built-in schema creates:
- Combat
- Visuals
- Radar
- World
- Config

You can get the raw schema first:

```lua
local schema = Bridge.Schema("esp")
```

Then edit it before attaching.

---

## Custom schema

```lua
Bridge.Attach(ui, esp, {
    prefix = "esp",
    schema = {
        {
            id = "combat",
            title = "Combat",
            Width = 250,
            items = {
                { kind = "toggle", id = "tg_on", label = "Target", path = "esp.target.on" },
                { kind = "slider", id = "tg_fov", label = "FOV", path = "esp.target.fov", min = 20, max = 500, step = 1 },
            },
        },
    }
})
```

---

## Live theme sync

If you want `bridge.theme` and `bridge.accent` changes to apply automatically:

```lua
Bridge.Attach(ui, esp, {
    liveTheme = true,
})
```

---

## Link methods

### Sync

```lua
link:sync()
```

Refreshes the UI from the mounted ESP config.

### Apply theme

```lua
link:applyTheme()
```

Reads:
- `bridge.theme`
- `bridge.accent`

Then applies the theme to:
- the UI
- the ESP

### Apply setup

```lua
link:applySetup()
```

Reads:
- `bridge.preset`
- `bridge.profile`
- `bridge.pack`

Then applies the matching ESP setup.

### Save pair

```lua
link:save("legit")
```

Saves:
- `ui:SaveConfig(name)`
- `esp:save(name)`

If no name is provided, it uses `bridge.cfgName`.

### Load pair

```lua
link:load("legit")
```

Loads:
- `ui:LoadConfig(name)`
- `esp:load(name)`

Then reapplies bridge theme and syncs mounted values.

### Detach

```lua
link:detach()
```

This destroys bridge-built windows and unmounts the ESP config root from the UI.

---

## Detach directly

```lua
Bridge.Detach(ui)
```

Use this if you want to remove the bridge later without destroying the UI or ESP themselves.

---

## Bridge toolkit

```lua
local Bridge = require(path.To.EasyESP_UI_Bridge)
local tk = Bridge.Toolkit
```

### Helpers

- `tk.Schema(prefix)`
- `tk.Attach(ui, esp, opt)`
- `tk.Detach(ui)`
- `tk.ApplyTheme(link)`
- `tk.ApplySetup(link)`
- `tk.Save(link, name)`
- `tk.Load(link, name)`
- `tk.Pair(UIMod, ESPMod, uiOpt, espOpt, bridgeOpt)`

### Quick pair helper

```lua
local UI = require(path.To.EasyUi)
local ESP = require(path.To.EasyESP)
local Bridge = require(path.To.EasyESP_UI_Bridge)

local ui, esp, link = Bridge.Toolkit.Pair(UI, ESP,
    { Title = "Stack", Theme = "pastel" },
    { on = true },
    { prefix = "esp" }
)
```

By default `Pair`:
- creates the UI
- creates the ESP
- enables the ESP unless `espOpt.on == false`
- starts the ESP unless `bridgeOpt.start == false`
- attaches the bridge

---

## Why use the bridge

Use the bridge if you want:
- the fastest paired setup
- a default ESP settings UI
- synced theme/profile/preset controls
- pair save/load buttons without writing the glue yourself

Do not use it if you want the systems to stay completely separate.
