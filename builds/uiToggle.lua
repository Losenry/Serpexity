local UserInputService = game:GetService("UserInputService")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local uisConnection = nil
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil
local function CreateFloatingIcon()
    local existingGui = PlayerGui:FindFirstChild("CustomFloatingIcon_Fluorine")
    if existingGui then existingGui:Destroy() end
    local FloatingIconGui = Instance.new("ScreenGui")
    FloatingIconGui.Name = "CustomFloatingIcon_Fluorine"
    FloatingIconGui.DisplayOrder = 999
    FloatingIconGui.ResetOnSpawn = false 

    local FloatingFrame = Instance.new("Frame")
    FloatingFrame.Name = "FloatingFrame"
    FloatingFrame.Position = UDim2.new(0, 250, 0.2, 0) 
    FloatingFrame.Size = UDim2.fromOffset(45, 45) 
    FloatingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    FloatingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    FloatingFrame.BackgroundTransparency = 0 -- Hitam Pekat
    FloatingFrame.BorderSizePixel = 0
    FloatingFrame.Parent = FloatingIconGui

    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Color = Color3.fromHex("#3b82f6")
    FrameStroke.Thickness = 2
    FrameStroke.Transparency = 0
    FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    FrameStroke.Parent = FloatingFrame

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 12) 
    FrameCorner.Parent = FloatingFrame

    local IconImage = Instance.new("ImageLabel")
    IconImage.Name = "Icon"
    IconImage.Image = "rbxassetid://79526326563914"
    IconImage.BackgroundTransparency = 1
    IconImage.Size = UDim2.new(1, -4, 1, -4) 
    IconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    IconImage.AnchorPoint = Vector2.new(0.5, 0.5)
    IconImage.Parent = FloatingFrame

    local ImageCorner = Instance.new("UICorner")
    ImageCorner.CornerRadius = UDim.new(0, 10)
    ImageCorner.Parent = IconImage
    
    FloatingIconGui.Parent = PlayerGui
    return FloatingIconGui, FloatingFrame
end

local function SetupFloatingIcon(FloatingIconGui, FloatingFrame)
    if uisConnection then 
        uisConnection:Disconnect() 
        uisConnection = nil
    end

    local function update(input)
        local delta = input.Position - dragStart
        FloatingFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end

    FloatingFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = FloatingFrame.Position
            
            local didMove = false

            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                    if not didMove then
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

    uisConnection = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function InitializeIcon()
    if not game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.CharacterAdded:Wait()
    end
    
    local gui, frame = CreateFloatingIcon()
    if gui and frame then
        SetupFloatingIcon(gui, frame)
    end
end

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1) 
    InitializeIcon()
end)
InitializeIcon()
