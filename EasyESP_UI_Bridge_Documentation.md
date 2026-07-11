EasyESP UI Bridge
Loadstring

Lua

local EasyESP_UI_Bridge = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/Bridge"))()

What it is

EasyESP_UI_Bridge is the optional pairing layer between EasyESP and EasyUi.

It is not required by either one.

Its job is to:

    mount esp.cfg into the UI store
    merge ESP descriptors with bridge-only descriptors
    build a default UI from descriptors when possible
    expose one link object for sync/apply/save/load/detach

Quick start

Lua

local EasyUi = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/ui"))()
local EasyESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/esp"))()
local EasyESP_UI_Bridge = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/Bridge"))()

local ui = EasyUi.new({
    Title = "Example",
    Theme = "pastel",
})

local esp = EasyESP.new()
esp:on(true)
esp:start()

local link = EasyESP_UI_Bridge.Attach(ui, esp)

What Attach does

Lua

local link = EasyESP_UI_Bridge.Attach(ui, esp, opt)

It:

    detaches any older bridge first
    mounts esp.cfg into the UI under a prefix
    seeds bridge helper values
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

Descriptor helpers
Bridge-only descriptors

Lua

local list = EasyESP_UI_Bridge.Descriptors("esp")

These cover bridge-specific UI items like:

    theme
    accent
    profile
    pack
    preset
    config name
    apply/save/load buttons

Merged descriptors

Lua

local merged = EasyESP_UI_Bridge.GetDescriptors("esp", esp)

This combines:

    EasyESP descriptors
    bridge descriptors

When ui:BuildFromDescriptors(...) exists, the bridge prefers this merged descriptor route instead of relying only on the older hand-written fallback schema.
Custom prefix

Lua

EasyESP_UI_Bridge.Attach(ui, esp, {
    prefix = "mainesp",
})

Then paths become:

    mainesp.box.on
    mainesp.target.fov
    mainesp.radar.on

Descriptor-driven build

When available, the bridge now prefers:

Lua

ui:BuildFromDescriptors(descs, opt)

That means the pairing flow is now moving toward a descriptor-first architecture.
Schema fallback

The bridge still keeps the older schema fallback path:

Lua

local schema = EasyESP_UI_Bridge.Schema("esp")

You can still force a custom schema:

Lua

EasyESP_UI_Bridge.Attach(ui, esp, {
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

Default order:

    Combat
    Visuals
    Radar
    World
    Self
    Config

Override it:

Lua

EasyESP_UI_Bridge.Attach(ui, esp, {
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

EasyESP_UI_Bridge.Attach(ui, esp, {
    liveTheme = true,
})

Link methods
Sync

Lua

link:sync()

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

EasyESP_UI_Bridge.Detach(ui)

Toolkit

Lua

local Toolkit = EasyESP_UI_Bridge.Toolkit

Helpers:

    Toolkit.Schema(prefix)
    Toolkit.Descriptors(prefix)
    Toolkit.GetDescriptors(prefix, esp)
    Toolkit.Attach(ui, esp, opt)
    Toolkit.Detach(ui)
    Toolkit.ApplyTheme(link)
    Toolkit.ApplySetup(link)
    Toolkit.Save(link, name)
    Toolkit.Load(link, name)
    Toolkit.Pair(UIMod, ESPMod, uiOpt, espOpt, bridgeOpt)

Quick pair helper

Lua

local EasyUi = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/ui"))()
local EasyESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/esp"))()
local EasyESP_UI_Bridge = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/Bridge"))()

local ui, esp, link = EasyESP_UI_Bridge.Toolkit.Pair(EasyUi, EasyESP,
    { Title = "Stack", Theme = "pastel" },
    { on = true },
    { prefix = "esp" }
)

Setup summary

Use the bridge when you want:

    EasyESP + EasyUi wired together quickly
    descriptor-driven bridge generation
    theme/profile/preset/save/load glue without writing it yourself

Skip it when you want either system completely standalone.
