function class(classname)
	return game:GetService(tostring(classname))
end

local CoreGui = class("CoreGui")
local TweenService = class("TweenService")
local RunService = class("RunService")
local Player = class('Players')
local loadstring = loadstring;
local LocalPlayer = Player.LocalPlayer
local IsParent = CoreGui or RunService:IsStudio() and LocalPlayer.PlayerGui
local Tweeninfo = TweenInfo.new
local index = {}
local COLOR_PRESETS = {
	white = Color3.fromRGB(255, 255, 255),
	dark = Color3.fromRGB(0, 0, 0),
	red = Color3.fromRGB(255, 0, 0),
	green = Color3.fromRGB(0, 255, 0),
	blue = Color3.fromRGB(0, 0, 255),
	yellow = Color3.fromRGB(255, 255, 0),
	cyan = Color3.fromRGB(0, 255, 255),
	magenta = Color3.fromRGB(255, 0, 255),
	gray = Color3.fromRGB(128, 128, 128)
}

function Movement(object, waits, Style, ...)
	TweenService:Create(object, Tweeninfo(waits, Style), ...):Play()
end

local function IsCreated(className, properties, children)
	local success, result = pcall(function()
		if typeof(className) ~= "string" then
			return "ObjectType must be a string, got " .. typeof(className)
		end
		local instance = Instance.new(className)
		if properties then
			assert(type(properties) == "table", "properties must be a table or nil")

			for propName, value in pairs(properties) do
				if propName ~= "Parent" then
					local setPropSuccess, err = pcall(function()
						instance[propName] = value
					end)

					if not setPropSuccess then
						--warn(string.format("Failed to set property '%s' on %s: %s", propName, className, tostring(err)))
					end
				end
			end

			if properties.Parent then
				instance.Parent = properties.Parent
			end
		end

		if children then
			assert(type(children) == "table", "children must be a table or nil")

			for _, child in pairs(children) do
				local setChildSuccess, err = pcall(function()
					child.Parent = instance
				end)

				if not setChildSuccess then
					warn(string.format("Failed to parent child to %s: %s", className, tostring(err)))
				end
			end
		end

		return instance
	end)

	if success then
		return result
	else
		warn("Failed to render object: " .. tostring(className), tostring(result))
		return nil
	end
end

function IsUDIM(x, y)
	assert(type(x) == "number", "Scale must be a number")
	assert(type(y) == "number", "Offset must be a number")
	return UDim.new(x, y)
end

function IsUDIM2(a, b, c, d)
	assert(type(a) == "number", "ScaleX must be a number")
	assert(type(b) == "number", "OffsetX must be a number")
	assert(type(c) == "number", "ScaleY must be a number")
	assert(type(d) == "number", "OffsetY must be a number")
	return UDim2.new(a, b, c, d)
end

configs = {
	Size = {
		Main = IsUDIM2(0, 600, 0, 400);
		Scrollbar = IsUDIM2(0, 40, 0, 344);
		Container = IsUDIM2(0, 540, 0, 354);
	};
	Theme = {
		["1"] = Color3.fromRGB(255,0,127);
		["2"] = Color3.fromRGB(58,0,29);
	};
}

function IsVEC(x, y)
	assert(type(x) == "number", "X must be a number")
	assert(type(y) == "number", "Y must be a number")
	return Vector2.new(x, y)
end

function IsRGB(r, g, b)
	local rgb = nil

	if not g or not b and r and type(r) == 'string' then
		local colorName = string.lower(r)
		rgb = COLOR_PRESETS[colorName]

		if not rgb then
			warn("Unknown color preset:", r)
			rgb = COLOR_PRESETS.white
		end
		return rgb
	end

	assert(type(r) == "number", "Red value must be a number")
	assert(type(g) == "number", "Green value must be a number")
	assert(type(b) == "number", "Blue value must be a number")

	local function clamp(value)
		return math.min(math.max(value, 0), 255)
	end

	rgb = Color3.fromRGB(clamp(r), clamp(g), clamp(b))
	return rgb
end

function index.IsParent(object,default)
	-- Store the original parent (CoreGui)
	local originalParent = default

	-- Function to check and restore parent
	local function checkParent()
		if object.Parent ~= originalParent then
			pcall(function()
				object.Parent = originalParent
			end)
		end
	end

	-- Set initial parent
	pcall(function()
		object.Parent = originalParent
	end)

	-- Create a connection to monitor parent changes
	local parentChangedConnection = object:GetPropertyChangedSignal("Parent"):Connect(function()
		checkParent()
	end)

	-- Backup check on every frame in case the above connection fails
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		checkParent()
	end)

	-- Return a cleanup function
	return function()
		parentChangedConnection:Disconnect()
		heartbeatConnection:Disconnect()
	end
end

local function Corner(object, radius)
	local corner = IsCreated("UICorner", {
		CornerRadius = IsUDIM(0, radius);
	});
	corner.Parent = object
end

local ReScale = function(uiScale)
	local UserInputService = game:GetService('UserInputService')
	if UserInputService.TouchEnabled then uiScale.Scale = 0.8;
    else uiScale.Scale = 1; end
end

local function IsNotiUi()
	local container = IsParent:FindFirstChild('@notification centre')
	if container then
		return container
	end

	local notification = {}

	notification.UserInterface = IsCreated('ScreenGui', {
		Name = "@notification centre";
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	})

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = notification.UserInterface
	ReScale(uiScale)

	notification.UserInterface.Parent = IsParent
	index.IsParent(notification.UserInterface, IsParent)

	notification.MainFrame = IsCreated('Frame',{
		Name = "@Frame";
		BackgroundColor3 = IsRGB(3, 3, 3);
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		AnchorPoint = IsVEC(0.5,0.5);
		Size = IsUDIM2(0.00249999994, 0, 0.36, 0);
		Position = IsUDIM2(0.996312261, 0, 0.5, 0);
		Visible = true;
	})
	notification.MainFrame.Parent = notification.UserInterface

	notification.ListLay = IsCreated('UIListLayout',{
		Name = "@ListLay";
		Padding = IsUDIM(0, 5);
		FillDirection = Enum.FillDirection.Vertical;
		HorizontalAlignment = Enum.HorizontalAlignment.Right;
		SortOrder = Enum.SortOrder.LayoutOrder;
		VerticalAlignment = Enum.VerticalAlignment.Center;
	})
	notification.ListLay.Parent = notification.MainFrame

	notification.padding = IsCreated("UIPadding", {
		Name = "@Padding";
		PaddingBottom = IsUDIM(0, 10);
		PaddingLeft = IsUDIM(0, 0);
		PaddingRight = IsUDIM(5, 0);
		PaddingTop = IsUDIM(0, 0);
	})
	notification.padding.Parent = notification.MainFrame

	return notification.UserInterface
end

function index.noti(options)
	local notification = {}
	local Icon = options.Icon or '6034837802'
	local Title = options.Title or "Serenity's Teams"
	local Desc = options.Desc or 'Loaded!'
	local Duration = options.Delay or options.Wait or options.Durations or options.Duration or 5
	local Color = options.Color or configs.Theme['1']
	local container = IsNotiUi()
	local mainFrame = container:FindFirstChild('@Frame')
    
    notification.Frame = IsCreated('Frame',{
        Name = "@Frame";
        BackgroundColor3 = IsRGB(20, 20, 20);
        BackgroundTransparency = 0;
        BorderSizePixel = 0;
        Size = IsUDIM2(0, 0, 0.2, 0);
        AnchorPoint = IsVEC(0.5,0.5);
        Position = IsUDIM2(-399, 0, 0.936196327, 0);
    })
    notification.Frame.Parent = mainFrame
    notification.Frame.ClipsDescendants = true

    notification.Logo = IsCreated('ImageLabel', {
        Name = "@Logo";
        BackgroundColor3 = IsRGB(3, 3, 3);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = IsUDIM2(0.075, 0, 0.384, 0);
        Position = IsUDIM2(0.069, 0, 0.5, 0);
        AnchorPoint = IsVEC(0.5, 0.5);
        Image = "rbxassetid://"..tostring(Icon);
        ImageColor3 = Color;
    })
    notification.Logo.Parent = notification.Frame

    notification.Descriptions = IsCreated('TextLabel', {
        Name = "@Description";
        BackgroundColor3 = IsRGB('white');
        BackgroundTransparency = 1;
        BorderColor3 = IsRGB('dark');
        BorderSizePixel = 0;
        Size = IsUDIM2(0.822, 0, 0.154, 0);
        Position = IsUDIM2(0.135, 0, 0.491, 0);
        Text = tostring(Desc);
        TextColor3 = IsRGB(255, 255, 255);
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal);
        TextTransparency = 0.45;
        TextSize = 10;
        TextWrapped = true;
        RichText = true;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Center;
    })
    notification.Descriptions.Parent = notification.Frame

    notification.HeadTitle = IsCreated('TextLabel', {
        Name = "@Title";
        BackgroundColor3 = IsRGB('white');
        BackgroundTransparency = 1;
        BorderColor3 = IsRGB('dark');
        BorderSizePixel = 0;
        Size = IsUDIM2(0.822, 0, 0.2, 0);
        Position = IsUDIM2(0.135, 0, 0.215, 0);
        Text = tostring(Title);
        TextColor3 = IsRGB(255, 255, 255);
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal);
        TextSize = 14;
        TextWrapped = true;
        RichText = true;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Center;
    })
    notification.HeadTitle.Parent = notification.Frame

    notification.Time = IsCreated('TextLabel', {
        Name = "@Time";
        BackgroundColor3 = IsRGB('white');
        BackgroundTransparency = 1;
        BorderColor3 = IsRGB('dark');
        BorderSizePixel = 0;
        Size = IsUDIM2(0.822, 0, 0.154, 0);
        Position = IsUDIM2(0.135000005, 0, 0.75, 0);
        Text = tostring(os.date("%a %b %d %H:%M:%S %Y"));
        TextColor3 = IsRGB(255, 255, 255);
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal);
        TextSize = 10;
        TextWrapped = true;
        TextTransparency = 0.45;
        RichText = true;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Center;
    })
    notification.Time.Parent = notification.Frame
    Corner(notification.Frame,4)

    task.spawn(function()
        Movement(notification.Frame, 0.5, Enum.EasingStyle.Quart, {Size = IsUDIM2(20, 0, 0.2, 0)})
        repeat task.wait() until notification.Frame.Size == IsUDIM2(20, 0, 0.2, 0)
        delay(Duration,function()
            notification.HeadTitle.Visible = false
            notification.Time.Visible = false
            notification.Descriptions.Visible = false

            Movement(notification.Frame, 0.5, Enum.EasingStyle.Quart, {Size = IsUDIM2(0, 0, 0.2, 0)})
            repeat task.wait() until notification.Frame.Size == IsUDIM2(0, 0, 0.2, 0)
            notification.Frame:Destroy()
        end)
    end)
end

index.noti({Title = 'Serplex Flow', Desc = 'HELLO WORLD!', Icon = '6034837802'})
return index
