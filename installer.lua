-- / * INSTALLER / EXAMPLE FOR UI LIBRARY

local HttpService = game:GetService("HttpService")
local SerplexBuilds = {
    ['loadGameContents'] = false,
    ['gameContents'] = 'https://api.github.com/repos/Losenry/seraph.loader/contents/',
    ['gameSave'] = 'serplex_cache_games',
    ['discordInvite'] = 'BDFJUn4b4V',
}

local Serplex, Modules = loadstring(game:HttpGet("https://root.s3ren1ty.xyz/v1/files/srn/1399532e183bf347e3480c989d60d0b2.lua"))()
local Window = Serplex:CreateWindow({
    Title = "Serplex Flow",
    Folder = "Serpexity",
    Icon = Modules.Ico,
    IconSize = 35,
    NewElements = true,
    Background = Modules.Theme,
    HideSearchBar = false,
    OpenButton = {
        Title = "Serpexity | Serenity",
        CornerRadius = UDim.new(1,0),
        StrokeThickness = 1,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(184, 179, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(179, 217, 255))}
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Default",
    },

    -- // * Key System Function * \\ --
    -- KeySystem = {
    --     Note = "Please get the key to use the script",
    --     SaveKey = true, -- turn this off if you dont want it to be automatic save worked key
    --     API = {
    --         { 
    --             Type = "pandadevelopment",
    --             ServiceId = '',
    --         }  
    --     }
    -- }
})

Window:SetBackgroundImageTransparency(0.8)
do
    Window:Tag({
        Title = "PREMIUM",
        Color = Color3.fromHex("#93c5fd")
    })
end

-- # Add Theme
do
    Serplex:AddTheme({
        Name = "Serplex",
        Dialog = Color3.fromHex("#0b0b14"),
        Accent = Color3.fromHex("#15162c"),
        Outline = Color3.fromHex("#e879f9"),
        ElementIcon = Color3.fromHex("#f472b6"),
        WindowBackground = Color3.fromHex("#0f1020"),
        Text = Color3.fromHex("#f5f3ff"),
        Placeholder = Color3.fromHex("#a1a1aa"),
        Button = Color3.fromHex("#1b1b33"),
        Icon = Color3.fromHex("#93c5fd"),
        TopbarButtonIcon = Color3.fromHex("#c084fc"),
        TopbarTitle = Color3.fromHex("#f5f3ff"),
        TopbarAuthor = Color3.fromHex("#a1a1aa"),
        TopbarIcon = Color3.fromHex("#a78bfa"),
        TabBackground = Color3.fromHex("#15162c"),
        TabTitle = Color3.fromHex("#f5f3ff"),
        TabIcon = Color3.fromHex("#d8b4fe"),
        ElementBackground = Color3.fromHex("#93c5fd"),
        ElementTitle = Color3.fromHex("#f5f3ff"),
        ElementDesc = Color3.fromHex("#c7c7d1"),
    })    
    
    Serplex:SetTheme("Serplex")
end

do
    local AboutUs = Window:Tab({
        Title = "About Us",
        Icon = "solar:home-2-bold",
        IconColor =Color3.fromHex("#7775F2"),
        IconShape = "Square",
    })

    local InviteCode = SerplexBuilds['discordInvite']
    local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true"
    local Response = HttpService:JSONDecode(request({
        Url = DiscordAPI,
        Method = "GET",
        Headers = {
            ["User-Agent"] = "Serplex/Example",
            ["Accept"] = "application/json"
        }
    }).Body)
    
    pcall(function()
        if Response and Response.guild then
            AboutUs:Section({
                Title = "Join our Discord server!",
                TextSize = 24,
            })

            AboutUs:Paragraph({
                Title = tostring(Response.guild.name),
                Desc = tostring(Response.guild.description),
                Image = "https://cdn.discordapp.com/icons/" .. Response.guild.id .. "/" .. Response.guild.icon .. ".png?size=1024",
                Thumbnail = Modules.BannerTheme,
                ImageSize = 48,
                Buttons = {
                    {
                        Title = "Copy link",
                        Icon = "link",
                        Callback = function()
                            setclipboard("https://discord.gg/" .. InviteCode)
                            Serplex:Notify({
                                Title = "Serenity Discord",
                                Content = "Copied to Clipboard!"
                            })
                        end
                    },
                }
            })
        end
    end)

    if SerplexBuilds['loadGameContents'] then
        AboutUs:Section({
            Title = "Script's Support Lists",
            TextSize = 24,
        })

        local REQUEST_DELAY = 1.2
        local RETRY_DELAY   = 3
        local MAX_RETRY     = 3
        local LAST_REQUEST = 0
        local universeCache = {}
        local function jsonRequest(url, retry)
            retry = retry or 0
        
            local now = os.clock()
            local delta = now - LAST_REQUEST
            if delta < REQUEST_DELAY then
                task.wait(REQUEST_DELAY - delta)
            end
            LAST_REQUEST = os.clock()
            local response = request({
                Url = url,
                Method = "GET",
                Headers = {
                    ["Accept"] = "application/json"
                }
            })
        
            if response.StatusCode == 429 then
                if retry < MAX_RETRY then
                    warn("429 Rate Limit, retrying...", retry + 1)
                    task.wait(RETRY_DELAY)
                    return jsonRequest(url, retry + 1)
                else
                    return nil, "Rate limited"
                end
            end
        
            if not response.Success then
                return nil, "HTTP Failed: " .. tostring(response.StatusCode)
            end
        
            return HttpService:JSONDecode(response.Body)
        end
        
        local function universeToPlaceData(universeId)
            local url = ("https://games.roblox.com/v1/games?universeIds=%s"):format(universeId)
            local data, err = jsonRequest(url)
            if not data or not data.data or not data.data[1] then
                return nil, err or "Invalid universeId"
            end
            return data.data[1]
        end

        local function getGameIconFromPlace(placeId, size)
            size = size or "512x512"
            local url = (
                "https://thumbnails.roblox.com/v1/places/gameicons" ..
                "?placeIds=%s&size=%s&format=Png&isCircular=false"
            ):format(placeId, size)
        
            local data, err = jsonRequest(url)
            if not data or not data.data or not data.data[1] then
                return nil, err or "No icon"
            end
        
            return data.data[1].imageUrl
        end

        local function getGameIconFromUniverse(universeId)
            if universeCache[universeId] then
                return universeCache[universeId].icon,
                    universeCache[universeId].name
            end
        
            local placeData, err = universeToPlaceData(universeId)
            if not placeData then
                return nil, err
            end
        
            local icon, iconErr = getGameIconFromPlace(placeData.rootPlaceId)
            if not icon then
                return nil, iconErr
            end
        
            universeCache[universeId] = {
                icon = icon,
                name = placeData.name
            }
        
            return icon, placeData.name
        end

        local function getLuaFiles(removeExtension)
            local url = SerplexBuilds['gameContents']
            local data, err = jsonRequest(url)
            if not data then
                warn(err)
                return {}
            end
        
            local files = {}
        
            for _, item in ipairs(data) do
                if item.type == "file" and item.name:sub(-4) == ".lua" then
                    local name = item.name
                    if removeExtension then
                        name = name:sub(1, -5)
                    end
        
                    table.insert(files, {
                        name = name,
                        url = item.download_url
                    })
                end
            end
        
            return files
        end 

        task.spawn(function()
            local files = getLuaFiles(true)
            
            if isfile('fastload.cfg') then
                return
            end

            wait(5)
            for _, file in ipairs(files) do
                local icon, gameName = getGameIconFromUniverse(file.name)
                if not isfile(SerplexBuilds['gameSave'] .. '/' .. gameName .. '.png') then
                    if not isfolder(SerplexBuilds['gameSave']) then
                        makefolder(SerplexBuilds['gameSave'])
                    end
                    writefile(SerplexBuilds['gameSave'] .. '/' .. gameName .. '.png', game:HttpGet(icon));
                end

                if icon and gameName then
                    AboutUs:Paragraph({
                        Title = tostring(gameName),
                        Image = getcustomasset(SerplexBuilds['gameSave'] .. '/' .. gameName .. '.png'),
                        ImageSize = 48
                    })
                end
                task.wait(1.5)
            end
        end)
    end
end

Window:Section({Title = "Main Sector", Icon = "nebula:sparkle"})
local MainTab = Window:Tab({
    Title = "General",
    Icon = "solar:home-2-bold",
    IconColor = Color3.fromHex("#83889E"),
    IconShape = "Square",
})

MainTab:Section({
    Title = "Basic Elements"
})

MainTab:Button({
    Title = "Click Me!",
    Desc = "This is a simple button",
    Callback = function()
        print("Button clicked!")
        Serplex:Notify({
            Title = "Success",
            Content = "You clicked the button!"
        })
    end
})

MainTab:Space()
MainTab:Toggle({
    Title = "Enable Feature",
    Desc = "Turn something on or off",
    Default = false,
    Callback = function(state)
        print("Toggle is now:", state)
    end
})

MainTab:Space()
MainTab:Input({
    Title = "Enter Text",
    Placeholder = "Type here...",
    Callback = function(text)
        print("You entered:", text)
    end
})

MainTab:Space()
MainTab:Slider({
    Title = "Value Slider",
    Step = 1,
    Value = {
        Min = 0,
        Max = 100,
        Default = 50,
    },
    Callback = function(value)
        print("Slider value:", value)
    end
})

MainTab:Space()
MainTab:Colorpicker({
    Title = "Pick a Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("Selected color:", color)
    end
})

MainTab:Space()
local MyParagraph = MainTab:Paragraph({
    Title = "Dynamic Paragraph",
    Desc = "This paragraph can be updated!",
    Image = "https://via.placeholder.com/150",
})

MainTab:Button({
    Title = "Update Paragraph Title",
    Callback = function()
        MyParagraph.ParagraphFrame:SetTitle("Updated Title at " .. os.date("%H:%M:%S"))
    end
})

MainTab:Button({
    Title = "Update Paragraph Desc",
    Callback = function()
        MyParagraph.ParagraphFrame:SetDesc("New description updated at " .. os.date("%H:%M:%S"))
    end
})

MainTab:Space()
MainTab:Dropdown({
    Title = "Select Option",
    Values = {
        {Title = "Option 1", Icon = "bird"},
        {Title = "Option 2", Icon = "house"},
        {Title = "Option 3", Icon = "star"},
    },
    AllowNone = true,
    Multi = false,
    Value = "Option 1",
    Callback = function(option)
        print("Selected:", option.Title)
    end
})

MainTab:Dropdown({
    Title = "Multi-Select Options",
    Desc = "You can select multiple options",
    Multi = true,
    AllowNone = true,
    Values = {
        {Title = "Feature A", Icon = "check"},
        {Title = "Feature B", Icon = "check"},
        {Title = "Feature C", Icon = "check"},
        {Title = "Feature D", Icon = "check"},
    },
    Callback = function(selectedOptions)
        local titles = {}
        for _, option in ipairs(selectedOptions) do
            table.insert(titles, option.Title)
        end
        print("Selected:", table.concat(titles, ", "))
    end
})
