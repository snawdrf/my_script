local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Prevent overlapping script executions and clean up previous run threads/listeners
_G.GG2_ScriptCount = (_G.GG2_ScriptCount or 0) + 1
local currentInstance = _G.GG2_ScriptCount

-- ProximityPrompt Caching to completely resolve workspace scanning lag
local allPrompts = {}
if _G.GG2_Connections then
    for _, conn in ipairs(_G.GG2_Connections) do
        pcall(function() conn:Disconnect() end)
    end
end
_G.GG2_Connections = {}

local function registerConnection(conn)
    table.insert(_G.GG2_Connections, conn)
end

local function onDescendantAdded(desc)
    if desc:IsA("ProximityPrompt") then
        table.insert(allPrompts, desc)
    end
end

local function onDescendantRemoving(desc)
    if desc:IsA("ProximityPrompt") then
        local idx = table.find(allPrompts, desc)
        if idx then
            table.remove(allPrompts, idx)
        end
    end
end

for _, desc in ipairs(workspace:GetDescendants()) do
    if desc:IsA("ProximityPrompt") then
        table.insert(allPrompts, desc)
    end
end

registerConnection(workspace.DescendantAdded:Connect(onDescendantAdded))
registerConnection(workspace.DescendantRemoving:Connect(onDescendantRemoving))

-- Clean up Fluent's DepthOfField blur immediately to unblur background
local function disableDepthOfField()
    for _, effect in ipairs(game.Lighting:GetChildren()) do
        if effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = false
        end
    end
end
disableDepthOfField()
game.Lighting.ChildAdded:Connect(function(child)
    if child:IsA("DepthOfFieldEffect") then
        task.wait()
        child.Enabled = false
    end
end)

-- Safe Loading of Game Modules (Asynchronous)
local SeedData = nil
local CrateData = nil
local GearShopData = nil
local Networking = nil

local function loadModules()
    local sharedModules = ReplicatedStorage:WaitForChild("SharedModules", 15)
    if not sharedModules then
        warn("SharedModules not found in ReplicatedStorage!")
        return false
    end
    
    local success1, err1 = pcall(function()
        Networking = require(sharedModules:WaitForChild("Networking", 5))
    end)
    local success2, err2 = pcall(function()
        SeedData = require(sharedModules:WaitForChild("SeedData", 5))
    end)
    local success3, err3 = pcall(function()
        CrateData = require(sharedModules:WaitForChild("CrateData", 5))
    end)
    local success4, err4 = pcall(function()
        GearShopData = require(sharedModules:WaitForChild("GearShopData", 5))
    end)
    
    if not (success1 and success2 and success3 and success4) then
        warn("Error requiring modules: ", err1, err2, err3, err4)
        return false
    end
    return true
end

-- State Configurations
_G.AutoFarmEnabled = false
_G.AutoFarmBetter = false
_G.MovementMode = "Instant" -- "Instant" or "Tween"
_G.TweenSpeed = 50
_G.AutoCollect = false
_G.AutoSell = false
_G.SellMode = "All" -- "All" or "Selective"
_G.SelectedCropsToSell = {}

_G.BuySeedsMode = "All" -- "All" or "Selected"
_G.SelectedSeedsToBuy = {}
_G.BuyCratesMode = "All" -- "All" or "Selected"
_G.SelectedCratesToBuy = {}
_G.BuyGearsMode = "All" -- "All" or "Selected"
_G.SelectedGearsToBuy = {}

_G.BuyRarity = "All"
_G.AutoBuyWholeShop = false
_G.AutoBuyCrates = false
_G.AutoBuyGears = false

_G.AutoSteal = false
_G.ProtectGarden = false
_G.ShovelAura = false
_G.EquipShovelKillAura = false
_G.GoldenSeedFarm = false
_G.SeedPackFarm = false
_G.AutoGrow = false
_G.AutoPot = false
_G.WalkSpeedValue = 16
_G.JumpPowerValue = 50
_G.CustomWalkSpeed = false
_G.CustomJumpPower = false

-- Fallback UI Lists (populates instantly to prevent empty tabs/crashes)
local seedNames = {"Wheat", "Tomato", "Pumpkin", "Carrot", "Bamboo", "Strawberry", "Berry"}
local crateNames = {"Common Crate", "Uncommon Crate", "Rare Crate", "Epic Crate", "Legendary Crate", "Mythic Crate", "Super Crate"}
local gearNames = {"Watering Can", "Super Watering Can", "Golden Watering Can", "Wooden Rake", "Golden Rake", "Shovel"}

-- Locate Local Player's Plot
local myPlot = nil
local function getMyPlot()
    if myPlot and myPlot.Parent then return myPlot end
    local plotId = LocalPlayer:GetAttribute("PlotId")
    if plotId then
        myPlot = workspace.Gardens:FindFirstChild("Plot" .. tostring(plotId))
        if myPlot then return myPlot end
    end
    for _, plot in ipairs(workspace.Gardens:GetChildren()) do
        if plot:GetAttribute("OwnerUserId") == LocalPlayer.UserId or plot:GetAttribute("Owner") == LocalPlayer.Name then
            myPlot = plot
            return plot
        end
    end
    return nil
end
getMyPlot()

-- Utility: Get Bounding / Grid Points on Plant Bed Parts
local function getGridPoints(part, spacing)
    local points = {}
    local size = part.Size
    local cframe = part.CFrame
    local halfX = size.X / 2
    local halfZ = size.Z / 2
    
    local startX = -halfX + spacing/2
    local endX = halfX - spacing/2
    local startZ = -halfZ + spacing/2
    local endZ = halfZ - spacing/2
    
    for x = startX, endX, spacing do
        for z = startZ, endZ, spacing do
            local localPos = Vector3.new(x, size.Y/2 + 0.1, z)
            local worldPos = cframe:PointToWorldSpace(localPos)
            table.insert(points, worldPos)
        end
    end
    return points
end

-- Utility: Find all Plant Bed Parts for a Plot
local function getPlantAreas(plot)
    local areas = {}
    for _, part in ipairs(plot:GetDescendants()) do
        if part:IsA("BasePart") and (CollectionService:HasTag(part, "PlantArea") or part.Name:find("PlantArea") or part.Name:find("BedSection")) then
            table.insert(areas, part)
        end
    end
    return areas
end

-- Utility: Check if a Position is clear of existing plants
local function isPositionFarFromPlants(position, plantsFolder, minDistance)
    if not plantsFolder then return true end
    for _, plant in ipairs(plantsFolder:GetChildren()) do
        if plant:IsA("Model") then
            local plantPos = plant.PrimaryPart and plant.PrimaryPart.Position or plant:GetPivot().Position
            local dist = (Vector2.new(position.X, position.Z) - Vector2.new(plantPos.X, plantPos.Z)).Magnitude
            if dist < minDistance then
                return false
            end
        end
    end
    return true
end

-- Movement: Instant Teleport vs Tween
local function movePlayer(targetCFrame)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if _G.MovementMode == "Tween" then
        local dist = (hrp.Position - targetCFrame.Position).Magnitude
        local duration = dist / _G.TweenSpeed
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        
        hrp.Anchored = true
        tween:Play()
        tween.Completed:Wait()
        hrp.Anchored = false
    else
        hrp.CFrame = targetCFrame
    end
end

-- Helper: Identify if a tool is a harvested crop/fruit
local function isCropTool(tool)
    if not tool then return false end
    if not (tool:IsA("Tool") or tool:IsA("Configuration")) then return false end
    if tool:GetAttribute("HarvestedFruit") == true then return true end
    if tool:GetAttribute("FruitName") ~= nil then return true end
    if tool:GetAttribute("FruitProxy") == true then return true end
    
    local name = tool.Name:lower()
    -- Check if it matches any seed name
    for _, sName in ipairs(seedNames) do
        local lowerSName = sName:lower()
        if name == lowerSName or name:find(lowerSName) then
            -- Exclude seed tools, cans, rakes, shovels, pots, etc.
            if not name:find("seed") and not name:find("can") and not name:find("rake") and not name:find("shovel") and not name:find("pot") then
                return true
            end
        end
    end
    if name:find("fruit") or name:find("harvest") then
        if not name:find("seed") and not name:find("can") and not name:find("rake") and not name:find("shovel") and not name:find("pot") then
            return true
        end
    end
    return false
end

-- Utility: Count current crops in character & backpack
local function getCurrentCropCount()
    local count = 0
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    
    local function countIn(container)
        if not container then return end
        for _, tool in ipairs(container:GetChildren()) do
            if isCropTool(tool) then
                count = count + 1
            end
        end
    end
    countIn(bp)
    countIn(char)
    return count
end

-- Utility: Check seed inventory count
local function getOwnedSeedsCount(seedName)
    local count = 0
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    
    local function check(container)
        if not container then return end
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == seedName .. " Seed" or tool.Name == seedName or tool:GetAttribute("SeedTool") == seedName) then
                count = count + 1
            end
        end
    end
    check(bp)
    check(char)
    return count
end

-- Utility: Retrieve a seed tool from backpack or character
local function getSeedTool(seedName)
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == seedName .. " Seed" or tool.Name == seedName or tool:GetAttribute("SeedTool") == seedName) then
                return tool
            end
        end
    end
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == seedName .. " Seed" or tool.Name == seedName or tool:GetAttribute("SeedTool") == seedName) then
                return tool
            end
        end
    end
    return nil
end

-- Utility: Check shop item stock
local function getStock(shopName, itemName)
    local stockValues = ReplicatedStorage:FindFirstChild("StockValues")
    local shopStock = stockValues and stockValues:FindFirstChild(shopName)
    local items = shopStock and shopStock:FindFirstChild("Items")
    local itemVal = items and items:FindFirstChild(itemName)
    return itemVal and itemVal.Value or 0
end

-- Selling Crops (Selective & Sell All)
local function sellCrops()
    if not Networking then
        loadModules()
    end
    if Networking and Networking.NPCS and Networking.NPCS.SellAll then
        pcall(function()
            Networking.NPCS.SellAll:Fire()
        end)
        task.wait(0.3)
    end
end

local function sellCropsSelective()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    if not bp or not char then return end
    
    if _G.SellMode == "All" then
        sellCrops()
        return
    end
    
    local tempStorage = LocalPlayer:FindFirstChild("TempToolStorage")
    if not tempStorage then
        tempStorage = Instance.new("Folder")
        tempStorage.Name = "TempToolStorage"
        tempStorage.Parent = LocalPlayer
    end
    
    local savedTools = {}
    local function processContainer(container)
        for _, tool in ipairs(container:GetChildren()) do
            if isCropTool(tool) then
                local name = tool:GetAttribute("FruitName") or tool.Name
                -- Clean name for comparison
                local cleanName = name
                cleanName = cleanName:gsub("%s*[Ff]ruit%s*$", "")
                cleanName = cleanName:gsub("%s*[Ss]eed%s*$", "")
                cleanName = cleanName:gsub("%s*[Cc]rop%s*$", "")
                cleanName = cleanName:match("^%s*(.-)%s*$") -- trim whitespace
                
                local sellThis = false
                if _G.SelectedCropsToSell[cleanName] == true then
                    sellThis = true
                else
                    for k, v in pairs(_G.SelectedCropsToSell) do
                        if v and k:lower() == cleanName:lower() then
                            sellThis = true
                            break
                        end
                    end
                end
                
                if not sellThis then
                    tool.Parent = tempStorage
                    table.insert(savedTools, tool)
                end
            end
        end
    end
    
    processContainer(bp)
    processContainer(char)
    
    sellCrops()
    task.wait(0.4)
    
    for _, tool in ipairs(savedTools) do
        tool.Parent = bp
    end
end

-- Shovel Combat: Swing & Hit Player
local function hitPlayerWithShovel(targetPlayer)
    local char = LocalPlayer.Character
    if not char then return end
    
    local shovel = char:FindFirstChild("Shovel") or LocalPlayer.Backpack:FindFirstChild("Shovel")
    if not shovel then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("shovel") then
                shovel = t; break
            end
        end
        if not shovel then
            for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if t:IsA("Tool") and t.Name:lower():find("shovel") then
                    shovel = t; break
                end
            end
        end
    end
    
    if shovel then
        if shovel.Parent ~= char then
            shovel.Parent = char
            task.wait(0.1)
        end
        Networking.Shovel.SwingShovel:Fire()
        Networking.Shovel.HitPlayer:Fire(targetPlayer.UserId)
    end
end

-- Shovel Equip + Kill Aura Core Function
local function autoEquipAndKillAura()
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Find and equip shovel
    local shovel = char:FindFirstChild("Shovel") or LocalPlayer.Backpack:FindFirstChild("Shovel")
    if not shovel then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("shovel") then
                shovel = t; break
            end
        end
        if not shovel then
            for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if t:IsA("Tool") and t.Name:lower():find("shovel") then
                    shovel = t; break
                end
            end
        end
    end
    
    if shovel and shovel.Parent ~= char then
        shovel.Parent = char
        task.wait(0.1)
    end
    
    -- Swing and hit nearby players
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist <= 18 then
                    Networking.Shovel.SwingShovel:Fire()
                    Networking.Shovel.HitPlayer:Fire(player.UserId)
                end
            end
        end
    end
end

-- UI Setup (Dawid's Fluent UI with Acrylic Disabled)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Grow A Garden 2",
    SubTitle = "Premium Automation Script",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- FIXED: Disabled background blur
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Auto Farm", Icon = "home" }),
    Steal = Window:AddTab({ Title = "Auto Steal", Icon = "swords" }),
    Shops = Window:AddTab({ Title = "Shops & Sell", Icon = "shopping-cart" }),
    Misc = Window:AddTab({ Title = "Miscellaneous", Icon = "settings" })
}

-- Tab 1: Auto Farm Controls
local ToggleFarm = Tabs.Main:AddToggle("AutoFarmToggle", {
    Title = "Auto Farm",
    Default = false,
    Callback = function(v)
        _G.AutoFarmEnabled = v
        if not v then
            pcall(function()
                local plot = getMyPlot()
                local spawnPt = plot and plot:FindFirstChild("SpawnPoint")
                if spawnPt then
                    movePlayer(spawnPt.CFrame + Vector3.new(0, 3, 0))
                end
            end)
        end
    end
})
local ToggleFarmBetter = Tabs.Main:AddToggle("AutoFarmBetterToggle", {
    Title = "Auto Farm Better (Single Harvest Only)",
    Default = false,
    Callback = function(v) _G.AutoFarmBetter = v end
})
local MoveModeDropdown = Tabs.Main:AddDropdown("MoveMode", {
    Title = "Movement Mode",
    Values = {"Instant", "Tween"},
    Default = "Instant",
    Callback = function(v) _G.MovementMode = v end
})
local SliderSpeed = Tabs.Main:AddSlider("TweenSpeedSlider", {
    Title = "Tween Speed",
    Min = 20, Max = 150, Default = 50,
    Rounding = 0,
    Callback = function(v) _G.TweenSpeed = v end
})

-- Separate Actions
local ToggleCollect = Tabs.Main:AddToggle("AutoCollectToggle", {
    Title = "Auto Collect/Harvest Plants",
    Default = false,
    Callback = function(v)
        _G.AutoCollect = v
        if not v then
            pcall(function()
                local plot = getMyPlot()
                local spawnPt = plot and plot:FindFirstChild("SpawnPoint")
                if spawnPt then
                    movePlayer(spawnPt.CFrame + Vector3.new(0, 3, 0))
                end
            end)
        end
    end
})
local ToggleSell = Tabs.Main:AddToggle("AutoSellToggle", {
    Title = "Auto Sell Backpack Crops",
    Default = false,
    Callback = function(v) _G.AutoSell = v end
})

-- Tab 2: Auto Steal & Shovel Combat
local ToggleSteal = Tabs.Steal:AddToggle("AutoStealToggle", {
    Title = "Auto Steal (Night Only)",
    Default = false,
    Callback = function(v)
        _G.AutoSteal = v
        if not v then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Anchored = false end
            end)
            pcall(function()
                local plot = getMyPlot()
                local spawnPt = plot and plot:FindFirstChild("SpawnPoint")
                if spawnPt then
                    movePlayer(spawnPt.CFrame + Vector3.new(0, 3, 0))
                end
            end)
        end
    end
})
local ToggleProtect = Tabs.Steal:AddToggle("ProtectGardenToggle", {
    Title = "Protect Garden (Auto-Kick Visitors)",
    Default = false,
    Callback = function(v) _G.ProtectGarden = v end
})
local ToggleShovelAura = Tabs.Steal:AddToggle("ShovelAuraToggle", {
    Title = "Shovel Kill Aura (Only swings shovel)",
    Default = false,
    Callback = function(v) _G.ShovelAura = v end
})
local ToggleEquipShovelKillAura = Tabs.Steal:AddToggle("EquipShovelKillAuraToggle", {
    Title = "Equip Shovel + Kill Aura (Auto equips & swings)",
    Default = false,
    Callback = function(v) _G.EquipShovelKillAura = v end
})

-- Tab 3: Shops & Sell
local SellModeDropdown = Tabs.Shops:AddDropdown("SellMode", {
    Title = "Sell Mode",
    Values = {"All", "Selective"},
    Default = "All",
    Callback = function(v) _G.SellMode = v end
})
local SellDropdown = Tabs.Shops:AddDropdown("SellDropdown", {
    Title = "Crops to Sell (Selective Mode)",
    Values = seedNames,
    Multi = true,
    Default = {},
    Callback = function(v) _G.SelectedCropsToSell = v end
})

-- Seeds Shop Configuration
local BuySeedsModeDropdown = Tabs.Shops:AddDropdown("BuySeedsMode", {
    Title = "Seed Buy Mode",
    Values = {"All", "Selected"},
    Default = "All",
    Callback = function(v) _G.BuySeedsMode = v end
})
local BuySeedsDropdown = Tabs.Shops:AddDropdown("BuySeedsDropdown", {
    Title = "Seeds to Auto Buy",
    Values = seedNames,
    Multi = true,
    Default = {},
    Callback = function(v) _G.SelectedSeedsToBuy = v end
})
local BuyRarityDropdown = Tabs.Shops:AddDropdown("BuyRarity", {
    Title = "Buy Seeds by Rarity Filter",
    Values = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"},
    Default = "All",
    Callback = function(v) _G.BuyRarity = v end
})

-- Crates Shop Configuration
local BuyCratesModeDropdown = Tabs.Shops:AddDropdown("BuyCratesMode", {
    Title = "Crate Buy Mode",
    Values = {"All", "Selected"},
    Default = "All",
    Callback = function(v) _G.BuyCratesMode = v end
})
local BuyCratesDropdown = Tabs.Shops:AddDropdown("BuyCratesDropdown", {
    Title = "Crates to Auto Buy (Cosmetics)",
    Values = crateNames,
    Multi = true,
    Default = {},
    Callback = function(v) _G.SelectedCratesToBuy = v end
})

-- Gears Shop Configuration
local BuyGearsModeDropdown = Tabs.Shops:AddDropdown("BuyGearsMode", {
    Title = "Gear Buy Mode",
    Values = {"All", "Selected"},
    Default = "All",
    Callback = function(v) _G.BuyGearsMode = v end
})
local BuyGearsDropdown = Tabs.Shops:AddDropdown("BuyGearsDropdown", {
    Title = "Gears to Auto Buy",
    Values = gearNames,
    Multi = true,
    Default = {},
    Callback = function(v) _G.SelectedGearsToBuy = v end
})

-- Shop Automation Toggles
local ToggleBuyWhole = Tabs.Shops:AddToggle("BuyWholeToggle", {
    Title = "Auto Buy Seeds (Active)",
    Default = false,
    Callback = function(v) _G.AutoBuyWholeShop = v end
})
local ToggleBuyCrates = Tabs.Shops:AddToggle("BuyCratesToggle", {
    Title = "Auto Buy Crates (Cosmetics)",
    Default = false,
    Callback = function(v) _G.AutoBuyCrates = v end
})
local ToggleBuyGears = Tabs.Shops:AddToggle("BuyGearsToggle", {
    Title = "Auto Buy Gears (Active)",
    Default = false,
    Callback = function(v) _G.AutoBuyGears = v end
})

-- Tab 4: Miscellaneous Features
local ToggleGoldenSeed = Tabs.Misc:AddToggle("GoldenSeedToggle", {
    Title = "Auto Collect Spawned Golden Seeds",
    Default = false,
    Callback = function(v) _G.GoldenSeedFarm = v end
})
local ToggleSeedPack = Tabs.Misc:AddToggle("SeedPackToggle", {
    Title = "Auto Collect Dropped Items (Seed Packs, Crates, etc.)",
    Default = false,
    Callback = function(v) _G.SeedPackFarm = v end
})
local ToggleGrow = Tabs.Misc:AddToggle("AutoGrowToggle", {
    Title = "Auto Grow/Water Plants (Spam Grow)",
    Default = false,
    Callback = function(v) _G.AutoGrow = v end
})
local TogglePot = Tabs.Misc:AddToggle("AutoPotToggle", {
    Title = "Auto Pot Plants (Multi-Harvests)",
    Default = false,
    Callback = function(v) _G.AutoPot = v end
})

-- Character Modifiers
local ToggleSpeed = Tabs.Misc:AddToggle("CustomSpeedToggle", {
    Title = "Custom WalkSpeed",
    Default = false,
    Callback = function(v) 
        _G.CustomWalkSpeed = v 
        if not v then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end)
        end
    end
})
local SliderSpeedVal = Tabs.Misc:AddSlider("WalkSpeedSlider", {
    Title = "WalkSpeed",
    Min = 16, Max = 150, Default = 16,
    Rounding = 0,
    Callback = function(v) _G.WalkSpeedValue = v end
})
local ToggleJump = Tabs.Misc:AddToggle("CustomJumpToggle", {
    Title = "Custom JumpPower",
    Default = false,
    Callback = function(v) 
        _G.CustomJumpPower = v 
        if not v then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = 50 end
            end)
        end
    end
})
local SliderJumpVal = Tabs.Misc:AddSlider("JumpPowerSlider", {
    Title = "JumpPower",
    Min = 50, Max = 250, Default = 50,
    Rounding = 0,
    Callback = function(v) _G.JumpPowerValue = v end
})

-- Teleports
Tabs.Misc:AddButton({
    Title = "Teleport to Spawn Stand",
    Callback = function()
        local stand = workspace:FindFirstChild("Teleports") and workspace.Teleports:FindFirstChild("Spawn")
        if stand then movePlayer(stand.CFrame + Vector3.new(0, 3, 0)) end
    end
})
Tabs.Misc:AddButton({
    Title = "Teleport to Seed Shop",
    Callback = function()
        local stand = workspace:FindFirstChild("Teleports") and workspace.Teleports:FindFirstChild("Seeds")
        if stand then movePlayer(stand.CFrame + Vector3.new(0, 3, 0)) end
    end
})
Tabs.Misc:AddButton({
    Title = "Teleport to Sell Area",
    Callback = function()
        local stand = workspace:FindFirstChild("Teleports") and workspace.Teleports:FindFirstChild("Sell")
        if stand then movePlayer(stand.CFrame + Vector3.new(0, 3, 0)) end
    end
})
Tabs.Misc:AddButton({
    Title = "Teleport to Own Garden Plot",
    Callback = function()
        local plot = getMyPlot()
        local spawnPt = plot and plot:FindFirstChild("SpawnPoint")
        if spawnPt then movePlayer(spawnPt.CFrame + Vector3.new(0, 3, 0)) end
    end
})

-- Mobile Draggable Toggle Button Fix
local function createMobileToggle()
    local parent = nil
    local success, _ = pcall(function() parent = game:GetService("CoreGui") end)
    if not success or not parent then
        parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Clean up pre-existing mobile toggle GUI
    local oldGui = parent:FindFirstChild("GG2ToggleGui")
    if oldGui then
        pcall(function() oldGui:Destroy() end)
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GG2ToggleGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = parent
    
    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Size = UDim2.new(0, 55, 0, 55)
    button.Position = UDim2.new(0.05, 0, 0.2, 0)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Text = "GG 2"
    button.Font = Enum.Font.JosefinSans
    button.BorderSizePixel = 0
    button.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 162, 232)
    stroke.Thickness = 2.5
    stroke.Parent = button
    
    -- Add image overlay with same rounded corners
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Name = "LogoImage"
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.BackgroundTransparency = 1
    imageLabel.BorderSizePixel = 0
    imageLabel.ZIndex = 11
    imageLabel.Image = ""
    imageLabel.Parent = button
    
    local imgCorner = Instance.new("UICorner")
    imgCorner.CornerRadius = UDim.new(0, 12)
    imgCorner.Parent = imageLabel
    
    -- Load asset asynchronously
    task.spawn(function()
        local rawUrl = "https://raw.githubusercontent.com/UNIVERSAL-SUN-HUB-DEV/spt/main/Gemini_Generated_Image_nu2dy6nu2dy6nu2d.jpeg"
        local success, data = pcall(function()
            return game:HttpGet(rawUrl)
        end)
        if success and data then
            local filename = "gg2_logo_nu2dy6.jpeg"
            local writeSuccess = pcall(function()
                writefile(filename, data)
            end)
            if writeSuccess then
                local assetSuccess, assetId = pcall(function()
                    return getcustomasset(filename)
                end)
                if assetSuccess and assetId then
                    imageLabel.Image = assetId
                    button.Text = "" -- hide default text if image loaded successfully
                end
            end
        end
    end)
    
    local dragging = false
    local dragInput, dragStart, startPos
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    button.Activated:Connect(function()
        Window:Minimize()
    end)
    
    button.Parent = screenGui
end
createMobileToggle()

-- Select first tab programmatically so controls render instantly on load
Window:SelectTab(1)

-- Asynchronous Module Loading & Dynamic Dropdown Population
task.spawn(function()
    for i = 1, 5 do
        if loadModules() then
            break
        end
        task.wait(2)
    end
    
    if SeedData then
        local newSeedNames = {}
        for _, item in pairs(SeedData) do
            if typeof(item) == "table" and item.SeedName and not table.find(newSeedNames, item.SeedName) then
                table.insert(newSeedNames, item.SeedName)
            end
        end
        if #newSeedNames > 0 then
            seedNames = newSeedNames
            pcall(function() SellDropdown:SetValues(seedNames) end)
            pcall(function() BuySeedsDropdown:SetValues(seedNames) end)
        end
    end
    
    if CrateData then
        local newCrateNames = {}
        -- FIXED: Removed pairs wrapper on CrateData.GetAllCrates generator function
        pcall(function()
            for _, crate in CrateData.GetAllCrates() do
                if typeof(crate) == "table" and crate.RestockChance and crate.Name and not table.find(newCrateNames, crate.Name) then
                    table.insert(newCrateNames, crate.Name)
                end
            end
        end)
        if #newCrateNames > 0 then
            crateNames = newCrateNames
            pcall(function() BuyCratesDropdown:SetValues(crateNames) end)
        end
    end
    
    if GearShopData then
        local newGearNames = {}
        for _, gear in pairs(GearShopData.Data) do
            if typeof(gear) == "table" and not gear.RobuxOnly and (gear.RestockChance or gear.EquippableGear) and gear.ItemName and not table.find(newGearNames, gear.ItemName) then
                table.insert(newGearNames, gear.ItemName)
            end
        end
        if #newGearNames > 0 then
            gearNames = newGearNames
            pcall(function() BuyGearsDropdown:SetValues(gearNames) end)
        end
    end
end)

-- Helper: Check if a specific seed is selected for purchase
local function isSeedSelectedForBuy(seedName)
    if _G.BuySeedsMode == "All" then
        return true
    end
    local hasSelection = false
    for k, v in pairs(_G.SelectedSeedsToBuy) do
        if v then hasSelection = true; break end
    end
    if not hasSelection then return true end
    return _G.SelectedSeedsToBuy[seedName] == true
end

-- Helper: Check if a crate is selected for purchase
local function isCrateSelectedForBuy(crateName)
    if _G.BuyCratesMode == "All" then
        return true
    end
    local hasSelection = false
    for k, v in pairs(_G.SelectedCratesToBuy) do
        if v then hasSelection = true; break end
    end
    if not hasSelection then return true end
    return _G.SelectedCratesToBuy[crateName] == true
end

-- Helper: Check if gear is selected for purchase
local function isGearSelectedForBuy(gearName)
    if _G.BuyGearsMode == "All" then
        return true
    end
    local hasSelection = false
    for k, v in pairs(_G.SelectedGearsToBuy) do
        if v then hasSelection = true; break end
    end
    if not hasSelection then return true end
    return _G.SelectedGearsToBuy[gearName] == true
end

---- BACKGROUND AUTOMATION LOOPS

-- Loop 1: Auto Buy Seeds / Crates / Gears (Selected or All modes)
task.spawn(function()
    while task.wait(1.5) do
        if _G.GG2_ScriptCount ~= currentInstance then break end
        if not SeedData then continue end
        local sheckles = LocalPlayer.leaderstats.Sheckles.Value
        
        -- Auto Buy Seeds
        if _G.AutoBuyWholeShop then
            pcall(function()
                for _, item in pairs(SeedData) do
                    if typeof(item) == "table" and item.RestockShop then
                        local name = item.SeedName
                        if isSeedSelectedForBuy(name) and (_G.BuyRarity == "All" or item.Rarity == _G.BuyRarity) then
                            local cost = item.PurchasePrice
                            local stock = getStock("SeedShop", name)
                            if stock > 0 and sheckles >= cost then
                                Networking.SeedShop.PurchaseSeed:Fire(name)
                                sheckles = sheckles - cost
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end)
        end
        
        -- Auto Buy Crates (Cosmetics)
        if _G.AutoBuyCrates and CrateData then
            pcall(function()
                for _, crate in CrateData.GetAllCrates() do
                    if typeof(crate) == "table" and crate.RestockChance then
                        local name = crate.Name
                        if isCrateSelectedForBuy(name) then
                            local cost = crate.Cost or 0
                            local stock = getStock("CrateShop", name)
                            if stock > 0 and sheckles >= cost then
                                Networking.CrateShop.PurchaseCrate:Fire(name)
                                sheckles = sheckles - cost
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end)
        end
        
        -- Auto Buy Gears
        if _G.AutoBuyGears and GearShopData then
            pcall(function()
                for _, gear in pairs(GearShopData.Data) do
                    if typeof(gear) == "table" and not gear.RobuxOnly and (gear.RestockChance or gear.EquippableGear) then
                        local name = gear.ItemName
                        if isGearSelectedForBuy(name) then
                            local cost = gear.Cost or 0
                            local stock = getStock("GearShop", name)
                            if stock > 0 and sheckles >= cost then
                                Networking.GearShop.PurchaseGear:Fire(name)
                                sheckles = sheckles - cost
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Loop 2: Shovel Kill Aura, Equip Shovel Aura, and Garden Protection (High Speed)
task.spawn(function()
    while task.wait(0.15) do
        if _G.GG2_ScriptCount ~= currentInstance then break end
        
        -- General Shovel Equip + Kill Aura
        if _G.EquipShovelKillAura then
            pcall(autoEquipAndKillAura)
        end
        
        -- Shovel Aura (only swings)
        if _G.ShovelAura and not _G.EquipShovelKillAura then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                            if dist <= 18 then
                                Networking.Shovel.SwingShovel:Fire()
                                Networking.Shovel.HitPlayer:Fire(player.UserId)
                            end
                        end
                    end
                end
            end)
        end
        
        -- Protect Garden (teleport, kick, teleport back)
        if _G.ProtectGarden then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local plot = getMyPlot()
                local prim = plot and plot.Visual:FindFirstChild("PRIM")
                if prim then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (player.Character.HumanoidRootPart.Position - prim.Position).Magnitude
                            if dist <= 60 then
                                local oldCFrame = hrp.CFrame
                                hrp.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                                task.wait(0.1)
                                hitPlayerWithShovel(player)
                                task.wait(0.1)
                                hrp.CFrame = oldCFrame
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Loop 3: Auto Collect Spawned Items (Universal Claimer for Golden Seeds & dropped items - OPTIMIZED)
task.spawn(function()
    while task.wait(0.4) do
        if _G.GG2_ScriptCount ~= currentInstance then break end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local targetPrompt = nil
        
        -- Helper: strict check that a prompt is safe and not a sign, NPC, shop, or other players' plot
        local function isSafePrompt(prompt)
            local parent = prompt.Parent
            if not parent then return false end
            
            -- Ignore prompts in other players' gardens
            local gardens = workspace:FindFirstChild("Gardens")
            if gardens then
                for _, plot in ipairs(gardens:GetChildren()) do
                    if plot ~= getMyPlot() and parent:IsDescendantOf(plot) then
                        return false
                    end
                end
            end
            
            -- Ignore NPC shops, stands, claims, expansions, and spawn/teleport prompts
            local name = prompt.Name:lower()
            local action = prompt.ActionText:lower()
            local obj = prompt.ObjectText:lower()
            local parentName = parent.Name:lower()
            
            if name:find("talk") or action:find("talk") or obj:find("talk") or parentName:find("talk") or
               name:find("shop") or action:find("shop") or obj:find("shop") or parentName:find("shop") or
               name:find("expand") or action:find("expand") or obj:find("expand") or parentName:find("expand") or
               name:find("claim") or action:find("claim") or obj:find("claim") or parentName:find("claim") or
               name:find("garden") or action:find("garden") or obj:find("garden") or parentName:find("garden") or
               name:find("teleport") or action:find("teleport") or obj:find("teleport") or parentName:find("teleport") or
               name:find("sell") or action:find("sell") or obj:find("sell") or parentName:find("sell") or
               name:find("spawn") or action:find("spawn") or obj:find("spawn") or parentName:find("spawn") then
                return false
            end
            
            -- Ignore map npcs and stands
            local map = workspace:FindFirstChild("Map")
            if map then
                local npcs = map:FindFirstChild("NPCs")
                if npcs and parent:IsDescendantOf(npcs) then return false end
                local stands = map:FindFirstChild("Stands")
                if stands and parent:IsDescendantOf(stands) then return false end
            end
            
            return true
        end
        
        -- 1. Auto Collect Golden Seeds (and Rainbow Seeds)
        if _G.GoldenSeedFarm then
            -- Check server spawn locations
            local spawnLocs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SeedPackSpawnServerLocations")
            if spawnLocs then
                for _, child in ipairs(spawnLocs:GetChildren()) do
                    local isGoldOrRainbow = child:GetAttribute("GoldSeed") == true or child:GetAttribute("RainbowSeed") == true or child.Name:lower():find("gold") or child.Name:lower():find("rainbow")
                    if isGoldOrRainbow then
                        local prompt = child:FindFirstChildWhichIsA("ProximityPrompt") or child:FindFirstChild("ProximityPrompt", true)
                        if prompt and prompt.Enabled and isSafePrompt(prompt) then
                            targetPrompt = prompt
                            break
                        end
                    end
                end
            end
            
            -- Check DroppedItems folder
            if not targetPrompt then
                local droppedFolder = workspace:FindFirstChild("DroppedItems")
                if droppedFolder then
                    for _, child in ipairs(droppedFolder:GetChildren()) do
                        local isGoldOrRainbow = child:GetAttribute("GoldSeed") == true or child:GetAttribute("RainbowSeed") == true or child.Name:lower():find("gold") or child.Name:lower():find("rainbow")
                        if isGoldOrRainbow then
                            local prompt = child:FindFirstChildWhichIsA("ProximityPrompt") or child:FindFirstChild("ProximityPrompt", true)
                            if prompt and prompt.Enabled and isSafePrompt(prompt) then
                                targetPrompt = prompt
                                break
                            end
                        end
                    end
                end
            end
            
            -- Fallback cached prompt search for Gold/Rainbow seeds (highly optimized)
            if not targetPrompt then
                for _, desc in ipairs(allPrompts) do
                    if desc.Parent and desc.Enabled and isSafePrompt(desc) then
                        local name = desc.Name:lower()
                        local action = desc.ActionText:lower()
                        local obj = desc.ObjectText:lower()
                        local isGoldOrRainbow = name:find("gold") or action:find("gold") or obj:find("gold") or
                                               name:find("rainbow") or action:find("rainbow") or obj:find("rainbow") or
                                               desc.Parent:GetAttribute("GoldSeed") == true or desc.Parent:GetAttribute("RainbowSeed") == true
                        if isGoldOrRainbow then
                            targetPrompt = desc
                            break
                        end
                    end
                end
            end
        end
        
        -- 2. Auto Collect Dropped Items (Seed Packs, Crates, etc.)
        if not targetPrompt and _G.SeedPackFarm then
            -- Check server spawn locations (excluding Gold/Rainbow seeds)
            local spawnLocs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SeedPackSpawnServerLocations")
            if spawnLocs then
                for _, child in ipairs(spawnLocs:GetChildren()) do
                    local isGoldOrRainbow = child:GetAttribute("GoldSeed") == true or child:GetAttribute("RainbowSeed") == true or child.Name:lower():find("gold") or child.Name:lower():find("rainbow")
                    if not isGoldOrRainbow then
                        local prompt = child:FindFirstChildWhichIsA("ProximityPrompt") or child:FindFirstChild("ProximityPrompt", true)
                        if prompt and prompt.Enabled and isSafePrompt(prompt) then
                            targetPrompt = prompt
                            break
                        end
                    end
                end
            end
            
            -- Check DroppedItems folder (player drops)
            if not targetPrompt then
                local droppedFolder = workspace:FindFirstChild("DroppedItems")
                if droppedFolder then
                    for _, child in ipairs(droppedFolder:GetChildren()) do
                        local isGoldOrRainbow = child:GetAttribute("GoldSeed") == true or child:GetAttribute("RainbowSeed") == true or child.Name:lower():find("gold") or child.Name:lower():find("rainbow")
                        if not isGoldOrRainbow then
                            local prompt = child:FindFirstChildWhichIsA("ProximityPrompt") or child:FindFirstChild("ProximityPrompt", true)
                            if prompt and prompt.Enabled and isSafePrompt(prompt) then
                                targetPrompt = prompt
                                break
                            end
                        end
                    end
                end
            end
            
            -- Fallback cached prompt search for dropped packs, crates, bags, etc. (highly optimized)
            if not targetPrompt then
                for _, desc in ipairs(allPrompts) do
                    if desc.Parent and desc.Enabled and isSafePrompt(desc) then
                        local name = desc.Name:lower()
                        local action = desc.ActionText:lower()
                        local obj = desc.ObjectText:lower()
                        
                        local isDroppedPack = name:find("pack") or action:find("pack") or obj:find("pack") or
                                              name:find("bag") or action:find("bag") or obj:find("bag") or
                                              name:find("dropped") or action:find("dropped") or obj:find("dropped") or
                                              name:find("crate") or action:find("crate") or obj:find("crate")
                        
                        if isDroppedPack then
                            targetPrompt = desc
                            break
                        end
                    end
                end
            end
        end
        
        -- Trigger prompt if found
        if targetPrompt then
            pcall(function()
                if targetPrompt.Parent and targetPrompt.Parent:IsA("BasePart") then
                    local oldCFrame = hrp.CFrame
                    movePlayer(CFrame.new(targetPrompt.Parent.Position + Vector3.new(0, 1.5, 0)))
                    task.wait(0.2)
                    if fireproximityprompt then
                        fireproximityprompt(targetPrompt)
                    else
                        targetPrompt:InputBegan(Enum.UserInputType.MouseButton1)
                        task.wait(0.05)
                        targetPrompt:InputEnded(Enum.UserInputType.MouseButton1)
                    end
                    task.wait(0.2)
                    movePlayer(oldCFrame)
                end
            end)
        end
    end
end)

-- Loop 4: Auto Grow & Auto Pot
task.spawn(function()
    while task.wait(0.5) do
        if _G.GG2_ScriptCount ~= currentInstance then break end
        
        local plot = getMyPlot()
        if not plot or not plot:FindFirstChild("Plants") then continue end
        
        -- Auto Grow (Spam fire growth remote using correct plant key name)
        if _G.AutoGrow then
            for _, plant in ipairs(plot.Plants:GetChildren()) do
                if plant:IsA("Model") then
                    local hasHarvestPrompt = plant:FindFirstChild("HarvestPrompt", true) ~= nil
                    if not hasHarvestPrompt then
                        local rawId = plant:GetAttribute("PlantId") or plant.Name:match("^%d+_(.+)$")
                        if rawId then
                            local plantId = tonumber(rawId) or rawId
                            Networking.GrowPlant:Fire(plantId)
                        end
                    end
                end
            end
        end
        
        -- Auto Pot
        if _G.AutoPot then
            for _, plant in ipairs(plot.Plants:GetChildren()) do
                if plant:IsA("Model") and not plant:GetAttribute("IsPotted") then
                    local age = plant:GetAttribute("Age") or 0
                    local maxAge = plant:GetAttribute("MaxAge") or 100
                    if age >= maxAge then
                        local emptyPot = LocalPlayer.Character:FindFirstChild("Empty Pot") or LocalPlayer.Backpack:FindFirstChild("Empty Pot")
                        if emptyPot then
                            local plantId = plant.Name
                            local shortId = plant.Name:match("^%d+_(.+)$") or plant.Name
                            Networking.Garden.PotPlant:Fire(plantId)
                            if shortId ~= plantId then
                                Networking.Garden.PotPlant:Fire(shortId)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Loop 5: Separate Auto Collect (Harvest) & Auto Sell
task.spawn(function()
    while task.wait(1.5) do
        if _G.GG2_ScriptCount ~= currentInstance then break end
        
        local plot = getMyPlot()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        -- Auto Collect / Harvest
        if _G.AutoCollect and plot and plot:FindFirstChild("Plants") then
            local harvestPrompts = {}
            for _, desc in ipairs(plot.Plants:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Name == "HarvestPrompt" then
                    table.insert(harvestPrompts, desc)
                end
            end
            
            if #harvestPrompts > 0 then
                local oldCFrame = hrp.CFrame
                for _, prompt in ipairs(harvestPrompts) do
                    if not _G.AutoCollect then break end
                    if prompt.Parent and prompt.Parent:IsA("BasePart") then
                        movePlayer(CFrame.new(prompt.Parent.Position + Vector3.new(0, 1.5, 0)))
                        task.wait(0.2)
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        else
                            prompt:InputBegan(Enum.UserInputType.MouseButton1)
                            task.wait(0.05)
                            prompt:InputEnded(Enum.UserInputType.MouseButton1)
                        end
                        task.wait(0.2)
                    end
                end
                movePlayer(oldCFrame)
            end
        end
        
        -- Auto Sell
        if _G.AutoSell and getCurrentCropCount() > 0 then
            sellCropsSelective()
        end
    end
end)

-- Loop 6: Main Auto Farm Loop (Planting, Harvesting, Selling)
local cachedGridPoints = nil
local cacheTimer = 0

task.spawn(function()
    while task.wait(1.5) do
        if _G.GG2_ScriptCount ~= currentInstance then break end
        
        if not _G.AutoFarmEnabled then 
            cachedGridPoints = nil
            continue 
        end
        if not SeedData then continue end
        
        local plot = getMyPlot()
        if not plot then continue end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        -- 1. Secure carrying stolen fruit if carrying
        if LocalPlayer:GetAttribute("CarryingStolenFruit") == true or LocalPlayer:GetAttribute("IsStealingFruit") == true then
            local targetPart = (plot:FindFirstChild("Visual") and plot.Visual:FindFirstChild("PRIM")) or plot:FindFirstChild("SpawnPoint")
            if targetPart then
                movePlayer(targetPart.CFrame + Vector3.new(0, 2, 0))
                task.wait(0.8)
            end
        end
        
        if not _G.AutoFarmEnabled then continue end
        
        -- 2. Harvest fully grown crops
        local harvestPrompts = {}
        for _, desc in ipairs(plot.Plants:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Name == "HarvestPrompt" then
                table.insert(harvestPrompts, desc)
            end
        end
        if #harvestPrompts > 0 then
            local oldCFrame = hrp.CFrame
            for _, prompt in ipairs(harvestPrompts) do
                if not _G.AutoFarmEnabled then break end
                if prompt.Parent and prompt.Parent:IsA("BasePart") then
                    movePlayer(CFrame.new(prompt.Parent.Position + Vector3.new(0, 1.5, 0)))
                    task.wait(0.2)
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    else
                        prompt:InputBegan(Enum.UserInputType.MouseButton1)
                        task.wait(0.05)
                        prompt:InputEnded(Enum.UserInputType.MouseButton1)
                    end
                    task.wait(0.2)
                end
            end
            movePlayer(oldCFrame)
        end
        
        if not _G.AutoFarmEnabled then continue end
        
        -- 3. Sell crops in backpack
        if getCurrentCropCount() > 0 then
            sellCropsSelective()
            task.wait(0.5)
        end
        
        if not _G.AutoFarmEnabled then continue end
        
        -- 4. Calculate free grid positions
        cacheTimer = cacheTimer + 1
        if cacheTimer >= 20 or not cachedGridPoints then
            cachedGridPoints = {}
            cacheTimer = 0
            local areas = getPlantAreas(plot)
            for _, area in ipairs(areas) do
                local points = getGridPoints(area, 2)
                for _, pt in ipairs(points) do
                    table.insert(cachedGridPoints, pt)
                end
            end
        end
        
        -- Get current plant positions to optimize distance checks (avoiding square roots)
        local plantPosList = {}
        if plot:FindFirstChild("Plants") then
            for _, plant in ipairs(plot.Plants:GetChildren()) do
                if plant:IsA("Model") then
                    local plantPos = plant.PrimaryPart and plant.PrimaryPart.Position or plant:GetPivot().Position
                    table.insert(plantPosList, { X = plantPos.X, Z = plantPos.Z })
                end
            end
        end
        
        local emptyPositions = {}
        local minDistanceSq = 1.5 * 1.5
        for _, pt in ipairs(cachedGridPoints) do
            local isFar = true
            local ptX, ptZ = pt.X, pt.Z
            for _, plantPos in ipairs(plantPosList) do
                local dx = ptX - plantPos.X
                local dz = ptZ - plantPos.Z
                if (dx * dx + dz * dz) < minDistanceSq then
                    isFar = false
                    break
                end
            end
            if isFar then
                table.insert(emptyPositions, pt)
            end
        end
        
        if not _G.AutoFarmEnabled then continue end
        
        -- 5. Plant seeds if spots are available
        if #emptyPositions > 0 then
            local sheckles = LocalPlayer.leaderstats.Sheckles.Value
            
            -- Find the best seed to buy based on selection & affordability
            local targetSeed = nil
            local highestPrice = -1
            
            for _, item in pairs(SeedData) do
                if typeof(item) == "table" and item.RestockShop then
                    local isOneTime = item.IsSingleHarvest == true
                    local matchOneTimeFilter = (not _G.AutoFarmBetter) or isOneTime
                    
                    if matchOneTimeFilter and isSeedSelectedForBuy(item.SeedName) and (_G.BuyRarity == "All" or item.Rarity == _G.BuyRarity) then
                        local cost = item.PurchasePrice
                        if cost <= sheckles and cost > highestPrice then
                            highestPrice = cost
                            targetSeed = item
                        end
                    end
                end
            end
            
            if targetSeed then
                local seedName = targetSeed.SeedName
                local owned = getOwnedSeedsCount(seedName)
                local needed = #emptyPositions - owned
                
                -- Purchase seeds
                if needed > 0 then
                    local buyCount = math.min(needed, math.floor(sheckles / targetSeed.PurchasePrice))
                    for i = 1, buyCount do
                        if not _G.AutoFarmEnabled then break end
                        Networking.SeedShop.PurchaseSeed:Fire(seedName)
                        task.wait(0.05)
                    end
                    task.wait(0.2)
                end
                
                -- Plant seeds
                for _, pos in ipairs(emptyPositions) do
                    if not _G.AutoFarmEnabled then break end
                    local tool = getSeedTool(seedName)
                    if tool then
                        movePlayer(CFrame.new(pos + Vector3.new(0, 1.5, 0)))
                        task.wait(0.2)
                        
                        if not _G.AutoFarmEnabled then break end
                        if tool.Parent ~= char then
                            tool.Parent = char
                            task.wait(0.2)
                        end
                        
                        if not _G.AutoFarmEnabled then break end
                        Networking.Plant.PlantSeed:Fire(pos, seedName, tool)
                        task.wait(0.15)
                    end
                end
            end
        end
    end
end)

-- Loop 7: Auto Steal Loop (Handles teleportation, kicking owners, stealing and securing)
task.spawn(function()
    while task.wait(1.5) do
        if _G.GG2_ScriptCount ~= currentInstance then break end
        if not _G.AutoSteal then continue end
        
        local Night = ReplicatedStorage:FindFirstChild("Night")
        if not Night or Night.Value ~= true then continue end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local plot = getMyPlot()
        
        -- 1. Secure stolen crop if carrying
        if LocalPlayer:GetAttribute("CarryingStolenFruit") == true or LocalPlayer:GetAttribute("IsStealingFruit") == true then
            if plot then
                local targetPart = (plot:FindFirstChild("Visual") and plot.Visual:FindFirstChild("PRIM")) or plot:FindFirstChild("SpawnPoint")
                if targetPart then
                    movePlayer(targetPart.CFrame + Vector3.new(0, 2, 0))
                    task.wait(1.0)
                end
            end
            continue
        end
        
        local function isOtherPlayerPlot(targetPlot)
            local oName = targetPlot:GetAttribute("Owner")
            local oId = targetPlot:GetAttribute("OwnerUserId")
            if not oName and not oId then return false end
            if oName == LocalPlayer.Name or oId == LocalPlayer.UserId then return false end
            return true
        end
        
        -- 2. Find up to 3 eligible crops to steal on other player plots
        local targets = {}
        
        for _, otherPlot in ipairs(workspace.Gardens:GetChildren()) do
            if not _G.AutoSteal then break end
            if isOtherPlayerPlot(otherPlot) then
                -- Check if owner is present in their garden
                local ownerPresent = false
                local ownerId = otherPlot:GetAttribute("OwnerUserId")
                local ownerName = otherPlot:GetAttribute("Owner")
                local targetOwner = nil
                if ownerId then
                    targetOwner = Players:GetPlayerByUserId(ownerId)
                elseif ownerName then
                    targetOwner = Players:FindFirstChild(ownerName)
                end
                
                if targetOwner and targetOwner.Character and targetOwner.Character:FindFirstChild("HumanoidRootPart") then
                    local prim = otherPlot.Visual:FindFirstChild("PRIM")
                    if prim then
                        local dist = (targetOwner.Character.HumanoidRootPart.Position - prim.Position).Magnitude
                        if dist <= 60 then
                            ownerPresent = true
                        end
                    end
                end
                
                -- If owner is present, we must kick them first
                if ownerPresent and targetOwner then
                    movePlayer(targetOwner.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                    task.wait(0.1)
                    hitPlayerWithShovel(targetOwner)
                    task.wait(0.5)
                    -- Re-fetch character/hrp since we moved
                    char = LocalPlayer.Character
                    hrp = char and char:FindFirstChild("HumanoidRootPart")
                else
                    -- Collect prompts on this plot
                    local plantsFolder = otherPlot:FindFirstChild("Plants")
                    if plantsFolder then
                        for _, desc in ipairs(plantsFolder:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") and (desc.Name == "StealPrompt" or CollectionService:HasTag(desc, "StealPrompt")) then
                                table.insert(targets, { prompt = desc, plot = otherPlot })
                                if #targets >= 3 then break end
                            end
                        end
                    end
                end
            end
            if #targets >= 3 then break end
        end
        
        -- 3. Steal collected targets in a batch (anchoring protects against boundary flings)
        if #targets > 0 and hrp then
            local oldCFrame = hrp.CFrame
            
            hrp.Anchored = true
            
            pcall(function()
                for _, target in ipairs(targets) do
                    if not _G.AutoSteal then break end
                    local targetPrompt = target.prompt
                    if targetPrompt.Parent and targetPrompt.Parent:IsA("BasePart") then
                        -- Teleport safely using position to avoid orientation offset issues
                        hrp.CFrame = CFrame.new(targetPrompt.Parent.Position + Vector3.new(0, 1.5, 0))
                        task.wait(0.25)
                        
                        local plantModel = targetPrompt:FindFirstAncestorWhichIsA("Model")
                        local pId = plantModel and plantModel:GetAttribute("PlantId")
                        local fId = plantModel and plantModel:GetAttribute("FruitId")
                        local uId = plantModel and tonumber(plantModel:GetAttribute("UserId"))
                        
                        if uId and pId then
                            Networking.Steal.BeginSteal:Fire(uId, pId, fId or "")
                            Networking.Steal.CompleteSteal:Fire()
                        else
                            if fireproximityprompt then
                                fireproximityprompt(targetPrompt)
                            else
                                targetPrompt:InputBegan(Enum.UserInputType.MouseButton1)
                                task.wait(0.05)
                                targetPrompt:InputEnded(Enum.UserInputType.MouseButton1)
                            end
                        end
                        task.wait(0.25)
                    end
                end
                
                -- Teleport back to our garden plot center or spawn point immediately to secure all stolen crops!
                if plot then
                    local targetPart = (plot:FindFirstChild("Visual") and plot.Visual:FindFirstChild("PRIM")) or plot:FindFirstChild("SpawnPoint")
                    if targetPart then
                        hrp.CFrame = targetPart.CFrame + Vector3.new(0, 2, 0)
                        task.wait(1.0) -- Wait for server to secure all items
                    end
                end
            end)
            
            pcall(function()
                hrp.Anchored = false
            end)
        end
    end
end)

-- Loop 8: Custom Character Modifiers (WalkSpeed / JumpPower)
task.spawn(function()
    while task.wait(0.2) do
        if _G.GG2_ScriptCount ~= currentInstance then break end
        
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if _G.CustomWalkSpeed then
                hum.WalkSpeed = _G.WalkSpeedValue
            else
                if hum.WalkSpeed == _G.WalkSpeedValue then
                    hum.WalkSpeed = 16
                end
            end
            if _G.CustomJumpPower then
                hum.JumpPower = _G.JumpPowerValue
            else
                if hum.JumpPower == _G.JumpPowerValue then
                    hum.JumpPower = 50
                end
            end
        end
    end
end)

-- Notify user script load succeeded
Fluent:Notify({
    Title = "Script Loaded",
    Content = "Grow A Garden 2 premium automation script has successfully doracake!",
    Duration = 5
})
