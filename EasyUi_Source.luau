--!nocheck
local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local Run = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer

local Theme = {
	Font = Enum.Font.GothamMedium,
	Bold = Enum.Font.GothamBold,
	Mono = Enum.Font.Code,

	Accent = Color3.fromRGB(236, 236, 240),
	Window = Color3.fromRGB(15, 15, 17),
	Panel = Color3.fromRGB(21, 21, 24),
	Card = Color3.fromRGB(27, 27, 31),
	Control = Color3.fromRGB(33, 33, 38),
	Hover = Color3.fromRGB(43, 43, 49),
	Stroke = Color3.fromRGB(46, 46, 53),
	Soft = Color3.fromRGB(36, 36, 42),
	Text = Color3.fromRGB(240, 240, 245),
	Sub = Color3.fromRGB(150, 150, 160),
	Muted = Color3.fromRGB(96, 96, 106),

	Ok = Color3.fromRGB(172, 226, 191),
	Warn = Color3.fromRGB(240, 214, 168),
	Err = Color3.fromRGB(240, 172, 178),
	Info = Color3.fromRGB(176, 205, 240),
}
local Kind = { ok = Theme.Ok, warn = Theme.Warn, error = Theme.Err, info = Theme.Info }

local E = {
	Smooth = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	Snap = TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Pop = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Now = TweenInfo.new(0.04, Enum.EasingStyle.Linear),
}

local function new(class, props, kids)
	local i = Instance.new(class)
	if props then
		for k, v in pairs(props) do
			if k ~= "Parent" then
				i[k] = v
			end
		end
	end
	if kids then
		for _, c in ipairs(kids) do
			c.Parent = i
		end
	end
	if props and props.Parent then
		i.Parent = props.Parent
	end
	return i
end

local function tw(i, info, props)
	local t = Tween:Create(i, info, props)
	t:Play()
	return t
end

local function corner(r, p)
	return new("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = p })
end

local function stroke(c, t, tr, p)
	return new("UIStroke", { Color = c or Theme.Stroke, Thickness = t or 1, Transparency = tr or 0, Parent = p })
end

local function pad(a, p, l, t, r, b)
	return new("UIPadding", {
		PaddingLeft = UDim.new(0, l or a),
		PaddingRight = UDim.new(0, r or a),
		PaddingTop = UDim.new(0, t or a),
		PaddingBottom = UDim.new(0, b or a),
		Parent = p,
	})
end

local function list(p, gap, dir)
	return new("UIListLayout", {
		FillDirection = dir or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, gap or 6),
		Parent = p,
	})
end

local function label(text, size, color, font, p)
	return new("TextLabel", {
		BackgroundTransparency = 1,
		Text = text or "",
		TextSize = size or 13,
		TextColor3 = color or Theme.Text,
		Font = font or Theme.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		RichText = true,
		Parent = p,
	})
end

local function hover(i, base, to)
	i.MouseEnter:Connect(function()
		tw(i, E.Fast, { BackgroundColor3 = to })
	end)
	i.MouseLeave:Connect(function()
		tw(i, E.Fast, { BackgroundColor3 = base })
	end)
end

local function ripple(p)
	local c = new("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.86,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(0, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = 30,
		Parent = p,
	})
	corner(999, c)
	local s = math.max(p.AbsoluteSize.X, p.AbsoluteSize.Y) * 1.7
	tw(c, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(s, s),
		BackgroundTransparency = 1,
	})
	task.delay(0.46, function()
		c:Destroy()
	end)
end

local function inside(gui, pos)
	if not (gui and gui.Parent and gui.Visible) then
		return false
	end
	local a, s = gui.AbsolutePosition, gui.AbsoluteSize
	return pos.X >= a.X and pos.X <= a.X + s.X and pos.Y >= a.Y and pos.Y <= a.Y + s.Y
end

local Color = {}
function Color.hex(c)
	return string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end
function Color.fromHex(s)
	s = s:gsub("#", "")
	return Color3.fromRGB(tonumber(s:sub(1, 2), 16) or 0, tonumber(s:sub(3, 4), 16) or 0, tonumber(s:sub(5, 6), 16) or 0)
end
function Color.lerp(a, b, t)
	return a:Lerp(b, t)
end

local activeMove, activeUp
Input.InputChanged:Connect(function(i)
	if activeMove and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		activeMove(Input:GetMouseLocation())
	end
end)
Input.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		if activeUp then
			activeUp()
		end
		activeMove, activeUp = nil, nil
	end
end)
local function beginDrag(move, up)
	activeMove, activeUp = move, up
end

local function draggable(handle, target)
	handle.Active = true
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			local start = Input:GetMouseLocation()
			local base = target.Position
			beginDrag(function(m)
				local d = m - start
				target.Position = UDim2.new(base.X.Scale, base.X.Offset + d.X, base.Y.Scale, base.Y.Offset + d.Y)
			end)
		end
	end)
end

local function mountGui()
	local g = new("ScreenGui", {
		Name = "EasyUI_" .. tostring(math.random(1e5, 9e5)),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	})
	local ok = pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(g)
			g.Parent = CoreGui
		elseif gethui then
			g.Parent = gethui()
		else
			g.Parent = CoreGui
		end
	end)
	if not ok or not g.Parent then
		g.Parent = LP and LP:WaitForChild("PlayerGui") or CoreGui
	end
	return g
end

local UI = {}
UI.__index = UI
UI._Tab = {}
UI._Sec = {}

function UI.new(o)
	o = o or {}
	local self = setmetatable({}, UI)
	self.gui = mountGui()
	self.title = o.title or "EasyUI"
	self.toggleKey = o.toggleKey or Enum.KeyCode.RightShift
	self.visible = true
	self.tabs = {}
	self.widgets = {}
	self.flags = {}
	self._flagWidgets = {}
	if o.accent then
		Theme.Accent = o.accent
	end

	local w, h = o.width or 560, o.height or 420
	local win = new("Frame", {
		Name = "Window",
		Size = UDim2.fromOffset(w, h),
		Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2),
		BackgroundColor3 = Theme.Window,
		BorderSizePixel = 0,
		Parent = self.gui,
	})
	corner(12, win)
	stroke(Theme.Stroke, 1, 0.2, win)
	self.window = win

	new("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxassetid://5554236805",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.45,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(23, 23, 277, 277),
		Size = UDim2.new(1, 60, 1, 60),
		Position = UDim2.new(0, -30, 0, -30),
		ZIndex = 0,
		Parent = win,
	})
	local scale = new("UIScale", { Scale = 1, Parent = win })
	self._scale = scale

	local bar = new("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, Parent = win })
	draggable(bar, win)
	local dot = new("Frame", {
		Size = UDim2.fromOffset(9, 9),
		Position = UDim2.new(0, 16, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = bar,
	})
	corner(999, dot)
	self._dot = dot
	local tlbl = label(self.title, 14, Theme.Text, Theme.Bold, bar)
	tlbl.Position = UDim2.new(0, 34, 0, 0)
	tlbl.Size = UDim2.new(1, -120, 1, 0)
	self._titleLbl = tlbl

	local function pill(x, color, cb)
		local b = new("TextButton", {
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.new(1, x, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Theme.Control,
			BorderSizePixel = 0,
			Parent = bar,
		})
		corner(7, b)
		stroke(Theme.Soft, 1, 0, b)
		local ic = new("Frame", {
			Size = UDim2.fromOffset(9, 2),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Parent = b,
		})
		corner(2, ic)
		hover(b, Theme.Control, Theme.Hover)
		b.MouseButton1Click:Connect(cb)
	end
	pill(-14, Theme.Err, function()
		self:Close()
	end)
	pill(-44, Theme.Sub, function()
		self:SetVisible(false)
	end)

	new("Frame", {
		Size = UDim2.new(1, -32, 0, 1),
		Position = UDim2.new(0, 16, 0, 42),
		BackgroundColor3 = Theme.Soft,
		BorderSizePixel = 0,
		Parent = win,
	})

	local side = new("Frame", {
		Size = UDim2.new(0, 150, 1, -54),
		Position = UDim2.new(0, 0, 0, 50),
		BackgroundTransparency = 1,
		Parent = win,
	})
	pad(12, side, 12, 6, 6, 12)
	list(side, 4)
	self._side = side

	local content = new("Frame", {
		Size = UDim2.new(1, -150, 1, -54),
		Position = UDim2.new(0, 150, 0, 50),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = win,
	})
	self._content = content

	local wm = new("Frame", {
		Size = UDim2.fromOffset(168, 26),
		Position = UDim2.new(0, 16, 0, 16),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Parent = self.gui,
	})
	corner(8, wm)
	stroke(Theme.Stroke, 1, 0.1, wm)
	draggable(wm, wm)
	local wmt = label(self.title .. "  •  0 fps", 12, Theme.Sub, Theme.Mono, wm)
	wmt.Position = UDim2.new(0, 10, 0, 0)
	wmt.Size = UDim2.new(1, -20, 1, 0)
	wm.Visible = o.watermark ~= false
	do
		local acc, frames = 0, 0
		Run.RenderStepped:Connect(function(dt)
			acc += dt
			frames += 1
			if acc >= 0.5 then
				wmt.Text = self.title .. "  •  " .. math.floor(frames / acc + 0.5) .. " fps"
				acc, frames = 0, 0
			end
		end)
	end

	self:_ctxInit()

	Input.InputBegan:Connect(function(i, gp)
		if gp then
			return
		end
		if i.KeyCode == self.toggleKey then
			self:SetVisible(not self.visible)
			return
		end
		if i.KeyCode ~= Enum.KeyCode.Unknown then
			for _, wd in ipairs(self.widgets) do
				if wd.bindKey == i.KeyCode and wd.activate then
					task.spawn(wd.activate)
				end
			end
		end
	end)

	scale.Scale = 0.9
	win.BackgroundTransparency = 1
	tw(win, E.Pop, { BackgroundTransparency = 0 })
	tw(scale, E.Pop, { Scale = 1 })
	return self
end

function UI:SetVisible(v)
	self.visible = v
	if v then
		self.window.Visible = true
		self._scale.Scale = 0.92
		self.window.BackgroundTransparency = 1
		tw(self.window, E.Pop, { BackgroundTransparency = 0 })
		tw(self._scale, E.Pop, { Scale = 1 })
	else
		tw(self._scale, E.Smooth, { Scale = 0.92 })
		local t = tw(self.window, E.Smooth, { BackgroundTransparency = 1 })
		t.Completed:Connect(function()
			if not self.visible then
				self.window.Visible = false
			end
		end)
	end
end

function UI:Close()
	tw(self._scale, E.Smooth, { Scale = 0.85 })
	local t = tw(self.window, E.Smooth, { BackgroundTransparency = 1 })
	t.Completed:Connect(function()
		self.gui:Destroy()
	end)
end

function UI:SetAccent(c)
	Theme.Accent = c
	self._dot.BackgroundColor3 = c
end

function UI:Get(flag)
	return self.flags[flag]
end

function UI:Set(flag, v)
	local api = self._flagWidgets[flag]
	if api and api.Set then
		api:Set(v)
	else
		self.flags[flag] = v
	end
end

function UI:_reg(wd)
	self.widgets[#self.widgets + 1] = wd
	if wd.row then
		wd.row.Active = true
		wd.row.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton2 then
				self:_openContext(wd)
			end
		end)
	end
	return wd
end

function UI:Tab(name)
	local m = self
	local btn = new("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Theme.Control,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = #self.tabs + 1,
		Parent = self._side,
	})
	corner(8, btn)
	local bs = stroke(Theme.Soft, 1, 1, btn)
	local tl = label(name, 13, Theme.Sub, Theme.Font, btn)
	tl.Position = UDim2.new(0, 12, 0, 0)
	tl.Size = UDim2.new(1, -12, 1, 0)

	local page = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Stroke,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
		Visible = false,
		Parent = self._content,
	})
	pad(14, page, 14, 12, 14, 16)
	list(page, 12)

	local tab = { button = btn, stroke = bs, page = page, label = tl }
	self.tabs[#self.tabs + 1] = tab

	local function activate()
		for _, t in ipairs(m.tabs) do
			t.page.Visible = false
			tw(t.button, E.Fast, { BackgroundTransparency = 1 })
			tw(t.stroke, E.Fast, { Transparency = 1 })
			tw(t.label, E.Fast, { TextColor3 = Theme.Sub })
		end
		page.Visible = true
		tw(btn, E.Fast, { BackgroundTransparency = 0 })
		tw(bs, E.Fast, { Transparency = 0 })
		tw(tl, E.Fast, { TextColor3 = Theme.Text })
	end
	btn.MouseButton1Click:Connect(activate)
	btn.MouseEnter:Connect(function()
		if not page.Visible then
			tw(tl, E.Fast, { TextColor3 = Theme.Text })
		end
	end)
	btn.MouseLeave:Connect(function()
		if not page.Visible then
			tw(tl, E.Fast, { TextColor3 = Theme.Sub })
		end
	end)
	if #self.tabs == 1 then
		task.defer(activate)
	end
	return setmetatable({ _m = self, _page = page }, { __index = UI._Tab })
end

function UI._Tab:Section(title)
	local card = new("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Parent = self._page,
	})
	corner(10, card)
	stroke(Theme.Soft, 1, 0, card)
	pad(12, card)
	list(card, 8)
	if title then
		local head = label(title, 13, Theme.Text, Theme.Bold, card)
		head.Size = UDim2.new(1, 0, 0, 18)
		head.LayoutOrder = -1
	end
	return setmetatable({ _m = self._m, _card = card }, { __index = UI._Sec })
end

local function rowFrame(parent, h)
	return new("Frame", { Size = UDim2.new(1, 0, 0, h or 30), BackgroundTransparency = 1, Parent = parent })
end

function UI._Sec:Label(text, color)
	local l = label(text, 12, color or Theme.Sub, Theme.Font, self._card)
	l.Size = UDim2.new(1, 0, 0, 16)
	l.TextWrapped = true
	l.AutomaticSize = Enum.AutomaticSize.Y
	return l
end

function UI._Sec:Divider()
	local d = new("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.Soft,
		BorderSizePixel = 0,
		Parent = self._card,
	})
	return d
end

function UI._Sec:Badge(text, kind)
	local col = Kind[kind] or Theme.Accent
	local r = rowFrame(self._card, 20)
	local b = new("Frame", {
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Theme.Control,
		BorderSizePixel = 0,
		Parent = r,
	})
	corner(6, b)
	stroke(Theme.Soft, 1, 0, b)
	pad(0, b, 8, 0, 8, 0)
	local dotc = new("Frame", {
		Size = UDim2.fromOffset(6, 6),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = col,
		BorderSizePixel = 0,
		Parent = b,
	})
	corner(999, dotc)
	local l = label("  " .. tostring(text), 11, Theme.Sub, Theme.Font, b)
	l.Position = UDim2.new(0, 8, 0, 0)
	l.Size = UDim2.new(0, 0, 1, 0)
	l.AutomaticSize = Enum.AutomaticSize.X
	return {
		Set = function(_, t2, k2)
			l.Text = "  " .. tostring(t2)
			dotc.BackgroundColor3 = Kind[k2] or col
		end,
	}
end

function UI._Sec:Toggle(o)
	o = o or {}
	local state = o.default or false
	local r = rowFrame(self._card, 28)
	local l = label(o.text or "Toggle", 13, Theme.Text, Theme.Font, r)
	l.Size = UDim2.new(1, -50, 1, 0)
	local track = new("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(40, 22),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = state and Theme.Accent or Theme.Control,
		BorderSizePixel = 0,
		Parent = r,
	})
	corner(999, track)
	stroke(Theme.Soft, 1, 0, track)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(16, 16),
		Position = state and UDim2.new(1, -3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		AnchorPoint = Vector2.new(state and 1 or 0, 0.5),
		BackgroundColor3 = state and Theme.Window or Theme.Sub,
		BorderSizePixel = 0,
		Parent = track,
	})
	corner(999, knob)

	local api = {}
	function api:Set(v)
		state = v and true or false
		tw(track, E.Smooth, { BackgroundColor3 = state and Theme.Accent or Theme.Control })
		tw(knob, E.Snap, {
			Position = state and UDim2.new(1, -3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			AnchorPoint = Vector2.new(state and 1 or 0, 0.5),
			BackgroundColor3 = state and Theme.Window or Theme.Sub,
		})
		if o.callback then
			task.spawn(o.callback, state)
		end
	end
	function api:Get()
		return state
	end
	if o.flag then
		self._m.flags[o.flag] = state
		self._m._flagWidgets[o.flag] = api
		local base = api.Set
		api.Set = function(_, v)
			self._m.flags[o.flag] = v and true or false
			base(api, v)
		end
	end
	track.MouseButton1Click:Connect(function()
		api:Set(not state)
	end)
	self._m:_reg({ kind = "toggle", opt = o, row = r, activate = function()
		api:Set(not state)
	end })
	return api
end

function UI._Sec:Button(o)
	o = o or {}
	local b = new("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Theme.Control,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = self._card,
	})
	corner(8, b)
	stroke(Theme.Soft, 1, 0, b)
	local l = label(o.text or "Button", 13, Theme.Text, Theme.Font, b)
	l.Size = UDim2.fromScale(1, 1)
	l.TextXAlignment = Enum.TextXAlignment.Center
	hover(b, Theme.Control, Theme.Hover)
	local function fire()
		ripple(b)
		if o.callback then
			task.spawn(o.callback)
		end
	end
	b.MouseButton1Click:Connect(fire)
	self._m:_reg({ kind = "button", opt = o, row = b, activate = fire })
	return { SetText = function(_, t2)
		l.Text = t2
	end }
end

function UI._Sec:Slider(o)
	o = o or {}
	local min, max = o.min or 0, o.max or 100
	local step, dec = o.step or 1, o.decimals or 0
	local value = math.clamp(o.default or min, min, max)
	local r = rowFrame(self._card, 40)
	local l = label(o.text or "Slider", 13, Theme.Text, Theme.Font, r)
	l.Size = UDim2.new(1, -60, 0, 18)
	local val = label("", 12, Theme.Sub, Theme.Mono, r)
	val.Size = UDim2.new(0, 60, 0, 18)
	val.Position = UDim2.new(1, -60, 0, 0)
	val.TextXAlignment = Enum.TextXAlignment.Right
	local track = new("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 0, 28),
		BackgroundColor3 = Theme.Control,
		BorderSizePixel = 0,
		Parent = r,
	})
	corner(999, track)
	local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = track })
	corner(999, fill)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(12, 12),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Text,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = track,
	})
	corner(999, knob)
	stroke(Theme.Soft, 1, 0, knob)

	local function fmt(v)
		if dec > 0 then
			return string.format("%." .. dec .. "f", v)
		end
		return tostring(math.floor(v + 0.5))
	end
	local api = {}
	local function apply(v, anim)
		value = math.clamp(math.floor(v / step + 0.5) * step, min, max)
		local a = (value - min) / (max - min)
		local info = anim and E.Fast or E.Now
		tw(fill, info, { Size = UDim2.new(a, 0, 1, 0) })
		tw(knob, info, { Position = UDim2.new(a, 0, 0.5, 0) })
		val.Text = fmt(value)
		if o.flag then
			self._m.flags[o.flag] = value
		end
		if o.callback then
			task.spawn(o.callback, value)
		end
	end
	function api:Set(v)
		apply(v, true)
	end
	function api:Get()
		return value
	end
	apply(value, false)
	if o.flag then
		self._m._flagWidgets[o.flag] = api
	end
	local dragging = false
	local function fromX()
		local a = math.clamp((Input:GetMouseLocation().X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		apply(min + a * (max - min), false)
	end
	track.MouseButton1Down:Connect(function()
		dragging = true
		fromX()
		beginDrag(function()
			if dragging then
				fromX()
			end
		end, function()
			dragging = false
		end)
	end)
	self._m:_reg({ kind = "slider", opt = o, row = r })
	return api
end

function UI._Sec:Dropdown(o)
	o = o or {}
	local items = o.options or {}
	local value = o.default or items[1]
	local open = false
	local holder = new("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self._card,
	})
	local head = new("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Theme.Control,
		BorderSizePixel = 0,
		Parent = holder,
	})
	corner(8, head)
	stroke(Theme.Soft, 1, 0, head)
	local l = label((o.text and o.text .. ":  " or "") .. tostring(value), 13, Theme.Text, Theme.Font, head)
	l.Position = UDim2.new(0, 10, 0, 0)
	l.Size = UDim2.new(1, -34, 1, 0)
	local arrow = label("▾", 12, Theme.Sub, Theme.Font, head)
	arrow.Position = UDim2.new(1, -22, 0, 0)
	arrow.Size = UDim2.fromOffset(16, 30)
	arrow.TextXAlignment = Enum.TextXAlignment.Center
	local body = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, 34),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = holder,
	})
	corner(8, body)
	stroke(Theme.Soft, 1, 0, body)
	pad(4, body)
	list(body, 3)

	local api = {}
	function api:Get()
		return value
	end
	function api:Set(v)
		value = v
		l.Text = (o.text and o.text .. ":  " or "") .. tostring(value)
		if o.flag then
			self._m.flags[o.flag] = v
		end
		if o.callback then
			task.spawn(o.callback, value)
		end
	end
	local function rebuild()
		for _, c in ipairs(body:GetChildren()) do
			if c:IsA("TextButton") then
				c:Destroy()
			end
		end
		for _, it in ipairs(items) do
			local opt = new("TextButton", {
				Text = "",
				AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, 26),
				BackgroundColor3 = Theme.Hover,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = body,
			})
			corner(6, opt)
			local ol = label(tostring(it), 12, it == value and Theme.Text or Theme.Sub, Theme.Font, opt)
			ol.Position = UDim2.new(0, 8, 0, 0)
			ol.Size = UDim2.new(1, -8, 1, 0)
			opt.MouseEnter:Connect(function()
				tw(opt, E.Fast, { BackgroundTransparency = 0 })
			end)
			opt.MouseLeave:Connect(function()
				tw(opt, E.Fast, { BackgroundTransparency = 1 })
			end)
			opt.MouseButton1Click:Connect(function()
				api:Set(it)
				open = false
				body.Visible = false
				tw(arrow, E.Fast, { Rotation = 0 })
				rebuild()
			end)
		end
	end
	head.MouseButton1Click:Connect(function()
		open = not open
		if open then
			rebuild()
			body.Visible = true
			tw(arrow, E.Fast, { Rotation = 180 })
		else
			body.Visible = false
			tw(arrow, E.Fast, { Rotation = 0 })
		end
	end)
	hover(head, Theme.Control, Theme.Hover)
	function api:SetItems(t)
		items = t
		rebuild()
	end
	if o.flag then
		self._m.flags[o.flag] = value
		self._m._flagWidgets[o.flag] = api
	end
	self._m:_reg({ kind = "dropdown", opt = o, row = head })
	return api
end

function UI._Sec:Keybind(o)
	o = o or {}
	local key = o.default
	local capturing = false
	local r = rowFrame(self._card, 28)
	local l = label(o.text or "Keybind", 13, Theme.Text, Theme.Font, r)
	l.Size = UDim2.new(1, -80, 1, 0)
	local b = new("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(76, 24),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Theme.Control,
		BorderSizePixel = 0,
		Parent = r,
	})
	corner(7, b)
	stroke(Theme.Soft, 1, 0, b)
	local bl = label(key and key.Name or "None", 12, Theme.Sub, Theme.Mono, b)
	bl.Size = UDim2.fromScale(1, 1)
	bl.TextXAlignment = Enum.TextXAlignment.Center
	b.MouseButton1Click:Connect(function()
		capturing = true
		bl.Text = "..."
		tw(b, E.Fast, { BackgroundColor3 = Theme.Hover })
	end)
	Input.InputBegan:Connect(function(i, gp)
		if capturing and not gp then
			capturing = false
			tw(b, E.Fast, { BackgroundColor3 = Theme.Control })
			if i.KeyCode == Enum.KeyCode.Escape then
				key = nil
				bl.Text = "None"
			elseif i.KeyCode ~= Enum.KeyCode.Unknown then
				key = i.KeyCode
				bl.Text = key.Name
			end
			if o.onChange then
				task.spawn(o.onChange, key)
			end
			return
		end
		if key and not gp and i.KeyCode == key and o.callback then
			task.spawn(o.callback, key)
		end
	end)
	self._m:_reg({ kind = "keybind", opt = o, row = r, noKeybind = true })
	return { Get = function()
		return key
	end }
end

function UI._Sec:Textbox(o)
	o = o or {}
	local r = rowFrame(self._card, 30)
	local box = new("TextBox", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Control,
		BorderSizePixel = 0,
		Text = o.default or "",
		PlaceholderText = o.placeholder or "",
		PlaceholderColor3 = Theme.Muted,
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = 13,
		ClearTextOnFocus = false,
		Parent = r,
	})
	corner(8, box)
	local st = stroke(Theme.Soft, 1, 0, box)
	pad(0, box, 10, 0, 10, 0)
	box.Focused:Connect(function()
		tw(st, E.Fast, { Color = Theme.Accent })
	end)
	box.FocusLost:Connect(function(enter)
		tw(st, E.Fast, { Color = Theme.Soft })
		if o.flag then
			self._m.flags[o.flag] = box.Text
		end
		if enter and o.callback then
			task.spawn(o.callback, box.Text)
		end
	end)
	self._m:_reg({ kind = "textbox", opt = o, row = r })
	return { Get = function()
		return box.Text
	end, Set = function(_, t2)
		box.Text = t2
	end }
end

function UI._Sec:Colorpicker(o)
	o = o or {}
	local color = o.default or Theme.Accent
	local r = rowFrame(self._card, 28)
	local l = label(o.text or "Color", 13, Theme.Text, Theme.Font, r)
	l.Size = UDim2.new(1, -40, 1, 0)
	local sw = new("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(34, 20),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = r,
	})
	corner(6, sw)
	stroke(Theme.Soft, 1, 0, sw)
	local pop = new("Frame", {
		Size = UDim2.fromOffset(180, 152),
		Position = UDim2.new(1, 0, 1, 6),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 40,
		Parent = sw,
	})
	corner(8, pop)
	stroke(Theme.Stroke, 1, 0, pop)
	pad(8, pop)
	local sat = new("ImageButton", {
		Size = UDim2.new(1, 0, 1, -30),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		ZIndex = 41,
		Parent = pop,
	})
	corner(6, sat)
	new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = sat })
	local dark = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 41, Parent = sat })
	corner(6, dark)
	new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }), Parent = dark })
	local hueBar = new("ImageButton", {
		Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.new(0, 0, 1, -22),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		ZIndex = 41,
		Parent = pop,
	})
	corner(6, hueBar)
	new("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
			ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
			ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
			ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
			ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
			ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
		}),
		Parent = hueBar,
	})
	local hu, sa, va = Color3.toHSV(color)
	local api = {}
	local function refresh()
		color = Color3.fromHSV(hu, sa, va)
		sw.BackgroundColor3 = color
		sat.BackgroundColor3 = Color3.fromHSV(hu, 1, 1)
		if o.flag then
			self._m.flags[o.flag] = color
		end
		if o.callback then
			task.spawn(o.callback, color)
		end
	end
	local ds, dh
	sat.MouseButton1Down:Connect(function()
		ds = true
		beginDrag(function(m)
			if ds then
				sa = math.clamp((m.X - sat.AbsolutePosition.X) / sat.AbsoluteSize.X, 0, 1)
				va = 1 - math.clamp((m.Y - sat.AbsolutePosition.Y) / sat.AbsoluteSize.Y, 0, 1)
				refresh()
			end
		end, function()
			ds = false
		end)
	end)
	hueBar.MouseButton1Down:Connect(function()
		dh = true
		beginDrag(function(m)
			if dh then
				hu = math.clamp((m.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
				refresh()
			end
		end, function()
			dh = false
		end)
	end)
	sw.MouseButton1Click:Connect(function()
		pop.Visible = not pop.Visible
	end)
	refresh()
	function api:Get()
		return color
	end
	function api:Set(_, c)
		hu, sa, va = Color3.toHSV(c)
		refresh()
	end
	if o.flag then
		self._m._flagWidgets[o.flag] = api
	end
	self._m:_reg({ kind = "color", opt = o, row = r })
	return api
end

function UI:Notify(o)
	o = o or {}
	local dur = o.duration or 4
	local col = Kind[o.kind] or Theme.Accent
	if not self._toasts then
		self._toasts = new("Frame", {
			Size = UDim2.new(0, 290, 1, -32),
			Position = UDim2.new(1, -16, 1, -16),
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 1,
			Parent = self.gui,
		})
		local ll = list(self._toasts, 8)
		ll.VerticalAlignment = Enum.VerticalAlignment.Bottom
		ll.HorizontalAlignment = Enum.HorizontalAlignment.Right
	end
	local card = new("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Position = UDim2.new(1, 320, 0, 0),
		Parent = self._toasts,
	})
	corner(10, card)
	stroke(Theme.Stroke, 1, 0.05, card)
	pad(10, card, 16, 10, 12, 10)
	local acc = new("Frame", { Size = UDim2.new(0, 3, 1, -16), Position = UDim2.new(0, 4, 0, 8), BackgroundColor3 = col, BorderSizePixel = 0, Parent = card })
	corner(999, acc)
	local t = label(o.title or "Notice", 13, Theme.Text, Theme.Bold, card)
	t.Position = UDim2.new(0, 6, 0, 0)
	t.Size = UDim2.new(1, -6, 0, 18)
	local msg = label(o.text or "", 12, Theme.Sub, Theme.Font, card)
	msg.Position = UDim2.new(0, 6, 0, 18)
	msg.Size = UDim2.new(1, -6, 0, 16)
	msg.TextWrapped = true
	local prog = new("Frame", { Size = UDim2.new(1, -12, 0, 2), Position = UDim2.new(0, 6, 1, -6), BackgroundColor3 = col, BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = card })
	corner(999, prog)
	tw(card, E.Pop, { Position = UDim2.new(1, 0, 0, 0) })
	tw(prog, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })
	task.delay(dur, function()
		local out = tw(card, E.Smooth, { Position = UDim2.new(1, 340, 0, 0), BackgroundTransparency = 1 })
		out.Completed:Connect(function()
			card:Destroy()
		end)
	end)
end

function UI:_ctxInit()
	local pop = new("Frame", {
		Size = UDim2.fromOffset(210, 40),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 60,
		Parent = self.gui,
	})
	corner(10, pop)
	stroke(Theme.Stroke, 1, 0.05, pop)
	local head = label("", 13, Theme.Text, Theme.Bold, pop)
	head.Position = UDim2.new(0, 12, 0, 8)
	head.Size = UDim2.new(1, -24, 0, 18)
	head.ZIndex = 61
	local hold = new("Frame", {
		Size = UDim2.new(1, -16, 0, 0),
		Position = UDim2.new(0, 8, 0, 30),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 61,
		Parent = pop,
	})
	pad(4, hold)
	list(hold, 6)
	self._ctx = pop
	self._ctxHead = head
	self._ctxHold = hold

	Input.InputBegan:Connect(function(i)
		if pop.Visible and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
			if not inside(pop, Input:GetMouseLocation()) then
				pop.Visible = false
			end
		end
	end)
end

function UI:_openContext(wd)
	local pop = self._ctx
	for _, c in ipairs(self._ctxHold:GetChildren()) do
		if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
			c:Destroy()
		end
	end
	self._ctxHead.Text = (wd.opt and wd.opt.text) or wd.kind or "Options"
	local sec = setmetatable({ _m = self, _card = self._ctxHold }, { __index = UI._Sec })

	if not wd.noKeybind and not (wd.opt and wd.opt.noKeybind) then
		local capturing = false
		local r = rowFrame(self._ctxHold, 26)
		local l = label("Keybind", 12, Theme.Sub, Theme.Font, r)
		l.Size = UDim2.new(1, -80, 1, 0)
		local b = new("TextButton", {
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.fromOffset(76, 22),
			Position = UDim2.new(1, 0, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Theme.Control,
			BorderSizePixel = 0,
			ZIndex = 62,
			Parent = r,
		})
		corner(6, b)
		stroke(Theme.Soft, 1, 0, b)
		local bl = label(wd.bindKey and wd.bindKey.Name or "None", 11, Theme.Sub, Theme.Mono, b)
		bl.Size = UDim2.fromScale(1, 1)
		bl.TextXAlignment = Enum.TextXAlignment.Center
		bl.ZIndex = 63
		b.MouseButton1Click:Connect(function()
			capturing = true
			bl.Text = "..."
		end)
		local conn
		conn = Input.InputBegan:Connect(function(i, gp)
			if not capturing then
				return
			end
			capturing = false
			if i.KeyCode == Enum.KeyCode.Escape then
				wd.bindKey = nil
				bl.Text = "None"
			elseif i.KeyCode ~= Enum.KeyCode.Unknown and not gp then
				wd.bindKey = i.KeyCode
				bl.Text = i.KeyCode.Name
			end
		end)
		pop.Destroying:Once(function()
			conn:Disconnect()
		end)
	end

	if wd.opt and wd.opt.context then
		task.spawn(wd.opt.context, sec, wd)
	end

	local m = Input:GetMouseLocation()
	pop.Position = UDim2.fromOffset(m.X + 4, m.Y + 4)
	pop.Visible = true
	pop.BackgroundTransparency = 1
	local s = new("UIScale", { Scale = 0.9, Parent = pop })
	tw(pop, E.Fast, { BackgroundTransparency = 0 })
	tw(s, E.Pop, { Scale = 1 })
	task.delay(0.32, function()
		if s then
			s:Destroy()
		end
	end)
end

function UI:Preview(o)
	o = o or {}
	local w, h = 220, 300
	local win = new("Frame", {
		Size = UDim2.fromOffset(w, h),
		Position = UDim2.new(0.5, 220, 0.5, -h / 2),
		BackgroundColor3 = Theme.Window,
		BorderSizePixel = 0,
		Parent = self.gui,
	})
	corner(12, win)
	stroke(Theme.Stroke, 1, 0.2, win)
	local bar = new("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Parent = win })
	draggable(bar, win)
	local t = label(self.title .. " — Preview", 12, Theme.Sub, Theme.Mono, bar)
	t.Position = UDim2.new(0, 14, 0, 0)
	t.Size = UDim2.new(1, -20, 1, 0)
	local holder = new("Frame", {
		Size = UDim2.new(1, -20, 1, -46),
		Position = UDim2.new(0, 10, 0, 38),
		BackgroundColor3 = Color3.fromRGB(10, 10, 12),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = win,
	})
	corner(10, holder)
	stroke(Theme.Soft, 1, 0, holder)
	local vp = new("ViewportFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Ambient = Color3.fromRGB(200, 200, 200), LightColor = Color3.new(1, 1, 1), Parent = holder })
	local cam = new("Camera", { Parent = vp })
	vp.CurrentCamera = cam
	local model = new("Model", { Parent = vp })
	local function part(size, pos, color)
		local p = new("Part", { Size = size, Color = color or Color3.fromRGB(210, 210, 215), Material = Enum.Material.SmoothPlastic, Anchored = true, CanCollide = false, Parent = model })
		p.CFrame = CFrame.new(pos)
		return p
	end
	local torso = part(Vector3.new(2, 2, 1), Vector3.new(0, 0, 0), Color3.fromRGB(225, 205, 215))
	part(Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 1.7, 0), Color3.fromRGB(240, 225, 230))
	part(Vector3.new(0.8, 2, 0.8), Vector3.new(-1.4, 0, 0))
	part(Vector3.new(0.8, 2, 0.8), Vector3.new(1.4, 0, 0))
	part(Vector3.new(0.9, 2, 0.9), Vector3.new(-0.5, -2, 0), Color3.fromRGB(60, 60, 66))
	part(Vector3.new(0.9, 2, 0.9), Vector3.new(0.5, -2, 0), Color3.fromRGB(60, 60, 66))
	model.PrimaryPart = torso
	local box = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(76, 150), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Parent = holder })
	stroke(Theme.Accent, 1.5, 0, box)
	corner(3, box)
	local nm = label("Player", 11, Theme.Text, Theme.Bold, holder)
	nm.Size = UDim2.fromOffset(120, 14)
	nm.AnchorPoint = Vector2.new(0.5, 1)
	nm.TextXAlignment = Enum.TextXAlignment.Center
	local hp = new("Frame", { Size = UDim2.fromOffset(3, 150), BackgroundColor3 = Theme.Ok, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5), Parent = holder })
	corner(999, hp)
	local ang = 0
	Run.RenderStepped:Connect(function(dt)
		if not vp.Parent then
			return
		end
		ang += dt * 0.6
		model:SetPrimaryPartCFrame(CFrame.new(0, 0, 0) * CFrame.Angles(0, ang, 0))
		cam.CFrame = CFrame.new(Vector3.new(0, 0.2, 8), Vector3.new(0, -0.2, 0))
		local by = box.AbsoluteSize
		nm.Position = UDim2.fromOffset(box.AbsolutePosition.X - holder.AbsolutePosition.X + by.X / 2, box.AbsolutePosition.Y - holder.AbsolutePosition.Y - 2)
		hp.Position = UDim2.fromOffset(box.AbsolutePosition.X - holder.AbsolutePosition.X - 4, box.AbsolutePosition.Y - holder.AbsolutePosition.Y + by.Y / 2)
		local pct = math.sin(ang * 1.5) * 0.5 + 0.5
		hp.Size = UDim2.fromOffset(3, by.Y)
		hp.BackgroundColor3 = Theme.Err:Lerp(Theme.Ok, pct)
	end)
	return win
end

UI.Toolkit = {
	Color = Color,
	Create = new,
	Tween = tw,
	Theme = Theme,
	Kinds = Kind,
}

return UI
