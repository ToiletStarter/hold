EasyESP UI Bridge
Overview

EasyESP_UI_Bridge is the optional pairing layer between EasyESP and EasyUi.

It is not required by either one.

Its job is simple:

    mount esp.cfg into the UI store
    build a default ESP settings layout
    keep shared helper values for theme/profile/preset/config name
    give you one link object for sync, apply, save, load, and detach

If you want both systems to stay separate, do not use the bridge.
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
    builds default bridge windows or a custom schema
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

Default behavior

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

Default windows

The built-in schema creates:

    Combat
    Visuals
    Radar
    World
    Config

Get the raw schema first:

Lua

local schema = Bridge.Schema("esp")

Then edit it before attaching.
Custom schema

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

Setup check

The bridge is streamlined because it removes repetitive glue, not because it hides everything.
Good use case

Use it when you want:

    a ready-made ESP control UI
    synced theme/profile/preset controls
    pair save/load
    fast startup for both systems together

Skip it when you want

    EasyESP by itself
    EasyUi by itself
    a fully custom pairing layer

That keeps the stack simple:

    EasyUi stays standalone
    EasyESP stays standalone
    the bridge only handles pairing
