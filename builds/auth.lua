-- new
local apiUrl = {
	['luarmor'] = 'https://sdkapi-public.luarmor.net/library.lua',
	['serpexity'] = 'https://api.s3ren1ty.xyz/Init/sdk-public_library.lua',
	['pandadevelopment'] = 'https://pandadevelopment.net',
}

local userIdentifier = {
	['userId'] = tostring(game:GetService("Players").LocalPlayer.UserId),
	['userIp'] = tostring(game:HttpGet('https://api.ipify.org/', true)),
	['userHwid'] = tostring(string.gsub(game:GetService('RbxAnalyticsService'):GetClientId(), '-', '')),
}

local apiRequest = function(cons)
    if type(cons) ~= "table" then return { Body = nil } end
    local url = cons.Url or cons.url or cons.URL
    local method = cons.Method or cons.method or cons.METHOD
    local headers = cons.Header or cons.headers or cons.Headers or {}
    local body = cons.Body or cons.body or cons.BODY or ""
    if not url or not method then return { Body = nil } end
    local success, result = pcall(function()
        local r = request({
            Url = url, 
            Method = method, 
            Headers = headers,
            Body = method ~= "GET" and body or nil
        })
        return r and r.Body
    end)

    if success and result then
        return { Body = result, body = result }
    end

    if method ~= "GET" then
        warn('[SERPXT] Non-GET request failed, no fallback')
        return { Body = nil, body = nil }
    end

    warn('[SERPXT] Attempt Failed')
    local queryList = {}
    for k, v in pairs(headers) do
        local encoded = tostring(v):gsub("([^%w%-_%.~])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        table.insert(queryList, k .. "=" .. encoded)
    end

    local finalUrl = url
    if #queryList > 0 then
        finalUrl = url .. (url:find("?") and "&" or "?") .. table.concat(queryList, "&")
    end

    local fallbackResult = nil
    local done = false
    task.spawn(function()
        local ok, fb = pcall(function()
            return game:HttpGet(finalUrl)
        end)
        fallbackResult = ok and fb or nil
        done = true
    end)
    local start = os.clock()
    while not done do
        if os.clock() - start >= 5 then
            warn("[SERPXT] Fallback timeout after 5s")
            break
        end
        task.wait(0.1)
    end
    return { Body = fallbackResult, body = fallbackResult }
end

return {
	pandadevelopment = {
		Name = "Panda Development",
		Icon = "panda",
		Args = {
			"ServiceId"
		},
		New = function(serviceId)
			return {
				Verify = function(key)
					local validatedAuth = apiUrl['pandadevelopment'] .. "/v2_validation?key=" .. tostring(key) .. "&service=" .. tostring(serviceId) .. "&hwid=" .. tostring(userIdentifier['userId'])
                    local responseCode = apiRequest({
                        ['Url'] = validatedAuth,
                        ['Method'] = 'GET',
                        ['Headers'] = {["User-Agent"] = "Roblox/Exploit"}
                    })

                    if responseCode and responseCode.Body then
                        local parseBody = game:GetService('HttpService'):JSONDecode(responseCode.Body)
                        if parseBody then
                            if parseBody.V2_Authentication and parseBody.V2_Authentication == "success" then
                                print('Auth Done!')
                                return true, parseBody["Key_Information"]["Premium_Mode"]
                            else
                                print('Auth Failed!')
                                return false, "Authentication failed: " .. parseBody.Key_Information.Notes or "Unknown reason", false
                            end
                        else
                            print('Parse JSON Failed!')
                            return false, "JSON decode error", false
                        end
                    else
                        return false, "Request pcall error", false
                    end
				end,

				Copy = function()
                    local getkeyAuth = apiUrl['pandadevelopment'] .. "/getkey?service=" .. tostring(serviceId) .. "&hwid=" .. tostring(userIdentifier['userId'])
                    if setclipboard then return setclipboard(getkeyAuth) end
                    print(getkeyAuth)
				end,
			}
		end,
	},

	serpexity = {
		Name = "Serpexity",
		Icon = "rbxassetid://74427403958006",
		Args = {
            'PremiumConfig'
        },
		New = function(PremiumConfig)
            local Sources = apiRequest({
                ['Url'] = apiUrl['serpexity'],
                ['Method'] = 'GET',
                ['Headers'] = {["User-Agent"] = "Roblox/Exploit"}
            }).Body

			_G.Authorize = 'Z2P1'
            local Install = loadstring(Sources){};
            local GetLink = Install.getkey()
			return {
				Verify = function(script_key)
                    print(script_key);
                    local validatedResponse = Install.check_key(script_key)
                    if (validatedResponse.ok == true) then
                        if (validatedResponse.code == "KEY_VALID") then
                            if typeof(PremiumConfig) == 'boolean' or typeof(PremiumConfig) == "nil" then
                                PremiumConfig = validatedResponse.isPremium
                            else
                                getgenv()[PremiumConfig] = validatedResponse.isPremium
								_G[PremiumConfig] = validatedResponse.isPremium
                            end
							game:GetService('CoreGui'):WaitForChild('Serpexity Progress'):Destroy()
                            return true, "Whitelisted!"
                        elseif (validatedResponse.code == "KEY_HWID_LOCKED") then
                            return false, "Key linked to a different HWID. Please reset it using our bot"
                        elseif (validatedResponse.code == "KEY_INCORRECT") then
                            return false, "Key is wrong or deleted!"
                        else
                            return false, "Key check failed:" .. validatedResponse.code
                        end
                    end
				end,

				Copy = function()
                    if setclipboard then return setclipboard(GetLink) end
                    print(GetLink)
				end,
			}
		end,
	},

	luarmor = {
		Name = "Luarmor",
		Icon = "rbxassetid://130918283130165",
		Args = {
			"ScriptId",
			"Discord"
		},
		New = function(scriptId, discordUrl)
			return {
				Verify = function(scriptKey)
                    local validatedAuth = apiRequest({
                        ['Url'] = apiUrl['luarmor'],
                        ['Method'] = 'GET',
                        ['Headers'] = {["User-Agent"] = "Roblox/Exploit"}
                    }).Body

                    local luarmorLibrary = loadstring(validatedAuth)();
                    luarmorLibrary.script_id = scriptId

                    local validatedResponse = luarmorLibrary.check_key(scriptKey);
                    if (validatedResponse.code == "KEY_VALID") then
                        return true, "Whitelisted!"
                    elseif (validatedResponse.code == "KEY_HWID_LOCKED") then
                        return false, "Key linked to a different HWID. Please reset it using our bot"
                    elseif (validatedResponse.code == "KEY_INCORRECT") then
                        return false, "Key is wrong or deleted!"
                    else
                        return false, "Key check failed:" .. validatedResponse.message .. " Code: " .. validatedResponse.code
                    end
				end,

				Copy = function()
                    if setclipboard then return setclipboard(discordUrl) end
                    print(discordUrl)
				end,
			}
		end,
	},
}
