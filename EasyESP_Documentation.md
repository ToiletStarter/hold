# EasyESP

## What it is
EasyESP is a standalone Drawing-based ESP system for Roblox executors.

It does not require the UI or bridge.

Main features:
- player ESP
- offscreen arrows
- radar
- target selector
- player list
- chams
- world overrides
- ring overlays
- custom entities
- hooks/modules
- JSON config export/import
- toolkit helpers
- singleton protection so a new instance kills the old one

---

## Basic setup

```lua
local ESP = require(path.To.EasyESP)

local esp = ESP.new()
esp:on(true)
esp:start()
```

Stop:

```lua
esp:stop()
```

Destroy:

```lua
esp:destroy()
```

---

## Constructor

```lua
local esp = ESP.new(options)
```

Example:

```lua
local esp = ESP.new({
    on = true,
    team = true,
    vis = {
        check = true,
        tint = true,
    },
    box = {
        on = true,
        kind = "corner",
        mode = "hp",
    },
    target = {
        on = true,
        showFov = true,
    },
})
```

---

## Core control

```lua
esp:on(true)
esp:setEnabled(true)
esp:toggle()

esp:start()
esp:stop()
esp:destroy()
```

---

## Themes / profiles / packs / presets

### Theme

```lua
esp:theme("pastel")
esp:applyTheme("carbon")
print(table.concat(esp:themes(), ", "))
```

### Performance profile

```lua
esp:profile("balanced")
esp:applyPerformance("high")
print(table.concat(esp:performanceProfiles(), ", "))
```

### Feature pack

```lua
esp:pack("comp")
esp:applyFeaturePack("world")
print(table.concat(esp:featurePacks(), ", "))
```

### Preset

```lua
esp:preset("legit")
esp:applyPreset("full")
print(table.concat(esp:presets(), ", "))
```

---

## Config table

Everything lives in `esp.cfg`.

### Common fields

```lua
esp.cfg.on = true
esp.cfg.maxRange = 3000
esp.cfg.espRange = 3000
esp.cfg.team = true
esp.cfg.rainbow = false
esp.cfg.rainbowRate = 1
```

### Visibility

```lua
esp.cfg.vis.check = true
esp.cfg.vis.hide = false
esp.cfg.vis.tint = true
esp.cfg.vis.points = 3
```

### Box

```lua
esp.cfg.box.on = true
esp.cfg.box.kind = "corner" -- corner / box / 3d / 3dcorner
esp.cfg.box.mode = "hp"     -- static / team / hp / dist
esp.cfg.box.w = 1
esp.cfg.box.fill = false
esp.cfg.box.col = Color3.fromRGB(192, 154, 255)
```

### Labels and extras

```lua
esp.cfg.name.on = true
esp.cfg.hp.on = true
esp.cfg.dist.on = true
esp.cfg.flags.on = false
esp.cfg.bones.on = false
esp.cfg.head.on = false
esp.cfg.gaze.on = false
esp.cfg.tracer.on = false
```

### Arrow

```lua
esp.cfg.arrow.on = true
esp.cfg.arrow.rad = 190
esp.cfg.arrow.size = 14
esp.cfg.arrow.fill = true
esp.cfg.arrow.outline = true
esp.cfg.arrow.dist = true
```

### Radar

```lua
esp.cfg.radar.on = true
esp.cfg.radar.x = 18
esp.cfg.radar.y = 170
esp.cfg.radar.r = 74
esp.cfg.radar.range = 500
esp.cfg.radar.rot = true
```

### Target

```lua
esp.cfg.target.on = true
esp.cfg.target.fov = 240
esp.cfg.target.showFov = true
esp.cfg.target.visOnly = false
esp.cfg.target.brackets = true
esp.cfg.target.line = false
```

### World

```lua
esp.cfg.world.on = true
esp.cfg.world.full = true
esp.cfg.world.noFog = true
esp.cfg.world.fov = 80
esp.cfg.world.bright = 2
```

### Self visuals

```lua
esp.cfg.self.wm.on = true
esp.cfg.self.compass.on = true
esp.cfg.self.fov.on = true
esp.cfg.self.cross.on = true
```

---

## Friends

```lua
esp:friend(player)
esp:markFriend(player)
esp:unfriend(player)
esp:unmarkFriend(player)
esp:clearFriends()

print(esp:isFriend(player))
```

---

## Rings

### Enemy ring specs

```lua
esp.cfg.rings.on = true
esp.cfg.rings.enemies = true

esp:addRingSpec({
    rad = 12,
    col = Color3.fromRGB(192, 154, 255),
    w = 1,
    glow = true,
    pulse = true,
    ticks = 8,
})
```

### World / attached ring

```lua
esp:addRing("drop", {
    at = workspace.Drop,
    rad = 10,
    col = Color3.fromRGB(120, 200, 255),
    glow = true,
    y = 0.1,
})

esp:dropRing("drop")
esp:clearRings()
```

---

## Entities

### Custom entity

```lua
esp:addEnt("generator", {
    get = function()
        return workspace:FindFirstChild("Generator")
    end,
    label = "Generator",
    col = Color3.fromRGB(255, 220, 110),
    box = true,
    name = true,
    dist = true,
    tracer = true,
    dot = true,
    max = 1200,
})
```

Alias:

```lua
esp:addEntity("generator", spec)
```

### Direct instance entity

```lua
esp:addInst("loot_1", workspace.LootCrate, {
    label = "Loot",
    col = Color3.fromRGB(120, 255, 190),
    dot = true,
    dist = true,
})
```

Alias:

```lua
esp:addInstanceEntity("loot_1", workspace.LootCrate, opt)
```

### Remove / clear

```lua
esp:dropEnt("generator")
esp:removeEntity("generator")
esp:clearEnts()
esp:clearEntities("loot_")
```

---

## Scanners

```lua
esp:scan(workspace, {
    prefix = "pickup_",
    limit = 80,
    names = { "ammo", "cash", "armor" },
    col = Color3.fromRGB(120, 255, 190),
})

esp:scanNPCs({
    col = Color3.fromRGB(255, 135, 135),
})

esp:scanTools({
    col = Color3.fromRGB(255, 220, 110),
})

esp:scanPickups({
    names = { "ammo", "cash", "armor", "med" },
})
```

---

## Hooks and modules

### Hook

```lua
esp:hook("center_dot", function(self, s)
    local x = s.bx + s.bw * 0.5
    local y = s.by + s.bh * 0.5
    self.pool:dot("hk" .. s.uid, x, y, 2, Color3.fromRGB(255, 255, 255), true, 1, 10)
end)

esp:unhook("center_dot")
```

Aliases:

```lua
esp:onDraw("center_dot", fn)
esp:removeDraw("center_dot")
```

### Module

```lua
esp:mod({
    name = "tag_demo",
    on = true,
    player = function(state, esp, s)
        esp.pool:txt("md" .. s.uid, "DEMO", s.bx + s.bw * 0.5, s.by - 28, 10, esp.cfg.box.col, true)
    end,
})

esp:module("tag_demo")
esp:toggleMod("tag_demo", false)
esp:dropMod("tag_demo")
```

Aliases:

```lua
esp:register(spec)
esp:toggleModule(name, on)
esp:unregister(name)
```

---

## Utility methods

```lua
local plr = esp:nearest(500, false)
local pos = esp:center(player)
local x, y, depth, onScreen = esp:project(workspace.Part.Position)
local vis = esp:sees(player.Character)
local stats = esp:getStats()
```

---

## Binds

```lua
esp:bind(Enum.KeyCode.F4, function(self)
    self:toggle()
end)

esp:clearBinds()
```

---

## Config export / import

### JSON

```lua
local json = esp:export()
esp:import(json)
```

### File save / load

```lua
esp:save("legit")
esp:load("legit")
print(table.concat(esp:configs(), ", "))
```

---

## Toolkit

```lua
local Toolkit = ESP.Toolkit
```

### Helpers

- `Toolkit.clone(tbl)`
- `Toolkit.merge(a, b)`
- `Toolkit.fill(a, b)`
- `Toolkit.color(r, g, b)`
- `Toolkit.hsv(h, s, v)`
- `Toolkit.ring(spec)`
- `Toolkit.flag(text, color)`
- `Toolkit.pathGet(tbl, path)`
- `Toolkit.pathSet(tbl, path, value)`
- `Toolkit.pathToggle(tbl, path)`
- `Toolkit.findPlayer(query)`
- `Toolkit.scan(root, predicate, limit)`
- `Toolkit.applyTheme(esp, name)`
- `Toolkit.applyProfile(esp, name)`
- `Toolkit.applyPack(esp, name)`
- `Toolkit.applyPreset(esp, name)`
- `Toolkit.quick(opt)` / `Toolkit.quickESP(opt)`

### Example

```lua
local ESP = require(path.To.EasyESP)
local tk = ESP.Toolkit

local esp = tk.quickESP({
    preset = "legit",
    on = true,
})
```

---

## Potassium notes

EasyESP is already shaped around Potassium’s Drawing stack:
- it uses `Drawing.new`, `setrenderproperty`, and `cleardrawcache`
- it spreads visibility, box, and tool refresh work across frames
- it keeps a pooled drawing cache instead of rebuilding objects every frame

If you want the fastest stable setup on Potassium, use:
- `esp:profile("low")` for weak games or heavy servers
- `esp:profile("balanced")` as default
- `esp:profile("high")` only if FPS is already good

The module also seeds its internal FPS average from `getfpscap()` when Potassium exposes it, which helps the first few scheduling decisions line up with the client cap.
