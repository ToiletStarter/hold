EasyESP
Loadstring

Lua

local EasyESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/esp"))()

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

Quick start

Lua

local EasyESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/hold/refs/heads/main/esp"))()

local esp = EasyESP.new()
esp:on(true)
esp:start()

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

Lua

esp:theme("pastel")
esp:applyTheme("carbon")

esp:profile("balanced")
esp:applyPerformance("high")

esp:pack("comp")
esp:applyFeaturePack("world")

esp:preset("legit")
esp:applyPreset("full")

Available names:

Lua

esp:themes()
esp:performanceProfiles()
esp:featurePacks()
esp:presets()

Config layout

Everything lives in esp.cfg.

Common groups:

    vis
    box
    target
    arrow
    radar
    list
    self
    world
    chams
    rings

Examples:

Lua

esp.cfg.box.on = true
esp.cfg.box.kind = "corner"
esp.cfg.box.mode = "hp"

esp.cfg.target.on = true
esp.cfg.target.fov = 240
esp.cfg.target.showFov = true

esp.cfg.radar.on = true
esp.cfg.list.on = true
esp.cfg.self.wm.on = true

Material chams now walk character descendants instead of only direct children, so accessories and other nested character parts are much more likely to be included.
Descriptor layer

EasyESP now exposes descriptor metadata for a large part of the settings surface.
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

This is what the bridge can now consume for descriptor-driven UI generation.
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

World ring

Lua

esp:addRing("drop", {
    at = workspace.Drop,
    rad = 10,
    col = Color3.fromRGB(120, 200, 255),
    glow = true,
    y = 0.1,
})

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

Entity lists are supported

get() can also return a table/array of objects.
That makes it easier to track folders or batches of items without registering each one manually.

Lua

esp:addEnt("pickups", {
    get = function()
        return workspace.Pickups:GetChildren()
    end,
    label = "Pickup",
    col = Color3.fromRGB(120, 255, 190),
    box = true,
    dist = true,
})

Aliases:

Lua

esp:addEntity("generator", spec)
esp:addInstanceEntity("loot_1", workspace.LootCrate, opt)

If the same id is reused for multiple instance registrations, EasyESP now tries to make the internal key unique instead of silently overwriting the older registration.

Remove/clear:

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

esp:scanNPCs({ col = Color3.fromRGB(255, 135, 135) })
esp:scanTools({ col = Color3.fromRGB(255, 220, 110) })
esp:scanPickups({ names = { "ammo", "cash", "armor", "med" } })

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

Lua

local json = esp:export()
esp:import(json)

esp:save("legit")
esp:load("legit")
print(table.concat(esp:configs(), ", "))

Dragging ESP HUD pieces

Middle click drag is supported for:

    radar
    player list
    ESP watermark

Toolkit

Lua

local Toolkit = EasyESP.Toolkit

Helpers:

    Toolkit.clone
    Toolkit.merge
    Toolkit.fill
    Toolkit.color
    Toolkit.hsv
    Toolkit.ring
    Toolkit.flag
    Toolkit.pathGet
    Toolkit.pathSet
    Toolkit.pathToggle
    Toolkit.findPlayer
    Toolkit.scan
    Toolkit.applyTheme
    Toolkit.applyProfile
    Toolkit.applyPack
    Toolkit.applyPreset
    Toolkit.getDescriptors
    Toolkit.getDescriptorDefaults
    Toolkit.getDescriptor
    Toolkit.validate
    Toolkit.quick / Toolkit.quickESP

Setup summary

EasyESP is streamlined around:

    fast startup
    clean config grouping
    scalable extension through hooks/modules/entities/rings/descriptors
