EasyUi
Loadstring

Lua

local EasyUi = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/ui"))()

Overview

EasyUi is a standalone Roblox UI framework built around:

    draggable windows
    tabs and subtabs inside windows
    a path-based state store
    overlays/HUD pieces
    schema and descriptor-based building
    config save/load
    plugins, custom widgets, and toolkit helpers

It does not require EasyESP.

Default menu key:

Lua

Enum.KeyCode.LeftAlt

Quick start

Lua

local EasyUi = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/ui"))()

local ui = EasyUi.new({
    Title = "My Menu",
    Theme = "pastel",
    Visible = true,
    Signature = "MyMenu",
})

local win = ui:Window("combat", "Combat", { Width = 300 })
local target = win:Tab("target", "Target")
local selector = target:SubTab("selector", "Selector")

selector:Toggle("aim_on", {
    label = "Aimbot",
    path = "combat.aimbot.on",
    default = false,
})

selector:Slider("fov", {
    label = "FOV",
    path = "combat.aimbot.fov",
    min = 20,
    max = 400,
    step = 1,
    default = 120,
})

Creating the UI

Lua

local ui = EasyUi.new({
    Title = "My Menu",
    Theme = "pastel",
    Accent = Color3.fromRGB(202, 164, 255),
    MenuKey = Enum.KeyCode.LeftAlt,
    Visible = true,
    Signature = "MyMenu",
    StartX = 16,
    StartY = 54,
    WindowMaxHeight = 420,
    Watermark = false,
})

Notes:

    a new EasyUi instance destroys the previous active EasyUi instance
    gethui() is used when available
    watermark is off by default

Core control

Lua

ui:SetVisible(true)
ui:GetVisible()
ui:Toggle()
ui:SetMenuKey(Enum.KeyCode.Insert)
ui:Destroy()

Destroy all active UI instances:

Lua

EasyUi.DestroyAll()

Themes

Lua

ui:SetTheme("carbon")
ui:SetAccent(Color3.fromRGB(120, 200, 255))
ui:ApplyTheme()

Helpers:

Lua

print(table.concat(EasyUi.GetThemes(), ", "))
local pastel = EasyUi.GetTheme("pastel")
EasyUi.AddTheme("mytheme", palette)

Store and mounting

Lua

ui:Set("combat.aimbot.on", true)
print(ui:Get("combat.aimbot.on"))

local unwatch = ui:Watch("combat.aimbot.on", function(value)
    print(value)
end, true)

unwatch()

Mount a table:

Lua

local cfg = {
    movement = {
        speed = 16,
        fly = false,
    }
}

ui:Mount("cfg", cfg)
ui:Set("cfg.movement.fly", true)
print(cfg.movement.fly)

Windows, tabs, and subtabs

Lua

local win = ui:Window("combat", "Combat", { Width = 300 })
local target = win:Tab("target", "Target")
local checks = target:SubTab("checks", "Checks")

Lookups:

Lua

ui:GetWindow("combat")
win:GetTab("target")
target:GetSubTab("checks")

Dragging:

    left drag header to move a window
    middle drag anywhere on a window to move it
    middle drag overlays too

Widgets

All widget add methods work on:

    Window
    Tab
    SubTab

Examples:

Lua

selector:Section("Main")
selector:Label("status", "Ready")
selector:Button("save_btn", "Save", { onPress = function() end })
selector:Toggle("aim_on", { label = "Aimbot", path = "combat.aimbot.on", default = false })
selector:Slider("fov", { label = "FOV", path = "combat.aimbot.fov", min = 20, max = 400, step = 1, default = 120 })
selector:Dropdown("part", { label = "Hit Part", path = "combat.part", items = { "Head", "Torso", "Root" }, default = "Head" })
selector:Mode("mode", { label = "Mode", path = "combat.mode", items = { "Legit", "Rage", "Silent" }, default = "Legit" })
selector:Keybind("key", { label = "Hotkey", path = "combat.key", default = Enum.KeyCode.Q })
selector:Box("name", { label = "Config Name", path = "config.name", default = "default" })
selector:Color("accent", { label = "Accent", path = "ui.accent", default = Color3.fromRGB(202, 164, 255) })
selector:Meter("load", { label = "Load", path = "stats.load", default = 0.25 })

Right-click binds

Many actionable controls support right-click binding:

    buttons
    toggles
    sliders
    dropdowns
    mode selectors

Right click the control, then press a key. Press Escape to clear.
Build from descriptors

Lua

ui:BuildFromDescriptors({
    {
        path = "esp.target.on",
        kind = "toggle",
        label = "Target",
        window = "Combat",
        tab = "Target",
        subtab = "Selector",
        section = "Main",
        order = 10,
        default = false,
    },
    {
        path = "esp.target.fov",
        kind = "slider",
        label = "FOV",
        window = "Combat",
        tab = "Target",
        subtab = "Selector",
        section = "Main",
        order = 20,
        min = 20,
        max = 500,
        step = 1,
        default = 240,
    },
})

Overlays

Lua

local ov = ui:Overlay("status", {
    x = 20,
    y = 20,
    w = 180,
    h = 28,
})

local frame = ov:GetFrame()

Builder helper:

Lua

ui:AddOverlay("hud_info", function(ov, ui0, tk)
    tk.Create("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "HUD INFO",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = ui0:GetTheme().text,
    }, ov:GetFrame())
end)

Configs

Lua

local data = ui:ExportConfig()
ui:ImportConfig(data)

ui:SaveConfig("legit")
ui:LoadConfig("legit")
ui:DeleteConfig("legit")
print(table.concat(ui:ListConfigs(), ", "))

ui:SetAutoload("legit")
ui:LoadAutoload()

Toolkit

Lua

local Toolkit = EasyUi.Toolkit

Main helpers:

    Toolkit.Create
    Toolkit.Corner
    Toolkit.Padding
    Toolkit.Stroke
    Toolkit.Tween
    Toolkit.PathGet
    Toolkit.PathSet
    Toolkit.PathToggle
    Toolkit.Build
    Toolkit.BuildFromDescriptors
    Toolkit.Overlay
    Toolkit.Mount
    Toolkit.GetWindow
    Toolkit.GetWidget
    Toolkit.GetOverlay
    Toolkit.GetContainer
    Toolkit.GetTab
    Toolkit.GetSubTab

Setup summary

Use EasyUi when you want:

    fast manual windows
    scalable descriptor-driven menus
    overlays/HUD pieces
    a standalone UI that can control any mounted table
