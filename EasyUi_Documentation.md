# EasyUi

## What it is
EasyUi is a standalone multi-window cheat-style UI system.

It does not require the ESP or the bridge.

Main features:
- draggable windows
- compact matte/pastel theme system
- path-based state store
- generic table mounting
- widgets
- overlays / HUD
- schema builder
- config save/load
- toolkit helpers
- singleton protection so a new UI kills the previous active UI

---

## Basic setup

```lua
local UI = require(path.To.EasyUi)

local ui = UI.new({
    Title = "My Menu",
    Theme = "pastel",
    MenuKey = Enum.KeyCode.LeftAlt,
    Visible = true,
    Signature = "MyMenu"
})
```

Destroy it:

```lua
ui:Destroy()
```

---

## Constructor options

```lua
local ui = UI.new({
    Title = "My Menu",
    Theme = "pastel",
    ThemeOverride = {},
    Accent = Color3.fromRGB(192, 154, 255),
    MenuKey = Enum.KeyCode.LeftAlt,
    Visible = true,
    Signature = "MyMenu",
    Id = "MyMenuGui",
    StartX = 16,
    StartY = 54,
    WindowMaxHeight = 420,
})
```

---

## Core UI control

```lua
ui:SetVisible(true)
ui:GetVisible()
ui:Toggle()
ui:SetMenuKey(Enum.KeyCode.Insert)
```

---

## Themes

```lua
ui:SetTheme("carbon")
ui:SetAccent(Color3.fromRGB(120, 200, 255))
ui:ApplyTheme()
```

### Theme helpers

```lua
print(table.concat(UI.GetThemes(), ", "))
local pastel = UI.GetTheme("pastel")
UI.AddTheme("mytheme", palette)
```

---

## Internal container

EasyUi creates its own container inside the `ScreenGui`.
Use it if you want a safe place for custom extension content.

```lua
local container = ui:GetContainer()
```

---

## State store

Widgets bind to paths, not widget order.

### Direct store use

```lua
ui:Set("combat.aimbot.on", true)
print(ui:Get("combat.aimbot.on"))

local stop = ui:Watch("combat.aimbot.on", function(value)
    print("new value", value)
end, true)

stop()
```

### Mount an external table

```lua
local cfg = {
    movement = {
        speed = 16,
        fly = false,
    }
}

ui:Mount("cfg", cfg)
ui:Set("cfg.movement.fly", true)
print(cfg.movement.fly)
```

Unmount:

```lua
ui:Unmount("cfg")
```

### Sync widgets from store

```lua
ui:Sync()
ui:Sync("cfg")
```

---

## Windows

### Create a window

```lua
local combat = ui:Window("combat", "Combat", {
    Width = 250,
    X = 20,
    Y = 60,
    Open = true,
    MaxHeight = 420,
})
```

Aliases:

```lua
ui:CreateWindow("combat", "Combat", opt)
ui:CreatePanel("Combat", opt)
```

### Window methods

```lua
combat:SetTitle("Combat Settings")
combat:SetVisible(true)
combat:Open()
combat:Close()
combat:ToggleOpen()
combat:Destroy()
```

### Window lookups

```lua
ui:GetWindows()
ui:GetWindow("combat")
```

---

## Widgets

## Section

```lua
combat:Section("Aim")
combat:AddSeparator("Aim")
```

## Label

```lua
local lbl = combat:Label("status", "Ready")
lbl:set("Running")
```

Old helper:

```lua
combat:AddLabel("Ready")
```

## Button

```lua
combat:Button("save_btn", "Save", {
    onPress = function()
        print("save")
    end,
})
```

Old helper:

```lua
combat:AddButton("Save", function()
    print("save")
end)
```

## Toggle

```lua
combat:Toggle("aim_on", {
    label = "Aimbot",
    path = "combat.aimbot.on",
    default = false,
    onChange = function(v)
        print(v)
    end,
})
```

Old helper:

```lua
combat:AddToggle("Aimbot", false, function(v)
    print(v)
end)
```

## Slider

```lua
combat:Slider("fov", {
    label = "FOV",
    path = "combat.fov",
    min = 20,
    max = 400,
    step = 1,
    default = 120,
})
```

Old helper:

```lua
combat:AddSlider("FOV", 20, 400, 120, 1, function(v)
    print(v)
end)
```

## Dropdown

```lua
combat:Dropdown("part", {
    label = "Hit Part",
    path = "combat.part",
    items = { "Head", "Torso", "Root" },
    default = "Head",
})
```

Old helper:

```lua
combat:AddDropdown("Hit Part", { "Head", "Torso" }, "Head", function(v)
    print(v)
end)
```

## Mode switch

```lua
combat:Mode("mode", {
    label = "Mode",
    path = "combat.mode",
    items = { "Legit", "Rage", "Silent" },
    default = "Legit",
})
```

Old helper:

```lua
combat:AddModeToggle("Mode", { "Legit", "Rage" }, "Legit", function(v)
    print(v)
end)
```

## Keybind

```lua
combat:Keybind("key", {
    label = "Hotkey",
    path = "combat.key",
    default = Enum.KeyCode.Q,
    onPress = function(key)
        print("pressed", key)
    end,
})
```

Old helper:

```lua
combat:AddKeybind("Hotkey", Enum.KeyCode.Q, function(key)
    print(key)
end)
```

## Text box

```lua
combat:Box("name", {
    label = "Config Name",
    path = "config.name",
    default = "default",
    placeholder = "name",
    onCommit = function(text)
        print(text)
    end,
})
```

Old helper:

```lua
combat:AddTextBox("Config Name", "default", "name", function(text)
    print(text)
end)
```

## Color picker

```lua
combat:Color("accent", {
    label = "Accent",
    path = "ui.accent",
    default = Color3.fromRGB(192, 154, 255),
})
```

Old helper:

```lua
combat:AddColorPicker("Accent", Color3.fromRGB(192, 154, 255), function(c)
    print(c)
end)
```

## Meter / progress

```lua
combat:Meter("load", {
    label = "Load",
    path = "stats.load",
    default = 0.25,
})
```

Old helper:

```lua
combat:AddProgressBar("Load", 0.25, function(v)
    print(v)
end)
```

---

## Custom widgets

### New-style

```lua
combat:Custom("custom_widget", function(win, id, opt)
    local tk = win.ui.Toolkit
    local row = tk.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
    }, win.body)

    local lbl = tk.Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Custom",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = win.ui:GetTheme().text,
    }, row)

    return {
        id = id,
        kind = "custom",
        row = row,
        value = "Custom",
        get = function(self) return self.value end,
        set = function(self, v) self.value = v; lbl.Text = tostring(v) end,
        applyTheme = function(self) lbl.TextColor3 = win.ui:GetTheme().text end,
        destroy = function(self) row:Destroy() end,
    }
end)
```

### Compatibility-style `AddCustom`

```lua
combat:AddCustom(function(win, ctx)
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
        applyTheme = function(self) lbl.TextColor3 = win.ui:GetTheme().text end,
        destroy = function(self) row:Destroy() end,
    }
end)
```

---

## Schema builder

```lua
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
```

---

## Overlays / HUD

### Create overlay

```lua
local ov = ui:Overlay("status", {
    x = 20,
    y = 20,
    w = 180,
    h = 32,
})

local frame = ov:GetFrame()
```

### Builder helper

```lua
ui:AddOverlay("hud_info", function(ov, ui, tk)
    tk.Create("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "HUD INFO",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = ui:GetTheme().text,
    }, ov:GetFrame())
end, {
    x = 20,
    y = 60,
    w = 160,
    h = 28,
})
```

### Overlay lookup

```lua
ui:GetOverlay("status")
```

---

## Watermark and toasts

### Watermark

```lua
ui:SetWatermark(function()
    return "My Menu | " .. os.date("%X")
end)

ui:SetWatermarkVisible(true)
```

### Toasts

```lua
ui:Toast("Loaded", "UI is ready", 2, "ok")
ui:Toast("Warning", "Check settings", 2, "warn")
ui:Toast("Error", "Something failed", 2, "err")
```

---

## Configs

### JSON export / import

```lua
local data = ui:ExportConfig()
ui:ImportConfig(data)
```

### File save / load

```lua
ui:SaveConfig("legit")
ui:LoadConfig("legit")
ui:DeleteConfig("legit")
print(table.concat(ui:ListConfigs(), ", "))
```

### Autoload

```lua
ui:SetAutoload("legit")
ui:LoadAutoload()
```

---

## Plugins and extensions

### Register widget

```lua
UI.RegisterWidget("mywidget", function(win, id, opt)
    -- return widget object
end)
```

### Register plugin

```lua
UI.RegisterPlugin("debug_panel", function(ui)
    local win = ui:Window("debug", "Debug")
    win:Label("status", "Ready")
    return win
end)
```

Use it:

```lua
ui:Use("debug_panel")
```

### Extend directly

```lua
ui:Extend(function(self)
    self:Toast("Extend", "Called", 1.5, "ok")
end)
```

---

## Toolkit

```lua
local Toolkit = UI.Toolkit
```

### Helpers

- `Toolkit.Create`
- `Toolkit.Corner`
- `Toolkit.Padding`
- `Toolkit.Stroke`
- `Toolkit.Tween`
- `Toolkit.Themes`
- `Toolkit.PathGet`
- `Toolkit.PathSet`
- `Toolkit.PathToggle`
- `Toolkit.Pack`
- `Toolkit.Unpack`
- `Toolkit.ThemeOf`
- `Toolkit.Color`
- `Toolkit.Dim`
- `Toolkit.RegisterWidget`
- `Toolkit.RegisterPlugin`
- `Toolkit.CleanName`
- `Toolkit.Build(ui, schema)`
- `Toolkit.Overlay(ui, id, opt)`
- `Toolkit.Watch(ui, path, fn, fire)`
- `Toolkit.Bind(ui, path, value)`
- `Toolkit.Mount(ui, name, root)`
- `Toolkit.GetWindow(ui, id)`
- `Toolkit.GetWidget(ui, id)`
- `Toolkit.GetOverlay(ui, id)`
- `Toolkit.GetContainer(ui)`

---

## Potassium notes

EasyUi already prefers Potassium’s hidden GUI path when `gethui()` exists.
That keeps menu content inside a hidden executor-owned container instead of relying only on `CoreGui`/`PlayerGui`.

The singleton guard also uses the shared executor global to prevent stacked UI instances when re-executed.
