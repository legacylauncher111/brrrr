local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Theme = {
    Bg = Color3.fromRGB(12, 12, 16),
    Bg2 = Color3.fromRGB(18, 18, 24),
    Panel = Color3.fromRGB(20, 20, 28),
    Panel2 = Color3.fromRGB(24, 24, 34),
    Stroke = Color3.fromRGB(70, 70, 92),
    Text = Color3.fromRGB(242, 242, 248),
    SubText = Color3.fromRGB(170, 170, 190),
    AccentA = Color3.fromRGB(120, 140, 255),
    AccentB = Color3.fromRGB(255, 110, 220),
    Good = Color3.fromRGB(90, 220, 170),
    Danger = Color3.fromRGB(255, 110, 110),
    Shadow = Color3.fromRGB(0, 0, 0),
}

local Settings = {
    AimbotMode = "Strong",
    TargetPart = "Head",
    FOV = 150,
    TeamCheck = true,
    Keybind = Enum.UserInputType.MouseButton2,
    Smoothness = 0.3,
    Enabled = false,
    AutoAim = false,
    AutoAimKeybind = Enum.KeyCode.Q,
    ShowFOV = false,
    FOVTransparency = 0.5,
    FOVColor = "RGB",
    Prediction = false,
    PredictionAmount = 0.15,
    WallCheck = false,
    VisibleCheck = true,
    TriggerBot = false,
    TriggerBotDelay = 0.1,
    SilentAim = false,
    SilentAimHitChance = 95,
    FlickAim = false,
    FlickAimSpeed = 0.1,
    Humanizer = false,
    HumanizerIntensity = 0.2,
    TargetSwitchDelay = 0.5,
    IgnoreKnocked = true,
    IgnoreFriends = false,
    IgnoreFF = true,  
    DebugMode = false,
    AutoKill = false,
    AutoKillDelay = 0.05,
    SpecificTarget = nil,
    TargetInfo = true,
    TargetInfoMode = "Mouse",
    TeleportMode = "To Player",
    TeleportTarget = nil,
    TeleportEnabled = false,
    BigHeadsEnabled = false,
    HeadSize = 2,
    RivalsSmoothness = 0.4,
    RivalsFOV = 200
}

local ESPSettings = {
    Enabled = false,
    TeamCheck = true,
    AliveCheck = true,
    TextColor = "255, 255, 255",
    TextSize = 13,
    TextFont = 2,
    TextTransparency = 0,
    Outline = true,
    OutlineColor = "0, 0, 0",
    Center = true,
    DisplayName = true,
    DisplayHealth = true,
    DisplayDistance = true,
    HealthDisplayMode = "Numbers",
    HighlightPlayers = false,
    HighlightColor = "255, 0, 0",
    HighlightTransparency = 0.7,
    Tracers = false,
    TracerColor = "255, 255, 255",
    TracerOrigin = "Bottom",
    WeaponESP = false,
    WeaponColor = "255, 255, 0",
    Chams = false,
    ChamsColor = "255, 0, 255",
    ChamsTransparency = 0.3,
    OutOfViewArrows = false,
    ArrowColor = "255, 0, 0",
    ArrowSize = 15,
    MaxDistance = 1000,
    GlowChams = false,
    GlowChamsColor = "255, 50, 50",
    GlowChamsTransparency = 0.3,
    BoxESP = false,
    BoxColor = "RGB"
}

local VisualSettings = {
    Crosshair = false,
    CrosshairSize = 12,
    CrosshairThickness = 1,
    CrosshairColor = "255, 255, 255",
    CrosshairType = "Cross",
    HitMarker = false,
    HitMarkerColor = "255, 0, 0",
    HitMarkerSize = 8,
    HitSound = false,
    HitSoundVolume = 0.5,
    KillSound = false,
    KillSoundVolume = 0.7,
    BulletTracers = false,
    TracerColor = "255, 255, 0",
    TracerLength = 100,
    FPSBoost = false,
    NoFlash = false,
    NoSmoke = false,
    NoBlur = false,
    OptimizationMode = false,
    SkyboxEnabled = false,
    SelectedSkybox = "SpongeBob Sky"
}

local MiscSettings = {
    AntiAFK = false,
    SpeedHack = false,
    SpeedMultiplier = 1.5,
    JumpPower = false,
    JumpMultiplier = 1.5,
    Noclip = false,
    InfJump = false,
    AutoReload = false,
    Radar = false,
    RadarRange = 200,
    Notification = true,
    AutoRespawn = false,
    SpinBot = false,
    SpinSpeed = 5,
    FakeLag = false,
    LagIntensity = 0.1,
    AntiAim = false,
    AntiAimType = "Jitter",
    AutoReportBlock = true,
    ServerHop = false,
    HopDelay = 60,
    AutoStomp = false,
    SpectatorList = false,
    PlayerList = false,
    SaveConfig = true
}

local ESP_Cache = {}
local HighlightParts = {}
local Chams = {}
local GlowChams = {}

local FOVCircle = nil
local rgbOffset = 0
local Crosshair = nil
local HitMarker = nil
local OriginalGraphics = {}
local LastTargetSwitch = 0
local CurrentTarget = nil
local HumanizerOffset = Vector3.new(0, 0, 0)
local RadarDots = {}
local RadarFrame = nil
local MenuVisible = true

local PlayerCache = {}
local OriginalHeadSizes = {}
local wallParams = RaycastParams.new()
wallParams.FilterType = Enum.RaycastFilterType.Exclude

local TargetInfoFrame = nil
local TargetInfoElements = {}
local LastTargetInfoUpdate = 0

local Skyboxes = {
    ["Purple Nebula"] = {Bk = "rbxassetid://159454299", Dn = "rbxassetid://159454296", Ft = "rbxassetid://159454293", Lf = "rbxassetid://159454286", Rt = "rbxassetid://159454300", Up = "rbxassetid://159454288"},
    Minecraft = {Bk = "rbxassetid://1876545003", Dn = "rbxassetid://1876544331", Ft = "rbxassetid://1876542941", Lf = "rbxassetid://1876543392", Rt = "rbxassetid://1876543764", Up = "rbxassetid://1876544642"},
    ["Night Sky"] = {Bk = "rbxassetid://12064107", Dn = "rbxassetid://12064152", Ft = "rbxassetid://12064121", Lf = "rbxassetid://12063984", Rt = "rbxassetid://12064115", Up = "rbxassetid://12064131"},
    ["SpongeBob Sky"] = {Bk = "rbxassetid://10287764626", Dn = "rbxassetid://10287766382", Ft = "rbxassetid://10287764626", Lf = "rbxassetid://10287763421", Rt = "rbxassetid://10287764626", Up = "rbxassetid://10287767597"},
    ["Purple Sky"] = {Bk = "rbxassetid://17103618635", Dn = "rbxassetid://17103622190", Ft = "rbxassetid://17103624898", Lf = "rbxassetid://17103628153", Rt = "rbxassetid://17103636666", Up = "rbxassetid://17103639457"},
    ["Pink Sky"] = {Bk = "rbxassetid://271042516", Dn = "rbxassetid://271077243", Ft = "rbxassetid://271042556", Lf = "rbxassetid://271042310", Rt = "rbxassetid://271042467", Up = "rbxassetid://271077958"}
}
local originalSkyData = {}
local skyboxInitialized = false

local function SaveSettings()
    if not MiscSettings.SaveConfig then return end
    
    local saveSettings = {}
    for k, v in pairs(Settings) do
        if typeof(v) == "EnumItem" then
            saveSettings[k] = {Type = "Enum", Name = tostring(v), EnumType = tostring(v.EnumType)}
        else
            saveSettings[k] = v
        end
    end
    
    local data = {
        Settings = saveSettings,
        ESPSettings = ESPSettings,
        VisualSettings = VisualSettings,
        MiscSettings = MiscSettings,
        Authorized = true,
        UserId = LocalPlayer.UserId
    }
    pcall(function()
        writefile("HatchingProject_Settings.json", HttpService:JSONEncode(data))
    end)
end

local function LoadSettings()
    local success, fileData = pcall(function()
        return readfile("HatchingProject_Settings.json")
    end)
    if success and fileData then
        local success2, data = pcall(function()
            return HttpService:JSONDecode(fileData)
        end)
        if success2 and data then
            if data.Settings then
                for k, v in pairs(data.Settings) do
                    if type(v) == "table" and v.Type == "Enum" then
                        if v.EnumType == "UserInputType" then
                            Settings[k] = Enum.UserInputType[v.Name:match("([^%.]+)$")]
                        elseif v.EnumType == "KeyCode" then
                            Settings[k] = Enum.KeyCode[v.Name:match("([^%.]+)$")]
                        end
                    else
                        Settings[k] = v
                    end
                end
            end
            if data.ESPSettings then ESPSettings = data.ESPSettings end
            if data.VisualSettings then VisualSettings = data.VisualSettings end
            if data.MiscSettings then MiscSettings = data.MiscSettings end
            return data.Authorized or false, data.UserId
        end
    end
    return false, nil
end

local AuthKey = "artnoob"
local Authorized = false
local loadedAuthorized, savedUserId = LoadSettings()
if loadedAuthorized and savedUserId == LocalPlayer.UserId then
    Authorized = true
end

local function make(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do inst[k] = v end
    return inst
end

local function corner(parent, r)
    return make("UICorner", {CornerRadius = UDim.new(0, r or 16), Parent = parent})
end

local function stroke(parent, thickness, transparency)
    return make("UIStroke", {
        Color = Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0.55,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function GetColor(Color)
    if Color == "RGB" then
        rgbOffset = (rgbOffset + 0.01) % 1
        local r = math.sin(rgbOffset * math.pi * 2 + 0) * 127 + 128
        local g = math.sin(rgbOffset * math.pi * 2 + 2) * 127 + 128
        local b = math.sin(rgbOffset * math.pi * 2 + 4) * 127 + 128
        return Color3.fromRGB(r, g, b)
    elseif Color == "Red" then
        return Color3.fromRGB(255, 0, 0)
    elseif Color == "Green" then
        return Color3.fromRGB(0, 255, 0)
    elseif Color == "Blue" then
        return Color3.fromRGB(0, 0, 255)
    elseif Color == "Yellow" then
        return Color3.fromRGB(255, 255, 0)
    elseif Color == "Purple" then
        return Color3.fromRGB(255, 0, 255)
    elseif Color == "White" then
        return Color3.fromRGB(255, 255, 255)
    elseif Color == "Cyan" then
        return Color3.fromRGB(0, 255, 255)
    elseif Color == "Orange" then
        return Color3.fromRGB(255, 165, 0)
    elseif Color == "Pink" then
        return Color3.fromRGB(255, 192, 203)
    else
        local R = tonumber(string.match(Color, "([%d]+)[%s]*,[%s]*[%d]+[%s]*,[%s]*[%d]+"))
        local G = tonumber(string.match(Color, "[%d]+[%s]*,[%s]*([%d]+)[%s]*,[%s]*[%d]+"))
        local B = tonumber(string.match(Color, "[%d]+[%s]*,[%s]*[%d]+[%s]*,[%s]*([%d]+)"))
        return Color3.fromRGB(R or 255, G or 255, B or 255)
    end
end

local function GetColorByDistance(distance)
    if distance <= 50 then
        return Color3.fromRGB(255, 80, 80)
    elseif distance <= 150 then
        return Color3.fromRGB(255, 255, 100)
    else
        return Color3.fromRGB(100, 255, 100)
    end
end

local function UpdateCache(player)
    local char = player.Character
    if char then
        PlayerCache[player] = {
            Character = char,
            Root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"),
            Head = char:FindFirstChild("Head"),
            Humanoid = char:FindFirstChildOfClass("Humanoid")
        }
    else
        PlayerCache[player] = nil
    end
end

local function UpdateHeadSize(character)
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    if not OriginalHeadSizes[character] then
        OriginalHeadSizes[character] = head.Size
    end
    
    if Settings.BigHeadsEnabled then
        head.Size = Vector3.new(Settings.HeadSize, Settings.HeadSize, Settings.HeadSize)
    else
        head.Size = OriginalHeadSizes[character]
    end
end

local function GetCharacterRootPart(character)
    if not character then return nil end
    local possibleNames = {
        "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "RootPart", "MainPart", "Body", "Chest", "Rig"
    }
    for _, name in ipairs(possibleNames) do
        local part = character:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            return part
        end
    end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("BasePart") and child.Name ~= "Head" then
            return child
        end
    end
    return nil
end

local function GetCharacterHeadPart(character)
    if not character then return nil end
    local possibleNames = {"Head", "HeadHB", "HeadHitbox", "HeadPart"}
    for _, name in ipairs(possibleNames) do
        local part = character:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            return part
        end
    end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("BasePart") and (child.Name:lower():find("head") or child == character:FindFirstChild("Head")) then
            return child
        end
    end
    return GetCharacterRootPart(character)
end

local function IsFriend(player)
    if not Settings.IgnoreFriends then return false end
    return player:IsFriendsWith(LocalPlayer.UserId)
end

local function IsKnocked(player)
    if not Settings.IgnoreKnocked then return false end
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    if humanoid:GetAttribute("Knocked") or humanoid:GetAttribute("KO") then return true end
    if humanoid:GetState() == Enum.HumanoidStateType.Physics then return true end
    if character:FindFirstChild("KO") or character:FindFirstChild("Knocked") then return true end
    return false
end

local function HasForceField(character)
    if not character then return false end
    
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("ForceField") then
            return true
        end
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if humanoid:GetAttribute("ForceField") or 
           humanoid:GetAttribute("Shield") or 
           humanoid:GetAttribute("Protected") or
           humanoid:GetAttribute("Invincible") then
            return true
        end
    end
    
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("Highlight") then
                    if child.Name:lower():find("shield") or 
                       child.Name:lower():find("force") or
                       child.Name:lower():find("protection") then
                        return true
                    end
                end
            end
            
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("ParticleEmitter") then
                    if child.Texture:find("shield") or 
                       child.Texture:find("force") or
                       child.Texture:find("bubble") then
                        return true
                    end
                end
            end
            
            if part.Transparency > 0.5 and part.Material == Enum.Material.ForceField then
                return true
            end
        end
    end
    
    return false
end

local function GetHitboxPart(character)
    if not character then return nil end
    local hitboxNames = {
        "Head", "HumanoidRootPart", "UpperTorso", "Torso", "Chest", "Hitbox",
        "HeadHB", "RootPart", "MainPart", "Body", "HeadHitbox", "TorsoHitbox"
    }
    
    local targetPart = Settings.TargetPart
    
    if targetPart == "Random" then
        local validParts = {}
        for _, name in ipairs(hitboxNames) do
            local part = character:FindFirstChild(name)
            if part then table.insert(validParts, part) end
        end
        if #validParts > 0 then
            return validParts[math.random(1, #validParts)]
        end
    end
    
    local part = character:FindFirstChild(targetPart)
    if part then return part end
    
    for _, name in ipairs(hitboxNames) do
        local altPart = character:FindFirstChild(name)
        if altPart then return altPart end
    end
    
    return GetCharacterRootPart(character) or GetCharacterHeadPart(character)
end

local function GetWeaponName(character)
    if not character then return "None" end
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then return tool.Name end
    return "None"
end

local function GetTargetUnderMouse()
    local mousePos = UserInputService:GetMouseLocation()
    local closestPlayer = nil
    local closestDist = 200
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local cache = PlayerCache[player]
        if not cache or not cache.Character or not cache.Character.Parent then
            UpdateCache(player)
            cache = PlayerCache[player]
            if not cache then continue end
        end
        
        local hum = cache.Humanoid
        if not hum or hum.Health <= 0 then continue end
        
        local part = GetHitboxPart(cache.Character)
        if not part then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        
        if dist < closestDist then
            closestDist = dist
            closestPlayer = player
        end
    end
    
    return closestPlayer
end

local lastRaycastTime = 0
local RAYCAST_COOLDOWN = 0.05 
local function GetAimbotTarget()
    if Settings.SpecificTarget then
        local target = Players:FindFirstChild(Settings.SpecificTarget)
        if target and target.Character then
            local hum = target.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return target
            end
        end
        return nil
    end
    
    local closestPlayer = nil
    local closestDist = Settings.AimbotMode == "Rivals" and Settings.RivalsFOV or Settings.FOV
    local mousePos = UserInputService:GetMouseLocation()
    local camPos = Camera.CFrame.Position
    local myTeam = LocalPlayer.Team
    
    local doRaycast = Settings.WallCheck and (tick() - lastRaycastTime) >= RAYCAST_COOLDOWN
    if doRaycast then
        lastRaycastTime = tick()
    end
    
    local playerList = Players:GetPlayers()
    for i = 1, #playerList do
        local player = playerList[i]
        if player == LocalPlayer then continue end
        if Settings.TeamCheck and player.Team == myTeam then continue end
        if Settings.IgnoreFriends and IsFriend(player) then continue end
        
        local cache = PlayerCache[player]
        if not cache or not cache.Character or not cache.Character.Parent then
            UpdateCache(player)
            cache = PlayerCache[player]
            if not cache then continue end
        end
        
        local hum = cache.Humanoid
        if not hum or hum.Health <= 0 then continue end
        if Settings.IgnoreKnocked and IsKnocked(player) then continue end
        if Settings.IgnoreFF and HasForceField(cache.Character) then continue end
        
        local part = GetHitboxPart(cache.Character)
        if not part then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist > (Settings.AimbotMode == "Rivals" and Settings.RivalsFOV or Settings.FOV) or dist >= closestDist then continue end
        
        if Settings.WallCheck then
            wallParams.FilterDescendantsInstances = {LocalPlayer.Character, cache.Character}
            local origin = camPos
            local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
            local raycastResult = workspace:Raycast(origin, direction, wallParams)
            
            if raycastResult then
                local hitPart = raycastResult.Instance
                local hitModel = hitPart:FindFirstAncestorOfClass("Model")
                if hitModel ~= cache.Character then
                    continue
                end
            end
        end
        
        closestDist = dist
        closestPlayer = player
    end
    return closestPlayer
end

local function AimAtTarget()
    if not Settings.Enabled then return end
    if not LocalPlayer or not LocalPlayer.Character then return end
    if not Camera then return end
    
    local shouldAim = false
    if Settings.AutoAim then
        shouldAim = UserInputService:IsKeyDown(Settings.AutoAimKeybind)
    else
        shouldAim = UserInputService:IsMouseButtonPressed(Settings.Keybind)
    end
    
    if not shouldAim then
        return 
    end
    
    local targetPlayer = GetAimbotTarget()
    
    if not targetPlayer or not targetPlayer.Character then
        return 
    end
    
    local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not targetHumanoid or targetHumanoid.Health <= 0 then
        return 
    end
    
    if CurrentTarget and CurrentTarget ~= targetPlayer and tick() - LastTargetSwitch < Settings.TargetSwitchDelay then
        return
    end
    
    CurrentTarget = targetPlayer
    LastTargetSwitch = tick()
    
    local part = GetHitboxPart(targetPlayer.Character)
    if not part then return end
    
    local targetPos = part.Position
    
    if Settings.Prediction then
        local velocity = part.Velocity
        if velocity and velocity.Magnitude and velocity.Magnitude > 5 then
            targetPos = targetPos + velocity * Settings.PredictionAmount
        end
    end
    
    if Settings.Humanizer then
        HumanizerOffset = Vector3.new(
            (math.random() * 2 - 1) * Settings.HumanizerIntensity,
            (math.random() * 2 - 1) * Settings.HumanizerIntensity,
            (math.random() * 2 - 1) * Settings.HumanizerIntensity
        )
        targetPos = targetPos + HumanizerOffset
    end
    
    pcall(function()
        if Settings.AimbotMode == "Rivals" then
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local deltaX = screenPos.X - mousePos.X
                local deltaY = screenPos.Y - mousePos.Y
                local smoothness = Settings.RivalsSmoothness
                mousemoverel(deltaX * smoothness, deltaY * smoothness)
            end
        else
            local camPos = Camera.CFrame.Position
            local dir = (targetPos - camPos).Unit
            local goal = CFrame.new(camPos, camPos + dir)
            
            if Settings.AimbotMode == "Strong" then
                Camera.CFrame = goal
            elseif Settings.AimbotMode == "Light" then
                Camera.CFrame = Camera.CFrame:Lerp(goal, Settings.Smoothness)
            elseif Settings.AimbotMode == "Flick" then
                if math.random(1, 100) <= Settings.SilentAimHitChance then
                    Camera.CFrame = Camera.CFrame:Lerp(goal, Settings.FlickAimSpeed)
                end
            elseif Settings.AimbotMode == "Humanized" then
                local jitter = Vector3.new(
                    (math.random() * 2 - 1) * Settings.HumanizerIntensity,
                    (math.random() * 2 - 1) * Settings.HumanizerIntensity,
                    (math.random() * 2 - 1) * Settings.HumanizerIntensity
                )
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(camPos, camPos + dir + jitter), Settings.Smoothness)
            end
        end
    end)
end

local function TriggerBot()
    if not Settings.TriggerBot then return end
    local targetPlayer = GetAimbotTarget()
    if not targetPlayer or not targetPlayer.Character then return end
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(Settings.TriggerBotDelay)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function AutoKill()
    if not Settings.AutoKill or not Settings.Enabled then return end
    local targetPlayer = GetAimbotTarget()
    if not targetPlayer or not targetPlayer.Character then return end
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    local part = GetHitboxPart(targetPlayer.Character)
    if not part then return end
    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return end
    if Settings.WallCheck then
        wallParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPlayer.Character}
        local origin = Camera.CFrame.Position
        local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
        local raycastResult = workspace:Raycast(origin, direction, wallParams)
        if raycastResult then return end
    end
    local mousePos = UserInputService:GetMouseLocation()
    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
    if dist <= Settings.FOV then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(Settings.AutoKillDelay)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end

local function CreateDrawing(class, props)
    local d = Drawing.new(class)
    for i, v in pairs(props) do 
        pcall(function() d[i] = v end)
    end
    return d
end

local function RemoveESP(player)
    if ESP_Cache[player] then
        for _, obj in pairs(ESP_Cache[player].Drawings) do 
            pcall(function() obj:Remove() end)
        end
        ESP_Cache[player] = nil
    end
    if player.Character then
        RemoveHighlight(player.Character)
        RemoveChams(player.Character)
        RemoveGlowChams(player.Character)
    end
end

local function ConstructESP(player)
    if player == LocalPlayer then return end
    if ESP_Cache[player] then return end
    
    ESP_Cache[player] = {
        Drawings = {
            BoxOutline = CreateDrawing("Square", {Color = Color3.new(0,0,0), Thickness = 3, Transparency = 0.8, Visible = false}),
            Box = CreateDrawing("Square", {Color = Color3.new(1,1,1), Thickness = 1, Transparency = 1, Visible = false}),
            HealthBar = CreateDrawing("Square", {Color = Color3.new(0,1,0), Filled = true, Visible = false}),
            HealthBarOutline = CreateDrawing("Square", {Color = Color3.new(0,0,0), Thickness = 1, Filled = false, Visible = false}),
            Name = CreateDrawing("Text", {Size = 13, Center = true, Outline = true, Color = Color3.new(1,1,1), Visible = false}),
            Tracer = CreateDrawing("Line", {Thickness = 1, Transparency = 0.7, Visible = false})
        }
    }
end

local function AddHighlight(character)
    if not ESPSettings.HighlightPlayers or not character then return end
    if HighlightParts[character] then
        for _, part in pairs(HighlightParts[character]) do part:Destroy() end
    end
    HighlightParts[character] = {}
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    for _, partName in ipairs({"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg", "Torso"}) do
        local part = character:FindFirstChild(partName)
        if part then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = GetColor(ESPSettings.HighlightColor)
            highlight.FillTransparency = ESPSettings.HighlightTransparency
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Adornee = part
            highlight.Parent = part
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            table.insert(HighlightParts[character], highlight)
        end
    end
end

local function RemoveHighlight(character)
    if HighlightParts[character] then
        for _, part in pairs(HighlightParts[character]) do part:Destroy() end
        HighlightParts[character] = nil
    end
end

local function AddChams(character)
    if not ESPSettings.Chams or not character then return end
    
    RemoveChams(character)
    Chams[character] = {}
    
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ChamsHighlight"
            highlight.FillColor = GetColor(ESPSettings.ChamsColor)
            highlight.FillTransparency = ESPSettings.ChamsTransparency
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Adornee = part
            highlight.Parent = part
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            table.insert(Chams[character], highlight)
        end
    end
end

local function RemoveChams(character)
    if not character then return end
    if Chams[character] then
        for _, part in pairs(Chams[character]) do
            if part then part:Destroy() end
        end
        Chams[character] = nil
    end
end

local function AddGlowChams(character)
    if not ESPSettings.GlowChams or not character then return end
    
    RemoveGlowChams(character)
    GlowChams[character] = {}
    
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local highlight = Instance.new("Highlight")
            highlight.Name = "GlowChamsHighlight"
            highlight.FillColor = GetColor(ESPSettings.GlowChamsColor)
            highlight.FillTransparency = ESPSettings.GlowChamsTransparency
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Adornee = part
            highlight.Parent = part
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            table.insert(GlowChams[character], highlight)
        end
    end
end

local function RemoveGlowChams(character)
    if not character then return end
    if GlowChams[character] then
        for _, part in pairs(GlowChams[character]) do
            if part then part:Destroy() end
        end
        GlowChams[character] = nil
    end
end

local function FullCleanupESP()
    for player, data in pairs(ESP_Cache) do
        RemoveESP(player)
    end
    table.clear(ESP_Cache)
    
    for char, _ in pairs(HighlightParts) do
        if HighlightParts[char] then
            for _, part in pairs(HighlightParts[char]) do
                if part then part:Destroy() end
            end
            HighlightParts[char] = nil
        end
    end
    
    for char, _ in pairs(Chams) do
        if Chams[char] then
            for _, part in pairs(Chams[char]) do
                if part then part:Destroy() end
            end
            Chams[char] = nil
        end
    end
    
    for char, _ in pairs(GlowChams) do
        if GlowChams[char] then
            for _, part in pairs(GlowChams[char]) do
                if part then part:Destroy() end
            end
            GlowChams[char] = nil
        end
    end
end

local function UpdateESP()
    if not ESPSettings.Enabled then
        for _, data in pairs(ESP_Cache) do
            for _, d in pairs(data.Drawings) do 
                d.Visible = false 
            end
        end
        return
    end

    for player, data in pairs(ESP_Cache) do
        if not player or not player.Parent then
            RemoveESP(player)
            continue
        end
        
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local drawings = data.Drawings
        
        if not char or not hum or hum.Health <= 0 then
            for _, d in pairs(drawings) do d.Visible = false end
            RemoveChams(char)
            RemoveGlowChams(char)
            continue
        end
        
        if Settings.SpecificTarget and player.Name ~= Settings.SpecificTarget then
            for _, d in pairs(drawings) do d.Visible = false end
            RemoveChams(char)
            RemoveGlowChams(char)
            continue
        end
        
        if ESPSettings.TeamCheck and player.Team == LocalPlayer.Team then
            for _, d in pairs(drawings) do d.Visible = false end
            RemoveChams(char)
            RemoveGlowChams(char)
            continue
        end
        
        local cf, size = char:GetBoundingBox()
        if not cf then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(cf.Position)
        local dist = (Camera.CFrame.Position - cf.Position).Magnitude
        
        if onScreen and dist <= ESPSettings.MaxDistance then
            local offset = size.Y / 2
            local topVec = (cf * CFrame.new(0, offset, 0)).Position
            local bottomVec = (cf * CFrame.new(0, -offset, 0)).Position
            
            local top = Camera:WorldToViewportPoint(topVec)
            local bottom = Camera:WorldToViewportPoint(bottomVec)
            
            local boxHeight = math.abs(top.Y - bottom.Y)
            local boxWidth = boxHeight * 0.55
            
            -- боксы
            if ESPSettings.BoxESP then
                local color = GetColor(ESPSettings.BoxColor)
                drawings.Box.Visible = true
                drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
                drawings.Box.Position = Vector2.new(screenPos.X - boxWidth/2, screenPos.Y - boxHeight/2)
                drawings.Box.Color = color
                
                drawings.BoxOutline.Visible = ESPSettings.Outline
                if ESPSettings.Outline then
                    drawings.BoxOutline.Size = drawings.Box.Size
                    drawings.BoxOutline.Position = drawings.Box.Position
                end
            else
                drawings.Box.Visible = false
                drawings.BoxOutline.Visible = false
            end
            
            if ESPSettings.DisplayHealth and ESPSettings.BoxESP then
                local healthPercent = hum.Health / hum.MaxHealth
                local barHeight = boxHeight * healthPercent
                
                drawings.HealthBar.Visible = true
                drawings.HealthBar.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1)
                drawings.HealthBar.Size = Vector2.new(3, barHeight)
                drawings.HealthBar.Position = Vector2.new(screenPos.X - boxWidth/2 - 5, screenPos.Y - boxHeight/2 + (boxHeight - barHeight))
                
                drawings.HealthBarOutline.Visible = true
                drawings.HealthBarOutline.Size = Vector2.new(3, boxHeight)
                drawings.HealthBarOutline.Position = Vector2.new(screenPos.X - boxWidth/2 - 5, screenPos.Y - boxHeight/2)
            else
                drawings.HealthBar.Visible = false
                drawings.HealthBarOutline.Visible = false
            end
            
            if ESPSettings.DisplayName then
                drawings.Name.Visible = true
                drawings.Name.Size = ESPSettings.TextSize
                drawings.Name.Color = GetColor(ESPSettings.TextColor)
                
                local displayName = player.DisplayName ~= "" and player.DisplayName or player.Name
                local text = displayName
                
                if ESPSettings.DisplayHealth then
                    text = text .. "\n[HP: " .. math.floor(hum.Health) .. "]"
                end
                if ESPSettings.DisplayDistance then
                    text = text .. " [" .. math.floor(dist) .. "m]"
                end
                
                drawings.Name.Text = text
                drawings.Name.Position = Vector2.new(screenPos.X, screenPos.Y - boxHeight/2 - 25)
            else
                drawings.Name.Visible = false
            end
            
            if ESPSettings.Tracers then
                drawings.Tracer.Visible = true
                drawings.Tracer.Color = GetColorByDistance(dist)
                
                local originY
                if ESPSettings.TracerOrigin == "Bottom" then
                    originY = Camera.ViewportSize.Y
                elseif ESPSettings.TracerOrigin == "Middle" then
                    originY = Camera.ViewportSize.Y / 2
                elseif ESPSettings.TracerOrigin == "Top" then
                    originY = 0
                elseif ESPSettings.TracerOrigin == "Crosshair" then
                    originY = Camera.ViewportSize.Y / 2
                else
                    local mousePos = UserInputService:GetMouseLocation()
                    originY = mousePos.Y
                end
                
                local originX = Camera.ViewportSize.X / 2
                if ESPSettings.TracerOrigin == "Mouse" then
                    local mousePos = UserInputService:GetMouseLocation()
                    originX = mousePos.X
                end
                
                drawings.Tracer.From = Vector2.new(originX, originY)
                drawings.Tracer.To = Vector2.new(screenPos.X, screenPos.Y + boxHeight/2)
            else
                drawings.Tracer.Visible = false
            end
            
            if ESPSettings.HighlightPlayers then AddHighlight(char) else RemoveHighlight(char) end
            if ESPSettings.Chams then AddChams(char) else RemoveChams(char) end
            if ESPSettings.GlowChams then AddGlowChams(char) else RemoveGlowChams(char) end
        else
            for _, d in pairs(drawings) do d.Visible = false end
            RemoveChams(char)
            RemoveGlowChams(char)
        end
    end
end


local function ApplyOptimization()
    if VisualSettings.OptimizationMode then
        OriginalGraphics = {
            Brightness = Lighting.Brightness,
            GlobalShadows = Lighting.GlobalShadows,
            FogEnd = Lighting.FogEnd,
            EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
            EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
        }
        
        Lighting.Brightness = 0
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 999999
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.CastShadow = false
            elseif v:IsA("Decal") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") then
                v.Enabled = false
            elseif v:IsA("Fire") or v:IsA("Smoke") then
                v.Enabled = false
            end
        end
    else
        for setting, value in pairs(OriginalGraphics) do
            if Lighting[setting] then
                Lighting[setting] = value
            end
        end
    end
end

local function AntiAFK()
    if not MiscSettings.AntiAFK then return end
    local virtualUser = game:GetService("VirtualUser")
    virtualUser:CaptureController()
    virtualUser:ClickButton2(Vector2.new())
end

local function SpeedHack()
    if not MiscSettings.SpeedHack or not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then 
        humanoid.WalkSpeed = 16 * MiscSettings.SpeedMultiplier
    end
end

local function JumpPower()
    if not MiscSettings.JumpPower or not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then 
        humanoid.JumpPower = 50 * MiscSettings.JumpMultiplier
    end
end

local function Noclip()
    if not MiscSettings.Noclip or not LocalPlayer.Character then return end
    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
    end
end

local function InfiniteJump()
    if not MiscSettings.InfJump then return end
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end

local function AutoReload()
    if not MiscSettings.AutoReload or not LocalPlayer.Character then return end
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        local ammo = tool:FindFirstChild("Ammo")
        if ammo and ammo.Value <= 0 then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        end
    end
end

local function AutoRespawn()
    if not MiscSettings.AutoRespawn then return end
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then 
        LocalPlayer:LoadCharacter()
    end
end

local function SpinBot()
    if not MiscSettings.SpinBot or not LocalPlayer.Character then return end
    local rootPart = GetCharacterRootPart(LocalPlayer.Character)
    if rootPart then
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(MiscSettings.SpinSpeed), 0)
    end
end

local function AntiAim()
    if not MiscSettings.AntiAim or not LocalPlayer.Character then return end
    local rootPart = GetCharacterRootPart(LocalPlayer.Character)
    if not rootPart then return end
    if MiscSettings.AntiAimType == "Jitter" then
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
    elseif MiscSettings.AntiAimType == "Spin" then
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(MiscSettings.SpinSpeed), 0)
    elseif MiscSettings.AntiAimType == "Backwards" then
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(180), 0)
    elseif MiscSettings.AntiAimType == "Random" then
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(math.random(0, 360)), 0)
    end
end

local function AutoStomp()
    if not MiscSettings.AutoStomp or not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if targetHumanoid and targetHumanoid.Health > 0 and targetHumanoid.Health <= 10 then
                local targetRoot = GetCharacterRootPart(player.Character)
                local localRoot = GetCharacterRootPart(LocalPlayer.Character)
                if targetRoot and localRoot and (targetRoot.Position - localRoot.Position).Magnitude < 5 then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    task.wait(0.1)
                    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                end
            end
        end
    end
end

local function TeleportToPlayer()
    if not Settings.TeleportEnabled then return end
    if not Settings.TeleportTarget then return end
    
    local targetPlayer = Players:FindFirstChild(Settings.TeleportTarget)
    if not targetPlayer or not targetPlayer.Character then return end
    
    local localChar = LocalPlayer.Character
    if not localChar then return end
    
    local localRoot = GetCharacterRootPart(localChar)
    if not localRoot then return end
    
    local targetHead = GetCharacterHeadPart(targetPlayer.Character)
    local targetRoot = GetCharacterRootPart(targetPlayer.Character)
    
    if Settings.TeleportMode == "To Player" and targetRoot then
        localRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 0, 3)
    elseif Settings.TeleportMode == "Above Head" and targetHead then
        localRoot.CFrame = CFrame.new(targetHead.Position + Vector3.new(0, 5, 0))
    end
end

local function updateSkybox()
    local Sky = Lighting:FindFirstChildOfClass("Sky")
    if not Sky then
        Sky = Instance.new("Sky")
        Sky.Parent = Lighting
    end
    
    if not skyboxInitialized then
        originalSkyData = {
            Bk = Sky.SkyboxBk, Dn = Sky.SkyboxDn, Ft = Sky.SkyboxFt,
            Lf = Sky.SkyboxLf, Rt = Sky.SkyboxRt, Up = Sky.SkyboxUp
        }
        skyboxInitialized = true
    end
    
    if VisualSettings.SkyboxEnabled then
        local Selection = Skyboxes[VisualSettings.SelectedSkybox]
        if Selection then
            Sky.SkyboxBk = Selection.Bk
            Sky.SkyboxDn = Selection.Dn
            Sky.SkyboxFt = Selection.Ft
            Sky.SkyboxLf = Selection.Lf
            Sky.SkyboxRt = Selection.Rt
            Sky.SkyboxUp = Selection.Up
        end
    else
        Sky.SkyboxBk = originalSkyData.Bk
        Sky.SkyboxDn = originalSkyData.Dn
        Sky.SkyboxFt = originalSkyData.Ft
        Sky.SkyboxLf = originalSkyData.Lf
        Sky.SkyboxRt = originalSkyData.Rt
        Sky.SkyboxUp = originalSkyData.Up
    end
end

local gui = make("ScreenGui", {
    Name = "HatchingProject",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    Parent = CoreGui
})

local function CreateTargetInfoPanel()
    local targetGui = Instance.new("ScreenGui")
    targetGui.Name = "TargetInfoPanel"
    targetGui.Parent = CoreGui
    targetGui.ResetOnSpawn = false
    targetGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    targetGui.Enabled = Settings.TargetInfo
    
    local panel = Instance.new("Frame")
    panel.Name = "MainPanel"
    panel.Size = UDim2.new(0, 280, 0, 195)
    panel.Position = UDim2.new(0, 100, 0, 100)
    panel.BackgroundColor3 = Theme.Panel
    panel.BorderSizePixel = 0
    panel.Visible = true
    panel.ZIndex = 10
    panel.Parent = targetGui
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 14)
    panelCorner.Parent = panel
    
    local panelStroke = Instance.new("UIStroke")
    panelStroke.Color = Theme.Stroke
    panelStroke.Thickness = 1
    panelStroke.Transparency = 0.55
    panelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    panelStroke.Parent = panel
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundColor3 = Theme.Panel2
    header.BorderSizePixel = 0
    header.ZIndex = 11
    header.Parent = panel
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 14)
    headerCorner.Parent = header
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(1, 0, 1, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "TARGET INFO"
    headerTitle.TextColor3 = Theme.AccentB
    headerTitle.TextSize = 13
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.ZIndex = 12
    headerTitle.Parent = header
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -36)
    content.Position = UDim2.new(0, 0, 0, 36)
    content.BackgroundTransparency = 1
    content.ZIndex = 11
    content.Parent = panel
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = content
    
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(0, 60, 0, 60)
    avatarFrame.Position = UDim2.new(0, 0, 0, 5)
    avatarFrame.BackgroundColor3 = Theme.Bg2
    avatarFrame.BorderSizePixel = 0
    avatarFrame.ZIndex = 12
    avatarFrame.Parent = content
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 12)
    avatarCorner.Parent = avatarFrame
    
    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = Theme.Stroke
    avatarStroke.Thickness = 1
    avatarStroke.Transparency = 0.65
    avatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    avatarStroke.Parent = avatarFrame
    
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "Avatar"
    avatarImg.Size = UDim2.new(1, 0, 1, 0)
    avatarImg.BackgroundColor3 = Theme.Bg
    avatarImg.BorderSizePixel = 0
    avatarImg.Image = "rbxassetid://108000429040400"
    avatarImg.ZIndex = 13
    avatarImg.Parent = avatarFrame
    
    local avatarImgCorner = Instance.new("UICorner")
    avatarImgCorner.CornerRadius = UDim.new(0, 12)
    avatarImgCorner.Parent = avatarImg
    
    local infoContainer = Instance.new("Frame")
    infoContainer.Size = UDim2.new(1, -74, 1, -5)
    infoContainer.Position = UDim2.new(0, 74, 0, 5)
    infoContainer.BackgroundTransparency = 1
    infoContainer.ZIndex = 12
    infoContainer.Parent = content
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 22)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "No Target"
    nameLabel.TextColor3 = Theme.Text
    nameLabel.TextSize = 15
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.ZIndex = 13
    nameLabel.Parent = infoContainer
    
    local teamLabel = Instance.new("TextLabel")
    teamLabel.Name = "TeamLabel"
    teamLabel.Size = UDim2.new(1, 0, 0, 18)
    teamLabel.Position = UDim2.new(0, 0, 0, 24)
    teamLabel.BackgroundTransparency = 1
    teamLabel.Text = "Team: --"
    teamLabel.TextColor3 = Theme.SubText
    teamLabel.TextSize = 12
    teamLabel.Font = Enum.Font.Gotham
    teamLabel.TextXAlignment = Enum.TextXAlignment.Left
    teamLabel.ZIndex = 13
    teamLabel.Parent = infoContainer
    
    local weaponLabel = Instance.new("TextLabel")
    weaponLabel.Name = "WeaponLabel"
    weaponLabel.Size = UDim2.new(1, 0, 0, 18)
    weaponLabel.Position = UDim2.new(0, 0, 0, 44)
    weaponLabel.BackgroundTransparency = 1
    weaponLabel.Text = "Weapon: --"
    weaponLabel.TextColor3 = Theme.SubText
    weaponLabel.TextSize = 12
    weaponLabel.Font = Enum.Font.Gotham
    weaponLabel.TextXAlignment = Enum.TextXAlignment.Left
    weaponLabel.TextTruncate = Enum.TextTruncate.AtEnd
    weaponLabel.ZIndex = 13
    weaponLabel.Parent = infoContainer
    
    local healthBarBg = Instance.new("Frame")
    healthBarBg.Size = UDim2.new(1, 0, 0, 8)
    healthBarBg.Position = UDim2.new(0, 0, 0, 72)
    healthBarBg.BackgroundColor3 = Theme.Bg
    healthBarBg.BorderSizePixel = 0
    healthBarBg.ZIndex = 13
    healthBarBg.Parent = infoContainer
    
    local healthBarBgCorner = Instance.new("UICorner")
    healthBarBgCorner.CornerRadius = UDim.new(0, 4)
    healthBarBgCorner.Parent = healthBarBg
    
    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Theme.Good
    healthBar.BorderSizePixel = 0
    healthBar.ZIndex = 14
    healthBar.Parent = healthBarBg
    
    local healthBarCorner = Instance.new("UICorner")
    healthBarCorner.CornerRadius = UDim.new(0, 4)
    healthBarCorner.Parent = healthBar
    
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "HealthLabel"
    healthLabel.Size = UDim2.new(1, 0, 0, 16)
    healthLabel.Position = UDim2.new(0, 0, 0, 82)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "-- / -- HP"
    healthLabel.TextColor3 = Theme.Good
    healthLabel.TextSize = 11
    healthLabel.Font = Enum.Font.GothamBold
    healthLabel.TextXAlignment = Enum.TextXAlignment.Right
    healthLabel.ZIndex = 13
    healthLabel.Parent = infoContainer
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0, 18)
    distanceLabel.Position = UDim2.new(0, 0, 0, 100)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "Distance: --m"
    distanceLabel.TextColor3 = Theme.AccentA
    distanceLabel.TextSize = 12
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Right
    distanceLabel.ZIndex = 13
    distanceLabel.Parent = infoContainer
    
    local dragButton = Instance.new("TextButton")
    dragButton.Size = UDim2.new(1, -60, 1, 0)
    dragButton.Position = UDim2.new(0, 0, 0, 0)
    dragButton.BackgroundTransparency = 1
    dragButton.Text = ""
    dragButton.ZIndex = 15
    dragButton.Parent = header
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 3)
    closeButton.BackgroundColor3 = Theme.Danger
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Theme.Text
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.GothamBold
    closeButton.ZIndex = 16
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        Settings.TargetInfo = false
        targetGui.Enabled = false
        SaveSettings()
    end)
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    dragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return targetGui, panel, {
        Avatar = avatarImg,
        Name = nameLabel,
        Team = teamLabel,
        Weapon = weaponLabel,
        HealthBar = healthBar,
        Health = healthLabel,
        Distance = distanceLabel
    }
end

local targetGui, targetPanel, targetElements = CreateTargetInfoPanel()

local function UpdateTargetInfo()
    if not Settings.TargetInfo then
        targetGui.Enabled = false
        return
    end
    
    targetGui.Enabled = true
    
    local target = GetTargetUnderMouse()
    
    if not target or not target.Character then
        targetElements.Name.Text = "No Target"
        targetElements.Team.Text = "Team: --"
        targetElements.Weapon.Text = "Weapon: --"
        targetElements.HealthBar.Size = UDim2.new(1, 0, 1, 0)
        targetElements.Health.Text = "-- / -- HP"
        targetElements.Distance.Text = "Distance: --m"
        return
    end
    
    local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        targetElements.Name.Text = "No Target"
        return
    end
    
    local head = GetCharacterHeadPart(target.Character)
    local distance = head and (Camera.CFrame.Position - head.Position).Magnitude or 0
    
    local displayName = target.DisplayName ~= "" and target.DisplayName or target.Name
    targetElements.Name.Text = displayName
    
    local teamName = target.Team and target.Team.Name or "None"
    targetElements.Team.Text = "Team: " .. teamName
    targetElements.Team.TextColor3 = target.Team == LocalPlayer.Team and Theme.Good or Theme.Danger
    
    targetElements.Weapon.Text = "Weapon: " .. GetWeaponName(target.Character)
    
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    targetElements.HealthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
    targetElements.HealthBar.BackgroundColor3 = Color3.fromHSV(healthPercent * 0.3, 1, 1)
    targetElements.Health.Text = math.floor(humanoid.Health) .. " / " .. math.floor(humanoid.MaxHealth) .. " HP"
    targetElements.Health.TextColor3 = Color3.fromHSV(healthPercent * 0.3, 1, 1)
    
    targetElements.Distance.Text = string.format("Distance: %.0fm", distance)
    
    if tick() - LastTargetInfoUpdate > 1 then
        LastTargetInfoUpdate = tick()
        pcall(function()
            local userId = target.UserId
            local thumbType = Enum.ThumbnailType.HeadShot
            local thumbSize = Enum.ThumbnailSize.Size420x420
            local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
            targetElements.Avatar.Image = content
        end)
    end
end

local dim = make("Frame", {
    Name = "Dim",
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.70,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    Visible = not Authorized,
    ZIndex = 5,
    Parent = gui
})

local keyModal = make("Frame", {
    Name = "KeyModal",
    BackgroundColor3 = Theme.Panel,
    BackgroundTransparency = 0.04,
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(520, 350),
    ZIndex = 20,
    Visible = not Authorized,
    Parent = gui
})
corner(keyModal, 22)
stroke(keyModal, 1, 0.45)

local keyContent = make("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 21,
    Parent = keyModal
})

make("UIPadding", {
    PaddingTop = UDim.new(0, 20),
    PaddingBottom = UDim.new(0, 20),
    PaddingLeft = UDim.new(0, 20),
    PaddingRight = UDim.new(0, 20),
    Parent = keyContent
})

local keyHeader = make("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 66),
    ZIndex = 22,
    Parent = keyContent
})

local avatar = make("ImageLabel", {
    BackgroundColor3 = Theme.Bg2,
    BorderSizePixel = 0,
    Image = "rbxassetid://108000429040400",
    Size = UDim2.fromOffset(54, 54),
    Position = UDim2.fromOffset(0, 6),
    ZIndex = 23,
    Parent = keyHeader
})
corner(avatar, 16)
stroke(avatar, 1, 0.65)

local keyTitle = make("TextLabel", {
    BackgroundTransparency = 1,
    Text = "Hatching Project",
    TextColor3 = Theme.Text,
    TextSize = 20,
    Font = Enum.Font.GothamSemibold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.fromOffset(66, 8),
    Size = UDim2.new(1, -66, 0, 24),
    Parent = keyHeader
})

local keyDesc = make("TextLabel", {
    BackgroundTransparency = 1,
    Text = "Enter access key to open the menu.",
    TextColor3 = Theme.SubText,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.fromOffset(66, 32),
    Size = UDim2.new(1, -66, 0, 20),
    Parent = keyHeader
})

local inputWrap = make("Frame", {
    BackgroundColor3 = Theme.Bg2,
    BackgroundTransparency = 0.02,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 50),
    Position = UDim2.new(0, 0, 0, 80),
    ZIndex = 22,
    Parent = keyContent
})
corner(inputWrap, 16)
stroke(inputWrap, 1, 0.65)

local keyBox = make("TextBox", {
    BackgroundTransparency = 1,
    ClearTextOnFocus = false,
    PlaceholderText = "Enter key...",
    PlaceholderColor3 = Theme.SubText,
    Text = "",
    TextColor3 = Theme.Text,
    TextSize = 16,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.fromOffset(10, 0),
    ZIndex = 23,
    Parent = inputWrap
})

local row = make("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 44),
    Position = UDim2.new(0, 0, 0, 140),
    ZIndex = 22,
    Parent = keyContent
})

local rowLayout = make("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = row
})

local btnCloseKey = make("TextButton", {
    BackgroundColor3 = Theme.Bg2,
    BackgroundTransparency = 0.02,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Size = UDim2.fromOffset(140, 44),
    Text = "Close",
    TextColor3 = Theme.Text,
    TextSize = 15,
    Font = Enum.Font.GothamSemibold,
    ZIndex = 50,
    Parent = row
})
corner(btnCloseKey, 14)
stroke(btnCloseKey, 1, 0.65)

local btnUnlock = make("TextButton", {
    BackgroundColor3 = Theme.AccentA,
    BackgroundTransparency = 0.02,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Size = UDim2.fromOffset(140, 44),
    Text = "Unlock",
    TextColor3 = Theme.Text,
    TextSize = 15,
    Font = Enum.Font.GothamSemibold,
    ZIndex = 50,
    Parent = row
})
corner(btnUnlock, 14)
stroke(btnUnlock, 1, 0.22)

local err = make("TextLabel", {
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = Theme.Danger,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    Position = UDim2.new(0, 0, 0, 210),
    Size = UDim2.new(1, 0, 0, 18),
    Parent = keyContent
})

local main = make("Frame", {
    Name = "MainMenu",
    BackgroundColor3 = Theme.Panel,
    BackgroundTransparency = 0.04,
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.54),
    Size = UDim2.fromOffset(820, 470),
    Visible = Authorized,
    ZIndex = 10,
    Parent = gui
})
corner(main, 22)
stroke(main, 1, 0.45)

local TOP_H = 72
local top = make("Frame", {
    Name = "Top",
    BackgroundColor3 = Theme.Panel2,
    BackgroundTransparency = 0.03,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, TOP_H),
    ZIndex = 11,
    Parent = main
})
corner(top, 22)
make("UIPadding", {PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = top})

local brand = make("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -360, 1, 0),
    ZIndex = 12,
    Parent = top
})

local brandImg = make("ImageLabel", {
    BackgroundColor3 = Theme.Bg2,
    BorderSizePixel = 0,
    Image = "rbxassetid://108000429040400",
    Size = UDim2.fromOffset(42, 42),
    Position = UDim2.fromOffset(0, 15),
    ZIndex = 13,
    Parent = brand
})
corner(brandImg, 14)
stroke(brandImg, 1, 0.65)

local bTitle = make("TextLabel", {
    BackgroundTransparency = 1,
    Text = "Hatching Project",
    TextColor3 = Theme.Text,
    TextSize = 18,
    Font = Enum.Font.GothamSemibold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.fromOffset(54, 12),
    Size = UDim2.new(1, -54, 0, 24),
    Parent = brand
})

local bSub = make("TextLabel", {
    BackgroundTransparency = 1,
    Text = "aim - esp - visuals - misc",
    TextColor3 = Theme.SubText,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.fromOffset(54, 38),
    Size = UDim2.new(1, -54, 0, 18),
    Parent = brand
})

local minimizeBtn = make("TextButton", {
    BackgroundColor3 = Theme.Bg2,
    BackgroundTransparency = 0.02,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Size = UDim2.fromOffset(44, 44),
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -68, 0.5, 0),
    Text = "-",
    TextColor3 = Theme.Text,
    TextSize = 24,
    Font = Enum.Font.GothamSemibold,
    ZIndex = 12,
    Parent = top
})
corner(minimizeBtn, 14)
stroke(minimizeBtn, 1, 0.65)

local searchWrap = make("Frame", {
    BackgroundColor3 = Theme.Bg2,
    BackgroundTransparency = 0.02,
    BorderSizePixel = 0,
    Size = UDim2.fromOffset(260, 44),
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -122, 0.5, 0),
    ZIndex = 12,
    Parent = top
})
corner(searchWrap, 14)
stroke(searchWrap, 1, 0.65)

local searchIcon = make("TextLabel", {
    BackgroundTransparency = 1,
    Text = "S",
    TextColor3 = Theme.SubText,
    TextSize = 16,
    Font = Enum.Font.GothamSemibold,
    Size = UDim2.fromOffset(28, 44),
    Position = UDim2.fromOffset(10, 0),
    Parent = searchWrap
})

local searchBox = make("TextBox", {
    BackgroundTransparency = 1,
    ClearTextOnFocus = false,
    PlaceholderText = "Search options...",
    PlaceholderColor3 = Theme.SubText,
    Text = "",
    TextColor3 = Theme.Text,
    TextSize = 14,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, -46, 1, 0),
    Position = UDim2.fromOffset(36, 0),
    ZIndex = 13,
    Parent = searchWrap
})

local closeBtn = make("TextButton", {
    BackgroundColor3 = Theme.Bg2,
    BackgroundTransparency = 0.02,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Size = UDim2.fromOffset(44, 44),
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -14, 0.5, 0),
    Text = "X",
    TextColor3 = Theme.Text,
    TextSize = 18,
    Font = Enum.Font.GothamSemibold,
    ZIndex = 12,
    Parent = top
})
corner(closeBtn, 14)
stroke(closeBtn, 1, 0.65)

local body = make("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, TOP_H),
    Size = UDim2.new(1, 0, 1, -TOP_H),
    ZIndex = 11,
    Parent = main
})

local bodyPad = make("UIPadding", {
    PaddingTop = UDim.new(0, 14),
    PaddingBottom = UDim.new(0, 22),
    PaddingLeft = UDim.new(0, 14),
    PaddingRight = UDim.new(0, 22),
    Parent = body
})

local RAIL_W = 220
local GAP = 14

local rail = make("Frame", {
    BackgroundColor3 = Theme.Bg2,
    BackgroundTransparency = 0.02,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(0, RAIL_W, 1, 0),
    ZIndex = 12,
    Parent = body
})
corner(rail, 18)
stroke(rail, 1, 0.65)
make("UIPadding", {PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = rail})

local railTitle = make("TextLabel", {
    BackgroundTransparency = 1,
    Text = "Tabs",
    TextColor3 = Theme.Text,
    TextSize = 16,
    Font = Enum.Font.GothamSemibold,
    Size = UDim2.new(1, 0, 0, 22),
    Parent = rail
})

local tabList = make("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 10),
    Parent = rail
})

local pagesWrap = make("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, RAIL_W + GAP, 0, 0),
    Size = UDim2.new(1, -(RAIL_W + GAP), 1, 0),
    ZIndex = 12,
    Parent = body
})

local pageHolder = make("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 12,
    Parent = pagesWrap
})

local resizer = make("Frame", {
    BackgroundColor3 = Theme.Bg2,
    BackgroundTransparency = 0.02,
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -10, 1, -10),
    Size = UDim2.fromOffset(18, 18),
    ZIndex = 30,
    Parent = main
})
corner(resizer, 7)
stroke(resizer, 1, 0.75)
make("TextLabel", {
    BackgroundTransparency = 1,
    Text = "R",
    TextColor3 = Theme.SubText,
    TextSize = 14,
    Font = Enum.Font.Gotham,
    Size = UDim2.fromScale(1, 1),
    Parent = resizer
})

local Registry = {}
local function registerWidget(frame, pageRef, id, titleText, descText)
    table.insert(Registry, {Frame=frame, Page=pageRef, Id=id or "", Title=titleText or "", Desc=descText or ""})
end

local function makeCard(parent, titleText, descText, h)
    local c = make("Frame", {
        BackgroundColor3 = Theme.Bg2,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, h or 86),
        ZIndex = 12,
        Parent = parent
    })
    corner(c, 18)
    stroke(c, 1, 0.75)
    make("UIPadding", {PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = c})
    local t = make("TextLabel", {
        BackgroundTransparency = 1,
        Text = titleText,
        TextColor3 = Theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -150, 0, 22),
        Parent = c
    })
    local d = make("TextLabel", {
        BackgroundTransparency = 1,
        Text = descText or "",
        TextColor3 = Theme.SubText,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -150, 0, 20),
        Position = UDim2.new(0, 0, 0, 24),
        Parent = c
    })
    return c, t, d
end

local function createToggle(parent, pageRef, id, titleText, descText, defaultValue, callback)
    local c = makeCard(parent, titleText, descText, 86)
    local value = defaultValue and true or false
    local track = make("Frame", {
        BackgroundColor3 = value and Theme.Good or Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(56, 30),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        ZIndex = 14,
        Parent = c
    })
    corner(track, 999)
    stroke(track, 1, 0.75)
    local knob = make("Frame", {
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.new(0, value and 30 or 3, 0.5, -12),
        ZIndex = 15,
        Parent = track
    })
    corner(knob, 999)
    local btn = make("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.fromScale(1, 1),
        ZIndex = 16,
        Parent = track
    })
    local function set(v)
        value = v
        track.BackgroundColor3 = value and Theme.Good or Theme.Panel
        knob.Position = UDim2.new(0, value and 30 or 3, 0.5, -12)
        if callback then callback(value) end
    end
    btn.MouseButton1Click:Connect(function() set(not value) end)
    registerWidget(c, pageRef, id, titleText, descText)
    return {Get=function() return value end, Set=set}
end

local function createSlider(parent, pageRef, id, titleText, descText, minV, maxV, defaultV, callback, valueFormat)
    local c = make("Frame", {
        BackgroundColor3 = Theme.Bg2,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 108),
        ZIndex = 12,
        Parent = parent
    })
    corner(c, 18)
    stroke(c, 1, 0.75)
    make("UIPadding", {PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = c})
    
    local t = make("TextLabel", {
        BackgroundTransparency = 1,
        Text = titleText,
        TextColor3 = Theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -80, 0, 22),
        Parent = c
    })
    
    local d = make("TextLabel", {
        BackgroundTransparency = 1,
        Text = descText or "",
        TextColor3 = Theme.SubText,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -80, 0, 20),
        Position = UDim2.new(0, 0, 0, 24),
        Parent = c
    })
    
    local valueBox = make("TextBox", {
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 60, 0, 22),
        Position = UDim2.new(1, -60, 0, 0),
        Text = valueFormat and valueFormat(defaultV) or string.format("%.1f", defaultV),
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        ZIndex = 13,
        Parent = c
    })
    corner(valueBox, 6)
    stroke(valueBox, 1, 0.75)
    
    local bar = make("Frame", {
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -24),
        ZIndex = 13,
        Parent = c
    })
    corner(bar, 999)
    stroke(bar, 1, 0.85)
    
    local fill = make("Frame", {
        BackgroundColor3 = Theme.AccentA,
        BorderSizePixel = 0,
        Size = UDim2.new((defaultV - minV) / (maxV - minV), 0, 1, 0),
        ZIndex = 14,
        Parent = bar
    })
    corner(fill, 999)
    
    local knob = make("Frame", {
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(18, 18),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((defaultV - minV) / (maxV - minV), 0, 0.5, 0),
        ZIndex = 15,
        Parent = bar
    })
    corner(knob, 999)
    
    local dragging = false
    local value = defaultV
    
    local function clamp(x, a, b)
        return math.max(a, math.min(b, x))
    end
    
    local function setValue(v)
        value = clamp(v, minV, maxV)
        local alpha = (value - minV) / (maxV - minV)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueBox.Text = valueFormat and valueFormat(value) or string.format("%.1f", value)
        if callback then callback(value) end
    end
    
    local function updateFromMouse(x)
        local absPos = bar.AbsolutePosition.X
        local absSize = bar.AbsoluteSize.X
        local alpha = clamp((x - absPos) / absSize, 0, 1)
        setValue(minV + alpha * (maxV - minV))
    end
    
    bar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromMouse(inp.Position.X)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromMouse(inp.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            SaveSettings()
        end
    end)
    
    valueBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local num = tonumber(valueBox.Text)
            if num then
                setValue(num)
            else
                valueBox.Text = valueFormat and valueFormat(value) or string.format("%.1f", value)
            end
        end
    end)
    
    registerWidget(c, pageRef, id, titleText, descText)
    return {Get=function() return value end, Set=setValue}
end

local function createDropdown(parent, pageRef, id, titleText, descText, options, defaultOption, callback)
    local c = make("Frame", {
        BackgroundColor3 = Theme.Bg2,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 86),
        ZIndex = 12,
        Parent = parent
    })
    corner(c, 18)
    stroke(c, 1, 0.75)
    make("UIPadding", {PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = c})
    
    local t = make("TextLabel", {
        BackgroundTransparency = 1,
        Text = titleText,
        TextColor3 = Theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -150, 0, 22),
        Parent = c
    })
    
    local d = make("TextLabel", {
        BackgroundTransparency = 1,
        Text = descText or "",
        TextColor3 = Theme.SubText,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -150, 0, 20),
        Position = UDim2.new(0, 0, 0, 24),
        Parent = c
    })
    
    local dropdownBtn = make("TextButton", {
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(140, 30),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Text = defaultOption or "None",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        ZIndex = 14,
        Parent = c
    })
    corner(dropdownBtn, 8)
    stroke(dropdownBtn, 1, 0.75)
    
    local dropdownOpen = false
    
    local dropdownOptions = make("Frame", {
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(140, 0),
        Position = UDim2.new(1, -154, 0, 40),
        Visible = false,
        ZIndex = 1000,
        Parent = gui
    })
    corner(dropdownOptions, 8)
    stroke(dropdownOptions, 1, 0.75)
    
    local optionsScrolling = make("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.AccentA,
        ZIndex = 1001,
        Parent = dropdownOptions
    })
    
    local optionsLayout = make("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = optionsScrolling
    })
    
    local function rebuildOptions()
        for _, child in ipairs(optionsScrolling:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        local currentOptions = options
        if type(options) == "function" then
            currentOptions = options()
        end
        
        if #currentOptions == 0 then
            currentOptions = {"None"}
        end
        
        for _, option in ipairs(currentOptions) do
            local btn = make("TextButton", {
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -4, 0, 28),
                Position = UDim2.new(0, 2, 0, 0),
                Text = option,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                ZIndex = 1002,
                Parent = optionsScrolling
            })
            corner(btn, 6)
            btn.MouseButton1Click:Connect(function()
                dropdownBtn.Text = option
                dropdownOpen = false
                dropdownOptions.Visible = false
                if callback then callback(option) end
                SaveSettings()
            end)
        end
        
        optionsScrolling.CanvasSize = UDim2.new(0, 0, 0, #currentOptions * 30 + 4)
    end
    
    dropdownBtn.MouseButton1Click:Connect(function()
        if dropdownOpen then
            dropdownOpen = false
            dropdownOptions.Visible = false
        else
            rebuildOptions()
            local btnPos = dropdownBtn.AbsolutePosition
            local btnSize = dropdownBtn.AbsoluteSize
            dropdownOptions.Position = UDim2.fromOffset(btnPos.X + btnSize.X - 140, btnPos.Y + btnSize.Y + 5)
            local optionCount = #(type(options) == "function" and options() or options)
            dropdownOptions.Size = UDim2.fromOffset(140, math.min(optionCount * 30, 150))
            dropdownOpen = true
            dropdownOptions.Visible = true
        end
    end)
    
    local function onInputBegan(input)
        if dropdownOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = Vector2.new(input.Position.X, input.Position.Y)
            local absPos = dropdownOptions.AbsolutePosition
            local absSize = dropdownOptions.AbsoluteSize
            if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or
               mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
                dropdownOpen = false
                dropdownOptions.Visible = false
            end
        end
    end
    
    UserInputService.InputBegan:Connect(onInputBegan)
    
    registerWidget(c, pageRef, id, titleText, descText)
    return {Get=function() return dropdownBtn.Text end, Set=function(v) dropdownBtn.Text = v end}
end

local function createKeybind(parent, pageRef, id, titleText, descText, defaultKey, callback)
    local c = make("Frame", {
        BackgroundColor3 = Theme.Bg2,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 86),
        ZIndex = 12,
        Parent = parent
    })
    corner(c, 18)
    stroke(c, 1, 0.75)
    make("UIPadding", {PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = c})
    
    local t = make("TextLabel", {
        BackgroundTransparency = 1,
        Text = titleText,
        TextColor3 = Theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -150, 0, 22),
        Parent = c
    })
    
    local d = make("TextLabel", {
        BackgroundTransparency = 1,
        Text = descText or "",
        TextColor3 = Theme.SubText,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -150, 0, 20),
        Position = UDim2.new(0, 0, 0, 24),
        Parent = c
    })
    
    local bindBtn = make("TextButton", {
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(120, 30),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Text = tostring(defaultKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", ""),
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ZIndex = 14,
        Parent = c
    })
    corner(bindBtn, 8)
    stroke(bindBtn, 1, 0.75)
    
    local listening = false
    
    bindBtn.MouseButton1Click:Connect(function()
        listening = true
        bindBtn.Text = "..."
    end)
    
    local connection = UserInputService.InputBegan:Connect(function(input)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                bindBtn.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                if callback then callback(input.KeyCode) end
                SaveSettings()
                connection:Disconnect()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                input.UserInputType == Enum.UserInputType.MouseButton2 or 
                input.UserInputType == Enum.UserInputType.MouseButton3 then
                listening = false
                bindBtn.Text = tostring(input.UserInputType):gsub("Enum.UserInputType.", "")
                if callback then callback(input.UserInputType) end
                SaveSettings()
                connection:Disconnect()
            end
        end
    end)
    
    registerWidget(c, pageRef, id, titleText, descText)
    return bindBtn
end

local TabData = {}
local CurrentTab

local function createPage(name)
    local p = make("ScrollingFrame", {
        Name = name,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        ScrollBarImageTransparency = 0.60,
        ZIndex = 12,
        Visible = false,
        Parent = pageHolder
    })
    local layout = make("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
        Parent = p
    })
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        p.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 18)
    end)
    return p
end

local function createTab(name, iconText)
    local btn = make("TextButton", {
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 46),
        Text = "",
        ZIndex = 13,
        Parent = rail
    })
    corner(btn, 14)
    stroke(btn, 1, 0.75)
    
    local pill = make("Frame", {
        BackgroundColor3 = Theme.AccentB,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(4, 26),
        Position = UDim2.fromOffset(10, 10),
        ZIndex = 14,
        Visible = false,
        Parent = btn
    })
    corner(pill, 8)
    
    local ico = make("TextLabel", {
        BackgroundTransparency = 1,
        Text = iconText,
        TextColor3 = Theme.SubText,
        TextSize = 16,
        Font = Enum.Font.GothamSemibold,
        Size = UDim2.fromOffset(28, 46),
        Position = UDim2.fromOffset(22, 0),
        Parent = btn
    })
    
    local txt = make("TextLabel", {
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -64, 1, 0),
        Position = UDim2.fromOffset(56, 0),
        Parent = btn
    })
    
    local page = createPage(name)
    
    local function setActive(active)
        pill.Visible = active
        if active then
            btn.BackgroundColor3 = Theme.Panel2
            ico.TextColor3 = Theme.AccentB
        else
            btn.BackgroundColor3 = Theme.Panel
            ico.TextColor3 = Theme.SubText
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        for _, obj in pairs(TabData) do
            obj.Page.Visible = false
            obj.SetActive(false)
        end
        page.Visible = true
        setActive(true)
        CurrentTab = name
        searchBox.Text = ""
    end)
    
    TabData[name] = {Button=btn, Page=page, SetActive=setActive}
    return page
end

local pageA = createTab("Aimbot", "A")
local pageB = createTab("Visual", "V")
local pageC = createTab("Misc", "M")
local pageD = createTab("Settings", "S")

createToggle(pageA, pageA, "aim_enabled", "Aimbot Enabled", "Master switch for aimbot", Settings.Enabled, function(v) Settings.Enabled = v; SaveSettings() end)
createDropdown(pageA, pageA, "aim_mode", "Aimbot Mode", "Strong / Light / Flick / Humanized / Rivals", 
    {"Strong", "Light", "Flick", "Humanized", "Rivals"}, Settings.AimbotMode, function(v) Settings.AimbotMode = v; SaveSettings() end)
createDropdown(pageA, pageA, "aim_target", "Target Part", "Head / Root / Torso / Random / Nearest", 
    {"Head", "HumanoidRootPart", "UpperTorso", "Random", "Nearest"}, Settings.TargetPart, function(v) Settings.TargetPart = v; SaveSettings() end)
createSlider(pageA, pageA, "aim_fov", "FOV", "Field of view radius (pixels)", 10, 500, Settings.FOV, function(v) Settings.FOV = v; SaveSettings() end, function(v) return string.format("%.0f", v) end)
createSlider(pageA, pageA, "rivals_fov", "Rivals FOV", "FOV for Rivals mode", 10, 500, Settings.RivalsFOV, function(v) Settings.RivalsFOV = v; SaveSettings() end, function(v) return string.format("%.0f", v) end)
createSlider(pageA, pageA, "aim_smooth", "Smoothness", "Aim smoothness (0.1-1.0)", 0.1, 1, Settings.Smoothness, function(v) Settings.Smoothness = v; SaveSettings() end, function(v) return string.format("%.2f", v) end)
createSlider(pageA, pageA, "rivals_smoothness", "Rivals Smoothness", "Mouse smoothness for Rivals", 0.1, 1, Settings.RivalsSmoothness, function(v) Settings.RivalsSmoothness = v; SaveSettings() end, function(v) return string.format("%.2f", v) end)
createToggle(pageA, pageA, "aim_teamcheck", "Team Check", "Don't aim at teammates", Settings.TeamCheck, function(v) Settings.TeamCheck = v; SaveSettings() end)
createToggle(pageA, pageA, "aim_friends", "Ignore Friends", "Don't aim at friends", Settings.IgnoreFriends, function(v) Settings.IgnoreFriends = v; SaveSettings() end)
createToggle(pageA, pageA, "aim_knocked", "Ignore Knocked", "Skip knocked players", Settings.IgnoreKnocked, function(v) Settings.IgnoreKnocked = v; SaveSettings() end)
createToggle(pageA, pageA, "aim_ignore_ff", "Ignore Force Field", "Don't aim at players with force field/shield", Settings.IgnoreFF, function(v) Settings.IgnoreFF = v; SaveSettings() end)
createToggle(pageA, pageA, "aim_autoaim", "Auto Aim", "Aim automatically when key held", Settings.AutoAim, function(v) Settings.AutoAim = v; SaveSettings() end)
createKeybind(pageA, pageA, "aim_autoaim_key", "Auto Aim Key", "Key for auto aim", Settings.AutoAimKeybind, function(v) Settings.AutoAimKeybind = v; SaveSettings() end)
createToggle(pageA, pageA, "aim_prediction", "Prediction", "Predict target movement", Settings.Prediction, function(v) Settings.Prediction = v; SaveSettings() end)
createSlider(pageA, pageA, "aim_prediction_amount", "Prediction Amount", "How much to predict", 0.05, 0.5, Settings.PredictionAmount, function(v) Settings.PredictionAmount = v; SaveSettings() end, function(v) return string.format("%.2f", v) end)
createToggle(pageA, pageA, "aim_wallcheck", "Wall Check", "Check for walls", Settings.WallCheck, function(v) Settings.WallCheck = v; SaveSettings() end)
createToggle(pageA, pageA, "aim_visible", "Visible Check", "Only aim at visible players", Settings.VisibleCheck, function(v) Settings.VisibleCheck = v; SaveSettings() end)
createToggle(pageA, pageA, "aim_trigger", "Trigger Bot", "Auto shoot when on target", Settings.TriggerBot, function(v) Settings.TriggerBot = v; SaveSettings() end)
createSlider(pageA, pageA, "aim_trigger_delay", "Trigger Delay", "Delay before shooting (s)", 0, 0.5, Settings.TriggerBotDelay, function(v) Settings.TriggerBotDelay = v; SaveSettings() end, function(v) return string.format("%.2f", v) end)
createToggle(pageA, pageA, "aim_autokill", "Auto Kill", "Auto shoot when in FOV", Settings.AutoKill, function(v) Settings.AutoKill = v; SaveSettings() end)
createSlider(pageA, pageA, "aim_autokill_delay", "Auto Kill Delay", "Delay for auto kill (s)", 0, 0.2, Settings.AutoKillDelay, function(v) Settings.AutoKillDelay = v; SaveSettings() end, function(v) return string.format("%.2f", v) end)
createToggle(pageA, pageA, "aim_target_info", "Target Info", "Show target info panel", Settings.TargetInfo, function(v) Settings.TargetInfo = v; targetGui.Enabled = v; SaveSettings() end)
createToggle(pageA, pageA, "aim_bigheads", "Big Heads", "Make enemy heads bigger", Settings.BigHeadsEnabled, function(v) Settings.BigHeadsEnabled = v; SaveSettings() end)
createSlider(pageA, pageA, "aim_headsize", "Head Size", "Size of enemy heads", 1, 5, Settings.HeadSize, function(v) Settings.HeadSize = v; SaveSettings() end, function(v) return string.format("%.1f", v) end)

createToggle(pageB, pageB, "esp_enabled", "ESP Enabled", "Show player info overlay", ESPSettings.Enabled, function(v) ESPSettings.Enabled = v; SaveSettings() end)
createToggle(pageB, pageB, "esp_boxesp", "Box ESP", "Show box around players", ESPSettings.BoxESP, function(v) ESPSettings.BoxESP = v; SaveSettings() end)
createDropdown(pageB, pageB, "esp_box_color", "Box Color", "RGB / Red / Green / Blue / Yellow / Purple / White / Cyan / Orange / Pink", 
    {"RGB", "Red", "Green", "Blue", "Yellow", "Purple", "White", "Cyan", "Orange", "Pink"}, ESPSettings.BoxColor, function(v) ESPSettings.BoxColor = v; SaveSettings() end)
createToggle(pageB, pageB, "esp_teamcheck", "Team Check", "Show/hide teammates", ESPSettings.TeamCheck, function(v) ESPSettings.TeamCheck = v; SaveSettings() end)
createToggle(pageB, pageB, "esp_alivecheck", "Alive Check", "Only show alive players", ESPSettings.AliveCheck, function(v) ESPSettings.AliveCheck = v; SaveSettings() end)
createToggle(pageB, pageB, "esp_name", "Display Name", "Show player names", ESPSettings.DisplayName, function(v) ESPSettings.DisplayName = v; SaveSettings() end)
createToggle(pageB, pageB, "esp_health", "Display Health", "Show health values", ESPSettings.DisplayHealth, function(v) ESPSettings.DisplayHealth = v; SaveSettings() end)
createToggle(pageB, pageB, "esp_distance", "Display Distance", "Show distance to player", ESPSettings.DisplayDistance, function(v) ESPSettings.DisplayDistance = v; SaveSettings() end)
createToggle(pageB, pageB, "esp_weapon", "Display Weapon", "Show weapon name", ESPSettings.WeaponESP, function(v) ESPSettings.WeaponESP = v; SaveSettings() end)
createDropdown(pageB, pageB, "esp_healthmode", "Health Display", "Numbers / Bar / Both", 
    {"Numbers", "Bar", "Both"}, ESPSettings.HealthDisplayMode, function(v) ESPSettings.HealthDisplayMode = v; SaveSettings() end)
createToggle(pageB, pageB, "esp_tracers", "Tracers", "Draw lines to players", ESPSettings.Tracers, function(v) ESPSettings.Tracers = v; SaveSettings() end)
createDropdown(pageB, pageB, "esp_tracer_origin", "Tracer Origin", "Where tracers start from", 
    {"Bottom", "Middle", "Top", "Mouse", "Crosshair"}, ESPSettings.TracerOrigin, function(v) ESPSettings.TracerOrigin = v; SaveSettings() end)
createToggle(pageB, pageB, "esp_chams", "Chams", "See players through walls", ESPSettings.Chams, function(v) ESPSettings.Chams = v; SaveSettings() end)
createToggle(pageB, pageB, "esp_glow_chams", "Glow Chams", "Red glow around players", ESPSettings.GlowChams, function(v) ESPSettings.GlowChams = v; SaveSettings() end)
createToggle(pageB, pageB, "esp_arrows", "Off-screen Arrows", "Arrows pointing to off-screen players", ESPSettings.OutOfViewArrows, function(v) ESPSettings.OutOfViewArrows = v; SaveSettings() end)
createSlider(pageB, pageB, "esp_textsize", "Text Size", "Size of ESP text", 8, 20, ESPSettings.TextSize, function(v) ESPSettings.TextSize = v; SaveSettings() end, function(v) return string.format("%.0f", v) end)
createSlider(pageB, pageB, "esp_maxdist", "Max Distance", "Maximum ESP render distance", 100, 5000, ESPSettings.MaxDistance, function(v) ESPSettings.MaxDistance = v; SaveSettings() end, function(v) return string.format("%.0f", v) end)
createToggle(pageB, pageB, "visual_skybox", "Enable Skybox", "Change the sky", VisualSettings.SkyboxEnabled, function(v) VisualSettings.SkyboxEnabled = v; updateSkybox(); SaveSettings() end)
createDropdown(pageB, pageB, "visual_skybox_select", "Select Skybox", "Purple Nebula / Minecraft / Night Sky / SpongeBob Sky / Purple Sky / Pink Sky", 
    {"Purple Nebula", "Minecraft", "Night Sky", "SpongeBob Sky", "Purple Sky", "Pink Sky"}, VisualSettings.SelectedSkybox, function(v) VisualSettings.SelectedSkybox = v; if VisualSettings.SkyboxEnabled then updateSkybox() end; SaveSettings() end)

createToggle(pageC, pageC, "misc_antiafk", "Anti AFK", "Prevent being kicked for AFK", MiscSettings.AntiAFK, function(v) MiscSettings.AntiAFK = v; SaveSettings() end)
createToggle(pageC, pageC, "misc_speed", "Speed Hack", "Increase walk speed", MiscSettings.SpeedHack, function(v) MiscSettings.SpeedHack = v; SaveSettings() end)
createSlider(pageC, pageC, "misc_speed_mult", "Speed Multiplier", "How fast to walk", 1, 30, MiscSettings.SpeedMultiplier, function(v) MiscSettings.SpeedMultiplier = v; SaveSettings() end, function(v) return string.format("%.1f", v) end)
createToggle(pageC, pageC, "misc_jump", "Jump Power", "Increase jump height", MiscSettings.JumpPower, function(v) MiscSettings.JumpPower = v; SaveSettings() end)
createSlider(pageC, pageC, "misc_jump_mult", "Jump Multiplier", "How high to jump", 1, 10, MiscSettings.JumpMultiplier, function(v) MiscSettings.JumpMultiplier = v; SaveSettings() end, function(v) return string.format("%.1f", v) end)
createToggle(pageC, pageC, "misc_noclip", "Noclip", "Walk through walls", MiscSettings.Noclip, function(v) MiscSettings.Noclip = v; SaveSettings() end)
createToggle(pageC, pageC, "misc_infjump", "Infinite Jump", "Jump in mid-air", MiscSettings.InfJump, function(v) MiscSettings.InfJump = v; SaveSettings() end)
createToggle(pageC, pageC, "misc_autoreload", "Auto Reload", "Automatically reload weapons", MiscSettings.AutoReload, function(v) MiscSettings.AutoReload = v; SaveSettings() end)
createToggle(pageC, pageC, "misc_autorespawn", "Auto Respawn", "Respawn automatically when killed", MiscSettings.AutoRespawn, function(v) MiscSettings.AutoRespawn = v; SaveSettings() end)
createToggle(pageC, pageC, "misc_spinbot", "Spinbot", "Constantly spin your character", MiscSettings.SpinBot, function(v) MiscSettings.SpinBot = v; SaveSettings() end)
createSlider(pageC, pageC, "misc_spinspeed", "Spin Speed", "How fast to spin", 1, 20, MiscSettings.SpinSpeed, function(v) MiscSettings.SpinSpeed = v; SaveSettings() end, function(v) return string.format("%.0f", v) end)
createToggle(pageC, pageC, "misc_antiaim", "Anti Aim", "Avoid being aimed at", MiscSettings.AntiAim, function(v) MiscSettings.AntiAim = v; SaveSettings() end)
createDropdown(pageC, pageC, "misc_antiaim_type", "Anti Aim Type", "Jitter / Spin / Backwards / Random", 
    {"Jitter", "Spin", "Backwards", "Random"}, MiscSettings.AntiAimType, function(v) MiscSettings.AntiAimType = v; SaveSettings() end)
createToggle(pageC, pageC, "misc_teleport_enabled", "Teleport Enabled", "Enable teleport to player", Settings.TeleportEnabled, function(v) Settings.TeleportEnabled = v; SaveSettings() end)
createDropdown(pageC, pageC, "misc_teleport_mode", "Teleport Mode", "To Player / Above Head", 
    {"To Player", "Above Head"}, Settings.TeleportMode, function(v) Settings.TeleportMode = v; SaveSettings() end)

local teleportDropdown = nil
local function getPlayerNames()
    local names = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    if #names == 0 then table.insert(names, "None") end
    return names
end

teleportDropdown = createDropdown(pageC, pageC, "misc_teleport_target", "Teleport Target", "Select player to teleport to", 
    getPlayerNames, nil, function(v) Settings.TeleportTarget = v; SaveSettings() end)

createToggle(pageD, pageD, "settings_save_config", "Save Config", "Save settings to file", MiscSettings.SaveConfig, function(v) MiscSettings.SaveConfig = v; SaveSettings() end)
createKeybind(pageD, pageD, "settings_aim_key", "Aim Key", "Key to activate aimbot (hold)", Settings.Keybind, function(v) Settings.Keybind = v; SaveSettings() end)
createKeybind(pageD, pageD, "settings_menu_key", "Menu Key", "Key to open/close menu", Enum.KeyCode.P, function(v) end)
createToggle(pageD, pageD, "settings_showfov", "Show FOV", "Display FOV circle on screen", Settings.ShowFOV, function(v) Settings.ShowFOV = v; SaveSettings() end)
createSlider(pageD, pageD, "settings_fov_trans", "FOV Transparency", "Transparency of FOV circle", 0, 1, Settings.FOVTransparency, function(v) Settings.FOVTransparency = v; SaveSettings() end, function(v) return string.format("%.2f", v) end)
createDropdown(pageD, pageD, "settings_fov_color", "FOV Color", "Color of FOV circle", 
    {"RGB", "Red", "Green", "Blue", "Yellow", "Purple", "White"}, Settings.FOVColor, function(v) Settings.FOVColor = v; SaveSettings() end)
createToggle(pageD, pageD, "settings_optimization", "Optimization Mode", "Disable shadows, particles and effects", VisualSettings.OptimizationMode, function(v) VisualSettings.OptimizationMode = v; ApplyOptimization(); SaveSettings() end)

TabData["Aimbot"].Page.Visible = true
TabData["Aimbot"].SetActive(true)
CurrentTab = "Aimbot"

local function normalize(s)
    return (s or ""):lower():gsub("%s+", " ")
end

local function applySearch()
    local q = normalize(searchBox.Text)
    local page = CurrentTab and TabData[CurrentTab] and TabData[CurrentTab].Page
    if not page then return end
    for _, item in ipairs(Registry) do
        if item.Page == page then
            if q == "" then
                item.Frame.Visible = true
            else
                local hay = normalize(item.Id .. " " .. item.Title .. " " .. item.Desc)
                item.Frame.Visible = (hay:find(q, 1, true) ~= nil)
            end
        end
    end
end
searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

do
    local dragging=false
    local dragStart, startPos
    top.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=inp.Position; startPos=main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
    end)
end

local MIN_SIZE = Vector2.new(680, 410)
local function getScreenMax()
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
    return Vector2.new(math.max(MIN_SIZE.X, vp.X - 60), math.max(MIN_SIZE.Y, vp.Y - 120))
end

local function snapEven(n)
    return math.floor((n + 1) / 2) * 2
end

local function applySizeSmooth(w,h)
    local max = getScreenMax()
    w = snapEven(math.clamp(w, MIN_SIZE.X, max.X))
    h = snapEven(math.clamp(h, MIN_SIZE.Y, max.Y))
    TweenService:Create(main, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(w,h)
    }):Play()
end

do
    local resizing=false
    local startMouse, startSize
    resizer.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing=true; startMouse=inp.Position; startSize=main.Size
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if resizing and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - startMouse
            applySizeSmooth(startSize.X.Offset + d.X, startSize.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then resizing=false end
    end)
end

local function tween(obj, time, props)
    local tw = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function showMain()
    tween(dim, 0.15, {BackgroundTransparency = 1})
    tween(keyModal, 0.15, {BackgroundTransparency = 1})
    task.delay(0.16, function()
        dim.Visible = false
        keyModal.Visible = false
    end)
    main.Visible = true
    main.BackgroundTransparency = 1
    tween(main, 0.18, {BackgroundTransparency = 0.04})
    
    task.delay(0.5, function()
        if VisualSettings.SkyboxEnabled then
            updateSkybox()
        end
    end)
end

local function showKey()
    main.Visible = false
    dim.Visible = true
    keyModal.Visible = true
    err.Text = ""
    keyBox.Text = ""
end

local function shake()
    local base = keyModal.Position
    keyModal.Position = base + UDim2.fromOffset(6, 0)
    task.delay(0.07, function() keyModal.Position = base - UDim2.fromOffset(6, 0) end)
    task.delay(0.14, function() keyModal.Position = base end)
end

local function tryUnlock()
    local typed = (keyBox.Text or ""):gsub("%s+", ""):lower()
    if typed == AuthKey then
        Authorized = true
        SaveSettings()
        showMain()
    else
        err.Text = "Invalid key. Try again."
        shake()
    end
end

btnUnlock.MouseButton1Click:Connect(tryUnlock)
keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then tryUnlock() end
end)

btnCloseKey.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)

local isMinimized = false
local originalSize = main.Size
local minimizedSize = UDim2.fromOffset(820, TOP_H)

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        tween(main, 0.2, {Size = minimizedSize})
        minimizeBtn.Text = "+"
        body.Visible = false
    else
        tween(main, 0.2, {Size = originalSize})
        minimizeBtn.Text = "-"
        body.Visible = true
    end
end)

closeBtn.MouseButton1Click:Connect(showKey)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.P then
        if main.Visible then
            main.Visible = false
            dim.Visible = true
        else
            main.Visible = true
            dim.Visible = false
        end
    end
end)

local function UpdateFOVCircle()
    if not FOVCircle then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 2
        FOVCircle.NumSides = 100
        FOVCircle.Filled = false
    end
    
    FOVCircle.Visible = Settings.ShowFOV
    FOVCircle.Transparency = Settings.FOVTransparency
    FOVCircle.Radius = Settings.AimbotMode == "Rivals" and Settings.RivalsFOV or Settings.FOV
    
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    FOVCircle.Color = GetColor(Settings.FOVColor)
end

local function UpdateCrosshair()
    if not Crosshair then
        Crosshair = Drawing.new("Circle")
        Crosshair.Thickness = VisualSettings.CrosshairThickness
        Crosshair.NumSides = 4
        Crosshair.Filled = false
    end
    Crosshair.Visible = VisualSettings.Crosshair
    if VisualSettings.CrosshairType == "Cross" then
        Crosshair.Thickness = VisualSettings.CrosshairThickness
        Crosshair.NumSides = 4
        Crosshair.Filled = false
        Crosshair.Radius = VisualSettings.CrosshairSize
    elseif VisualSettings.CrosshairType == "Dot" then
        Crosshair.Thickness = 1
        Crosshair.NumSides = 100
        Crosshair.Filled = true
        Crosshair.Radius = 2
    elseif VisualSettings.CrosshairType == "Circle" then
        Crosshair.Thickness = VisualSettings.CrosshairThickness
        Crosshair.NumSides = 100
        Crosshair.Filled = false
        Crosshair.Radius = VisualSettings.CrosshairSize
    elseif VisualSettings.CrosshairType == "Square" then
        Crosshair.Thickness = VisualSettings.CrosshairThickness
        Crosshair.NumSides = 4
        Crosshair.Filled = false
        Crosshair.Radius = VisualSettings.CrosshairSize
    end
    Crosshair.Color = GetColor(VisualSettings.CrosshairColor)
    local screenSize = Camera.ViewportSize
    Crosshair.Position = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
end

for _, player in pairs(Players:GetPlayers()) do
    ConstructESP(player)
end
Players.PlayerAdded:Connect(ConstructESP)
Players.PlayerRemoving:Connect(RemoveESP)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        UpdateCache(player)
        OriginalHeadSizes[character] = nil
    end)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        UpdateCache(player)
        player.CharacterAdded:Connect(function(character)
            task.wait(0.5)
            UpdateCache(player)
            OriginalHeadSizes[character] = nil
        end)
    end
end

RunService.RenderStepped:Connect(function()
    pcall(UpdateESP)
    if Settings.Enabled then
        pcall(AimAtTarget)
    end
    pcall(UpdateTargetInfo)
    pcall(UpdateFOVCircle)
    pcall(UpdateCrosshair)
    pcall(SpeedHack)
    pcall(JumpPower)
    pcall(Noclip)
    pcall(AutoReload)
    pcall(AutoRespawn)
    pcall(SpinBot)
    pcall(AntiAim)
    pcall(AutoStomp)
    pcall(TeleportToPlayer)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            pcall(UpdateHeadSize, player.Character)
        end
    end
end)

task.spawn(function()
    while true do
        pcall(TriggerBot)
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        pcall(AutoKill)
        task.wait(Settings.AutoKillDelay)
    end
end)

task.spawn(function()
    while true do
        pcall(AntiAFK)
        task.wait(30)
    end
end)

UserInputService.JumpRequest:Connect(function()
    pcall(InfiniteJump)
end)

ApplyOptimization()

if Authorized then
    showMain()
else
    showKey()
end
