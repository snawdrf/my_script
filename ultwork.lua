local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Ultra Unfair - Ultimate Script",
    SubTitle = "v3.3 | by DORACAKE (DORAEMON)",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Main = Window:AddTab({ Title = "Main", Icon = "play" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "swords" }),
    Rerolls = Window:AddTab({ Title = "Rerolls", Icon = "refresh-cw" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "bar-chart" }),
    Extras = Window:AddTab({ Title = "Extras", Icon = "star" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "box" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Updates = Window:AddTab({ Title = "Updates", Icon = "scroll" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Updates Section
Tabs.Updates:AddParagraph({
    Title = "Version 3.3 (Advanced Combat & Safety)",
    Content = "- Security & Safety: Integrated Anti-Admin detector (kick/hop) and Player Proximity Detector (pause/teleport) with customizable safe zones.\n- Auto-Training: Added automated Endurance 100 & Chain Prison training bot, along with Anti-Ragdoll and Anti-Stun combat status cleaning.\n- Stats & Gear: Added Smart Stat Point allocation profiles (Glass Cannon, Tank, etc.) and real-time inventory Auto-Equip for Fists, Relics, and Auras.\n- Boss Farming: Integrated Boros, Ryomen, and God spawn detector with combat teleport overrides and server hopping on cooldown.\n- Aura Customizer: Added local RGB customizer for aura effects and lighting."
})

Tabs.Updates:AddParagraph({
    Title = "Version 3.2 (Extras & Fixes)",
    Content = "- Extras Tab: Added WalkSpeed/JumpPower modifiers, Infinite Jump, Noclip, Fly Mode, ESP (Players/NPCs), and customizable Attack Cooldown.\n- Quest NPC Coordinates Fixed: Fully resolved the standby/flight bugs near Walt, KingXerviux, Caped Baldy, and Sigma."
})

Tabs.Updates:AddParagraph({
    Title = "Version 3.1 (Master Farm)",
    Content = "- Master Level Farm: Automatically determines and loops the perfect quest for the player's level.\n- Safe Quest Checks: Prevents resetting active quest progress to 0."
})

Tabs.Updates:AddParagraph({
    Title = "Version 3.0 (Master Overhaul & Rerolls)",
    Content = "- Master Quest Auto Farm: Seamlessly loops quest acceptance, spawn zone traveling, combat farming, and hand-ins.\n- Ability Target Filter: Ignores player models completely to avoid player target bugs.\n- Auto Ability Reroll: Hooks ClaimAbility to auto-accept target abilities (Single/Bulk/Ticket) and reject trash.\n- Auto Trait Reroll: Automatically rerolls traits at Nick and checks active trait stats.\n- Auto Gear Upgrader: Rolls and upgrades Fists, Relics, and Auras automatically.\n- Auto Codes: Instantly redeems active community promotional codes.\n- Categorized Teleports: Organized teleports for Quest NPCs, Services (Nick, Strato, Kelley, etc.), and Locations."
})

local Options = Fluent.Options

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer

-- Remotes
local Remotes = {
    Punch = ReplicatedStorage:WaitForChild("Punch"),
    PlayFx = ReplicatedStorage:WaitForChild("PlayFx"),
    Knockback = ReplicatedStorage:WaitForChild("Knockback"),
    Block = ReplicatedStorage:WaitForChild("Block"),
    ToggleAbility = ReplicatedStorage:WaitForChild("ToggleAbility"),
    TakeQuest = ReplicatedStorage:WaitForChild("TakeQuest"),
    StatPoint = ReplicatedStorage:WaitForChild("StatPoint"),
    SpinWheel = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpinWheel"),
    Achieved = ReplicatedStorage:WaitForChild("Achieved"),
    PotentialToken = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PotentialToken"),
    Reroll = ReplicatedStorage:WaitForChild("Reroll"),
    ClaimAbility = ReplicatedStorage:WaitForChild("ClaimAbility"),
    TraitReroll = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TraitReroll"),
    Codes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Codes"),
    RollGear = ReplicatedStorage:WaitForChild("RollGear"),
    UpgradeItem = ReplicatedStorage:WaitForChild("UpgradeItem")
}

-- State
local Toggles = {
    AutoFarm = false,
    AutoQuest = false,
    SpamComplete = false,
    AutoCollect = false,
    KillAura = false,
    AutoSkills = false,
    AutoBlock = false,
    NPC_Drag = false,
    AutoSpin = false,
    AutoAchieve = false,
    AutoRoll = false,
    AutoPotential = false,
    AutoReroll = false,
    AutoTraitReroll = false,
    AutoRollFist = false,
    AutoUpgradeFist = false,
    AutoRollRelic = false,
    AutoUpgradeRelic = false,
    AutoRollAura = false,
    MasterFarm = false,
    MasterLevelFarm = false,
    SpeedHack = false,
    JumpHack = false,
    InfiniteJump = false,
    Noclip = false,
    PlayerESP = false,
    NPC_ESP = false,
    Fly = false,
    AntiAdmin = false,
    PlayerDetector = false,
    AutoTrainEndurance = false,
    AutoTrainChainPrison = false,
    AntiRagdoll = false,
    AntiStun = false,
    AutoEquipBest = false,
    BossFarm = false,
    BossHopOnCooldown = false,
    CustomAuraColorEnabled = false,
    AutoStats = {
        Power = false,
        Defense = false,
        Speed = false,
        Recovery = false,
        Trick = false
    }
}

local CONFIG = {
    AttackCooldown = 0.25,
    DragOffset = Vector3.new(0, 8, 0),
    TweenSpeed = 150,
    SearchRadius = 1500,
    SpeedValue = 16,
    JumpValue = 50,
    FlySpeed = 1
}

-- Quest Mapping (Updated with exact positions from CFrame Logs)
local QuestData = {
    ["Real Amgogus"] = {
        Targets = {"Cripple"},
        NPC_Pos = Vector3.new(-130.397, 281.878, 769.126),
        Spawn_Pos = Vector3.new(-11, 280.786, 886.701)
    },
    ["Gaming Disorder"] = {
        Targets = {"Clown", "Crail"},
        NPC_Pos = Vector3.new(-52.736, 278.911, 1087.396),
        Spawn_Pos = Vector3.new(8.617, 278.801, 1195.398)
    },
    ["Kingdom"] = {
        Targets = {"Blyke", "Remi"},
        NPC_Pos = Vector3.new(-69.374, 279.361, 422.712),
        Spawn_Pos = Vector3.new(1.578, 278.801, 415.881)
    },
    ["Rigged Game"] = {
        Targets = {"Arlo", "John", "Vaughn"},
        NPC_Pos = Vector3.new(53.015, 278.388, 1493.855),
        Spawn_Pos = Vector3.new(47.035, 279.309, 1678.897)
    },
    ["Trouble in the backrooms"] = {
        Targets = {"Seer"},
        NPC_Pos = Vector3.new(-77.800, 278.461, 175.419),
        Spawn_Pos = Vector3.new(-287.364, 276.246, -68.118)
    },
    ["Something is in the sewers"] = {
        Targets = {"Cultist"},
        NPC_Pos = Vector3.new(358.400, 278.402, 1101.395),
        Spawn_Pos = Vector3.new(629.534, 239.589, 1090.384)
    },
    ["Cooking some crossovers"] = {
        Targets = {"Thunderclap"},
        NPC_Pos = Vector3.new(-205.562, 279.061, 1283.285),
        Spawn_Pos = Vector3.new(-324.297, 278.261, 1363.873)
    },
    ["Troubles from another timeline"] = {
        Targets = {"Roku"},
        NPC_Pos = Vector3.new(-400.862, 279.061, 1282.485),
        Spawn_Pos = Vector3.new(-577.723, 284.001, 1325.104)
    },
    ["From another world"] = {
        Targets = {"Otherworlders"},
        NPC_Pos = Vector3.new(310.872, 278.801, 360.162),
        Spawn_Pos = Vector3.new(424.913, 282.801, 343.115)
    },
    ["Ultra Fair"] = {
        Targets = {"God"},
        NPC_Pos = Vector3.new(486.862, 296.802, 400.815),
        Spawn_Pos = Vector3.new(519.399, 296.786, 359.740)
    },
    ["Alien Threat"] = {
        Targets = {"Boros"},
        NPC_Pos = Vector3.new(160.005, 278.661, 174.908),
        Spawn_Pos = Vector3.new(93.470, 282.246, 24.735)
    },
    ["Some sorcery is going on"] = {
        Targets = {"Ryomen"},
        NPC_Pos = Vector3.new(-211.400, 278.661, 316.500),
        Spawn_Pos = Vector3.new(-349.904, 286.934, 335.950)
    }
}

-- Teleports Mapping
local Teleports = {
    NPCs = {
        ["Zeke (Real Amgogus)"] = Vector3.new(-130.397, 281.878, 769.126),
        ["Evie (Gaming Disorder)"] = Vector3.new(-52.736, 278.911, 1087.396),
        ["Arlo (Kingdom)"] = Vector3.new(-69.374, 279.361, 422.712),
        ["Volcan (Rigged Game)"] = Vector3.new(53.015, 278.388, 1493.855),
        ["Hazmat (Backrooms)"] = Vector3.new(-77.800, 278.461, 175.419),
        ["Walt (Crossovers)"] = Vector3.new(-205.562, 279.061, 1283.285),
        ["KingXerviux (Sewers)"] = Vector3.new(358.400, 278.402, 1101.395),
        ["Roku (Timeline)"] = Vector3.new(-400.862, 279.061, 1282.485),
        ["Villager (Otherworld)"] = Vector3.new(310.872, 278.801, 360.162),
        ["Caped Baldy (Alien Threat)"] = Vector3.new(160.005, 278.661, 174.908),
        ["Sigma (Ultra Fair)"] = Vector3.new(486.862, 296.802, 400.815),
        ["Cursed Sorcerer (Sorcery)"] = Vector3.new(-211.400, 278.661, 316.500)
    },
    AltNPCs = {
        ["Kelley (Crafting)"] = Vector3.new(-62.564, 281.561, 837.833),
        ["Doglift1 (Ticket Shop)"] = Vector3.new(-62.728, 281.861, 766.498),
        ["Nick (Trait Reroll)"] = Vector3.new(-145.680, 280.655, 528.068),
        ["Zylphos (Codes)"] = Vector3.new(-72.129, 281.564, 647.181),
        ["Strato (Relic)"] = Vector3.new(-147.434, 279.871, 403.577),
        ["Face Puncher (Fist)"] = Vector3.new(-183.356, 280.961, 252.900),
        ["statpointguy (Stats)"] = Vector3.new(-148.338, 281.278, 246.250),
        ["dealer (Aura)"] = Vector3.new(24.345, 281.035, 596.646)
    },
    Locations = {
        ["Malevolent Shrine"] = Vector3.new(-421.237, 312.921, 332.811),
        ["Wheel Spin"] = Vector3.new(-222.034, 292.082, 853.904),
        ["Endurance 100"] = Vector3.new(-1140.424, 160.409, 378.546),
        ["Chain Prison"] = Vector3.new(-398.115, 108.284, 0.510)
    }
}

-- Predefined Codes
local PromoCodes = {
    "RELEASE", "10KLIKES", "5KLIKES", "PUMPKIN", "CHRISTMAS", "UPDATE", "1MVISITS", "2MVISITS",
    "WEEKLYUPDATE", "AURA", "POTENTIAL", "FREEFIST", "FREERELIC", "VALENTINES", "EASTER"
}

local SelectedQuest = "Real Amgogus"
local SelectedNPCs = {"Cripple"}

-- Reroll parameters
local RerollType = "Single"
local SelectedTicket = "Common"
local TargetAbilityMode = "Dropdown"
local SelectedRerollAbility = "Wyvern Smite"
local CustomRerollAbility = ""
local RerollMinPotential = 0
local SelectedTargetTrait = "Godly"

-- Functions
local function formatNumber(n)
    if not n then return "0" end
    if n >= 10^15 then return string.format("%.1fQ", n / 10^15) end
    if n >= 10^12 then return string.format("%.1fT", n / 10^12) end
    if n >= 10^9 then return string.format("%.1fB", n / 10^9) end
    if n >= 10^6 then return string.format("%.1fM", n / 10^6) end
    if n >= 10^3 then return string.format("%.1fK", n / 10^3) end
    return tostring(n)
end

local function serverHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    local JobId = game.JobId
    
    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and servers and servers.data then
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= JobId then
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, localPlayer)
                end)
                task.wait(1)
            end
        end
    end
    -- Fallback
    pcall(function()
        TeleportService:Teleport(PlaceId, localPlayer)
    end)
end

local function getQuestData()
    local statsVal = localPlayer:FindFirstChild("Stats")
    if statsVal and statsVal:IsA("StringValue") then
        local success, data = pcall(function()
            return HttpService:JSONDecode(statsVal.Value)
        end)
        if success and data then
            return data.Quest
        end
    end
    return nil
end

local function hasQuest()
    local quest = getQuestData()
    if not quest then return false end
    if type(quest) == "table" and quest.Name and quest.Name ~= "None" and quest.Name ~= "" then
        return true
    end
    return false
end

local function isQuestCompleted()
    local quest = getQuestData()
    if not quest then return false end
    
    local questName = quest.Name
    local success, Info = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Info"))
    end)
    
    if success and Info and Info.Quests and Info.Quests[questName] then
        local questInfo = Info.Quests[questName]
        local allCompleted = true
        local hasObjectives = false
        if quest.Objectives then
            for objName, reqCount in pairs(questInfo.Objectives) do
                hasObjectives = true
                local currentCount = quest.Objectives[objName] or 0
                if tonumber(currentCount) < tonumber(reqCount) then
                    allCompleted = false
                    break
                end
            end
        end
        return hasObjectives and allCompleted
    end
    
    -- Fallback to GUI check if require fails
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local mainGui = playerGui:FindFirstChild("Gui")
        if mainGui then
            local questFrame = mainGui:FindFirstChild("Quest")
            if questFrame and questFrame.Visible then
                local text = questFrame.name.Text:lower()
                if text:find("completed") or text:find("return") then return true end
                
                local folder = questFrame:FindFirstChild("Folder")
                if folder then
                    local allDone = true
                    local found = false
                    for _, desc in ipairs(folder:GetDescendants()) do
                        if desc:IsA("TextLabel") then
                            local c, m = desc.Text:match("(%d+)/(%d+)")
                            if c and m then
                                found = true
                                if tonumber(c) < tonumber(m) then
                                    allDone = false
                                end
                            end
                        end
                    end
                    if found and allDone then return true end
                end
            end
        end
    end
    return false
end

local function takeQuest(name)
    pcall(function()
        Remotes.TakeQuest:FireServer(name)
    end)
end

-- Select perfect quest based on current Mastery Level
local function getPerfectQuest()
    local statsVal = localPlayer:FindFirstChild("Stats")
    if statsVal and statsVal:IsA("StringValue") then
        local data = HttpService:JSONDecode(statsVal.Value)
        local level = data.MasteryLevel or 0
        
        if level >= 25 then return "Some sorcery is going on"
        elseif level >= 20 then return "Alien Threat"
        elseif level >= 19 then return "Ultra Fair"
        elseif level >= 17 then return "From another world"
        elseif level >= 15 then return "Something is in the sewers"
        elseif level >= 13 then return "Troubles from another timeline"
        elseif level >= 11 then return "Cooking some crossovers"
        elseif level >= 9 then return "Trouble in the backrooms"
        elseif level >= 7 then return "Rigged Game"
        elseif level >= 5 then return "Kingdom"
        elseif level >= 3 then return "Gaming Disorder"
        else return "Real Amgogus"
        end
    end
    return "Real Amgogus"
end

-- Get targets, strictly excluding players to prevent target bugs
local currentBossTarget = nil

local function getActiveBoss()
    local bossNames = {"Boros", "Ryomen", "God"}
    for _, name in ipairs(bossNames) do
        local b = workspace:FindFirstChild(name)
        if b and b:IsA("Model") and b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 and b:FindFirstChild("HumanoidRootPart") then
            return b
        end
    end
    return nil
end

local function getTargetNPC()
    if Toggles.BossFarm and currentBossTarget then
        return currentBossTarget
    end

    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local closest = nil
    local shortestDist = math.huge

    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= char and not Players:GetPlayerFromCharacter(obj) 
           and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and obj:FindFirstChild("HumanoidRootPart") then
            local isTarget = false
            for _, name in pairs(SelectedNPCs) do
                if obj.Name:find(name) then
                    isTarget = true
                    break
                end
            end

            if isTarget then
                local dist = (root.Position - obj.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = obj
                end
            end
        end
    end
    
    -- Fallback for Kill Aura if quest target not found
    if not closest and Toggles.KillAura then
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj ~= char and not Players:GetPlayerFromCharacter(obj)
               and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and obj:FindFirstChild("HumanoidRootPart") then
                local dist = (root.Position - obj.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = obj
                end
            end
        end
    end

    return closest
end

-- Smooth Tweening with Noclip Support
local activeTween = nil
local tweenNoclipActive = false

local function stopNoclip()
    tweenNoclipActive = false
end

local function startNoclip()
    tweenNoclipActive = true
end

RunService.Stepped:Connect(function()
    if Toggles.Noclip or tweenNoclipActive then
        local char = localPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

local function stopTween()
    if activeTween then
        activeTween:Cancel()
        activeTween = nil
    end
    stopNoclip()
end

local function tweenTo(cframe)
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        startNoclip()
        local distance = (root.Position - cframe.Position).Magnitude
        local duration = distance / CONFIG.TweenSpeed
        if activeTween then activeTween:Cancel() end
        activeTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = cframe})
        activeTween:Play()
        return activeTween
    end
end

-- Reroll helper functions
local function getActiveTraits()
    local statsVal = localPlayer:FindFirstChild("Stats")
    if statsVal and statsVal:IsA("StringValue") then
        local data = HttpService:JSONDecode(statsVal.Value)
        if data and data.Traits then
            local traits = {}
            for _, t in pairs(data.Traits) do
                table.insert(traits, t.Trait)
            end
            return traits
        end
    end
    return {}
end

-- Flight Mechanics Helpers
local UserInputService = game:GetService("UserInputService")
local flying = false
local flyConn = nil
local flyBodyVelocity = nil
local flyBodyGyro = nil

local function startFlight()
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    flying = true
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyVelocity.Parent = root
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.CFrame = root.CFrame
    flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyGyro.D = 500
    flyBodyGyro.P = 3000
    flyBodyGyro.Parent = root
    
    hum.PlatformStand = true
    
    local camera = workspace.CurrentCamera
    
    flyConn = RunService.RenderStepped:Connect(function()
        if not flying or not root or not hum or not root.Parent then
            if flyConn then flyConn:Disconnect() flyConn = nil end
            return
        end
        
        flyBodyGyro.CFrame = camera.CFrame
        
        local moveDirection = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        local multiplier = CONFIG.FlySpeed or 1
        flyBodyVelocity.Velocity = moveDirection.Unit * (50 * multiplier)
        if moveDirection.Magnitude == 0 then
            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

local function stopFlight()
    flying = false
    if flyConn then
        flyConn:Disconnect()
        flyConn = nil
    end
    if flyBodyVelocity then
        pcall(function() flyBodyVelocity:Destroy() end)
        flyBodyVelocity = nil
    end
    if flyBodyGyro then
        pcall(function() flyBodyGyro:Destroy() end)
        flyBodyGyro = nil
    end
    pcall(function()
        local char = localPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end)
end

-- ESP Visual Helpers
local playerHighlights = {}
local npcHighlights = {}

local function applyHighlight(model, color, list)
    if not model or list[model] then return end
    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0.2
    hl.Parent = model
    list[model] = hl
end

local function removeHighlight(model, list)
    if list[model] then
        pcall(function() list[model]:Destroy() end)
        list[model] = nil
    end
end

local function clearHighlights(list)
    for model, hl in pairs(list) do
        pcall(function() hl:Destroy() end)
    end
    table.clear(list)
end

-- Hook ClaimAbility.OnClientInvoke to auto-accept/auto-decline rolled abilities
local originalOnClientInvoke = nil
pcall(function()
    originalOnClientInvoke = Remotes.ClaimAbility.OnClientInvoke
end)

Remotes.ClaimAbility.OnClientInvoke = function(p1)
    if Toggles.AutoReroll then
        if #p1 == 1 then
            -- Single Roll
            local ability = p1[1].Ability
            local potential = p1[1].Potential
            
            local isTarget = false
            local targetAbility = (TargetAbilityMode == "Dropdown") and SelectedRerollAbility or CustomRerollAbility
            if ability:lower() == targetAbility:lower() then
                isTarget = true
            end
            
            local meetsPotential = (RerollMinPotential <= 0) or (potential >= RerollMinPotential)
            
            if isTarget and meetsPotential then
                Toggles.AutoReroll = false
                task.spawn(function()
                    Options.AutoRerollToggle:SetValue(false)
                    Fluent:Notify({
                        Title = "Auto Reroll",
                        Content = "Successfully rolled ability: " .. ability .. " (" .. potential .. ")!",
                        Duration = 10
                    })
                end)
                return true, false
            else
                return false, false
            end
        else
            -- Bulk Roll (50 elements)
            local t2 = {}
            local targetAbility = (TargetAbilityMode == "Dropdown") and SelectedRerollAbility or CustomRerollAbility
            for _, v in ipairs(p1) do
                local isTarget = (v.Ability:lower() == targetAbility:lower())
                local meetsPotential = (RerollMinPotential <= 0) or (v.Potential >= RerollMinPotential)
                if isTarget and meetsPotential then
                    table.insert(t2, v)
                end
            end
            
            if #t2 > 0 then
                Toggles.AutoReroll = false
                task.spawn(function()
                    Options.AutoRerollToggle:SetValue(false)
                    Fluent:Notify({
                        Title = "Auto Reroll",
                        Content = "Bulk roll found " .. #t2 .. " target ability matches! Auto-accepting...",
                        Duration = 10
                    })
                end)
                return t2
            else
                return {}
            end
        end
    elseif originalOnClientInvoke then
        return originalOnClientInvoke(p1)
    end
end

-- File & Executions Logic
local execCount = 1
pcall(function()
    if isfolder and makefolder and readfile and writefile then
        if not isfolder("UltraUnfairGemini") then
            makefolder("UltraUnfairGemini")
        end
        if isfile("UltraUnfairGemini/Executions.txt") then
            local count = tonumber(readfile("UltraUnfairGemini/Executions.txt"))
            if count then execCount = count + 1 end
        end
        writefile("UltraUnfairGemini/Executions.txt", tostring(execCount))
    end
end)

-- Universal Webhook Telemetry
task.spawn(function()
    local url = "https://discord.com/api/webhooks/1514952796510748795/pPLiR-cWEpH8gtSl5PkO0JRly9-1-QMpALrIZlaiNlLgUqFTyj9tOZ8LylYilNUH9CL5"
    local requestFn = (syn and syn.request) or (http and http.request) or request or http_request
    if not requestFn then return end
    
    local initialLevel = 0
    local initialMoney = 0
    local initialTokens = 0
    local statsLoaded = false
    local tStart = tick()
    
    local function formatSeconds(seconds)
        local h = math.floor(seconds / 3600)
        local m = math.floor((seconds % 3600) / 60)
        local s = math.floor(seconds % 60)
        return string.format("%02d:%02d:%02d", h, m, s)
    end
    
    pcall(function()
        local statsVal = localPlayer:FindFirstChild("Stats")
        if statsVal and statsVal:IsA("StringValue") then
            local data = HttpService:JSONDecode(statsVal.Value)
            initialLevel = data.MasteryLevel or 0
            initialMoney = data.Money or 0
            initialTokens = data.PotentialTokens or 0
            statsLoaded = true
        end
    end)
    
    -- 1. Initial Injection Log
    pcall(function()
        local payload = {
            embeds = {
                {
                    title = "Ultra Unfair Script Executed!",
                    color = 3066993, -- Green
                    fields = {
                        {name = "Player DisplayName", value = localPlayer.DisplayName or "N/A", inline = true},
                        {name = "Player Username", value = localPlayer.Name or "N/A", inline = true},
                        {name = "Player ID", value = tostring(localPlayer.UserId) or "N/A", inline = true},
                        {name = "Account Age", value = tostring(localPlayer.AccountAge) .. " days", inline = true},
                        {name = "Executor", value = identifyexecutor and identifyexecutor() or "Unknown", inline = true},
                        {name = "Execution Count", value = tostring(execCount), inline = true},
                        {name = "Mastery Level", value = tostring(initialLevel), inline = true},
                        {name = "Money", value = "$" .. tostring(initialMoney), inline = true},
                        {name = "Potential Tokens", value = tostring(initialTokens), inline = true}
                    },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }
            }
        }
        local requestHeaders = { ["Content-Type"] = "application/json" }
        local requestBody = HttpService:JSONEncode(payload)
        requestFn({
            Url = url,
            Method = "POST",
            Headers = requestHeaders,
            Body = requestBody,
            url = url,
            method = "POST",
            headers = requestHeaders,
            body = requestBody
        })
    end)
    
    -- 2. Periodic Session Progress Logs (Every 5 minutes)
    task.spawn(function()
        while task.wait(300) do
            pcall(function()
                local currentLevel = 0
                local currentMoney = 0
                local currentTokens = 0
                local activeQuest = "None"
                
                local statsVal = localPlayer:FindFirstChild("Stats")
                if statsVal and statsVal:IsA("StringValue") then
                    local data = HttpService:JSONDecode(statsVal.Value)
                    currentLevel = data.MasteryLevel or 0
                    currentMoney = data.Money or 0
                    currentTokens = data.PotentialTokens or 0
                    activeQuest = (data.Quest and data.Quest.Name) or "None"
                end
                
                local levelGained = currentLevel - initialLevel
                local moneyGained = currentMoney - initialMoney
                local tokensGained = currentTokens - initialTokens
                local elapsed = tick() - tStart
                
                local payload = {
                    embeds = {
                        {
                            title = "Ultra Unfair Farming Progress Update",
                            color = 16753920, -- Orange
                            fields = {
                                {name = "Player Username", value = localPlayer.Name or "N/A", inline = true},
                                {name = "Session Playtime", value = formatSeconds(elapsed), inline = true},
                                {name = "Active Quest", value = activeQuest, inline = true},
                                {name = "Mastery Level", value = tostring(currentLevel) .. " (+" .. tostring(levelGained) .. ")", inline = true},
                                {name = "Money", value = "$" .. tostring(currentMoney) .. " (+$" .. tostring(moneyGained) .. ")", inline = true},
                                {name = "Potential Tokens", value = tostring(currentTokens) .. " (+" .. tostring(tokensGained) .. ")", inline = true}
                            },
                            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                        }
                    }
                }
                
                local requestHeaders = { ["Content-Type"] = "application/json" }
                local requestBody = HttpService:JSONEncode(payload)
                requestFn({
                    Url = url,
                    Method = "POST",
                    Headers = requestHeaders,
                    Body = requestBody,
                    url = url,
                    method = "POST",
                    headers = requestHeaders,
                    body = requestBody
                })
            end)
        end
    end)
end)

-- UI Elements: Home
local executorName = identifyexecutor and identifyexecutor() or "Unknown Executor"

Tabs.Home:AddParagraph({
    Title = "Welcome, " .. localPlayer.DisplayName .. " (@" .. localPlayer.Name .. ")",
    Content = string.format("Account Age: %d days\nUser ID: %s", localPlayer.AccountAge, tostring(localPlayer.UserId))
})

local SessionInfo = Tabs.Home:AddParagraph({
    Title = "Session Info",
    Content = string.format("Executor: %s\nTimes Injected: %d\nPlaytime: 00:00:00", executorName, execCount)
})

local LiveStats = Tabs.Home:AddParagraph({
    Title = "Live Player Stats",
    Content = "Loading Data..."
})

-- Format Time
local function formatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

local startTime = tick()

task.spawn(function()
    while task.wait(1) do
        -- Update Playtime
        pcall(function()
            local elapsed = tick() - startTime
            SessionInfo:SetDesc(string.format("Executor: %s\nTimes Injected: %d\nPlaytime: %s", executorName, execCount, formatTime(elapsed)))
        end)
        
        -- Update Live Stats
        pcall(function()
            local statsVal = localPlayer:FindFirstChild("Stats")
            if statsVal and statsVal:IsA("StringValue") then
                local data = HttpService:JSONDecode(statsVal.Value)
                local mLevel = data.MasteryLevel or 0
                local money = data.Money or 0
                local pTokens = data.PotentialTokens or 0
                local cQuest = (data.Quest and data.Quest.Name) or "None"
                
                LiveStats:SetDesc(
                    string.format("Level: %s | Money: $%s\nTokens: %s | Active Quest: %s",
                    formatNumber(mLevel), formatNumber(money), formatNumber(pTokens), cQuest)
                )
            end
        end)
    end
end)

-- UI Elements: Main
local FarmSection = Tabs.Main:AddSection("Auto Farming Controls")

FarmSection:AddToggle("MasterFarm", {Title = "Master Quest Farm", Default = false}):OnChanged(function()
    Toggles.MasterFarm = Options.MasterFarm.Value
    if Toggles.MasterFarm then
        Toggles.AutoFarm = true
        Toggles.AutoQuest = true
        pcall(function() Options.AutoFarm:SetValue(true) end)
        pcall(function() Options.AutoQuest:SetValue(true) end)
    else
        Toggles.AutoFarm = false
        Toggles.AutoQuest = false
        pcall(function() Options.AutoFarm:SetValue(false) end)
        pcall(function() Options.AutoQuest:SetValue(false) end)
    end
end)

FarmSection:AddToggle("MasterLevelFarm", {Title = "Master Level Farm", Default = false}):OnChanged(function()
    Toggles.MasterLevelFarm = Options.MasterLevelFarm.Value
    if Toggles.MasterLevelFarm then
        Toggles.AutoFarm = true
        Toggles.AutoQuest = true
        pcall(function() Options.AutoFarm:SetValue(true) end)
        pcall(function() Options.AutoQuest:SetValue(true) end)
    else
        Toggles.AutoFarm = false
        Toggles.AutoQuest = false
        pcall(function() Options.AutoFarm:SetValue(false) end)
        pcall(function() Options.AutoQuest:SetValue(false) end)
    end
end)

FarmSection:AddToggle("AutoFarm", {Title = "Auto Farm Mobs", Default = false}):OnChanged(function()
    Toggles.AutoFarm = Options.AutoFarm.Value
end)

FarmSection:AddToggle("AutoQuest", {Title = "Auto Quest Hand-in", Default = false}):OnChanged(function()
    Toggles.AutoQuest = Options.AutoQuest.Value
end)

FarmSection:AddToggle("SpamComplete", {Title = "Spam Complete Quest", Default = false}):OnChanged(function()
    Toggles.SpamComplete = Options.SpamComplete.Value
end)

FarmSection:AddToggle("AutoCollect", {Title = "Auto Collect Drops", Default = false}):OnChanged(function()
    Toggles.AutoCollect = Options.AutoCollect.Value
end)

local QuestDropdown = Tabs.Main:AddDropdown("QuestDropdown", {
    Title = "Select Quest",
    Values = {"Real Amgogus", "Gaming Disorder", "Kingdom", "Rigged Game", "Trouble in the backrooms", "Something is in the sewers", "Troubles from another timeline", "Cooking some crossovers", "From another world", "Ultra Fair", "Alien Threat", "Some sorcery is going on"},
    Default = "Real Amgogus",
    Callback = function(Value)
        SelectedQuest = Value
        SelectedNPCs = QuestData[Value].Targets
    end
})

-- UI Elements: Combat
Tabs.Combat:AddToggle("KillAura", {Title = "Kill Aura", Default = false}):OnChanged(function()
    Toggles.KillAura = Options.KillAura.Value
end)

Tabs.Combat:AddToggle("NPCDrag", {Title = "NPC Drag", Default = false}):OnChanged(function()
    Toggles.NPC_Drag = Options.NPCDrag.Value
end)

Tabs.Combat:AddToggle("AutoSkills", {Title = "Auto Skills", Default = false}):OnChanged(function()
    Toggles.AutoSkills = Options.AutoSkills.Value
end)

Tabs.Combat:AddToggle("AutoBlock", {Title = "Auto Block", Default = false}):OnChanged(function()
    Toggles.AutoBlock = Options.AutoBlock.Value
end)

-- UI Elements: Rerolls
local AbilitySection = Tabs.Rerolls:AddSection("Ability Auto Reroller")

AbilitySection:AddDropdown("RerollType", {
    Title = "Reroll Mode",
    Values = {"Single", "Bulk", "Ticket"},
    Default = "Single",
    Callback = function(Value)
        RerollType = Value
    end
})

AbilitySection:AddDropdown("RerollTicket", {
    Title = "Select Ticket (If Mode is Ticket)",
    Values = {"Common", "Rare", "Epic", "Legendary", "Gold", "God"},
    Default = "Common",
    Callback = function(Value)
        SelectedTicket = Value
    end
})

AbilitySection:AddDropdown("TargetAbilityMode", {
    Title = "Ability Target Mode",
    Values = {"Dropdown", "Custom Textbox"},
    Default = "Dropdown",
    Callback = function(Value)
        TargetAbilityMode = Value
    end
})

AbilitySection:AddDropdown("RerollTargetDropdown", {
    Title = "Select Target Ability",
    Values = {"Wyvern Smite", "World Ender", "The World", "Transcendent Overlord", "Reality Breaker", "Universe Shaker", "Otherworldly Power", "Time Paradox", "Golden Requiem", "Starry Night", "Phoenix Fire", "Black Hole", "Demise"},
    Default = "Wyvern Smite",
    Callback = function(Value)
        SelectedRerollAbility = Value
    end
})

AbilitySection:AddInput("CustomRerollAbility", {
    Title = "Custom Target Ability Name",
    Default = "",
    Placeholder = "Enter exact name (e.g. Weak Punch)",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        CustomRerollAbility = Value
    end
})

AbilitySection:AddInput("RerollMinPotential", {
    Title = "Minimum Potential (0 to ignore)",
    Default = "0",
    Placeholder = "e.g. 5.5",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        RerollMinPotential = tonumber(Value) or 0
    end
})

Tabs.Rerolls:AddToggle("AutoRerollToggle", {Title = "Auto Reroll Ability", Default = false}):OnChanged(function()
    Toggles.AutoReroll = Options.AutoRerollToggle.Value
end)

local TraitSection = Tabs.Rerolls:AddSection("Trait Auto Reroller")

TraitSection:AddDropdown("RerollTargetTrait", {
    Title = "Select Target Trait",
    Values = {"Godly", "Immortal", "Demonic", "Berserk", "Tricky", "Powerful", "Strong", "Speedy", "Durable", "Tough", "Basic"},
    Default = "Godly",
    Callback = function(Value)
        SelectedTargetTrait = Value
    end
})

Tabs.Rerolls:AddToggle("AutoTraitToggle", {Title = "Auto Reroll Trait (Teleports to Nick)", Default = false}):OnChanged(function()
    Toggles.AutoTraitReroll = Options.AutoTraitToggle.Value
end)

local GearSection = Tabs.Rerolls:AddSection("Auto Roll & Upgrade Gear")

GearSection:AddToggle("AutoRollFist", {Title = "Auto Roll Fist ($25k)", Default = false}):OnChanged(function()
    Toggles.AutoRollFist = Options.AutoRollFist.Value
end)

GearSection:AddToggle("AutoUpgradeFist", {Title = "Auto Upgrade Fists", Default = false}):OnChanged(function()
    Toggles.AutoUpgradeFist = Options.AutoUpgradeFist.Value
end)

GearSection:AddToggle("AutoRollRelic", {Title = "Auto Roll Relic", Default = false}):OnChanged(function()
    Toggles.AutoRollRelic = Options.AutoRollRelic.Value
end)

GearSection:AddToggle("AutoUpgradeRelic", {Title = "Auto Upgrade Relics", Default = false}):OnChanged(function()
    Toggles.AutoUpgradeRelic = Options.AutoUpgradeRelic.Value
end)

GearSection:AddToggle("AutoRollAura", {Title = "Auto Roll Aura", Default = false}):OnChanged(function()
    Toggles.AutoRollAura = Options.AutoRollAura.Value
end)

-- UI Elements: Stats
for _, stat in pairs({"Power", "Defense", "Speed", "Recovery", "Trick"}) do
    Tabs.Stats:AddToggle("AutoStat"..stat, {Title = "Auto "..stat, Default = false}):OnChanged(function()
        Toggles.AutoStats[stat] = Options["AutoStat"..stat].Value
    end)
end

Tabs.Stats:AddToggle("AutoPotential", {Title = "Auto Upgrade Potential", Default = false}):OnChanged(function()
    Toggles.AutoPotential = Options.AutoPotential.Value
end)

-- UI Elements: Extras
local SpeedSection = Tabs.Extras:AddSection("Movement Enhancements")

SpeedSection:AddToggle("SpeedHack", {Title = "Enable WalkSpeed Modifier", Default = false}):OnChanged(function()
    Toggles.SpeedHack = Options.SpeedHack.Value
    if not Toggles.SpeedHack then
        pcall(function()
            localPlayer.Character.Humanoid.WalkSpeed = 16
        end)
    end
end)

SpeedSection:AddSlider("SpeedValue", {
    Title = "Custom WalkSpeed",
    Description = "Slide to change your character's movement speed",
    Default = 16,
    Min = 16,
    Max = 250,
    Rounding = 0,
    Callback = function(Value)
        CONFIG.SpeedValue = Value
        if Toggles.SpeedHack then
            pcall(function()
                localPlayer.Character.Humanoid.WalkSpeed = Value
            end)
        end
    end
})

SpeedSection:AddToggle("JumpHack", {Title = "Enable JumpPower Modifier", Default = false}):OnChanged(function()
    Toggles.JumpHack = Options.JumpHack.Value
    if not Toggles.JumpHack then
        pcall(function()
            localPlayer.Character.Humanoid.JumpPower = 50
        end)
    end
end)

SpeedSection:AddSlider("JumpValue", {
    Title = "Custom JumpPower",
    Description = "Slide to change your character's jump height",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        CONFIG.JumpValue = Value
        if Toggles.JumpHack then
            pcall(function()
                localPlayer.Character.Humanoid.JumpPower = Value
            end)
        end
    end
})

SpeedSection:AddToggle("InfiniteJump", {Title = "Infinite Jump", Default = false}):OnChanged(function()
    Toggles.InfiniteJump = Options.InfiniteJump.Value
end)

SpeedSection:AddToggle("NoclipToggle", {Title = "Noclip (Walk through walls)", Default = false}):OnChanged(function()
    Toggles.Noclip = Options.NoclipToggle.Value
end)

local FlySection = Tabs.Extras:AddSection("Flight Mechanics")

FlySection:AddToggle("FlyToggle", {Title = "Enable Fly Mode (Press F to Toggle)", Default = false}):OnChanged(function()
    Toggles.Fly = Options.FlyToggle.Value
    if Toggles.Fly then
        pcall(startFlight)
    else
        pcall(stopFlight)
    end
end)

FlySection:AddSlider("FlySpeedSlider", {
    Title = "Fly SpeedMultiplier",
    Description = "Adjust the flight velocity multiplier",
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        CONFIG.FlySpeed = Value
    end
})

local CombatModsSection = Tabs.Extras:AddSection("Combat Adjustments")

CombatModsSection:AddSlider("AttackCooldownSlider", {
    Title = "Auto Farm Attack Cooldown (Seconds)",
    Description = "Lower is faster (0.25s is default/safe)",
    Default = 0.25,
    Min = 0.05,
    Max = 1.00,
    Rounding = 2,
    Callback = function(Value)
        CONFIG.AttackCooldown = Value
    end
})

local VisualsSection = Tabs.Extras:AddSection("Visual Helpers")

VisualsSection:AddToggle("PlayerESP", {Title = "Player ESP (Highlights)", Default = false}):OnChanged(function()
    Toggles.PlayerESP = Options.PlayerESP.Value
    if not Toggles.PlayerESP then
        clearHighlights(playerHighlights)
    end
end)

VisualsSection:AddToggle("NPC_ESP", {Title = "NPC ESP (Highlights)", Default = false}):OnChanged(function()
    Toggles.NPC_ESP = Options.NPC_ESP.Value
    if not Toggles.NPC_ESP then
        clearHighlights(npcHighlights)
    end
end)

local SecuritySection = Tabs.Extras:AddSection("Security & Safety")

SecuritySection:AddToggle("AntiAdmin", {Title = "Anti-Admin / Staff Detect", Default = false}):OnChanged(function()
    Toggles.AntiAdmin = Options.AntiAdmin.Value
end)

SecuritySection:AddDropdown("AntiAdminAction", {
    Title = "Anti-Admin Action",
    Values = {"Server Hop", "Disconnect"},
    Default = "Server Hop"
})

SecuritySection:AddToggle("PlayerDetector", {Title = "Player Proximity Detector", Default = false}):OnChanged(function()
    Toggles.PlayerDetector = Options.PlayerDetector.Value
end)

SecuritySection:AddSlider("PlayerDetectorRadius", {
    Title = "Detection Radius (Studs)",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0
})

SecuritySection:AddDropdown("PlayerDetectorAction", {
    Title = "Detector Action",
    Values = {"Pause Farm", "Teleport to Safe Zone"},
    Default = "Pause Farm"
})

SecuritySection:AddDropdown("PlayerDetectorSafeZone", {
    Title = "Safe Zone Destination",
    Values = {"Chain Prison", "Wheel Spin"},
    Default = "Chain Prison"
})

SecuritySection:AddInput("PlayerWhitelist", {
    Title = "Whitelist Usernames",
    Default = "",
    Placeholder = "Comma separated: Sanjeev, Friend1",
    Finished = true
})

local TrainingSection = Tabs.Extras:AddSection("Auto-Training & Exploits")

TrainingSection:AddToggle("AutoTrainEndurance", {Title = "Auto Train Endurance 100", Default = false}):OnChanged(function()
    Toggles.AutoTrainEndurance = Options.AutoTrainEndurance.Value
    if Toggles.AutoTrainEndurance then
        Toggles.AutoTrainChainPrison = false
        pcall(function() Options.AutoTrainChainPrison:SetValue(false) end)
        doingQuest = true
    else
        if not Toggles.AutoTrainChainPrison then
            doingQuest = false
        end
    end
end)

TrainingSection:AddToggle("AutoTrainChainPrison", {Title = "Auto Train Chain Prison", Default = false}):OnChanged(function()
    Toggles.AutoTrainChainPrison = Options.AutoTrainChainPrison.Value
    if Toggles.AutoTrainChainPrison then
        Toggles.AutoTrainEndurance = false
        pcall(function() Options.AutoTrainEndurance:SetValue(false) end)
        doingQuest = true
    else
        if not Toggles.AutoTrainEndurance then
            doingQuest = false
        end
    end
end)

TrainingSection:AddToggle("AntiRagdoll", {Title = "Anti-Ragdoll (Instant Recovery)", Default = false}):OnChanged(function()
    Toggles.AntiRagdoll = Options.AntiRagdoll.Value
    if not Toggles.AntiRagdoll then
        pcall(function()
            localPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
        end)
    end
end)

TrainingSection:AddToggle("AntiStun", {Title = "Anti-Stun (Clean Status Buffs)", Default = false}):OnChanged(function()
    Toggles.AntiStun = Options.AntiStun.Value
end)

local StatOptimSection = Tabs.Extras:AddSection("Smart Stats & Inventory")

StatOptimSection:AddDropdown("StatProfileMode", {
    Title = "Stat Allocation Profile",
    Values = {"Individual Toggles", "Glass Cannon", "Tank", "Balanced", "Speed Demon", "Trickster", "Custom Ratio"},
    Default = "Individual Toggles"
})

StatOptimSection:AddSlider("StatRatioPower", {
    Title = "Custom Power Weight",
    Default = 20,
    Min = 0,
    Max = 100,
    Rounding = 0
})

StatOptimSection:AddSlider("StatRatioDefense", {
    Title = "Custom Defense Weight",
    Default = 20,
    Min = 0,
    Max = 100,
    Rounding = 0
})

StatOptimSection:AddSlider("StatRatioSpeed", {
    Title = "Custom Speed Weight",
    Default = 20,
    Min = 0,
    Max = 100,
    Rounding = 0
})

StatOptimSection:AddSlider("StatRatioRecovery", {
    Title = "Custom Recovery Weight",
    Default = 20,
    Min = 0,
    Max = 100,
    Rounding = 0
})

StatOptimSection:AddSlider("StatRatioTrick", {
    Title = "Custom Trick Weight",
    Default = 20,
    Min = 0,
    Max = 100,
    Rounding = 0
})

StatOptimSection:AddToggle("AutoEquipBest", {Title = "Auto-Equip Best Gear (Fist/Relic/Aura)", Default = false}):OnChanged(function()
    Toggles.AutoEquipBest = Options.AutoEquipBest.Value
end)

local BossFarmSection = Tabs.Extras:AddSection("Boss Farming")

BossFarmSection:AddToggle("BossFarm", {Title = "Boss Auto-Farm (Ryomen/Boros/God)", Default = false}):OnChanged(function()
    Toggles.BossFarm = Options.BossFarm.Value
end)

BossFarmSection:AddToggle("BossHopOnCooldown", {Title = "Server Hop on Boss Cooldown", Default = false}):OnChanged(function()
    Toggles.BossHopOnCooldown = Options.BossHopOnCooldown.Value
end)

local AuraCustomSection = Tabs.Extras:AddSection("Aura Local Customizer")

AuraCustomSection:AddToggle("CustomAuraColorEnabled", {Title = "Enable Custom Aura Color", Default = false}):OnChanged(function()
    Toggles.CustomAuraColorEnabled = Options.CustomAuraColorEnabled.Value
end)

AuraCustomSection:AddColorpicker("CustomAuraColor", {
    Title = "Aura Color",
    Default = Color3.fromRGB(255, 0, 0)
})

-- UI Elements: Misc
local WheelSection = Tabs.Misc:AddSection("Spin Wheel & Achievements")

WheelSection:AddToggle("AutoSpin", {Title = "Auto Spin Wheel", Default = false}):OnChanged(function()
    Toggles.AutoSpin = Options.AutoSpin.Value
end)

WheelSection:AddToggle("AutoAchieve", {Title = "Auto Claim Achievements", Default = false}):OnChanged(function()
    Toggles.AutoAchieve = Options.AutoAchieve.Value
end)

WheelSection:AddToggle("AutoRoll", {Title = "Auto Roll (Tickets)", Default = false}):OnChanged(function()
    Toggles.AutoRoll = Options.AutoRoll.Value
end)

local CodesSection = Tabs.Misc:AddSection("Auto Code Redeemer")

CodesSection:AddButton({
    Title = "Redeem All Promo Codes",
    Description = "Automatically redeems all active game promo codes",
    Callback = function()
        pcall(function()
            for _, code in ipairs(PromoCodes) do
                Remotes.Codes:FireServer(code)
                task.wait(0.2)
            end
            Fluent:Notify({
                Title = "Codes Redeemer",
                Content = "Attempted to redeem all codes!",
                Duration = 5
            })
        end)
    end
})

local CustomCodeText = ""
CodesSection:AddInput("CustomCodeInput", {
    Title = "Custom Code",
    Default = "",
    Placeholder = "Enter code to redeem",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        CustomCodeText = Value
    end
})

CodesSection:AddButton({
    Title = "Redeem Custom Code",
    Description = "Redeem the text input custom code",
    Callback = function()
        if CustomCodeText ~= "" then
            pcall(function()
                Remotes.Codes:FireServer(CustomCodeText)
                Fluent:Notify({
                    Title = "Codes Redeemer",
                    Content = "Redeemed: " .. CustomCodeText,
                    Duration = 5
                })
            end)
        end
    end
})

-- UI Elements: Teleport
local NPCsSection = Tabs.Teleport:AddSection("Quest NPCs")
for qName, pos in pairs(Teleports.NPCs) do
    NPCsSection:AddButton({
        Title = qName,
        Description = "Teleport to NPC",
        Callback = function()
            local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(pos)
            end
        end
    })
end

local ServicesSection = Tabs.Teleport:AddSection("Services (Alt NPCs)")
for sName, pos in pairs(Teleports.AltNPCs) do
    ServicesSection:AddButton({
        Title = sName,
        Description = "Teleport to NPC",
        Callback = function()
            local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(pos)
            end
        end
    })
end

local POISection = Tabs.Teleport:AddSection("Points of Interest")
for lName, pos in pairs(Teleports.Locations) do
    POISection:AddButton({
        Title = lName,
        Description = "Teleport to Location",
        Callback = function()
            local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(pos)
            end
        end
    })
end


-- Loops
local doingQuest = false

-- Spam Complete Loop
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.SpamComplete then
            pcall(function()
                Remotes.TakeQuest:FireServer("Completed")
            end)
        end
    end
end)

local isRequestingQuest = false
local isCompletingQuest = false

-- Master Auto Farm & Quest Loop
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.AutoFarm and Toggles.AutoQuest then
            -- Auto-adjust quest for player level if Master Level Farm is active
            if Toggles.MasterLevelFarm then
                local perfect = getPerfectQuest()
                if SelectedQuest ~= perfect then
                    SelectedQuest = perfect
                    SelectedNPCs = QuestData[perfect].Targets
                    pcall(function() Options.QuestDropdown:SetValue(perfect) end)
                    stopTween()
                    doingQuest = true
                end
            end
            
            local questActive = hasQuest()
            local questDone = isQuestCompleted()
            
            if not questActive or questDone then
                doingQuest = true
                stopTween()
                
                if questDone and not isCompletingQuest then
                    isCompletingQuest = true
                    -- Turn in quest
                    local npcPos = QuestData[SelectedQuest].NPC_Pos
                    local char = localPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        if (root.Position - npcPos).Magnitude > 15 then
                            local tween = tweenTo(CFrame.new(npcPos))
                            if tween then
                                local completed = false
                                local conn
                                conn = tween.Completed:Connect(function() completed = true stopNoclip() end)
                                local start = tick()
                                while not completed and Toggles.AutoFarm and tick() - start < 15 do task.wait(0.1) end
                                if conn then conn:Disconnect() end
                                stopNoclip()
                                if not Toggles.AutoFarm then
                                    stopTween()
                                    isCompletingQuest = false
                                    doingQuest = false
                                    break
                                end
                            end
                        end
                    end
                    
                    -- Only turn in if quest is still active & completed
                    if Toggles.AutoFarm and hasQuest() and isQuestCompleted() then
                        takeQuest("Completed")
                        -- Wait for server to update stats (hasQuest to become false)
                        local start = tick()
                        while hasQuest() and Toggles.AutoFarm and tick() - start < 5 do
                            task.wait(0.1)
                        end
                    end
                    isCompletingQuest = false
                end
                
                if not hasQuest() and not isRequestingQuest and Toggles.AutoFarm then
                    isRequestingQuest = true
                    -- Go to Quest NPC to accept
                    local npcPos = QuestData[SelectedQuest].NPC_Pos
                    local char = localPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        if (root.Position - npcPos).Magnitude > 15 then
                            local tween = tweenTo(CFrame.new(npcPos))
                            if tween then
                                local completed = false
                                local conn
                                conn = tween.Completed:Connect(function() completed = true stopNoclip() end)
                                local start = tick()
                                while not completed and Toggles.AutoFarm and tick() - start < 15 do task.wait(0.1) end
                                if conn then conn:Disconnect() end
                                stopNoclip()
                                if not Toggles.AutoFarm then
                                    stopTween()
                                    isRequestingQuest = false
                                    doingQuest = false
                                    break
                                end
                            end
                        end
                    end
                    
                    -- Only accept if we still don't have a quest to avoid progress reset (0 progress bug)
                    if Toggles.AutoFarm and not hasQuest() then
                        takeQuest(SelectedQuest)
                        -- Wait for server to update stats (hasQuest to become true)
                        local start = tick()
                        while not hasQuest() and Toggles.AutoFarm and tick() - start < 5 do
                            task.wait(0.1)
                        end
                    end
                    isRequestingQuest = false
                end
            else
                doingQuest = false
            end
        else
            doingQuest = false
        end
    end
end)

-- Movement & Target Tracking Loop
task.spawn(function()
    while task.wait(0.2) do
        if Toggles.AutoFarm or (Toggles.BossFarm and currentBossTarget) then
            local target = getTargetNPC()
            local char = localPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if root then
                if target and target:FindFirstChild("HumanoidRootPart") then
                    local targetPos = target.HumanoidRootPart.Position
                    local dist = (root.Position - targetPos).Magnitude
                    
                    if dist > 20 then
                        -- Tween to target
                        tweenTo(target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4))
                    else
                        -- Stay close for combat
                        stopTween()
                        if not Toggles.NPC_Drag then
                            root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                        end
                    end
                elseif Toggles.AutoFarm and not doingQuest then
                    -- No targets found. Tween to Mob Spawn zone
                    stopTween()
                    local spawnPos = QuestData[SelectedQuest].Spawn_Pos
                    local distToSpawn = (root.Position - spawnPos).Magnitude
                    if distToSpawn > 15 then
                        local tween = tweenTo(CFrame.new(spawnPos))
                        if tween then
                            local completed = false
                            local conn
                            conn = tween.Completed:Connect(function() completed = true stopNoclip() end)
                            local start = tick()
                            while not completed and Toggles.AutoFarm and tick() - start < 10 do task.wait(0.1) end
                            if conn then conn:Disconnect() end
                            stopNoclip()
                            if not Toggles.AutoFarm then
                                stopTween()
                            end
                        end
                    end
                end
            end
        else
            if not Toggles.AutoFarm and not (Toggles.BossFarm and currentBossTarget) and activeTween then
                stopTween()
            end
        end
    end
end)

-- Combat Execution (Heartbeat)
local lastAttackTime = 0
local comboIndex = 1

RunService.Heartbeat:Connect(function()
    if not Toggles.AutoFarm and not Toggles.KillAura and not (Toggles.BossFarm and currentBossTarget) then return end
    if doingQuest and not Toggles.KillAura and not (Toggles.BossFarm and currentBossTarget) then return end
    if playerDetectorPaused then return end
    
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local target = getTargetNPC()

    if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
        -- Drag
        if Toggles.NPC_Drag then
            pcall(function()
                target.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(CONFIG.DragOffset)
                target.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                target.HumanoidRootPart.RotVelocity = Vector3.new(0,0,0)
            end)
        end

        -- Attack
        local currentTime = tick()
        if currentTime - lastAttackTime >= CONFIG.AttackCooldown then
            lastAttackTime = currentTime
            
            pcall(function()
                if target.Humanoid.Health > 0 then
                    local cancellations = 0
                    if char:FindFirstChild("Cancellations") then
                        cancellations = char.Cancellations.Value
                    end
                    
                    Remotes.PlayFx:FireServer("", comboIndex)
                    if comboIndex == 6 then
                        Remotes.Punch:FireServer(target.Humanoid, 6, cancellations, "Heavy", "DamageMultiplier: 2")
                    else
                        Remotes.Punch:FireServer(target.Humanoid, comboIndex, cancellations, nil, "DamageMultiplier: 1")
                    end
                    
                    local safeName = target.Name
                    if SelectedNPCs then
                        for _, n in pairs(SelectedNPCs) do
                            if target.Name:find(n) then
                                safeName = n
                                break
                            end
                        end
                    end
                    Remotes.Knockback:FireServer(safeName, 2)
                    
                    comboIndex = comboIndex + 1
                    if comboIndex > 6 then comboIndex = 1 end
                else
                    comboIndex = 1
                end
            end)
        end
    end
end)

-- Auto Collect Drops
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.AutoCollect then
            pcall(function()
                local char = localPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local drops = workspace:FindFirstChild("drops")
                
                if root and drops and firetouchinterest then
                    for _, drop in ipairs(drops:GetDescendants()) do
                        if drop:IsA("BasePart") and drop:FindFirstChild("TouchInterest") then
                            firetouchinterest(root, drop, 0)
                            task.wait()
                            firetouchinterest(root, drop, 1)
                        end
                    end
                end
            end)
        end
    end
end)

-- Stats Loop (Smart Profile Support)
local statNames = {"Power", "Defense", "Speed", "Recovery", "Trick"}

task.spawn(function()
    while task.wait(1.5) do
        local mode = (Options.StatProfileMode and Options.StatProfileMode.Value) or "Individual Toggles"
        if mode == "Individual Toggles" then
            -- Old behavior
            for stat, enabled in pairs(Toggles.AutoStats) do
                if enabled then
                    pcall(function()
                        Remotes.StatPoint:InvokeServer(stat)
                    end)
                end
            end
        else
            -- Profile behavior
            local weights = {Power = 0, Defense = 0, Speed = 0, Recovery = 0, Trick = 0}
            if mode == "Glass Cannon" then
                weights.Power = 80
                weights.Speed = 20
            elseif mode == "Tank" then
                weights.Defense = 60
                weights.Recovery = 40
            elseif mode == "Balanced" then
                weights.Power = 20
                weights.Defense = 20
                weights.Speed = 20
                weights.Recovery = 20
                weights.Trick = 20
            elseif mode == "Speed Demon" then
                weights.Speed = 80
                weights.Power = 20
            elseif mode == "Trickster" then
                weights.Trick = 80
                weights.Speed = 20
            elseif mode == "Custom Ratio" then
                weights.Power = Options.StatRatioPower.Value or 20
                weights.Defense = Options.StatRatioDefense.Value or 20
                weights.Speed = Options.StatRatioSpeed.Value or 20
                weights.Recovery = Options.StatRatioRecovery.Value or 20
                weights.Trick = Options.StatRatioTrick.Value or 20
            end
            
            -- Read current allocated stat points from player stats JSON
            local statsVal = localPlayer:FindFirstChild("Stats")
            if statsVal and statsVal:IsA("StringValue") then
                local success, data = pcall(function()
                    return HttpService:JSONDecode(statsVal.Value)
                end)
                
                if success and data and data.StatPoints then
                    local statPoints = data.StatPoints
                    local bestStat = nil
                    local minScore = math.huge
                    
                    for _, name in ipairs(statNames) do
                        local weight = weights[name] or 0
                        if weight > 0 then
                            local current = statPoints[name] or 0
                            local score = current / weight
                            if score < minScore then
                                minScore = score
                                bestStat = name
                            end
                        end
                    end
                    
                    if bestStat then
                        pcall(function()
                            Remotes.StatPoint:InvokeServer(bestStat)
                        end)
                    end
                end
            end
        end
    end
end)

-- Auto Ability Reroller Loop
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.AutoReroll then
            local success, err = pcall(function()
                if RerollType == "Bulk" then
                    Remotes.Reroll:InvokeServer(nil, nil, true)
                elseif RerollType == "Single" then
                    Remotes.Reroll:InvokeServer()
                else
                    Remotes.Reroll:InvokeServer(SelectedTicket)
                end
            end)
            if not success then
                task.wait(1.5)
            end
        end
    end
end)

-- Auto Trait Reroller Loop
task.spawn(function()
    while task.wait(1) do
        if Toggles.AutoTraitReroll then
            local hasTarget = false
            local currentTraits = getActiveTraits()
            for _, t in ipairs(currentTraits) do
                if t:lower() == SelectedTargetTrait:lower() then
                    hasTarget = true
                    break
                end
            end
            
            if hasTarget then
                Toggles.AutoTraitReroll = false
                Options.AutoTraitToggle:SetValue(false)
                Fluent:Notify({
                    Title = "Trait Reroll",
                    Content = "Successfully rolled target trait: " .. SelectedTargetTrait .. "!",
                    Duration = 10
                })
            else
                local char = localPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local nickPos = Vector3.new(-145.680, 280.655, 528.068)
                if root then
                    if (root.Position - nickPos).Magnitude > 10 then
                        root.CFrame = CFrame.new(nickPos)
                        task.wait(0.5)
                    end
                end
                pcall(function()
                    Remotes.TraitReroll:FireServer("Trait")
                end)
            end
        end
    end
end)

-- Gear Reroll & Upgrade Loops
task.spawn(function()
    while task.wait(1) do
        if Toggles.AutoRollFist then
            pcall(function()
                Remotes.RollGear:InvokeServer("Fist")
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if Toggles.AutoRollRelic then
            pcall(function()
                Remotes.RollGear:InvokeServer("Relic")
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if Toggles.AutoRollAura then
            pcall(function()
                Remotes.RollGear:InvokeServer("Aura")
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if Toggles.AutoUpgradeFist then
            pcall(function()
                local statsVal = localPlayer:FindFirstChild("Stats")
                if statsVal then
                    local v13 = HttpService:JSONDecode(statsVal.Value)
                    if v13 and v13.Fists then
                        for i = 1, #v13.Fists do
                            Remotes.UpgradeItem:InvokeServer("Fist", i)
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if Toggles.AutoUpgradeRelic then
            pcall(function()
                local statsVal = localPlayer:FindFirstChild("Stats")
                if statsVal then
                    local v13 = HttpService:JSONDecode(statsVal.Value)
                    if v13 and v13.Relics then
                        for i = 1, #v13.Relics do
                            Remotes.UpgradeItem:InvokeServer("Relic", i)
                        end
                    end
                end
            end)
        end
    end
end)

-- Spin Wheel Loop
task.spawn(function()
    while task.wait(5) do
        if Toggles.AutoSpin then
            pcall(function()
                if localPlayer:FindFirstChild("WheelSpins") and localPlayer.WheelSpins.Value > 0 then
                    Remotes.SpinWheel:InvokeServer("Roll")
                end
            end)
        end
    end
end)

-- Auto Roll Loop (Tickets)
task.spawn(function()
    while task.wait(5) do
        if Toggles.AutoRoll then
            pcall(function()
                Remotes.Reroll:InvokeServer()
            end)
        end
    end
end)

-- Auto Claim Achievements Loop
task.spawn(function()
    while task.wait(10) do
        if Toggles.AutoAchieve then
            pcall(function()
                local achieves = {"Rank Up", "Aura Pro", "Face Puncher", "Skilled Fighter", "Boss Slayer"}
                for _, ach in ipairs(achieves) do
                    Remotes.Achieved:InvokeServer(ach)
                    task.wait(0.2)
                end
            end)
        end
    end
end)

-- Auto Upgrade Potential Loop
task.spawn(function()
    while task.wait(1) do
        if Toggles.AutoPotential then
            pcall(function()
                Remotes.PotentialToken:FireServer()
            end)
        end
    end
end)

-- Skills Loop
task.spawn(function()
    while task.wait(4) do
        if Toggles.AutoSkills then
            pcall(function()
                Remotes.ToggleAbility:InvokeServer(false)
                task.wait(0.2)
                Remotes.ToggleAbility:InvokeServer(true)
            end)
        end
    end
end)

-- Block Loop
task.spawn(function()
    local wasBlocking = false
    while task.wait(0.1) do
        if Toggles.AutoBlock then
            if not wasBlocking then
                Remotes.Block:FireServer(true)
                wasBlocking = true
            end
        elseif wasBlocking then
            Remotes.Block:FireServer(false)
            wasBlocking = false
        end
    end
end)

-- Anti-AFK
local vu = game:GetService("VirtualUser")
localPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- WalkSpeed & JumpPower Heartbeat Loop
RunService.Heartbeat:Connect(function()
    local char = localPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        if Toggles.SpeedHack then
            hum.WalkSpeed = CONFIG.SpeedValue or 16
        end
        if Toggles.JumpHack then
            hum.UseJumpPower = true
            hum.JumpPower = CONFIG.JumpValue or 50
        end
    end
end)

-- Hook _G.adjustspeed to force custom speed
task.spawn(function()
    while not _G.adjustspeed do task.wait(0.5) end
    local originalAdjustSpeed = _G.adjustspeed
    _G.adjustspeed = function(p1, p2)
        if originalAdjustSpeed then
            originalAdjustSpeed(p1, p2)
        end
        local char = localPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum and Toggles.SpeedHack then
            hum.WalkSpeed = CONFIG.SpeedValue or 16
        end
    end
end)

-- Infinite Jump Handler
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfiniteJump then
        pcall(function()
            local char = localPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- ESP Loop
task.spawn(function()
    while task.wait(1) do
        if Toggles.PlayerESP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    applyHighlight(player.Character, Color3.fromRGB(0, 162, 255), playerHighlights)
                end
            end
            for char, _ in pairs(playerHighlights) do
                local player = Players:GetPlayerFromCharacter(char)
                if not player or not char.Parent then
                    removeHighlight(char, playerHighlights)
                end
            end
        end
        
        if Toggles.NPC_ESP then
            local npcFolders = {workspace:FindFirstChild("QuestNPCs"), workspace:FindFirstChild("AltNPCs")}
            for _, folder in ipairs(npcFolders) do
                if folder then
                    for _, npc in ipairs(folder:GetChildren()) do
                        if npc:IsA("Model") then
                            applyHighlight(npc, Color3.fromRGB(255, 162, 0), npcHighlights)
                        end
                    end
                end
            end
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj ~= localPlayer.Character and not Players:GetPlayerFromCharacter(obj) 
                   and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                    applyHighlight(obj, Color3.fromRGB(255, 0, 100), npcHighlights)
                end
            end
            for npc, _ in pairs(npcHighlights) do
                if not npc.Parent then
                    removeHighlight(npc, npcHighlights)
                end
            end
        end
    end
end)

-- Fly Hotkey listener
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        Toggles.Fly = not Toggles.Fly
        pcall(function() Options.FlyToggle:SetValue(Toggles.Fly) end)
    end
end)

-- Anti-Admin & Player Detector Loop
local playerDetectorPaused = false
local originalCFrameBeforeTP = nil

task.spawn(function()
    while task.wait(1) do
        -- 1. Anti-Admin check
        if Toggles.AntiAdmin then
            local adminFound = false
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer then
                    local isStaff = false
                    -- Creator check
                    if player.UserId == game.CreatorId then
                        isStaff = true
                    end
                    -- Group rank check
                    if not isStaff and game.CreatorType == Enum.CreatorType.Group then
                        local rank = player:GetRankInGroup(game.CreatorId)
                        if rank and rank >= 100 then
                            isStaff = true
                        end
                    end
                    -- Official Roblox Admin check
                    if not isStaff then
                        pcall(function()
                            if player:GetRankInGroup(1200769) > 0 then
                                isStaff = true
                            end
                        end)
                    end
                    if isStaff then
                        adminFound = true
                        break
                    end
                end
            end
            
            if adminFound then
                if Options.AntiAdminAction.Value == "Disconnect" then
                    localPlayer:Kick("Security: Staff/Admin detected in server.")
                else
                    serverHop()
                end
                task.wait(5)
            end
        end
        
        -- 2. Player Proximity Detector check
        if Toggles.PlayerDetector then
            local nearbyPlayerFound = false
            local whitelistStr = (Options.PlayerWhitelist and Options.PlayerWhitelist.Value) or ""
            local whitelist = {}
            for name in string.gmatch(whitelistStr, "[^,%s]+") do
                whitelist[name:lower()] = true
            end
            
            local char = localPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        if not whitelist[player.Name:lower()] and not whitelist[player.DisplayName:lower()] then
                            local dist = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= (Options.PlayerDetectorRadius.Value or 50) then
                                nearbyPlayerFound = true
                                break
                            end
                        end
                    end
                end
            end
            
            if nearbyPlayerFound then
                playerDetectorPaused = true
                if Options.PlayerDetectorAction.Value == "Teleport to Safe Zone" then
                    local destName = Options.PlayerDetectorSafeZone.Value
                    local destPos = Teleports.Locations[destName]
                    if destPos and char and root then
                        if not originalCFrameBeforeTP then
                            originalCFrameBeforeTP = root.CFrame
                        end
                        stopTween()
                        root.CFrame = CFrame.new(destPos)
                    end
                else
                    -- Pause farm
                    stopTween()
                end
            else
                if playerDetectorPaused then
                    playerDetectorPaused = false
                    -- Return to original position
                    if Options.PlayerDetectorAction.Value == "Teleport to Safe Zone" and originalCFrameBeforeTP then
                        local char = localPlayer.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.CFrame = originalCFrameBeforeTP
                        end
                        originalCFrameBeforeTP = nil
                    end
                end
            end
        else
            playerDetectorPaused = false
            originalCFrameBeforeTP = nil
        end
    end
end)

-- Auto Training Loop
task.spawn(function()
    while task.wait(0.2) do
        if Toggles.AutoTrainEndurance or Toggles.AutoTrainChainPrison then
            local char = localPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                doingQuest = true
                stopTween()
                
                local targetPos
                if Toggles.AutoTrainEndurance then
                    targetPos = Teleports.Locations["Endurance 100"]
                else
                    targetPos = Teleports.Locations["Chain Prison"]
                end
                
                if targetPos then
                    local dist = (root.Position - targetPos).Magnitude
                    if dist > 15 then
                        root.CFrame = CFrame.new(targetPos)
                        task.wait(0.5)
                    end
                    pcall(function()
                        Remotes.Train:FireServer()
                    end)
                end
            end
        end
    end
end)

-- Anti-Ragdoll & Anti-Stun Handler
local function setupAntiRagdoll(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        if Toggles.AntiRagdoll then
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        end
        hum.StateChanged:Connect(function(old, new)
            if Toggles.AntiRagdoll and (new == Enum.HumanoidStateType.Physics or new == Enum.HumanoidStateType.Ragdoll) then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end
end

localPlayer.CharacterAdded:Connect(setupAntiRagdoll)
if localPlayer.Character then
    setupAntiRagdoll(localPlayer.Character)
end

task.spawn(function()
    while task.wait(0.1) do
        if Toggles.AntiStun then
            local char = localPlayer.Character
            if char then
                for _, child in ipairs(char:GetChildren()) do
                    if child:IsA("ValueBase") then
                        local name = child.Name:lower()
                        if name:find("stun") or name:find("slow") or name:find("confused") then
                            pcall(function() child:Destroy() end)
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Equip Best Gear Loop
task.spawn(function()
    while task.wait(5) do
        if Toggles.AutoEquipBest then
            local statsVal = localPlayer:FindFirstChild("Stats")
            if statsVal and statsVal:IsA("StringValue") then
                local success, data = pcall(function()
                    return HttpService:JSONDecode(statsVal.Value)
                end)
                
                if success and data then
                    local info = require(game.ReplicatedStorage:WaitForChild("Info"))
                    
                    -- Fists
                    if data.Fists and #data.Fists > 0 then
                        local bestIdx = nil
                        local bestVal = -math.huge
                        for i, fist in ipairs(data.Fists) do
                            local fistScore = 0
                            pcall(function()
                                local stats = info.GetFistStats(fist.Name, fist.Level)
                                for _, val in pairs(stats) do
                                    fistScore = fistScore + val
                                end
                            end)
                            if fistScore > bestVal then
                                bestVal = fistScore
                                bestIdx = i
                            end
                        end
                        if bestIdx and bestIdx ~= data.Fist then
                            pcall(function()
                                game.ReplicatedStorage.Equip:FireServer("Fist", bestIdx)
                            end)
                        end
                    end
                    
                    -- Relics
                    if data.Relics and #data.Relics > 0 then
                        local bestIdx = nil
                        local bestVal = -math.huge
                        for i, relic in ipairs(data.Relics) do
                            local relicVal = 0
                            pcall(function()
                                relicVal = info.GetRelicStat(relic.Name, relic.Level)
                            end)
                            if relicVal > bestVal then
                                bestVal = relicVal
                                bestIdx = i
                            end
                        end
                        if bestIdx and bestIdx ~= data.Relic then
                            pcall(function()
                                game.ReplicatedStorage.Equip:FireServer("Relic", bestIdx)
                            end)
                        end
                    end
                    
                    -- Auras
                    if data.Auras and #data.Auras > 0 then
                        local bestIdx = nil
                        local bestVal = -math.huge
                        for i, aura in ipairs(data.Auras) do
                            local auraVal = 0
                            pcall(function()
                                auraVal = info.Auras[aura.Name].GetStat(aura.Level)
                            end)
                            if auraVal > bestVal then
                                bestVal = auraVal
                                bestIdx = i
                            end
                        end
                        if bestIdx and bestIdx ~= data.Aura then
                            pcall(function()
                                game.ReplicatedStorage.Equip:FireServer("Aura", bestIdx)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- Boss Farming Loop
task.spawn(function()
    local lastHopTime = tick()
    while task.wait(1) do
        if Toggles.BossFarm then
            local boss = getActiveBoss()
            if boss then
                currentBossTarget = boss
            else
                currentBossTarget = nil
                if Toggles.BossHopOnCooldown and tick() - lastHopTime > 15 then
                    serverHop()
                    lastHopTime = tick()
                    task.wait(5)
                end
            end
        else
            currentBossTarget = nil
        end
    end
end)

-- Aura Color Heartbeat Loop
RunService.Heartbeat:Connect(function()
    if Toggles.CustomAuraColorEnabled then
        local char = localPlayer.Character
        if char then
            local customColor = (Options.CustomAuraColor and Options.CustomAuraColor.Value) or Color3.fromRGB(255, 0, 0)
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("ParticleEmitter") then
                    local name = v.Name:lower()
                    if name:find("aura") or name:find("particle") or name:find("effect") then
                        v.Color = ColorSequence.new(customColor)
                    end
                elseif v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                    local name = v.Name:lower()
                    if name:find("aura") or name:find("light") or name:find("effect") then
                        v.Color = customColor
                    end
                end
            end
        end
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("UltraUnfairGemini")
SaveManager:SetFolder("UltraUnfairGemini/Main")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)

Fluent:Notify({
    Title = "Ultra Unfair v3.2",
    Content = "BAKE DORACAKE ,SCRIPT LOADED!",
    Duration = 5
})
