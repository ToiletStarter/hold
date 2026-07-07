EasyUi
Overview

EasyUi is a standalone Roblox UI system built around small draggable windows, a path-based store, and optional overlays.

It is meant to be easy to use in two ways:

    quick manual setup with a few windows and widgets
    larger schema-driven setups with mounted config tables

It does not require EasyESP.

Default menu key:

Lua

Enum.KeyCode.LeftAlt

Default watermark state:

    off

Quick start

Lua

local EasyUi = require(path.To.EasyUi)

local ui = EasyUi.new({
    Title = "My Menu",
    Theme = "pastel",
    Visible = true,
    Signature = "MyMenu",
})

local combat = ui:Window("combat", "Combat", { Width = 260 })

combat:Toggle("aim_on", {
    label = "Aimbot",
    path = "combat.aimbot.on",
    default = false,
})

combat:Slider("fov", {
    label = "FOV",
    path = "combat.aimbot.fov",
    min = 20,
    max = 400,
    step = 1,
    default = 120,
})

combat:Button("save", "Save Config", {
    onPress = function()
        ui:SaveConfig("default")
    end,
})

Constructor

Lua

local ui = EasyUi.new(options)

Common options

Lua

local ui = EasyUi.new({
    Title = "My Menu",
    Theme = "pastel",
    ThemeOverride = nil,
    Accent = Color3.fromRGB(192, 154, 255),
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

The UI uses a path-based store. That is the main reason it stays manageable when the setup gets bigger.
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
    Width = 260,
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

Window lookups

Lua

ui:GetWindows()
ui:GetWindow("combat")

Dragging behavior

    left click and drag the header to move a window
    middle click and drag anywhere on the window to move it
    middle click and drag overlays too
    the last interacted window comes to the front
    overlapping windows are auto-resolved on build/import/resize

Widgets
Section

Lua

win:Section("Aim")
win:AddSeparator("Aim")

Label

Lua

local lbl = win:Label("status", "Ready")
lbl:set("Running")

Old helper:

Lua

win:AddLabel("Ready")

Button

Lua

win:Button("save_btn", "Save", {
    onPress = function()
        print("save")
    end,
})

Old helper:

Lua

win:AddButton("Save", function()
    print("save")
end)

Toggle

Lua

win:Toggle("aim_on", {
    label = "Aimbot",
    path = "combat.aimbot.on",
    default = false,
    onChange = function(v)
        print(v)
    end,
})

Old helper:

Lua

win:AddToggle("Aimbot", false, function(v)
    print(v)
end)

Slider

Lua

win:Slider("fov", {
    label = "FOV",
    path = "combat.aimbot.fov",
    min = 20,
    max = 400,
    step = 1,
    default = 120,
})

Old helper:

Lua

win:AddSlider("FOV", 20, 400, 120, 1, function(v)
    print(v)
end)

Dropdown

Lua

win:Dropdown("part", {
    label = "Hit Part",
    path = "combat.aimbot.part",
    items = { "Head", "Torso", "Root" },
    default = "Head",
})

Mode switch

Lua

win:Mode("mode", {
    label = "Mode",
    path = "combat.mode",
    items = { "Legit", "Rage", "Silent" },
    default = "Legit",
})

Keybind

Lua

win:Keybind("key", {
    label = "Hotkey",
    path = "combat.key",
    default = Enum.KeyCode.Q,
    onPress = function(key)
        print("pressed", key)
    end,
})

Text box

Lua

win:Box("name", {
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

win:Color("accent", {
    label = "Accent",
    path = "ui.accent",
    default = Color3.fromRGB(192, 154, 255),
})

Meter / progress

Lua

win:Meter("load", {
    label = "Load",
    path = "stats.load",
    default = 0.25,
})

Custom widgets
Direct custom widget

Lua

win:Custom("custom_widget", function(win0, id, opt)
    local tk = win0.ui.Toolkit
    local row = tk.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
    }, win0.body)

    local lbl = tk.Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Custom",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = win0.ui:GetTheme().text,
    }, row)

    return {
        id = id,
        kind = "custom",
        row = row,
        value = "Custom",
        get = function(self) return self.value end,
        set = function(self, v) self.value = v; lbl.Text = tostring(v) end,
        applyTheme = function(self) lbl.TextColor3 = win0.ui:GetTheme().text end,
        destroy = function(self) row:Destroy() end,
    }
end)

Compatibility-style AddCustom

Lua

win:AddCustom(function(win0, ctx)
    local row = ctx.mk("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
    }, ctx.body)

    local lbl = ctx.mk("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Custom",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = ctx.theme.text,
    }, row)

    return {
        id = "custom_label",
        kind = "custom",
        row = row,
        value = "Custom",
        get = function(self) return self.value end,
        set = function(self, v) self.value = v; lbl.Text = tostring(v) end,
        applyTheme = function(self) lbl.TextColor3 = win0.ui:GetTheme().text end,
        destroy = function(self) row:Destroy() end,
    }
end)

Build from schema

Lua

ui:Build({
    {
        id = "visuals",
        title = "Visuals",
        Width = 250,
        items = {
            { kind = "section", text = "ESP" },
            { kind = "toggle", id = "box_on", label = "Box", path = "cfg.esp.box" },
            { kind = "slider", id = "range", label = "Range", path = "cfg.esp.range", min = 100, max = 3000, step = 50 },
            { kind = "color", id = "accent", label = "Accent", path = "cfg.ui.accent" },
        },
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

EasyUi.RegisterWidget("mywidget", function(win, id, opt)
    -- return widget
end)

Register a plugin

Lua

EasyUi.RegisterPlugin("debug_panel", function(ui)
    local win = ui:Window("debug", "Debug")
    win:Label("status", "Ready")
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
    Toolkit.Overlay(ui, id, opt)
    Toolkit.Watch(ui, path, fn, fire)
    Toolkit.Bind(ui, path, value)
    Toolkit.Mount(ui, name, root)
    Toolkit.GetWindow(ui, id)
    Toolkit.GetWidget(ui, id)
    Toolkit.GetOverlay(ui, id)
    Toolkit.GetContainer(ui)

Setup check

EasyUi is streamlined in a useful way:
Fast setup

If you just want a menu:

    new()
    Window()
    a few widgets

Scalable setup

If you want a bigger system:

    Mount
    path-bound widgets
    Build(schema)
    overlays
    plugins
    custom widgets

That means it is easy to add/remove features without rewriting everything.
