EasyESP UI Bridge
What it is

EasyESP_UI_Bridge is the optional pairing layer between EasyESP and EasyUi.

It is not required by either one.

Its job is to:

    mount esp.cfg into the UI store
    merge ESP descriptors with bridge-only descriptors
    build a default UI from descriptors when possible
    expose one link object for sync/apply/save/load/detach

If you want EasyESP and EasyUi to stay separate, do not use the bridge.
Quick start

Lua

local EasyUi = require(path.To.EasyUi)
local EasyESP = require(path.To.EasyESP)
local Bridge = require(path.To.EasyESP_UI_Bridge)

local ui = EasyUi.new({
    Title = "Example",
    Theme = "pastel",
})

local esp = EasyESP.new()
esp:on(true)
esp:start()

local link = Bridge.Attach(ui, esp)

What Attach does

Lua

local link = Bridge.Attach(ui, esp, opt)

It:

    detaches any older bridge first
    mounts esp.cfg into the UI under a prefix
    seeds bridge helper values like theme/profile/preset/name
    builds windows from descriptors when available
    falls back to the old manual schema if needed
    returns a link object

Returned object:

Lua

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

Default prefix

Default prefix:

Lua

"esp"

So bridge widget paths look like:

    esp.box.on
    esp.target.fov
    esp.radar.on
    esp.world.on

Bridge helper paths:

    bridge.esp
    bridge.theme
    bridge.accent
    bridge.profile
    bridge.pack
    bridge.preset
    bridge.cfgName

Custom prefix

Lua

Bridge.Attach(ui, esp, {
    prefix = "mainesp",
})

Then paths become:

    mainesp.box.on
    mainesp.target.fov
    mainesp.radar.on

Descriptor-first bridge flow
ESP descriptors

If EasyESP exposes descriptors, the bridge prefers those.
Bridge descriptors

The bridge also injects bridge-only descriptors for things like:

    theme
    accent
    profile
    pack
    preset
    config name
    save/load/apply buttons

You can fetch the bridge-only descriptors:

Lua

local list = Bridge.Descriptors("esp")

You can fetch the merged descriptor list:

Lua

local merged = Bridge.GetDescriptors("esp", esp)

Default descriptor-driven build

When available, the bridge now prefers:

Lua

ui:BuildFromDescriptors(descs, opt)

That means the default bridge is already moving away from one giant hardcoded schema table.
Schema fallback

The bridge still keeps the older schema fallback path for compatibility:

Lua

local schema = Bridge.Schema("esp")

You can still force a custom schema:

Lua

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

Window order and width

When building from descriptors, the bridge applies default window ordering and widths.

Default window order:

    Combat
    Visuals
    Radar
    World
    Self
    Config

You can override it:

Lua

Bridge.Attach(ui, esp, {
    windowOrder = {
        Combat = 1,
        Config = 2,
        Visuals = 3,
    },
    windowWidth = {
        Combat = 320,
        Visuals = 300,
        Config = 260,
    },
})

Live theme sync

If you want bridge.theme and bridge.accent changes to apply automatically:

Lua

Bridge.Attach(ui, esp, {
    liveTheme = true,
})

Link methods
Sync

Lua

link:sync()

Refreshes bridge-bound widgets from the mounted ESP config.
Apply theme

Lua

link:applyTheme()

Reads:

    bridge.theme
    bridge.accent

Then applies the result to:

    EasyUi
    EasyESP

Apply setup

Lua

link:applySetup()

Reads:

    bridge.preset
    bridge.profile
    bridge.pack

Then applies the matching ESP setup.
Save pair

Lua

link:save("legit")

Saves:

    ui:SaveConfig(name)
    esp:save(name)

If no name is provided, it uses bridge.cfgName.
Load pair

Lua

link:load("legit")

Loads:

    ui:LoadConfig(name)
    esp:load(name)

Then reapplies bridge theme and syncs again.
Detach

Lua

link:detach()

This destroys bridge-built windows and unmounts the ESP config root from the UI.
Detach directly

Lua

Bridge.Detach(ui)

Use this if you want to remove the bridge without destroying the UI or ESP themselves.
Bridge toolkit

Lua

local Bridge = require(path.To.EasyESP_UI_Bridge)
local tk = Bridge.Toolkit

Helpers

    tk.Schema(prefix)
    tk.Descriptors(prefix)
    tk.GetDescriptors(prefix, esp)
    tk.Attach(ui, esp, opt)
    tk.Detach(ui)
    tk.ApplyTheme(link)
    tk.ApplySetup(link)
    tk.Save(link, name)
    tk.Load(link, name)
    tk.Pair(UIMod, ESPMod, uiOpt, espOpt, bridgeOpt)

Quick pair helper

Lua

local EasyUi = require(path.To.EasyUi)
local EasyESP = require(path.To.EasyESP)
local Bridge = require(path.To.EasyESP_UI_Bridge)

local ui, esp, link = Bridge.Toolkit.Pair(EasyUi, EasyESP,
    { Title = "Stack", Theme = "pastel" },
    { on = true },
    { prefix = "esp" }
)

By default Pair:

    creates the UI
    creates the ESP
    enables the ESP unless espOpt.on == false
    starts the ESP unless bridgeOpt.start == false
    attaches the bridge

Setup summary

The bridge now has two clear roles:
Fast pairing layer

Use it when you want EasyUi and EasyESP working together quickly.
Descriptor merge layer

Use it when you want to consume:

    ESP descriptors
    bridge descriptors
    descriptor-driven UI generation

That means it stays useful without forcing either system to depend on the other.
