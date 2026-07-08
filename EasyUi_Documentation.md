EasyUi
What it is

EasyUi is a standalone Roblox UI framework built around:

    draggable windows
    tabs and subtabs inside windows
    a path-based state store
    overlays/HUD pieces
    schema and descriptor-based building
    config save/load
    extension through plugins, custom widgets, and a toolkit

It does not require EasyESP.

Default menu key:

Lua

Enum.KeyCode.LeftAlt

Quick start

Lua

local EasyUi = require(path.To.EasyUi)

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

local ui = EasyUi.new(options)

Common options

Lua

local ui = EasyUi.new({
    Title = "My Menu",
    Theme = "pastel",
    ThemeOverride = nil,
    Accent = Color3.fromRGB(202, 164, 255),
    MenuKey = Enum.KeyCode.LeftAlt,
    Visible = true,
    Signature = "MyMenu",
    Id = "MyMenuGui",
    StartX = 16,
    StartY = 54,
    WindowMaxHeight = 420,
    Watermark = false,
})

Notes

    creating a new EasyUi instance destroys the previous active EasyUi instance
    gethui() is used when available
    the UI creates its own internal container for safe extension content
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
Change theme or accent

Lua

ui:SetTheme("carbon")
ui:SetAccent(Color3.fromRGB(120, 200, 255))
ui:ApplyTheme()

Theme helpers

Lua

print(table.concat(EasyUi.GetThemes(), ", "))
local pastel = EasyUi.GetTheme("pastel")
EasyUi.AddTheme("mytheme", palette)

Store and mounting

EasyUi uses a path-based store. This is the core of how widgets stay organized.
Direct get/set

Lua

ui:Set("combat.aimbot.on", true)
print(ui:Get("combat.aimbot.on"))

Watch a path

Lua

local unwatch = ui:Watch("combat.aimbot.on", function(value)
    print("new value:", value)
end, true)

unwatch()

Mount an external table

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

Unmount it:

Lua

ui:Unmount("cfg")

Sync widgets from store

Lua

ui:Sync()
ui:Sync("cfg")

Windows
Create a window

Lua

local win = ui:Window("combat", "Combat", {
    Width = 300,
    X = 18,
    Y = 72,
    Open = true,
    MaxHeight = 420,
})

Aliases:

Lua

ui:CreateWindow("combat", "Combat", opt)
ui:CreatePanel("Combat", opt)

Window methods

Lua

win:SetTitle("Combat Settings")
win:SetVisible(true)
win:Open()
win:Close()
win:ToggleOpen()
win:Destroy()

Window lookup

Lua

ui:GetWindows()
ui:GetWindow("combat")

Dragging behavior

    left click and drag the header to move a window
    middle click and drag anywhere on the window to move it
    last interacted window comes to the front
    overlapping windows auto-resolve on build/import/resize

Tabs and subtabs

This is the main anti-cramping layer in the current UI.
Create tabs

Lua

local target = win:Tab("target", "Target")
local prediction = win:Tab("prediction", "Prediction")

Create subtabs

Lua

local selector = target:SubTab("selector", "Selector")
local checks = target:SubTab("checks", "Checks")

Lookup helpers

Lua

win:GetTab("target")
target:GetSubTab("selector")

Why use them

Tabs and subtabs let one window carry more settings without turning into one giant flat scroll stack.
Widgets

All widget add methods work on:

    Window
    Tab
    SubTab

Section

Lua

selector:Section("Main")
selector:AddSeparator("Main")

Label

Lua

local lbl = selector:Label("status", "Ready")
lbl:set("Running")

Button

Lua

selector:Button("save_btn", "Save", {
    onPress = function()
        print("save")
    end,
})

Toggle

Lua

selector:Toggle("aim_on", {
    label = "Aimbot",
    path = "combat.aimbot.on",
    default = false,
    onChange = function(v)
        print(v)
    end,
})

Slider

Lua

selector:Slider("fov", {
    label = "FOV",
    path = "combat.aimbot.fov",
    min = 20,
    max = 400,
    step = 1,
    default = 120,
})

Dropdown

Lua

selector:Dropdown("part", {
    label = "Hit Part",
    path = "combat.aimbot.part",
    items = { "Head", "Torso", "Root" },
    default = "Head",
})

Mode switch

Lua

selector:Mode("mode", {
    label = "Mode",
    path = "combat.mode",
    items = { "Legit", "Rage", "Silent" },
    default = "Legit",
})

Keybind

Lua

selector:Keybind("key", {
    label = "Hotkey",
    path = "combat.key",
    default = Enum.KeyCode.Q,
    onPress = function(key)
        print("pressed", key)
    end,
})

Text box

Lua

selector:Box("name", {
    label = "Config Name",
    path = "config.name",
    default = "default",
    placeholder = "name",
    onCommit = function(text)
        print(text)
    end,
})

Color picker

Lua

selector:Color("accent", {
    label = "Accent",
    path = "ui.accent",
    default = Color3.fromRGB(202, 164, 255),
})

Meter / progress

Lua

selector:Meter("load", {
    label = "Load",
    path = "stats.load",
    default = 0.25,
})

Binds on controls

You can right click many controls to set a bind for them.

Supported in a practical way on:

    buttons
    toggles
    sliders
    dropdowns
    mode selectors

General behavior:

    right click the control
    press a key
    press Escape to clear
    pressing the bound key triggers that control’s activate() behavior

Examples:

    toggle flips
    button fires
    slider steps forward
    dropdown cycles
    mode cycles

You can also define a bind up front:

Lua

selector:Toggle("aim_on", {
    label = "Aimbot",
    path = "combat.aimbot.on",
    bindKey = Enum.KeyCode.E,
})

Build from schema

Lua

ui:Build({
    {
        id = "visuals",
        title = "Visuals",
        Width = 260,
        items = {
            { kind = "section", text = "ESP" },
            { kind = "toggle", id = "box_on", label = "Box", path = "cfg.esp.box" },
            { kind = "slider", id = "range", label = "Range", path = "cfg.esp.range", min = 100, max = 3000, step = 50 },
            { kind = "color", id = "accent", label = "Accent", path = "cfg.ui.accent" },
        },
    },
})

Build from descriptors

This is the more scalable route.

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

Optional ordering/width:

Lua

ui:BuildFromDescriptors(descs, {
    windowOrder = {
        Combat = 1,
        Visuals = 2,
        Config = 3,
    },
    windowWidth = {
        Combat = 300,
        Visuals = 300,
        Config = 260,
    },
})

Overlays / HUD
Create an overlay

Lua

local ov = ui:Overlay("status", {
    x = 20,
    y = 20,
    w = 180,
    h = 28,
})

local frame = ov:GetFrame()

Builder helper

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
end, {
    x = 20,
    y = 60,
    w = 160,
    h = 28,
})

Overlay lookup

Lua

ui:GetOverlay("status")

Dragging overlays

    middle click and drag an overlay anywhere to move it

Watermark and toasts
Watermark

Lua

ui:SetWatermark(function()
    return "My Menu | " .. os.date("%X")
end)

ui:SetWatermarkVisible(true)

Toasts

Lua

ui:Toast("Loaded", "UI is ready", 2, "ok")
ui:Toast("Warning", "Check settings", 2, "warn")
ui:Toast("Error", "Something failed", 2, "err")

Configs
JSON export / import

Lua

local data = ui:ExportConfig()
ui:ImportConfig(data)

File save / load

Lua

ui:SaveConfig("legit")
ui:LoadConfig("legit")
ui:DeleteConfig("legit")
print(table.concat(ui:ListConfigs(), ", "))

Autoload

Lua

ui:SetAutoload("legit")
ui:LoadAutoload()

Plugins and extension
Register a custom widget builder

Lua

EasyUi.RegisterWidget("mywidget", function(target, id, opt)
    -- return widget
end)

Register a plugin

Lua

EasyUi.RegisterPlugin("debug_panel", function(ui)
    local win = ui:Window("debug", "Debug")
    local tab = win:Tab("main", "Main")
    tab:Label("status", "Ready")
    return win
end)

Use it:

Lua

ui:Use("debug_panel")

Extend directly

Lua

ui:Extend(function(self)
    self:Toast("Extend", "Called", 1.5, "ok")
end)

Toolkit

Lua

local Toolkit = EasyUi.Toolkit

Helpers

    Toolkit.Create
    Toolkit.Corner
    Toolkit.Padding
    Toolkit.Stroke
    Toolkit.Tween
    Toolkit.Themes
    Toolkit.PathGet
    Toolkit.PathSet
    Toolkit.PathToggle
    Toolkit.Pack
    Toolkit.Unpack
    Toolkit.ThemeOf
    Toolkit.Color
    Toolkit.Dim
    Toolkit.RegisterWidget
    Toolkit.RegisterPlugin
    Toolkit.CleanName
    Toolkit.Build(ui, schema)
    Toolkit.BuildFromDescriptors(ui, descs, opt)
    Toolkit.Overlay(ui, id, opt)
    Toolkit.Watch(ui, path, fn, fire)
    Toolkit.Bind(ui, path, value)
    Toolkit.Mount(ui, name, root)
    Toolkit.GetWindow(ui, id)
    Toolkit.GetWidget(ui, id)
    Toolkit.GetOverlay(ui, id)
    Toolkit.GetContainer(ui)
    Toolkit.GetTab(win, id)
    Toolkit.GetSubTab(tab, id)

Setup summary

EasyUi now has two strong setup styles:
Fast manual setup

Use:

    new()
    Window()
    Tab()
    SubTab()
    widgets

Scalable setup

Use:

    Mount
    path-bound widgets
    BuildFromDescriptors(...)
    overlays
    plugins
    custom widgets

That means it is easy to start small and still scale without rewriting everything later.
