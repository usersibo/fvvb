local MaterialLib = loadstring([[
local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Функция для создания тени (UIStroke имитация)
local function AddShadow(obj)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0,0,0)
    stroke.Thickness = 4
    stroke.Transparency = 0.85
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = obj
    return stroke
end

function Library:NewWindow(config)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MaterialLibGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    -- Пытаемся заспавнить в CoreGui, чтобы не пропадало при респавне, иначе в PlayerGui
    local success = pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    if not success then screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    -- Главное окно
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 350, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainFrame.Parent = screenGui
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    AddShadow(MainFrame)

    -- Заголовок (App Bar)
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = Color3.fromRGB(63, 81, 181) -- Material Indigo
    TopBar.Parent = MainFrame
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)
    
    -- Маска для углов (чтобы нижние углы бара были квадратными)
    local BarMask = Instance.new("Frame")
    BarMask.Size = UDim2.new(1, 0, 0.5, 0)
    BarMask.Position = UDim2.new(0, 0, 0.5, 0)
    BarMask.BackgroundColor3 = Color3.fromRGB(63, 81, 181)
    BarMask.BorderSizePixel = 0
    BarMask.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Name or "Material Library"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.SourceSansSemibold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 18
    CloseBtn.Font = Enum.Font.SourceSans
    CloseBtn.Parent = TopBar
    CloseBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Контент (скроллинг)
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, -20, 1, -60)
    ContentFrame.Position = UDim2.new(0, 10, 0, 55)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ScrollBarThickness = 4
    ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(189, 189, 189)
    ContentFrame.Parent = MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 10)
    Layout.Parent = ContentFrame

    -- Логика Drag (Перетаскивание)
    local dragging = false
    local dragInput, mousePos, framePos

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = MainFrame.Position
        end
    end)

    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            MainFrame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)

    local windowFunctions = {}

    function windowFunctions:AddToggle(config)
        local Name = config.Name or "Toggle"
        local Callback = config.Callback or function() end
        local Default = config.Default or false

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = "ToggleFrame"
        ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(245, 245, 245) -- Light gray card
        ToggleFrame.Parent = ContentFrame
        Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 4)
        AddShadow(ToggleFrame)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -60, 1, 0)
        Label.Position = UDim2.new(0, 15, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.TextColor3 = Color3.fromRGB(33, 33, 33)
        Label.Font = Enum.Font.SourceSans
        Label.TextSize = 16
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextYAlignment = Enum.TextYAlignment.Center
        Label.Parent = ToggleFrame

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 36, 0, 20)
        Btn.Position = UDim2.new(1, -45, 0.5, -10)
        Btn.BackgroundColor3 = Color3.fromRGB(158, 158, 158)
        Btn.AutoButtonColor = false
        Btn.Text = ""
        Btn.Parent = ToggleFrame
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 16, 0, 16)
        Knob.Position = UDim2.new(0, 2, 0.5, -8)
        Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Knob.Parent = Btn
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

        local toggled = Default
        local function update()
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = toggled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(158, 158, 158)}):Play()
            TweenService:Create(Knob, TweenInfo.new(0.2), {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
            Callback(toggled)
        end

        update() -- Применить дефолтное состояние

        Btn.MouseButton1Click:Connect(function()
            toggled = not toggled
            update()
        end)

        -- Обновление высоты скролла
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
    end

    function windowFunctions:AddButton(config)
        local Name = config.Name or "Button"
        local Callback = config.Callback or function() end

        local Btn = Instance.new("TextButton")
        Btn.Name = "Button"
        Btn.Size = UDim2.new(1, 0, 0, 40)
        Btn.BackgroundColor3 = Color3.fromRGB(63, 81, 181)
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Text = Name
        Btn.Font = Enum.Font.SourceSansSemibold
        Btn.TextSize = 16
        Btn.AutoButtonColor = false
        Btn.Parent = ContentFrame
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
        AddShadow(Btn)

        Btn.MouseButton1Click:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(48, 63, 159)}):Play()
            wait(0.1)
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(63, 81, 181)}):Play()
            Callback()
        end)

        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
    end

    return windowFunctions
end

return Library
]])()

return MaterialLib
