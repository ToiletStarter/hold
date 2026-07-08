EasyESP
What it is

EasyESP is a standalone Drawing-based ESP system built mainly around Potassium’s Drawing APIs.

It does not require EasyUi or the bridge.

Main features:

    player ESP
    offscreen arrows
    radar
    target selector
    player list
    rings
    custom entities
    hooks/modules
    chams
    world overrides
    JSON config save/load
    descriptor layer
    toolkit helpers
    singleton protection so a new ESP replaces the old one

Quick start

Lua

local EasyESP = require(path.To.EasyESP)

local esp = EasyESP.new()
esp:on(true)
esp:start()

Stop:

Lua

esp:stop()

Destroy:

Lua

esp:destroy()

Constructor

Lua

local esp = EasyESP.new(options)

Example:

Lua

local esp = EasyESP.new({
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

Core control

Lua

esp:on(true)
esp:setEnabled(true)
esp:toggle()

esp:start()
esp:stop()
esp:destroy()

Destroy all live ESP instances:

Lua

EasyESP.DestroyAll()

Themes / profiles / packs / presets
Theme

Lua

esp:theme("pastel")
esp:applyTheme("carbon")
print(table.concat(esp:themes(), ", "))

Performance profile

Lua

esp:profile("balanced")
esp:applyPerformance("high")
print(table.concat(esp:performanceProfiles(), ", "))

Feature pack

Lua

esp:pack("comp")
esp:applyFeaturePack("world")
print(table.concat(esp:featurePacks(), ", "))

Preset

Lua

esp:preset("legit")
esp:applyPreset("full")
print(table.concat(esp:presets(), ", "))

Config layout

Everything lives in esp.cfg.
Main fields

Lua

esp.cfg.on = true
esp.cfg.maxRange = 3000
esp.cfg.espRange = 3000
esp.cfg.team = true
esp.cfg.rainbow = false
esp.cfg.rainbowRate = 1

Visibility

Lua

esp.cfg.vis.check = true
esp.cfg.vis.hide = false
esp.cfg.vis.tint = true
esp.cfg.vis.points = 3

Box

Lua

esp.cfg.box.on = true
esp.cfg.box.kind = "corner" -- corner / box / 3d / 3dcorner
esp.cfg.box.mode = "hp"     -- static / team / hp / dist
esp.cfg.box.w = 1
esp.cfg.box.fill = false
esp.cfg.box.col = Color3.fromRGB(202, 164, 255)

Labels and extras

Lua

esp.cfg.name.on = true
esp.cfg.hp.on = true
esp.cfg.dist.on = true
esp.cfg.flags.on = false
esp.cfg.bones.on = false
esp.cfg.head.on = false
esp.cfg.gaze.on = false
esp.cfg.tracer.on = false

Arrow

Lua

esp.cfg.arrow.on = true
esp.cfg.arrow.rad = 190
esp.cfg.arrow.size = 14
esp.cfg.arrow.fill = true
esp.cfg.arrow.outline = true
esp.cfg.arrow.dist = true

Radar

Lua

esp.cfg.radar.on = true
esp.cfg.radar.x = 18
esp.cfg.radar.y = 170
esp.cfg.radar.r = 74
esp.cfg.radar.range = 500
esp.cfg.radar.rot = true

Target

Lua

esp.cfg.target.on = true
esp.cfg.target.fov = 240
esp.cfg.target.showFov = true
esp.cfg.target.visOnly = false
esp.cfg.target.brackets = true
esp.cfg.target.line = false

List

Lua

esp.cfg.list.on = true
esp.cfg.list.x = 18
esp.cfg.list.y = 350
esp.cfg.list.w = 220
esp.cfg.list.max = 10

World

Lua

esp.cfg.world.on = true
esp.cfg.world.full = true
esp.cfg.world.noFog = true
esp.cfg.world.fov = 80
esp.cfg.world.bright = 2

Self visuals

Lua

esp.cfg.self.wm.on = true
esp.cfg.self.compass.on = true
esp.cfg.self.fov.on = true
esp.cfg.self.cross.on = true

Descriptor layer

This is the new source of truth for many UI-facing settings.
Static access

Lua

local descs = EasyESP.GetDescriptors()
local defaults = EasyESP.GetDescriptorDefaults()
local one = EasyESP.GetDescriptor("target.fov")
local value = EasyESP.Validate("target.fov", 999)

Instance access

Lua

local descs = esp:GetDescriptors()
local defaults = esp:GetDescriptorDefaults()
local one = esp:GetDescriptor("target.fov")
local value = esp:Validate("target.fov", 999)

Descriptor example

Lua

{
    path = "target.fov",
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
}

This layer is what the new bridge/UI build path uses.
Friends

Lua

esp:friend(player)
esp:markFriend(player)
esp:unfriend(player)
esp:unmarkFriend(player)
esp:clearFriends()

print(esp:isFriend(player))

Rings
Enemy ring specs

Lua

esp.cfg.rings.on = true
esp.cfg.rings.enemies = true

esp:addRingSpec({
    rad = 12,
    col = Color3.fromRGB(202, 164, 255),
    w = 1,
    glow = true,
    pulse = true,
    ticks = 8,
})

World / attached ring

Lua

esp:addRing("drop", {
    at = workspace.Drop,
    rad = 10,
    col = Color3.fromRGB(120, 200, 255),
    glow = true,
    y = 0.1,
})

esp:dropRing("drop")
esp:clearRings()

Entities
Custom entity

Lua

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

Alias:

Lua

esp:addEntity("generator", spec)

Direct instance entity

Lua

esp:addInst("loot_1", workspace.LootCrate, {
    label = "Loot",
    col = Color3.fromRGB(120, 255, 190),
    dot = true,
    dist = true,
})

Alias:

Lua

esp:addInstanceEntity("loot_1", workspace.LootCrate, opt)

Remove / clear

Lua

esp:dropEnt("generator")
esp:removeEntity("generator")
esp:clearEnts()
esp:clearEntities("loot_")

Scanners

Lua

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

Hooks and modules
Hook

Lua

esp:hook("center_dot", function(self, s)
    local x = s.bx + s.bw * 0.5
    local y = s.by + s.bh * 0.5
    self.pool:dot("hk" .. s.uid, x, y, 2, Color3.fromRGB(255, 255, 255), true, 1, 10)
end)

esp:unhook("center_dot")

Aliases:

Lua

esp:onDraw("center_dot", fn)
esp:removeDraw("center_dot")

Module

Lua

esp:mod({
    name = "tag_demo",
    on = true,
    player = function(state, esp0, s)
        esp0.pool:txt("md" .. s.uid, "DEMO", s.bx + s.bw * 0.5, s.by - 28, 10, esp0.cfg.box.col, true)
    end,
})

esp:module("tag_demo")
esp:toggleMod("tag_demo", false)
esp:dropMod("tag_demo")

Aliases:

Lua

esp:register(spec)
esp:toggleModule(name, on)
esp:unregister(name)

Utility methods

Lua

local plr = esp:nearest(500, false)
local pos = esp:center(player)
local x, y, depth, onScreen = esp:project(workspace.Part.Position)
local vis = esp:sees(player.Character)
local stats = esp:getStats()

Binds

Lua

esp:bind(Enum.KeyCode.F4, function(self)
    self:toggle()
end)

esp:clearBinds()

Config export / import
JSON

Lua

local json = esp:export()
esp:import(json)

File save / load

Lua

esp:save("legit")
esp:load("legit")
print(table.concat(esp:configs(), ", "))

Dragging ESP HUD pieces

Middle click drag is supported for:

    radar
    player list
    ESP watermark

That makes it easier to place the main on-screen ESP panels without needing the UI bridge.
Toolkit

Lua

local Toolkit = EasyESP.Toolkit

Helpers

    Toolkit.clone(tbl)
    Toolkit.merge(a, b)
    Toolkit.fill(a, b)
    Toolkit.color(r, g, b)
    Toolkit.hsv(h, s, v)
    Toolkit.ring(spec)
    Toolkit.flag(text, color)
    Toolkit.pathGet(tbl, path)
    Toolkit.pathSet(tbl, path, value)
    Toolkit.pathToggle(tbl, path)
    Toolkit.findPlayer(query)
    Toolkit.scan(root, predicate, limit)
    Toolkit.applyTheme(esp, name)
    Toolkit.applyProfile(esp, name)
    Toolkit.applyPack(esp, name)
    Toolkit.applyPreset(esp, name)
    Toolkit.getDescriptors(prefix?)
    Toolkit.getDescriptorDefaults(prefix?)
    Toolkit.getDescriptor(path)
    Toolkit.validate(path, value)
    Toolkit.quick(opt) / Toolkit.quickESP(opt)

Setup summary

EasyESP is streamlined around three things:
Fast startup

Use:

    new()
    on(true)
    start()

Clean config grouping

Most settings live in sensible clusters:

    vis
    box
    target
    radar
    list
    self
    world
    chams

Scalable extension

Use:

    hooks
    modules
    entities
    rings
    descriptors
    toolkit helpers

That keeps the base flow simple while still letting you scale the system cleanly.
