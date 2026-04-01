local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local uisConnection = nil
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil
local isOpen = false
local iconInitialized = false
local savedPosition = UDim2.new(0, 250, 0.2, 0)

local function CreateFloatingIcon()
    local existingGui = PlayerGui:FindFirstChild("CustomFloatingIcon_Fluorine")
    if existingGui then existingGui:Destroy() end

    local FloatingIconGui = Instance.new("ScreenGui")
    FloatingIconGui.Name = "CustomFloatingIcon_Fluorine"
    FloatingIconGui.DisplayOrder = 999
    FloatingIconGui.ResetOnSpawn = false

    local FloatingFrame = Instance.new("Frame")
    FloatingFrame.Name = "FloatingFrame"
    FloatingFrame.Position = savedPosition
    FloatingFrame.Size = UDim2.fromOffset(46, 46)
    FloatingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    FloatingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    FloatingFrame.BackgroundTransparency = 0
    FloatingFrame.BorderSizePixel = 0
    FloatingFrame.ZIndex = 3
    FloatingFrame.Parent = FloatingIconGui

    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Name = "FrameStroke"
    FrameStroke.Color = Color3.fromRGB(255, 255, 255)
    FrameStroke.Thickness = 1.5
    FrameStroke.Transparency = 0
    FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    FrameStroke.Parent = FloatingFrame

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 10)
    FrameCorner.Parent = FloatingFrame

    local IconImage = Instance.new("ImageLabel")
    IconImage.Name = "Icon"
    IconImage.Image = "rbxassetid://104544516159070"
    IconImage.BackgroundTransparency = 1
    IconImage.Size = UDim2.new(1, -8, 1, -8)
    IconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    IconImage.AnchorPoint = Vector2.new(0.5, 0.5)
    IconImage.ZIndex = 4
    IconImage.Parent = FloatingFrame

    FloatingIconGui.Parent = PlayerGui

    return FloatingIconGui, FloatingFrame
end

local function UpdateToggleColor(FloatingFrame)
    local stroke = FloatingFrame:FindFirstChild("FrameStroke")
    if stroke then
        if isOpen then
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(34, 197, 94)}):Play()
        else
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 255, 255)}):Play()
        end
    end
end

local function SetupFloatingIcon(FloatingIconGui, FloatingFrame)
    if uisConnection then
        uisConnection:Disconnect()
        uisConnection = nil
    end

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        FloatingFrame.Position = newPos
        savedPosition = newPos
    end

    FloatingFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = FloatingFrame.Position

            TweenService:Create(FloatingFrame, TweenInfo.new(0.1), {Size = UDim2.fromOffset(40, 40)}):Play()

            local didMove = false
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                    savedPosition = FloatingFrame.Position -- เซฟตอนปล่อย
                    TweenService:Create(FloatingFrame, TweenInfo.new(0.15, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(46, 46)}):Play()
                    if not didMove then
                        isOpen = not isOpen
                        UpdateToggleColor(FloatingFrame)
                        if Window and Window.Toggle then
                            Window:Toggle()
                        end
                    end
                end
            end)

            local moveConnection
            moveConnection = input.Changed:Connect(function()
                if dragging and (input.Position - dragStart).Magnitude > 5 then
                    didMove = true
                    moveConnection:Disconnect()
                end
            end)
        end
    end)

    FloatingFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    FloatingFrame.MouseEnter:Connect(function()
        TweenService:Create(FloatingFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(50, 50)}):Play()
    end)
    FloatingFrame.MouseLeave:Connect(function()
        TweenService:Create(FloatingFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(46, 46)}):Play()
    end)

    uisConnection = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    FloatingIconGui.AncestryChanged:Connect(function(_, parent)
        if not parent then
            iconInitialized = false
            task.wait(0.5)
            if not iconInitialized then
                local gui, frame = CreateFloatingIcon()
                if gui and frame then
                    iconInitialized = true
                    SetupFloatingIcon(gui, frame)
                end
            end
        end
    end)
end

local function InitializeIcon()
    if iconInitialized then return end
    iconInitialized = true
    local gui, frame = CreateFloatingIcon()
    if gui and frame then
        SetupFloatingIcon(gui, frame)
    end
end

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait()
    local existingGui = PlayerGui:FindFirstChild("CustomFloatingIcon_Fluorine")
    if not existingGui then
        iconInitialized = false
        InitializeIcon()
    end
end)

InitializeIcon()
