--[[
	MaterialUI — Roblox Material Design UI Library
	Android 6 (Marshmallow) style
	
	Использование:
		local MaterialUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/.../MaterialUI.lua"))()
	
	Или вставь исходник напрямую в ModuleScript.
]]

local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local Players         = game:GetService("Players")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ─── Цвета Material ───────────────────────────────────────────────────────────
local Colors = {
	Primary       = Color3.fromRGB(63,  81,  181), -- Indigo 500
	PrimaryDark   = Color3.fromRGB(48,  63,  159), -- Indigo 700
	Accent        = Color3.fromRGB(255, 64,  129), -- Pink A200
	White         = Color3.fromRGB(255, 255, 255),
	Surface       = Color3.fromRGB(255, 255, 255),
	Background    = Color3.fromRGB(250, 250, 250),
	TextPrimary   = Color3.fromRGB(33,  33,  33),
	TextSecondary = Color3.fromRGB(117, 117, 117),
	TextHint      = Color3.fromRGB(189, 189, 189),
	Divider       = Color3.fromRGB(224, 224, 224),
	Success       = Color3.fromRGB(76,  175, 80),
	Warning       = Color3.fromRGB(255, 152, 0),
	Error         = Color3.fromRGB(244, 67,  54),
	Ripple        = Color3.fromRGB(0,   0,   0),
	TrackOff      = Color3.fromRGB(189, 189, 189),
	TrackOn       = Color3.fromRGB(159, 168, 218),
	ThumbOff      = Color3.fromRGB(245, 245, 245),
}

-- ─── Утилиты ──────────────────────────────────────────────────────────────────
local Util = {}

function Util.tween(obj, props, duration, style, dir)
	duration = duration or 0.2
	style    = style    or Enum.EasingStyle.Quad
	dir      = dir      or Enum.EasingDirection.Out
	local t  = TweenService:Create(obj, TweenInfo.new(duration, style, dir), props)
	t:Play()
	return t
end

function Util.corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 2)
	c.Parent = parent
	return c
end

function Util.padding(parent, all, top, right, bottom, left)
	local p = Instance.new("UIPadding")
	if all then
		p.PaddingTop    = UDim.new(0, all)
		p.PaddingRight  = UDim.new(0, all)
		p.PaddingBottom = UDim.new(0, all)
		p.PaddingLeft   = UDim.new(0, all)
	else
		p.PaddingTop    = UDim.new(0, top    or 0)
		p.PaddingRight  = UDim.new(0, right  or 0)
		p.PaddingBottom = UDim.new(0, bottom or 0)
		p.PaddingLeft   = UDim.new(0, left   or 0)
	end
	p.Parent = parent
	return p
end

function Util.listLayout(parent, dir, padding)
	local l = Instance.new("UIListLayout")
	l.FillDirection       = dir or Enum.FillDirection.Vertical
	l.SortOrder           = Enum.SortOrder.LayoutOrder
	l.Padding             = UDim.new(0, padding or 0)
	l.HorizontalAlignment = Enum.HorizontalAlignment.Left
	l.Parent = parent
	return l
end

-- Ripple эффект на Frame/Button
function Util.ripple(parent, x, y, color)
	color = color or Colors.Ripple
	local container = Instance.new("Frame")
	container.Size              = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.ClipsDescendants  = true
	container.BorderSizePixel   = 0
	container.ZIndex            = parent.ZIndex + 1
	container.Parent            = parent

	local abs = parent.AbsoluteSize
	local cx  = x and (x - parent.AbsolutePosition.X) or abs.X / 2
	local cy  = y and (y - parent.AbsolutePosition.Y) or abs.Y / 2
	local size = math.max(abs.X, abs.Y) * 2.2

	local circle = Instance.new("Frame")
	circle.Size                = UDim2.new(0, 0, 0, 0)
	circle.Position            = UDim2.new(0, cx, 0, cy)
	circle.AnchorPoint         = Vector2.new(0.5, 0.5)
	circle.BackgroundColor3    = color
	circle.BackgroundTransparency = 0.82
	circle.BorderSizePixel     = 0
	circle.ZIndex              = container.ZIndex + 1
	circle.Parent              = container
	Util.corner(circle, 9999)

	Util.tween(circle, {
		Size = UDim2.new(0, size, 0, size),
		BackgroundTransparency = 0.92,
	}, 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	task.delay(0.45, function()
		Util.tween(circle, { BackgroundTransparency = 1 }, 0.2)
		task.delay(0.2, function()
			container:Destroy()
		end)
	end)
end

-- ─── Библиотека ───────────────────────────────────────────────────────────────
local MaterialUI = {}
MaterialUI.__index = MaterialUI

--[[
	MaterialUI.new(title)
	Создаёт окно (Window) с тулбаром и скроллящимся контентом.
	Возвращает объект Window.
]]
function MaterialUI.new(title)
	local self = setmetatable({}, MaterialUI)

	-- ScreenGui
	self._gui = Instance.new("ScreenGui")
	self._gui.Name            = "MaterialUI_" .. title
	self._gui.ResetOnSpawn    = false
	self._gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
	self._gui.IgnoreGuiInset  = true
	self._gui.Parent          = playerGui

	-- Тень окна
	local shadow = Instance.new("Frame")
	shadow.Size               = UDim2.new(0, 286, 0.55, 8)
	shadow.Position           = UDim2.new(0, 18, 0, 18)
	shadow.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.75
	shadow.BorderSizePixel    = 0
	shadow.Parent             = self._gui
	Util.corner(shadow, 3)
	self._shadow = shadow

	-- Основной контейнер
	local win = Instance.new("Frame")
	win.Name              = "Window"
	win.Size              = UDim2.new(0, 284, 0.55, 0)
	win.Position          = UDim2.new(0, 16, 0, 16)
	win.BackgroundColor3  = Colors.Background
	win.BorderSizePixel   = 0
	win.ClipsDescendants  = true
	win.Parent            = self._gui
	Util.corner(win, 2)
	self._win = win

	-- Toolbar
	local toolbar = Instance.new("Frame")
	toolbar.Name            = "Toolbar"
	toolbar.Size            = UDim2.new(1, 0, 0, 56)
	toolbar.BackgroundColor3 = Colors.Primary
	toolbar.BorderSizePixel = 0
	toolbar.ZIndex          = 3
	toolbar.Parent          = win
	self._toolbar = toolbar

	-- Toolbar title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size              = UDim2.new(1, -72, 1, 0)
	titleLabel.Position          = UDim2.new(0, 16, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text              = title
	titleLabel.TextColor3        = Colors.White
	titleLabel.Font              = Enum.Font.GothamBold
	titleLabel.TextSize          = 20
	titleLabel.TextXAlignment    = Enum.TextXAlignment.Left
	titleLabel.ZIndex            = 4
	titleLabel.Parent            = toolbar
	self._titleLabel = titleLabel

	-- Кнопка закрыть ✕
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size              = UDim2.new(0, 40, 0, 40)
	closeBtn.Position          = UDim2.new(1, -48, 0.5, -20)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text              = "✕"
	closeBtn.TextColor3        = Color3.fromRGB(255, 255, 255)
	closeBtn.Font              = Enum.Font.GothamBold
	closeBtn.TextSize          = 18
	closeBtn.ZIndex            = 5
	closeBtn.Parent            = toolbar

	closeBtn.MouseButton1Click:Connect(function()
		self:toggle()
	end)

	-- Скроллящийся контент
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name              = "Content"
	scroll.Size              = UDim2.new(1, 0, 1, -56)
	scroll.Position          = UDim2.new(0, 0, 0, 56)
	scroll.BackgroundColor3  = Colors.Background
	scroll.BorderSizePixel   = 0
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = Colors.Primary
	scroll.CanvasSize        = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent            = win
	self._scroll = scroll

	-- Авто-лэйаут контента
	local layout = Util.listLayout(scroll, Enum.FillDirection.Vertical, 0)
	Util.padding(scroll, nil, 8, 0, 8, 0)
	self._layout = layout

	-- Drag окна
	self:_makeDraggable(toolbar, win, shadow)

	self._visible = true
	self._elements = {}
	return self
end

-- Драг
function MaterialUI:_makeDraggable(handle, win, shadow)
	local dragging, dragStart, startPos
	handle.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
			dragging  = true
			dragStart = inp.Position
			startPos  = win.Position
		end
	end)
	handle.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
			or inp.UserInputType == Enum.UserInputType.Touch) then
			local delta = inp.Position - dragStart
			local newPos = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
			win.Position    = newPos
			shadow.Position = UDim2.new(
				newPos.X.Scale, newPos.X.Offset + 2,
				newPos.Y.Scale, newPos.Y.Offset + 2
			)
		end
	end)
end

-- Показать / скрыть
function MaterialUI:toggle()
	self._visible = not self._visible
	Util.tween(self._win, {
		Size = self._visible
			and UDim2.new(0, 284, 0.55, 0)
			or  UDim2.new(0, 284, 0, 56),
	}, 0.25, Enum.EasingStyle.Quart)
	Util.tween(self._shadow, {
		BackgroundTransparency = self._visible and 0.75 or 1,
	}, 0.25)
end

-- ─── Секция (subheader) ───────────────────────────────────────────────────────
function MaterialUI:addSection(text)
	local frame = Instance.new("Frame")
	frame.Size              = UDim2.new(1, 0, 0, 36)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel   = 0
	frame.LayoutOrder       = #self._elements + 1
	frame.Parent            = self._scroll

	local label = Instance.new("TextLabel")
	label.Size           = UDim2.new(1, -16, 1, 0)
	label.Position       = UDim2.new(0, 16, 0, 0)
	label.BackgroundTransparency = 1
	label.Text           = string.upper(text)
	label.TextColor3     = Colors.Primary
	label.Font           = Enum.Font.GothamBold
	label.TextSize       = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent         = frame

	-- Разделитель сверху (кроме первой секции)
	if #self._elements > 0 then
		local div = Instance.new("Frame")
		div.Size            = UDim2.new(1, 0, 0, 1)
		div.BackgroundColor3 = Colors.Divider
		div.BorderSizePixel = 0
		div.Parent          = frame
	end

	table.insert(self._elements, frame)
	return frame
end

-- ─── Toggle ───────────────────────────────────────────────────────────────────
--[[
	:addToggle(label, description, default, callback)
	callback(bool)
]]
function MaterialUI:addToggle(label, description, default, callback)
	local state = default or false

	local row = Instance.new("TextButton")
	row.Name              = "Toggle_" .. label
	row.Size              = UDim2.new(1, 0, 0, description and 64 or 48)
	row.BackgroundColor3  = Colors.Surface
	row.BorderSizePixel   = 0
	row.Text              = ""
	row.AutoButtonColor   = false
	row.LayoutOrder       = #self._elements + 1
	row.ClipsDescendants  = true
	row.Parent            = self._scroll

	-- Разделитель
	local div = Instance.new("Frame")
	div.Size            = UDim2.new(1, -16, 0, 1)
	div.Position        = UDim2.new(0, 16, 1, -1)
	div.BackgroundColor3 = Colors.Divider
	div.BorderSizePixel = 0
	div.ZIndex          = 2
	div.Parent          = row

	-- Иконка-кружок
	local icon = Instance.new("Frame")
	icon.Size              = UDim2.new(0, 36, 0, 36)
	icon.Position          = UDim2.new(0, 12, 0.5, -18)
	icon.BackgroundColor3  = Color3.fromRGB(232, 234, 246)
	icon.BorderSizePixel   = 0
	icon.Parent            = row
	Util.corner(icon, 9999)

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size              = UDim2.new(1, 0, 1, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text              = "⚙"
	iconLabel.TextColor3        = Colors.Primary
	iconLabel.Font              = Enum.Font.GothamBold
	iconLabel.TextSize          = 16
	iconLabel.Parent            = icon

	-- Тексты
	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size           = UDim2.new(1, -110, 0, 20)
	titleLbl.Position       = UDim2.new(0, 60, 0, description and 12 or 14)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text           = label
	titleLbl.TextColor3     = Colors.TextPrimary
	titleLbl.Font           = Enum.Font.Gotham
	titleLbl.TextSize       = 14
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent         = row

	if description then
		local descLbl = Instance.new("TextLabel")
		descLbl.Size           = UDim2.new(1, -110, 0, 16)
		descLbl.Position       = UDim2.new(0, 60, 0, 36)
		descLbl.BackgroundTransparency = 1
		descLbl.Text           = description
		descLbl.TextColor3     = Colors.TextSecondary
		descLbl.Font           = Enum.Font.Gotham
		descLbl.TextSize       = 11
		descLbl.TextXAlignment = Enum.TextXAlignment.Left
		descLbl.TextTruncate   = Enum.TextTruncate.AtEnd
		descLbl.Parent         = row
	end

	-- Track
	local track = Instance.new("Frame")
	track.Size              = UDim2.new(0, 36, 0, 14)
	track.Position          = UDim2.new(1, -52, 0.5, -7)
	track.BackgroundColor3  = state and Colors.TrackOn or Colors.TrackOff
	track.BorderSizePixel   = 0
	track.Parent            = row
	Util.corner(track, 9999)

	-- Thumb
	local thumb = Instance.new("Frame")
	thumb.Size              = UDim2.new(0, 20, 0, 20)
	thumb.Position          = state
		and UDim2.new(0, 18, 0.5, -10)
		or  UDim2.new(0, -2, 0.5, -10)
	thumb.BackgroundColor3  = state and Colors.Primary or Colors.ThumbOff
	thumb.BorderSizePixel   = 0
	thumb.ZIndex            = 3
	thumb.Parent            = track
	Util.corner(thumb, 9999)

	-- Тень thumb
	local ts = Instance.new("Frame")
	ts.Size              = UDim2.new(1, 6, 1, 6)
	ts.Position          = UDim2.new(0, -3, 0, -3)
	ts.BackgroundColor3  = Color3.fromRGB(0,0,0)
	ts.BackgroundTransparency = 0.78
	ts.BorderSizePixel   = 0
	ts.ZIndex            = 2
	ts.Parent            = thumb
	Util.corner(ts, 9999)

	local function applyState(s)
		state = s
		Util.tween(track, { BackgroundColor3 = s and Colors.TrackOn or Colors.TrackOff }, 0.18)
		Util.tween(thumb, {
			Position = s and UDim2.new(0, 18, 0.5, -10) or UDim2.new(0, -2, 0.5, -10),
			BackgroundColor3 = s and Colors.Primary or Colors.ThumbOff,
		}, 0.18)
		if callback then callback(s) end
	end

	row.MouseButton1Click:Connect(function(x, y)
		local pos = UserInputService:GetMouseLocation()
		Util.ripple(row, pos.X, pos.Y)
		applyState(not state)
	end)

	table.insert(self._elements, row)

	-- Публичный контроль
	return {
		set = function(v) applyState(v) end,
		get = function() return state end,
	}
end

-- ─── Button ───────────────────────────────────────────────────────────────────
--[[
	:addButton(label, description, icon, callback)
	icon — любой UTF символ или текст, можно ""
	callback()
]]
function MaterialUI:addButton(label, description, icon, callback)
	local row = Instance.new("TextButton")
	row.Name              = "Button_" .. label
	row.Size              = UDim2.new(1, 0, 0, description and 64 or 48)
	row.BackgroundColor3  = Colors.Surface
	row.BorderSizePixel   = 0
	row.Text              = ""
	row.AutoButtonColor   = false
	row.LayoutOrder       = #self._elements + 1
	row.ClipsDescendants  = true
	row.Parent            = self._scroll

	local div = Instance.new("Frame")
	div.Size            = UDim2.new(1, -16, 0, 1)
	div.Position        = UDim2.new(0, 16, 1, -1)
	div.BackgroundColor3 = Colors.Divider
	div.BorderSizePixel = 0
	div.Parent          = row

	-- Иконка
	if icon and icon ~= "" then
		local ic = Instance.new("Frame")
		ic.Size             = UDim2.new(0, 36, 0, 36)
		ic.Position         = UDim2.new(0, 12, 0.5, -18)
		ic.BackgroundColor3 = Color3.fromRGB(252, 228, 236)
		ic.BorderSizePixel  = 0
		ic.Parent           = row
		Util.corner(ic, 9999)
		local il = Instance.new("TextLabel")
		il.Size              = UDim2.new(1, 0, 1, 0)
		il.BackgroundTransparency = 1
		il.Text              = icon
		il.TextColor3        = Colors.Accent
		il.Font              = Enum.Font.GothamBold
		il.TextSize          = 16
		il.Parent            = ic
	end

	local offsetX = (icon and icon ~= "") and 60 or 16

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size           = UDim2.new(1, -offsetX - 16, 0, 20)
	titleLbl.Position       = UDim2.new(0, offsetX, 0, description and 12 or 14)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text           = label
	titleLbl.TextColor3     = Colors.TextPrimary
	titleLbl.Font           = Enum.Font.Gotham
	titleLbl.TextSize       = 14
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent         = row

	if description then
		local descLbl = Instance.new("TextLabel")
		descLbl.Size           = UDim2.new(1, -offsetX - 16, 0, 16)
		descLbl.Position       = UDim2.new(0, offsetX, 0, 36)
		descLbl.BackgroundTransparency = 1
		descLbl.Text           = description
		descLbl.TextColor3     = Colors.TextSecondary
		descLbl.Font           = Enum.Font.Gotham
		descLbl.TextSize       = 11
		descLbl.TextXAlignment = Enum.TextXAlignment.Left
		descLbl.Parent         = row
	end

	-- Стрелка
	local arrow = Instance.new("TextLabel")
	arrow.Size              = UDim2.new(0, 20, 0, 20)
	arrow.Position          = UDim2.new(1, -28, 0.5, -10)
	arrow.BackgroundTransparency = 1
	arrow.Text              = "›"
	arrow.TextColor3        = Colors.TextHint
	arrow.Font              = Enum.Font.GothamBold
	arrow.TextSize          = 22
	arrow.Parent            = row

	row.MouseButton1Click:Connect(function()
		local pos = UserInputService:GetMouseLocation()
		Util.ripple(row, pos.X, pos.Y)
		task.delay(0.15, function()
			if callback then callback() end
		end)
	end)

	table.insert(self._elements, row)
	return row
end

-- ─── Slider ───────────────────────────────────────────────────────────────────
--[[
	:addSlider(label, min, max, default, callback)
	callback(value)
]]
function MaterialUI:addSlider(label, min_, max_, default, callback)
	min_    = min_    or 0
	max_    = max_    or 100
	default = default or min_

	local row = Instance.new("Frame")
	row.Name              = "Slider_" .. label
	row.Size              = UDim2.new(1, 0, 0, 72)
	row.BackgroundColor3  = Colors.Surface
	row.BorderSizePixel   = 0
	row.LayoutOrder       = #self._elements + 1
	row.Parent            = self._scroll

	local div = Instance.new("Frame")
	div.Size            = UDim2.new(1, -16, 0, 1)
	div.Position        = UDim2.new(0, 16, 1, -1)
	div.BackgroundColor3 = Colors.Divider
	div.BorderSizePixel = 0
	div.Parent          = row

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size           = UDim2.new(1, -80, 0, 18)
	titleLbl.Position       = UDim2.new(0, 16, 0, 10)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text           = label
	titleLbl.TextColor3     = Colors.TextPrimary
	titleLbl.Font           = Enum.Font.Gotham
	titleLbl.TextSize       = 13
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent         = row

	local valLbl = Instance.new("TextLabel")
	valLbl.Size           = UDim2.new(0, 48, 0, 18)
	valLbl.Position       = UDim2.new(1, -60, 0, 10)
	valLbl.BackgroundTransparency = 1
	valLbl.Text           = tostring(default)
	valLbl.TextColor3     = Colors.Primary
	valLbl.Font           = Enum.Font.GothamBold
	valLbl.TextSize       = 13
	valLbl.TextXAlignment = Enum.TextXAlignment.Right
	valLbl.Parent         = row

	-- Трек слайдера
	local trackBg = Instance.new("Frame")
	trackBg.Size            = UDim2.new(1, -32, 0, 4)
	trackBg.Position        = UDim2.new(0, 16, 0, 44)
	trackBg.BackgroundColor3 = Colors.Divider
	trackBg.BorderSizePixel = 0
	trackBg.Parent          = row
	Util.corner(trackBg, 9999)

	local trackFill = Instance.new("Frame")
	trackFill.Size           = UDim2.new(0, 0, 1, 0)
	trackFill.BackgroundColor3 = Colors.Primary
	trackFill.BorderSizePixel = 0
	trackFill.Parent         = trackBg
	Util.corner(trackFill, 9999)

	-- Thumb слайдера
	local thumb = Instance.new("Frame")
	thumb.Size              = UDim2.new(0, 16, 0, 16)
	thumb.AnchorPoint       = Vector2.new(0.5, 0.5)
	thumb.Position          = UDim2.new(0, 0, 0.5, 0)
	thumb.BackgroundColor3  = Colors.Primary
	thumb.BorderSizePixel   = 0
	thumb.ZIndex            = 3
	thumb.Parent            = trackBg
	Util.corner(thumb, 9999)

	-- Инициализируем позицию
	local function setValue(v)
		v = math.clamp(v, min_, max_)
		local frac = (v - min_) / (max_ - min_)
		trackFill.Size   = UDim2.new(frac, 0, 1, 0)
		thumb.Position   = UDim2.new(frac, 0, 0.5, 0)
		valLbl.Text      = tostring(math.round(v))
		if callback then callback(math.round(v)) end
	end
	setValue(default)

	-- Drag слайдера
	local dragging = false
	local function onInput(inp)
		if dragging then
			local abs = trackBg.AbsolutePosition
			local sz  = trackBg.AbsoluteSize
			local frac = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
			local v = min_ + frac * (max_ - min_)
			setValue(v)
		end
	end

	thumb.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(onInput)
	trackBg.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			onInput(inp)
		end
	end)

	table.insert(self._elements, row)
	return {
		set = setValue,
		get = function() return tonumber(valLbl.Text) end,
	}
end

-- ─── Label (статичный текст / статус) ────────────────────────────────────────
--[[
	:addLabel(text, color)
	color — необязательный Color3
]]
function MaterialUI:addLabel(text, color)
	local row = Instance.new("Frame")
	row.Name              = "Label"
	row.Size              = UDim2.new(1, 0, 0, 36)
	row.BackgroundTransparency = 1
	row.BorderSizePixel   = 0
	row.LayoutOrder       = #self._elements + 1
	row.Parent            = self._scroll

	local lbl = Instance.new("TextLabel")
	lbl.Size           = UDim2.new(1, -32, 1, 0)
	lbl.Position       = UDim2.new(0, 16, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text           = text
	lbl.TextColor3     = color or Colors.TextSecondary
	lbl.Font           = Enum.Font.Gotham
	lbl.TextSize       = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextWrapped    = true
	lbl.Parent         = row

	table.insert(self._elements, row)
	return {
		set = function(t, c)
			lbl.Text = t
			if c then lbl.TextColor3 = c end
		end,
		get = function() return lbl.Text end,
	}
end

-- ─── Keybind ──────────────────────────────────────────────────────────────────
--[[
	:addKeybind(label, description, defaultKey, callback)
	defaultKey — Enum.KeyCode
	callback(keyCode)
]]
function MaterialUI:addKeybind(label, description, defaultKey, callback)
	local currentKey = defaultKey or Enum.KeyCode.RightShift
	local binding    = false

	local row = Instance.new("TextButton")
	row.Name              = "Keybind_" .. label
	row.Size              = UDim2.new(1, 0, 0, description and 64 or 48)
	row.BackgroundColor3  = Colors.Surface
	row.BorderSizePixel   = 0
	row.Text              = ""
	row.AutoButtonColor   = false
	row.LayoutOrder       = #self._elements + 1
	row.ClipsDescendants  = true
	row.Parent            = self._scroll

	local div = Instance.new("Frame")
	div.Size            = UDim2.new(1, -16, 0, 1)
	div.Position        = UDim2.new(0, 16, 1, -1)
	div.BackgroundColor3 = Colors.Divider
	div.BorderSizePixel = 0
	div.Parent          = row

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size           = UDim2.new(1, -110, 0, 20)
	titleLbl.Position       = UDim2.new(0, 16, 0, description and 12 or 14)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text           = label
	titleLbl.TextColor3     = Colors.TextPrimary
	titleLbl.Font           = Enum.Font.Gotham
	titleLbl.TextSize       = 14
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent         = row

	if description then
		local descLbl = Instance.new("TextLabel")
		descLbl.Size           = UDim2.new(1, -110, 0, 16)
		descLbl.Position       = UDim2.new(0, 16, 0, 36)
		descLbl.BackgroundTransparency = 1
		descLbl.Text           = description
		descLbl.TextColor3     = Colors.TextSecondary
		descLbl.Font           = Enum.Font.Gotham
		descLbl.TextSize       = 11
		descLbl.TextXAlignment = Enum.TextXAlignment.Left
		descLbl.Parent         = row
	end

	-- Кнопка-бейдж с текущей клавишей
	local badge = Instance.new("Frame")
	badge.Size              = UDim2.new(0, 72, 0, 28)
	badge.Position          = UDim2.new(1, -84, 0.5, -14)
	badge.BackgroundColor3  = Color3.fromRGB(232, 234, 246)
	badge.BorderSizePixel   = 0
	badge.Parent            = row
	Util.corner(badge, 4)

	local badgeLbl = Instance.new("TextLabel")
	badgeLbl.Size              = UDim2.new(1, 0, 1, 0)
	badgeLbl.BackgroundTransparency = 1
	badgeLbl.Text              = tostring(currentKey.Name)
	badgeLbl.TextColor3        = Colors.Primary
	badgeLbl.Font              = Enum.Font.GothamBold
	badgeLbl.TextSize          = 11
	badgeLbl.Parent            = badge

	local function startBinding()
		binding = true
		badgeLbl.Text      = "..."
		badge.BackgroundColor3 = Color3.fromRGB(255, 243, 224)
		badgeLbl.TextColor3    = Colors.Warning
	end

	local function finishBinding(key)
		binding            = false
		currentKey         = key
		badgeLbl.Text      = key.Name
		badge.BackgroundColor3 = Color3.fromRGB(232, 234, 246)
		badgeLbl.TextColor3    = Colors.Primary
		if callback then callback(key) end
	end

	row.MouseButton1Click:Connect(function()
		local pos = UserInputService:GetMouseLocation()
		Util.ripple(row, pos.X, pos.Y)
		if not binding then startBinding() end
	end)

	UserInputService.InputBegan:Connect(function(inp, gp)
		if binding and not gp and inp.UserInputType == Enum.UserInputType.Keyboard then
			finishBinding(inp.KeyCode)
		end
	end)

	table.insert(self._elements, row)
	return {
		get = function() return currentKey end,
	}
end

-- ─── ColorPicker (упрощённый, HSV) ───────────────────────────────────────────
--[[
	:addColorPicker(label, defaultColor, callback)
	callback(Color3)
]]
function MaterialUI:addColorPicker(label, defaultColor, callback)
	local color = defaultColor or Color3.fromRGB(63, 81, 181)
	local open   = false

	local wrap = Instance.new("Frame")
	wrap.Name             = "ColorPicker_" .. label
	wrap.Size             = UDim2.new(1, 0, 0, 48)
	wrap.BackgroundColor3 = Colors.Surface
	wrap.BorderSizePixel  = 0
	wrap.LayoutOrder      = #self._elements + 1
	wrap.ClipsDescendants = true
	wrap.Parent           = self._scroll

	local div = Instance.new("Frame")
	div.Size            = UDim2.new(1, -16, 0, 1)
	div.Position        = UDim2.new(0, 16, 1, -1)
	div.BackgroundColor3 = Colors.Divider
	div.BorderSizePixel = 0
	div.Parent          = wrap

	local header = Instance.new("TextButton")
	header.Size              = UDim2.new(1, 0, 0, 48)
	header.BackgroundTransparency = 1
	header.Text              = ""
	header.AutoButtonColor   = false
	header.ClipsDescendants  = true
	header.Parent            = wrap

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size           = UDim2.new(1, -80, 0, 20)
	titleLbl.Position       = UDim2.new(0, 16, 0, 14)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text           = label
	titleLbl.TextColor3     = Colors.TextPrimary
	titleLbl.Font           = Enum.Font.Gotham
	titleLbl.TextSize       = 14
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent         = header

	-- Превью цвета
	local preview = Instance.new("Frame")
	preview.Size             = UDim2.new(0, 28, 0, 28)
	preview.Position         = UDim2.new(1, -48, 0.5, -14)
	preview.BackgroundColor3 = color
	preview.BorderSizePixel  = 0
	preview.Parent           = header
	Util.corner(preview, 4)

	-- HSV палитра (упрощённая: 6 hue кнопок + S/V слайдеры)
	local picker = Instance.new("Frame")
	picker.Size             = UDim2.new(1, 0, 0, 120)
	picker.Position         = UDim2.new(0, 0, 0, 48)
	picker.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	picker.BorderSizePixel  = 0
	picker.Parent           = wrap

	Util.padding(picker, 10)

	local hues = {0, 30, 60, 120, 180, 240, 270, 300, 330}
	local hueRow = Instance.new("Frame")
	hueRow.Size             = UDim2.new(1, 0, 0, 28)
	hueRow.BackgroundTransparency = 1
	hueRow.Parent           = picker
	Util.listLayout(hueRow, Enum.FillDirection.Horizontal, 6)

	local currentH, currentS, currentV = Color3.toHSV(color)

	local function applyColor()
		local c = Color3.fromHSV(currentH, currentS, currentV)
		color                = c
		preview.BackgroundColor3 = c
		if callback then callback(c) end
	end

	for _, h in ipairs(hues) do
		local btn = Instance.new("TextButton")
		btn.Size              = UDim2.new(0, 22, 0, 22)
		btn.BackgroundColor3  = Color3.fromHSV(h / 360, 0.8, 0.9)
		btn.Text              = ""
		btn.AutoButtonColor   = false
		btn.BorderSizePixel   = 0
		btn.Parent            = hueRow
		Util.corner(btn, 4)
		btn.MouseButton1Click:Connect(function()
			currentH = h / 360
			applyColor()
		end)
	end

	-- Saturation slider
	local satLabel = Instance.new("TextLabel")
	satLabel.Size           = UDim2.new(0.45, -4, 0, 14)
	satLabel.Position       = UDim2.new(0, 0, 0, 38)
	satLabel.BackgroundTransparency = 1
	satLabel.Text           = "Saturation"
	satLabel.TextColor3     = Colors.TextSecondary
	satLabel.Font           = Enum.Font.Gotham
	satLabel.TextSize       = 10
	satLabel.TextXAlignment = Enum.TextXAlignment.Left
	satLabel.Parent         = picker

	local satTrack = Instance.new("Frame")
	satTrack.Size            = UDim2.new(0.45, -4, 0, 4)
	satTrack.Position        = UDim2.new(0, 0, 0, 58)
	satTrack.BackgroundColor3 = Colors.Divider
	satTrack.BorderSizePixel = 0
	satTrack.Parent          = picker
	Util.corner(satTrack, 9999)

	local satFill = Instance.new("Frame")
	satFill.Size            = UDim2.new(currentS, 0, 1, 0)
	satFill.BackgroundColor3 = Colors.Primary
	satFill.BorderSizePixel = 0
	satFill.Parent          = satTrack
	Util.corner(satFill, 9999)

	local satThumb = Instance.new("Frame")
	satThumb.Size            = UDim2.new(0, 14, 0, 14)
	satThumb.AnchorPoint     = Vector2.new(0.5, 0.5)
	satThumb.Position        = UDim2.new(currentS, 0, 0.5, 0)
	satThumb.BackgroundColor3 = Colors.Primary
	satThumb.BorderSizePixel = 0
	satThumb.ZIndex          = 3
	satThumb.Parent          = satTrack
	Util.corner(satThumb, 9999)

	-- Value slider
	local valLabel = Instance.new("TextLabel")
	valLabel.Size           = UDim2.new(0.45, -4, 0, 14)
	valLabel.Position       = UDim2.new(0.55, 0, 0, 38)
	valLabel.BackgroundTransparency = 1
	valLabel.Text           = "Brightness"
	valLabel.TextColor3     = Colors.TextSecondary
	valLabel.Font           = Enum.Font.Gotham
	valLabel.TextSize       = 10
	valLabel.TextXAlignment = Enum.TextXAlignment.Left
	valLabel.Parent         = picker

	local valTrack = Instance.new("Frame")
	valTrack.Size            = UDim2.new(0.45, -4, 0, 4)
	valTrack.Position        = UDim2.new(0.55, 0, 0, 58)
	valTrack.BackgroundColor3 = Colors.Divider
	valTrack.BorderSizePixel = 0
	valTrack.Parent          = picker
	Util.corner(valTrack, 9999)

	local valFill = Instance.new("Frame")
	valFill.Size            = UDim2.new(currentV, 0, 1, 0)
	valFill.BackgroundColor3 = Colors.Warning
	valFill.BorderSizePixel = 0
	valFill.Parent          = valTrack
	Util.corner(valFill, 9999)

	local valThumb = Instance.new("Frame")
	valThumb.Size            = UDim2.new(0, 14, 0, 14)
	valThumb.AnchorPoint     = Vector2.new(0.5, 0.5)
	valThumb.Position        = UDim2.new(currentV, 0, 0.5, 0)
	valThumb.BackgroundColor3 = Colors.Warning
	valThumb.BorderSizePixel = 0
	valThumb.ZIndex          = 3
	valThumb.Parent          = valTrack
	Util.corner(valThumb, 9999)

	-- Drag для satTrack и valTrack
	local function makeSliderDrag(track, fill, thumb_, onVal)
		local drag = false
		thumb_.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end
		end)
		track.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				drag = true
				local f = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				onVal(f)
				fill.Size    = UDim2.new(f, 0, 1, 0)
				thumb_.Position = UDim2.new(f, 0, 0.5, 0)
			end
		end)
		UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
		end)
		UserInputService.InputChanged:Connect(function(inp)
			if drag and inp.UserInputType == Enum.UserInputType.MouseMovement then
				local f = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				onVal(f)
				fill.Size    = UDim2.new(f, 0, 1, 0)
				thumb_.Position = UDim2.new(f, 0, 0.5, 0)
			end
		end)
	end

	makeSliderDrag(satTrack, satFill, satThumb, function(v) currentS = v; applyColor() end)
	makeSliderDrag(valTrack, valFill, valThumb, function(v) currentV = v; applyColor() end)

	-- Открыть / закрыть
	header.MouseButton1Click:Connect(function()
		open = not open
		Util.tween(wrap, { Size = UDim2.new(1, 0, 0, open and 168 or 48) }, 0.22)
	end)

	table.insert(self._elements, wrap)
	return {
		get = function() return color end,
		set = function(c)
			color = c
			preview.BackgroundColor3 = c
			currentH, currentS, currentV = Color3.toHSV(c)
		end,
	}
end

-- ─── Notify (уведомление снизу) ───────────────────────────────────────────────
--[[
	MaterialUI.notify(gui, text, duration)
	gui — ScreenGui куда добавлять (или nil — playerGui)
	duration — секунды (default 3)
]]
function MaterialUI.notify(parentGui, text, duration)
	parentGui = parentGui or playerGui
	duration  = duration or 3

	local snack = Instance.new("Frame")
	snack.Size              = UDim2.new(0, 260, 0, 44)
	snack.Position          = UDim2.new(0.5, -130, 1, 60)
	snack.BackgroundColor3  = Color3.fromRGB(50, 50, 50)
	snack.BorderSizePixel   = 0
	snack.ZIndex            = 20
	snack.Parent            = parentGui
	Util.corner(snack, 4)

	local lbl = Instance.new("TextLabel")
	lbl.Size              = UDim2.new(1, -24, 1, 0)
	lbl.Position          = UDim2.new(0, 12, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text              = text
	lbl.TextColor3        = Colors.White
	lbl.Font              = Enum.Font.Gotham
	lbl.TextSize          = 13
	lbl.TextXAlignment    = Enum.TextXAlignment.Left
	lbl.TextTruncate      = Enum.TextTruncate.AtEnd
	lbl.ZIndex            = 21
	lbl.Parent            = snack

	-- Анимация появления
	Util.tween(snack, { Position = UDim2.new(0.5, -130, 1, -60) }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	task.delay(duration, function()
		Util.tween(snack, { Position = UDim2.new(0.5, -130, 1, 60) }, 0.2)
		task.delay(0.21, function() snack:Destroy() end)
	end)
end

return MaterialUI
