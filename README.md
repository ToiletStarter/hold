Easy Stack

Easy Stack is a small modular Roblox script stack made up of:

    EasyUi
    EasyESP
    EasyESP_UI_Bridge

The systems are designed so you can use them:

    completely standalone
    or together through the bridge

Modules
EasyUi

Standalone multi-window UI framework.
EasyESP

Standalone Drawing-based ESP framework.
EasyESP_UI_Bridge

Optional pairing layer between EasyUi and EasyESP.
Loadstrings
EasyUi

Lua

local EasyUi = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/ui"))()

EasyESP

Lua

local EasyESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/esp"))()

EasyESP_UI_Bridge

Lua

local EasyESP_UI_Bridge = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/Bridge"))()

All three

Lua

local EasyUi = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/ui"))()
local EasyESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/esp"))()
local EasyESP_UI_Bridge = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/Bridge"))()

Quick start
EasyUi only

Lua

local EasyUi = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/ui"))()

local ui = EasyUi.new({
    Title = "My Menu",
    Theme = "pastel",
    Visible = true,
})

local win = ui:Window("main", "Main", { Width = 300 })
local tab = win:Tab("general", "General")
local sub = tab:SubTab("basic", "Basic")

sub:Toggle("demo", {
    label = "Enabled",
    path = "demo.enabled",
    default = true,
})

EasyESP only

Lua

local EasyESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/esp"))()

local esp = EasyESP.new()
esp:on(true)
esp:start()

EasyUi + EasyESP + Bridge

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

Docs

    EasyUi Documentation
    EasyESP Documentation
    EasyESP UI Bridge Documentation

Why use the bridge?

Use the bridge when you want:

    EasyESP mounted directly into EasyUi
    automatic ESP settings UI
    descriptor-driven UI generation when available
    theme/profile/preset/save/load glue

Skip the bridge when you want:

    EasyUi only
    EasyESP only
    fully custom pairing logic

EasyUi highlights

    windows, tabs, and subtabs
    path-based store
    overlays/HUD pieces
    config save/load
    right-click bindable controls
    middle-click drag for windows and overlays
    toolkit helpers

See full usage in:

    EasyUi Documentation

EasyESP highlights

    target selector
    radar/list/watermark HUD pieces
    entity/ring/module/hook systems
    themes/profiles/packs/presets
    descriptor layer
    middle-click drag for ESP HUD pieces
    toolkit helpers

See full usage in:

    EasyESP Documentation

Bridge highlights

    mounts esp.cfg into EasyUi
    merges ESP descriptors with bridge descriptors
    builds a default paired UI
    exposes sync, applyTheme, applySetup, save, load, detach
    toolkit pair helper

See full usage in:

    EasyESP UI Bridge Documentation

Notes

    EasyUi default menu key is LeftAlt
    EasyUi watermark is off by default
    creating a new EasyUi instance destroys the previous active one
    creating a new EasyESP instance destroys the previous active one
    the bridge detaches older bridge state before attaching a new one

Recommended path
If you just want a UI

Start with EasyUi
If you just want ESP

Start with EasyESP
If you want the full stack

Use:

    EasyUi
    EasyESP
    EasyESP_UI_Bridge
    example.luau
