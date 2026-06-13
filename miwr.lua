local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Mini War - Elite Script",
    SubTitle = "v1.4 | BY DORACAKE (DORAEMON)",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Tycoon = Window:AddTab({ Title = "Tycoon", Icon = "hammer" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "shield" }),
    Automation = Window:AddTab({ Title = "Automation", Icon = "refresh-cw" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "wrench" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- State Variables
local Toggles = {
    AutoCollectTP = false,
    AutoCollectNoTP = false,
    AutoSell = false,
    AutoExpand = false,
    AutoRebirth = false,
    AutoDeploy = false,
    AutoRockets = false,
    AutoDailyClaim = false,
    AutoQuestClaim = false,
    AutoOfflineClaim = false,
    AutoResearch = false,
    MasterArmyFarm = false,
    AutoPlace = false,
    AutoOptimizePlot = false,
    AutoSellBackpack = false,
    AutoBuyFarm = false,
    BuyAllFarm = true,
    AutoBuyHouse = false,
    BuyAllHouse = true,
    AutoBuyMilitary = false,
    BuyAllMilitary = true,
    AutoBuyDecor = false,
    BuyAllDecor = true
}

local SelectedArmyIndex = 1
local SelectedCapturePoint = nil
local CapturePointsList = {}
local CapturePointInstances = {}

-- Player movement stats
local WalkSpeed = 16
local JumpPower = 50
local Noclip = false

-- Roblox Services & Modules
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local GetBridge = require(ReplicatedStorage.util.GetBridge)
local ClientData = require(ReplicatedStorage.client.modules.ClientData)
local GetPlotModel = require(ReplicatedStorage.util.GetPlotModel)
local SkillsConfig = require(ReplicatedStorage.shared.config.SkillsConfig)
local BuildingsConfig = require(ReplicatedStorage.shared.config.BuildingsConfig)
local getAmountOfSpecifiedBuildingThatPlayerOwns = require(ReplicatedStorage.util.getAmountOfSpecifiedBuildingThatPlayerOwns)
local shopPriceIncrementConfig = require(ReplicatedStorage.shared.config.shopPriceIncrementConfig)

-- Formatting helper functions
local function formatNumber(val)
    local num = tonumber(val)
    if not num then return tostring(val) end
    local formatted = tostring(math.round(num))
    local k
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

local function formatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

-- Discord Webhook Logger (Hidden from UI)
local startTime = tick()
local executorName = identifyexecutor and identifyexecutor() or "Unknown Executor"

local function sendWebhook()
    local success, err = pcall(function()
        local state = ClientData.playerProducer:getState().player
        if not state then return end
        
        local cash = state.money or "0"
        local rebirths = state.rebirth or 0
        local gems = state.gems or 0
        local tutorialStage = state.tutorialStage or 0
        local elapsed = tick() - startTime
        local playtime = formatTime(elapsed)
        
        local totalPlaytime = state.playtime or 0
        local unlockedSectorsCount = state.unlockedSectors and #state.unlockedSectors or 0
        local unlockedSkillsCount = 0
        if state.skills and state.skills.unlockedSkills then
            for _ in pairs(state.skills.unlockedSkills) do
                unlockedSkillsCount = unlockedSkillsCount + 1
            end
        end
        local buildingsCount = 0
        if state.plotBuildings then
            for _ in pairs(state.plotBuildings) do
                buildingsCount = buildingsCount + 1
            end
        end
        
        local webhookUrl = "https://discord.com/api/webhooks/1515052081751527444/PgV-eH1t5uKDEIej4s4qcYyj2W_rdBbfTGT0e4AFMvAE7acM7FPow1JDLTE8CH-wUT9v"
        
        local payload = {
            embeds = {
                {
                    title = "Mini War Auto-Farm Session Log",
                    color = 3447003, -- Blue Color Accent
                    fields = {
                        { name = "Player Name", value = LocalPlayer.Name, inline = true },
                        { name = "User ID", value = tostring(LocalPlayer.UserId), inline = true },
                        { name = "Executor", value = executorName, inline = true },
                        { name = "Session Playtime", value = playtime, inline = true },
                        { name = "Total Playtime", value = formatTime(totalPlaytime), inline = true },
                        { name = "Cash", value = "$" .. formatNumber(cash), inline = true },
                        { name = "Rebirths", value = formatNumber(rebirths), inline = true },
                        { name = "Gems", value = formatNumber(gems), inline = true },
                        { name = "Tutorial Stage", value = tostring(tutorialStage), inline = true },
                        { name = "Sectors Unlocked", value = tostring(unlockedSectorsCount), inline = true },
                        { name = "Skills Researched", value = tostring(unlockedSkillsCount), inline = true },
                        { name = "Plot Buildings", value = tostring(buildingsCount), inline = true }
                    },
                    footer = { text = "Mini War Bot Logger • Antigravity CLI" },
                    timestamp = DateTime.now():ToIsoDate()
                }
            }
        }
        
        local jsonPayload = HttpService:JSONEncode(payload)
        local requestFunc = request or http_request or (syn and syn.request)
        if requestFunc then
            requestFunc({
                Url = webhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = jsonPayload
            })
        else
            HttpService:PostAsync(webhookUrl, jsonPayload, Enum.HttpContentType.ApplicationJson)
        end
    end)
    if not success then
        warn("[Logger Error]: Failed to post stats to webhook - " .. tostring(err))
    end
end

-- Trigger webhook upon initialization (wait slightly for state replication)
task.delay(5, function()
    sendWebhook()
end)

-- Trigger webhook every 5 minutes
task.spawn(function()
    while task.wait(300) do
        sendWebhook()
    end
end)

-- Trigger webhook upon Rebirth event detection
local lastRebirthCount = nil
ClientData.playerProducer:subscribe(function(state)
    return state.player.rebirth
end, function(rebirths)
    if lastRebirthCount and rebirths > lastRebirthCount then
        task.spawn(sendWebhook)
    end
    lastRebirthCount = rebirths
end)

-- Home Tab UI elements
local SessionInfo = Tabs.Home:AddParagraph({
    Title = "Session Info",
    Content = "Loading..."
})

local PlayerInfo = Tabs.Home:AddParagraph({
    Title = "Player Information",
    Content = "Loading..."
})

-- Session Info Update Loop
task.spawn(function()
    while task.wait(1) do
        -- Update Session Info
        pcall(function()
            local elapsed = tick() - startTime
            SessionInfo:SetDesc(string.format("Executor: %s\nPlaytime: %s", executorName, formatTime(elapsed)))
        end)
        
        -- Update Real-time Stats
        pcall(function()
            local state = ClientData.playerProducer:getState().player
            if state then
                local cash = state.money or "0"
                local rebirths = state.rebirth or 0
                local gems = state.gems or 0
                local tutorialStage = state.tutorialStage or 0
                PlayerInfo:SetDesc(string.format("Cash: $%s\nRebirths: %s\nGems: %s\nTutorial Stage: %s", 
                    formatNumber(cash), formatNumber(rebirths), formatNumber(gems), tostring(tutorialStage)))
            end
        end)
    end
end)

-- Tycoon Tab Elements
Tabs.Tycoon:AddToggle("AutoCollectTP", {Title = "Auto Collect (TP Bypass)", Default = false}):OnChanged(function()
    Toggles.AutoCollectTP = Options.AutoCollectTP.Value
end)

Tabs.Tycoon:AddToggle("AutoCollectNoTP", {Title = "Auto Collect (No Teleport)", Default = false}):OnChanged(function()
    Toggles.AutoCollectNoTP = Options.AutoCollectNoTP.Value
end)

Tabs.Tycoon:AddToggle("AutoSell", {Title = "Auto Sell Resources", Default = false}):OnChanged(function()
    Toggles.AutoSell = Options.AutoSell.Value
end)

Tabs.Tycoon:AddToggle("AutoExpand", {Title = "Auto Expand Base (Buy Sectors)", Default = false}):OnChanged(function()
    Toggles.AutoExpand = Options.AutoExpand.Value
end)

Tabs.Tycoon:AddToggle("AutoPlace", {Title = "Auto Place Buildings", Default = false}):OnChanged(function()
    Toggles.AutoPlace = Options.AutoPlace.Value
end)

Tabs.Tycoon:AddToggle("AutoOptimizePlot", {Title = "Auto Set Best Plot (Replace Worst)", Default = false}):OnChanged(function()
    Toggles.AutoOptimizePlot = Options.AutoOptimizePlot.Value
end)

-- Shop options have been relocated to the dedicated Shop tab

Tabs.Tycoon:AddToggle("AutoSellBackpack", {Title = "Auto Sell Backpack Buildings", Default = false}):OnChanged(function()
    Toggles.AutoSellBackpack = Options.AutoSellBackpack.Value
end)

Tabs.Tycoon:AddToggle("AutoRebirth", {Title = "Auto Rebirth", Default = false}):OnChanged(function()
    Toggles.AutoRebirth = Options.AutoRebirth.Value
end)

-- Plot Retrieval Logic
local playersPlot = nil
task.spawn(function()
    playersPlot = GetPlotModel(LocalPlayer)
    while not playersPlot do
        task.wait(1)
        playersPlot = GetPlotModel(LocalPlayer)
    end
end)

-- Auto Collect Resources Loop (TP Bypass variant)
task.spawn(function()
    while task.wait(1.5) do
        if Toggles.AutoCollectTP and playersPlot then
            pcall(function()
                local buildings = playersPlot:FindFirstChild("Plot") and playersPlot.Plot:FindFirstChild("Buildings")
                if buildings then
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    
                    local collectQueue = {}
                    for _, building in ipairs(buildings:GetChildren()) do
                        local toCollect = building:GetAttribute("ResourcesToCollect") or 0
                        if toCollect > 0 then
                            table.insert(collectQueue, building)
                        end
                    end
                    
                    if #collectQueue > 0 then
                        if root then
                            local oldCFrame = root.CFrame
                            local teleportedAny = false
                            
                            -- Proximity-based sorting to prevent wild teleport jumps
                            local playerPos = root.Position
                            table.sort(collectQueue, function(a, b)
                                local partA = a.PrimaryPart or a:FindFirstChildWhichIsA("BasePart")
                                local partB = b.PrimaryPart or b:FindFirstChildWhichIsA("BasePart")
                                local distA = partA and (playerPos - partA.Position).Magnitude or math.huge
                                local distB = partB and (playerPos - partB.Position).Magnitude or math.huge
                                return distA < distB
                            end)
                            
                            for _, building in ipairs(collectQueue) do
                                local primary = building.PrimaryPart or building:FindFirstChildWhichIsA("BasePart")
                                if primary then
                                    local dist = (root.Position - primary.Position).Magnitude
                                    if dist > 15 then
                                        teleportedAny = true
                                        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                        root.CFrame = primary.CFrame + Vector3.new(0, 3, 0)
                                        task.wait(0.12)
                                    end
                                    GetBridge("CollectResources"):Fire(building)
                                    if dist > 15 then
                                        task.wait(0.08)
                                    else
                                        task.wait(0.05)
                                    end
                                    playerPos = root.Position
                                end
                            end
                            
                            if teleportedAny then
                                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                root.CFrame = oldCFrame
                            end
                        else
                            for _, building in ipairs(collectQueue) do
                                GetBridge("CollectResources"):Fire(building)
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Collect Resources Loop (No Teleport variant)
task.spawn(function()
    while task.wait(1.5) do
        if Toggles.AutoCollectNoTP and playersPlot then
            pcall(function()
                local buildings = playersPlot:FindFirstChild("Plot") and playersPlot.Plot:FindFirstChild("Buildings")
                if buildings then
                    for _, building in ipairs(buildings:GetChildren()) do
                        local toCollect = building:GetAttribute("ResourcesToCollect") or 0
                        if toCollect > 0 then
                            GetBridge("CollectResources"):Fire(building)
                            task.wait(0.05)
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Sell Resources Loop
task.spawn(function()
    while task.wait(1) do
        if Toggles.AutoSell then
            pcall(function()
                GetBridge("SellAll"):Fire()
            end)
        end
    end
end)

-- Auto Expand Base Loop
task.spawn(function()
    while task.wait(2) do
        if Toggles.AutoExpand and playersPlot then
            pcall(function()
                local expandFolder = playersPlot:FindFirstChild("Plot") and playersPlot.Plot:FindFirstChild("ExpandPlot")
                if expandFolder then
                    for _, sector in ipairs(expandFolder:GetChildren()) do
                        local folderObj = sector:FindFirstChildWhichIsA("Folder")
                        if folderObj then
                            local plotPart = folderObj:FindFirstChild("PlotPart")
                            if plotPart then
                                local prompt = plotPart:FindFirstChildWhichIsA("ProximityPrompt")
                                if prompt and prompt.Enabled then
                                    GetBridge("ExpandPlot"):Fire(sector)
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Snapping placement finder
local function findPlacementCFrameAsync(buildingName, callback)
    task.spawn(function()
        local Zone1 = playersPlot and playersPlot:FindFirstChild("Plot") 
                      and playersPlot.Plot:FindFirstChild("BuildZone") 
                      and playersPlot.Plot.BuildZone:FindFirstChild("Zone1")
        if not Zone1 then callback(nil) return end
        
        local GridMod = require(ReplicatedStorage.shared.modules.Grid)
        local Objects = ReplicatedStorage.shared.model.Objects
        local templateModel = Objects:FindFirstChild(buildingName)
        if not templateModel then callback(nil) return end
        
        local gridObj = GridMod.new(Zone1, templateModel)
        local Hitbox = gridObj.preview:FindFirstChild("Hitbox")
        if not Hitbox then
            gridObj:Destroy()
            callback(nil)
            return
        end
        
        local Size2 = Zone1.Size
        local limitX = math.floor(Size2.X / 2)
        local limitZ = math.floor(Size2.Z / 2)
        
        local count = 0
        for x = -limitX, limitX, 2 do
            for z = -limitZ, limitZ, 2 do
                for rot = 0, 3 do
                    gridObj.rotation = rot
                    local testPos = Zone1.CFrame * Vector3.new(x, 0, z)
                    local cf = gridObj:CalculatePosition(testPos)
                    local isValid = gridObj:ValidatePlacement(LocalPlayer, cf)
                    if isValid then
                        gridObj:Destroy()
                        callback(cf)
                        return
                    end
                    
                    count = count + 1
                    if count % 150 == 0 then
                        task.wait()
                    end
                end
            end
        end
        
        gridObj:Destroy()
        callback(nil)
    end)
end

-- Helper functions to rank buildings (least valuable vs best backpack building)
local function getLeastValuableBuilding()
    local leastVal = math.huge
    local leastId = nil
    local leastName = nil
    
    local state = ClientData.playerProducer:getState().player
    if state and state.plotBuildings then
        for id, bData in pairs(state.plotBuildings) do
            local config = BuildingsConfig[bData.buildingName]
            if config then
                local val = (config.GrownResource and config.GrownResource.Price) or config.Price or 0
                if val < leastVal then
                    leastVal = val
                    leastId = id
                    leastName = bData.buildingName
                end
            end
        end
    end
    return leastId, leastName, leastVal
end

local function getBestBuildingInBackpack()
    local bestVal = -1
    local bestName = nil
    
    local state = ClientData.playerProducer:getState().player
    if state and state.backpack then
        for name, bData in pairs(state.backpack) do
            if bData.amount > 0 then
                local config = BuildingsConfig[name]
                if config then
                    local val = (config.GrownResource and config.GrownResource.Price) or config.Price or 0
                    if val > bestVal then
                        bestVal = val
                        bestName = name
                    end
                end
            end
        end
    end
    return bestName, bestVal
end

-- Auto Place Buildings Loop (Empties backpack onto available grid cells)
task.spawn(function()
    while task.wait(3) do
        if Toggles.AutoPlace and playersPlot and not Toggles.AutoOptimizePlot then
            pcall(function()
                local bestName = getBestBuildingInBackpack()
                if bestName then
                    findPlacementCFrameAsync(bestName, function(cf)
                        if cf then
                            GetBridge("PlaceBuilding"):Fire({
                                modelName = bestName,
                                modelCFrame = cf
                            })
                        end
                    end)
                end
            end)
        end
    end
end)

-- Auto Set Best Plot Loop (Demolishes weakest structures to slot in better backpack structures)
local isOptimizing = false
task.spawn(function()
    while task.wait(4) do
        if Toggles.AutoOptimizePlot and playersPlot and not isOptimizing then
            isOptimizing = true
            pcall(function()
                local bestName, bestVal = getBestBuildingInBackpack()
                if bestName then
                    -- Test if it fits in empty space
                    findPlacementCFrameAsync(bestName, function(cf)
                        if cf then
                            GetBridge("PlaceBuilding"):Fire({
                                modelName = bestName,
                                modelCFrame = cf
                            })
                            isOptimizing = false
                        else
                            -- Plot full. Compare values with the worst building on plot.
                            local leastId, leastName, leastVal = getLeastValuableBuilding()
                            if leastId and bestVal > leastVal then
                                -- Demolish the worst building
                                ReplicatedStorage.ReplicateStore:FireServer({
                                    name = "secureRemoveBuildingFromPlot",
                                    arguments = { leastId }
                                })
                                task.wait(0.8)
                            end
                            isOptimizing = false
                        end
                    end)
                else
                    isOptimizing = false
                end
            end)
        end
    end
end)

-- Shop Pricing Logic
local function getBuildingShopPrice(buildingName, config)
    local owned = getAmountOfSpecifiedBuildingThatPlayerOwns(LocalPlayer, buildingName)
    local increment = shopPriceIncrementConfig[buildingName]
    if increment then
        if increment.fixedPrices then
            return increment.fixedPrices[math.min(owned + 1, #increment.fixedPrices)]
        else
            local mult = 1 + increment.percentIncrement / 100
            if config.gemPrice then
                local p = math.floor(config.gemPrice * mult ^ owned)
                if increment.priceLimit then p = math.min(p, increment.priceLimit) end
                return p, true
            else
                local p = math.floor(config.Price * mult ^ owned)
                if increment.priceLimit then p = math.min(p, increment.priceLimit) end
                return p, false
            end
        end
    end
    if config.gemPrice then
        return config.gemPrice, true
    else
        return config.Price or 0, false
    end
end

-- Helper to parse comma-separated strings to building lists
local function parseList(text)
    local items = {}
    if not text then return items end
    for item in string.gmatch(text, "[^,]+") do
        local clean = string.gsub(item, "^%s*(.-)%s*$", "%1")
        if clean ~= "" then
            items[clean] = true
        end
    end
    return items
end

-- Auto Buy Shop Buildings Loop (Granular Category-Specific)
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            local state = ClientData.playerProducer:getState().player
            if not state then return end
            local playerCash = tonumber(state.money) or 0
            local playerGems = state.gems or 0
            
            local categories = {
                { name = "Farm", toggle = "AutoBuyFarm", buyAll = "BuyAllFarm", input = "FarmBuyListInput" },
                { name = "House", toggle = "AutoBuyHouse", buyAll = "BuyAllHouse", input = "HouseBuyListInput" },
                { name = "Military", toggle = "AutoBuyMilitary", buyAll = "BuyAllMilitary", input = "MilitaryBuyListInput" },
                { name = "Decor", toggle = "AutoBuyDecor", buyAll = "BuyAllDecor", input = "DecorBuyListInput" }
            }
            
            for _, cat in ipairs(categories) do
                local isEnabled = Options[cat.toggle] and Options[cat.toggle].Value
                if isEnabled then
                    local catData = state.shopsStock[cat.name]
                    if catData and catData.stock then
                        local buyAll = Options[cat.buyAll] and Options[cat.buyAll].Value
                        local allowedItems = {}
                        if not buyAll and Options[cat.input] then
                            allowedItems = parseList(Options[cat.input].Value)
                        end
                        
                        for buildingName, stockAmount in pairs(catData.stock) do
                            if stockAmount > 0 then
                                if buyAll or allowedItems[buildingName] then
                                    local config = BuildingsConfig[buildingName]
                                    if config and (not config.researchNeeded or (state.skills and state.skills.unlockedSkills[config.researchNeeded])) then
                                        local price, isGem = getBuildingShopPrice(buildingName, config)
                                        if isGem then
                                            if playerGems >= price then
                                                GetBridge("BuyFromShop"):Fire({
                                                    shop = cat.name,
                                                    item = buildingName
                                                })
                                                task.wait(0.2)
                                            end
                                        else
                                            if playerCash >= price then
                                                GetBridge("BuyFromShop"):Fire({
                                                    shop = cat.name,
                                                    item = buildingName
                                                })
                                                task.wait(0.2)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Shop Tab UI Elements & List Manipulation
local defaultFarmList = {"Windmill", "WheatFarm", "TomatoFarm", "CarrotFarm", "PotatoFarm", "BerryFarm", "CornFarm", "AppleFarm", "GemMine", "CloneFacility"}
local defaultHouseList = {"Tent", "Cabin", "WoodHouse", "BrickHouse", "ModernHouse", "Mansion", "Apartment", "Hotel"}
local defaultMilitaryList = {"Barracks", "ShootingRange", "TankFactory", "Helipad", "Hangar", "NavyYard", "DefenseTower", "SniperTower", "TowerTurret", "MissileLauncher"}
local defaultDecorList = {"Tree", "Bush", "Fence", "LightPole", "Bench", "Statue", "Fountain", "FlagPole"}

local FarmList = table.clone(defaultFarmList)
local HouseList = table.clone(defaultHouseList)
local MilitaryList = table.clone(defaultMilitaryList)
local DecorList = table.clone(defaultDecorList)

local function formatList(itemsTable)
    local sorted = {}
    for k, _ in pairs(itemsTable) do
        table.insert(sorted, k)
    end
    table.sort(sorted)
    return table.concat(sorted, ", ")
end

local function addItemToList(inputOptionName, itemName)
    local inputObj = Options[inputOptionName]
    if inputObj then
        local currentText = inputObj.Value or ""
        local items = parseList(currentText)
        if not items[itemName] then
            items[itemName] = true
            inputObj:SetValue(formatList(items))
        end
    end
end

local function removeItemFromList(inputOptionName, itemName)
    local inputObj = Options[inputOptionName]
    if inputObj then
        local currentText = inputObj.Value or ""
        local items = parseList(currentText)
        if items[itemName] then
            items[itemName] = nil
            inputObj:SetValue(formatList(items))
        end
    end
end

-- Factories Section
Tabs.Shop:AddSection("Factories (Farms)")
Tabs.Shop:AddToggle("AutoBuyFarm", {Title = "Auto Buy Farms", Default = false}):OnChanged(function()
    Toggles.AutoBuyFarm = Options.AutoBuyFarm.Value
end)
Tabs.Shop:AddToggle("BuyAllFarm", {Title = "Buy All Farm Types", Default = true}):OnChanged(function()
    Toggles.BuyAllFarm = Options.BuyAllFarm.Value
end)
local FarmDropdown = Tabs.Shop:AddDropdown("FarmSelector", {
    Title = "Select Farm Type",
    Values = FarmList,
    Default = FarmList[1] or "None",
    Callback = function() end
})
Tabs.Shop:AddInput("FarmBuyListInput", {
    Title = "Allowed Farm Buy List (Comma Separated)",
    Default = "Windmill, WheatFarm",
    Placeholder = "Enter farm names...",
    Finished = false,
    Callback = function() end
})
Tabs.Shop:AddButton({
    Title = "Add Selected Farm to Buy List",
    Callback = function()
        local val = Options.FarmSelector.Value
        if val and val ~= "None" and val ~= "" then
            addItemToList("FarmBuyListInput", val)
        end
    end
})
Tabs.Shop:AddButton({
    Title = "Remove Selected Farm from Buy List",
    Callback = function()
        local val = Options.FarmSelector.Value
        if val and val ~= "None" and val ~= "" then
            removeItemFromList("FarmBuyListInput", val)
        end
    end
})

-- Houses Section
Tabs.Shop:AddSection("Houses")
Tabs.Shop:AddToggle("AutoBuyHouse", {Title = "Auto Buy Houses", Default = false}):OnChanged(function()
    Toggles.AutoBuyHouse = Options.AutoBuyHouse.Value
end)
Tabs.Shop:AddToggle("BuyAllHouse", {Title = "Buy All House Types", Default = true}):OnChanged(function()
    Toggles.BuyAllHouse = Options.BuyAllHouse.Value
end)
local HouseDropdown = Tabs.Shop:AddDropdown("HouseSelector", {
    Title = "Select House Type",
    Values = HouseList,
    Default = HouseList[1] or "None",
    Callback = function() end
})
Tabs.Shop:AddInput("HouseBuyListInput", {
    Title = "Allowed House Buy List (Comma Separated)",
    Default = "Tent, Cabin",
    Placeholder = "Enter house names...",
    Finished = false,
    Callback = function() end
})
Tabs.Shop:AddButton({
    Title = "Add Selected House to Buy List",
    Callback = function()
        local val = Options.HouseSelector.Value
        if val and val ~= "None" and val ~= "" then
            addItemToList("HouseBuyListInput", val)
        end
    end
})
Tabs.Shop:AddButton({
    Title = "Remove Selected House from Buy List",
    Callback = function()
        local val = Options.HouseSelector.Value
        if val and val ~= "None" and val ~= "" then
            removeItemFromList("HouseBuyListInput", val)
        end
    end
})

-- Military Section
Tabs.Shop:AddSection("Military (Army)")
Tabs.Shop:AddToggle("AutoBuyMilitary", {Title = "Auto Buy Military Buildings", Default = false}):OnChanged(function()
    Toggles.AutoBuyMilitary = Options.AutoBuyMilitary.Value
end)
Tabs.Shop:AddToggle("BuyAllMilitary", {Title = "Buy All Military Types", Default = true}):OnChanged(function()
    Toggles.BuyAllMilitary = Options.BuyAllMilitary.Value
end)
local MilitaryDropdown = Tabs.Shop:AddDropdown("MilitarySelector", {
    Title = "Select Military Building",
    Values = MilitaryList,
    Default = MilitaryList[1] or "None",
    Callback = function() end
})
Tabs.Shop:AddInput("MilitaryBuyListInput", {
    Title = "Allowed Military Buy List (Comma Separated)",
    Default = "Barracks",
    Placeholder = "Enter military names...",
    Finished = false,
    Callback = function() end
})
Tabs.Shop:AddButton({
    Title = "Add Selected Military to Buy List",
    Callback = function()
        local val = Options.MilitarySelector.Value
        if val and val ~= "None" and val ~= "" then
            addItemToList("MilitaryBuyListInput", val)
        end
    end
})
Tabs.Shop:AddButton({
    Title = "Remove Selected Military from Buy List",
    Callback = function()
        local val = Options.MilitarySelector.Value
        if val and val ~= "None" and val ~= "" then
            removeItemFromList("MilitaryBuyListInput", val)
        end
    end
})

-- Special Section
Tabs.Shop:AddSection("Special (Decor)")
Tabs.Shop:AddToggle("AutoBuyDecor", {Title = "Auto Buy Special Buildings", Default = false}):OnChanged(function()
    Toggles.AutoBuyDecor = Options.AutoBuyDecor.Value
end)
Tabs.Shop:AddToggle("BuyAllDecor", {Title = "Buy All Special Types", Default = true}):OnChanged(function()
    Toggles.BuyAllDecor = Options.BuyAllDecor.Value
end)
local DecorDropdown = Tabs.Shop:AddDropdown("DecorSelector", {
    Title = "Select Special Building",
    Values = DecorList,
    Default = DecorList[1] or "None",
    Callback = function() end
})
Tabs.Shop:AddInput("DecorBuyListInput", {
    Title = "Allowed Special Buy List (Comma Separated)",
    Default = "Tree",
    Placeholder = "Enter special names...",
    Finished = false,
    Callback = function() end
})
Tabs.Shop:AddButton({
    Title = "Add Selected Special to Buy List",
    Callback = function()
        local val = Options.DecorSelector.Value
        if val and val ~= "None" and val ~= "" then
            addItemToList("DecorBuyListInput", val)
        end
    end
})
Tabs.Shop:AddButton({
    Title = "Remove Selected Special from Buy List",
    Callback = function()
        local val = Options.DecorSelector.Value
        if val and val ~= "None" and val ~= "" then
            removeItemFromList("DecorBuyListInput", val)
        end
    end
})

-- Dynamic Shop Stock Tracker and Dropdown Populator
local function updateShopDropdowns()
    pcall(function()
        local state = ClientData.playerProducer:getState().player
        if not state or not state.shopsStock then return end
        
        local function checkCategory(catName, currentList, dropdownObj, defaultList)
            local catData = state.shopsStock[catName]
            if catData and catData.stock then
                local items = {}
                for _, v in ipairs(defaultList) do
                    items[v] = true
                end
                for k, _ in pairs(catData.stock) do
                    items[k] = true
                end
                
                local keys = {}
                for k, _ in pairs(items) do
                    table.insert(keys, k)
                end
                table.sort(keys)
                
                local changed = (#keys ~= #currentList)
                if not changed then
                    for i, v in ipairs(keys) do
                        if v ~= currentList[i] then
                            changed = true
                            break
                        end
                    end
                end
                
                if changed then
                    table.clear(currentList)
                    for _, v in ipairs(keys) do
                        table.insert(currentList, v)
                    end
                    if dropdownObj then
                        dropdownObj:SetValues(currentList)
                    end
                end
            end
        end
        
        checkCategory("Farm", FarmList, FarmDropdown, defaultFarmList)
        checkCategory("House", HouseList, HouseDropdown, defaultHouseList)
        checkCategory("Military", MilitaryList, MilitaryDropdown, defaultMilitaryList)
        checkCategory("Decor", DecorList, DecorDropdown, defaultDecorList)
    end)
end

-- Initialize dropdown values with current state and start background updates
task.spawn(function()
    task.wait(2)
    updateShopDropdowns()
    while task.wait(5) do
        updateShopDropdowns()
    end
end)

-- Auto Sell Backpack Buildings Loop
task.spawn(function()
    while task.wait(5) do
        if Toggles.AutoSellBackpack then
            pcall(function()
                GetBridge("SellAllBuildings"):Fire()
            end)
        end
    end
end)

-- Auto Rebirth Loop
task.spawn(function()
    while task.wait(5) do
        if Toggles.AutoRebirth then
            pcall(function()
                GetBridge("GiveRebirth"):Fire()
            end)
        end
    end
end)

-- Combat Tab Elements
-- Find unowned capture points logic
local function findUnownedCapturePoint()
    local instances = CollectionService:GetTagged("CapturePoint")
    for _, cp in ipairs(instances) do
        local base = cp.Parent and cp.Parent.Parent
        if base then
            local owner = base:GetAttribute("Owner")
            local coOwner = base:GetAttribute("CoOwner")
            if owner ~= LocalPlayer.Name and coOwner ~= LocalPlayer.Name then
                return cp
            end
        end
    end
    return nil
end

local function updateCapturePoints()
    local names = {}
    local mapping = {}
    local instances = CollectionService:GetTagged("CapturePoint")
    for _, cp in ipairs(instances) do
        local displayName = cp.Name
        local base = cp:FindFirstAncestorWhichIsA("Model")
        if base and base.Parent and base.Parent.Name == "MilitaryBase" then
            displayName = "Base: " .. base.Name
        elseif cp.Name == "ToxicKingOfTheHillBase" then
            displayName = "KOTH: Toxic"
        end
        table.insert(names, displayName)
        mapping[displayName] = cp
    end
    CapturePointsList = names
    CapturePointInstances = mapping
end

updateCapturePoints()

local CombatDropdown = Tabs.Combat:AddDropdown("CapturePointSelector", {
    Title = "Select Target Capture Point",
    Values = CapturePointsList,
    Default = CapturePointsList[1] or "None",
    Callback = function(Value)
        SelectedCapturePoint = CapturePointInstances[Value]
    end
})
SelectedCapturePoint = CapturePointInstances[CapturePointsList[1]]

-- Dynamic updates to capture points list
CollectionService:GetInstanceAddedSignal("CapturePoint"):Connect(function()
    updateCapturePoints()
    if CombatDropdown then
        CombatDropdown:SetValues(CapturePointsList)
    end
end)

CollectionService:GetInstanceRemovedSignal("CapturePoint"):Connect(function()
    updateCapturePoints()
    if CombatDropdown then
        CombatDropdown:SetValues(CapturePointsList)
    end
end)

local ArmyDropdown = Tabs.Combat:AddDropdown("ArmySelector", {
    Title = "Select Army to Deploy",
    Values = {"All Armies", "Army 1", "Army 2", "Army 3", "Army 4", "Army 5", "Army 6", "Army 7", "Army 8", "Army 9", "Army 10"},
    Default = "Army 1",
    Callback = function(Value)
        if Value == "All Armies" then
            SelectedArmyIndex = "All"
        else
            SelectedArmyIndex = tonumber(Value:match("%d+")) or 1
        end
    end
})

Tabs.Combat:AddToggle("AutoDeploy", {Title = "Auto Deploy Troops", Default = false}):OnChanged(function()
    Toggles.AutoDeploy = Options.AutoDeploy.Value
end)

Tabs.Combat:AddToggle("MasterArmyFarm", {Title = "Master Army Farm (Auto Target Unowned)", Default = false}):OnChanged(function()
    Toggles.MasterArmyFarm = Options.MasterArmyFarm.Value
end)

Tabs.Combat:AddToggle("AutoRockets", {Title = "Auto Fire Rockets", Default = false}):OnChanged(function()
    Toggles.AutoRockets = Options.AutoRockets.Value
end)

-- Teleport to Target Capture Point Base button (fast capture method)
Tabs.Combat:AddButton({
    Title = "Teleport to Selected Base",
    Callback = function()
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and SelectedCapturePoint then
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                root.CFrame = SelectedCapturePoint.CFrame + Vector3.new(0, 5, 0)
            end
        end)
    end
})

-- Auto Deploy Troops / Master Farm Loop (Dispatches troops at 0.5s intervals for high capture speed)
task.spawn(function()
    while task.wait(0.5) do
        if SelectedCapturePoint then
            -- Master Army Farm target shifting
            if Toggles.MasterArmyFarm then
                pcall(function()
                    local base = SelectedCapturePoint.Parent and SelectedCapturePoint.Parent.Parent
                    if base then
                        local owner = base:GetAttribute("Owner")
                        local coOwner = base:GetAttribute("CoOwner")
                        if owner == LocalPlayer.Name or coOwner == LocalPlayer.Name then
                            local newTarget = findUnownedCapturePoint()
                            if newTarget then
                                SelectedCapturePoint = newTarget
                                for displayName, cp in pairs(CapturePointInstances) do
                                    if cp == newTarget then
                                        CombatDropdown:SetValue(displayName)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            
            -- Troop Dispatch
            if Toggles.AutoDeploy or Toggles.MasterArmyFarm then
                pcall(function()
                    if SelectedArmyIndex == "All" then
                        for i = 1, 10 do
                            GetBridge("SendTroopsToPoint"):Fire({
                                armyIndex = i,
                                capturePoint = SelectedCapturePoint
                            })
                            task.wait(0.02)
                        end
                    else
                        GetBridge("SendTroopsToPoint"):Fire({
                            armyIndex = SelectedArmyIndex,
                            capturePoint = SelectedCapturePoint
                        })
                    end
                end)
            end
        end
    end
end)

-- Auto Fire Rockets Loop
task.spawn(function()
    while task.wait(3) do
        if Toggles.AutoRockets and SelectedCapturePoint then
            pcall(function()
                GetBridge("SendRocketsToPoint"):Fire({
                    capturePoint = SelectedCapturePoint
                })
            end)
        end
    end
end)

-- Automation Tab Elements
Tabs.Automation:AddToggle("AutoResearch", {Title = "Auto Upgrade Research", Default = false}):OnChanged(function()
    Toggles.AutoResearch = Options.AutoResearch.Value
end)

Tabs.Automation:AddToggle("AutoDailyClaim", {Title = "Auto Claim Daily Rewards", Default = false}):OnChanged(function()
    Toggles.AutoDailyClaim = Options.AutoDailyClaim.Value
end)

Tabs.Automation:AddToggle("AutoQuestClaim", {Title = "Auto Claim Finished Quests", Default = false}):OnChanged(function()
    Toggles.AutoQuestClaim = Options.AutoQuestClaim.Value
end)

Tabs.Automation:AddToggle("AutoOfflineClaim", {Title = "Auto Claim Offline Money", Default = false}):OnChanged(function()
    Toggles.AutoOfflineClaim = Options.AutoOfflineClaim.Value
end)

-- Auto Research Upgrade Loop
task.spawn(function()
    while task.wait(4) do
        if Toggles.AutoResearch then
            pcall(function()
                local state = ClientData.playerProducer:getState().player
                if state and state.skills then
                    local isResearching = false
                    for skillId, unlockFinishTime in pairs(state.skills.currentlyUnlockingSkills) do
                        isResearching = true
                        break
                    end
                    
                    if not isResearching then
                        local playerCash = tonumber(state.money) or 0
                        for skillName, canUnlock in pairs(state.skills.skillsThatCanBeUnlocked) do
                            if canUnlock then
                                local config = SkillsConfig[skillName]
                                if config and playerCash >= config.Cost then
                                    GetBridge("TryToBuySkill"):Fire(skillName)
                                    task.wait(0.5)
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Claim Daily Rewards Loop
task.spawn(function()
    while task.wait(10) do
        if Toggles.AutoDailyClaim then
            pcall(function()
                local state = ClientData.playerProducer:getState().player
                local daily = state.dailyRewards
                if daily then
                    local lastClaim = tonumber(daily.lastClaimAt) or 0
                    local now = workspace:GetServerTimeNow()
                    if (now - lastClaim) >= 86400 then
                        GetBridge("DailyRewardsClaim"):Fire()
                    end
                end
            end)
        end
    end
end)

-- Auto Claim Completed Quests Loop
task.spawn(function()
    while task.wait(5) do
        if Toggles.AutoQuestClaim then
            pcall(function()
                local state = ClientData.playerProducer:getState().player
                local quests = state.questData and state.questData.activeQuests
                if quests then
                    local QuestsConfig = require(ReplicatedStorage.shared.config.QuestsConfig)
                    for questId, questObj in pairs(quests) do
                        local config = QuestsConfig[questId]
                        if config and questObj.progress >= config.max and not questObj.completed then
                            GetBridge("TryToCompleteQuest"):Fire(questId)
                            task.wait(0.2)
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Claim Offline Earnings Loop
task.spawn(function()
    while task.wait(10) do
        if Toggles.AutoOfflineClaim then
            pcall(function()
                GetBridge("collectOfflineMoney"):Fire()
            end)
        end
    end
end)

-- Misc Tab Elements (WalkSpeed, JumpPower, Noclip)
Tabs.Misc:AddSlider("WalkSpeedSlider", {
    Title = "Walk Speed",
    Description = "Adjust character walk speed (Default: 16)",
    Min = 16,
    Max = 150,
    Default = 16,
    Rounding = 1,
    Callback = function(Value)
        WalkSpeed = Value
    end
})

Tabs.Misc:AddSlider("JumpPowerSlider", {
    Title = "Jump Power",
    Description = "Adjust character jump power (Default: 50)",
    Min = 50,
    Max = 200,
    Default = 50,
    Rounding = 1,
    Callback = function(Value)
        JumpPower = Value
    end
})

Tabs.Misc:AddToggle("NoclipToggle", {Title = "Noclip", Default = false}):OnChanged(function()
    Noclip = Options.NoclipToggle.Value
end)

-- Noclip loop
game:GetService("RunService").Stepped:Connect(function()
    if Noclip then
        pcall(function()
            local char = LocalPlayer.Character
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-- WalkSpeed & JumpPower loop
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = WalkSpeed
                hum.JumpPower = JumpPower
            end
        end)
    end
end)

-- Settings UI & Save Management Configuration
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("MiniWarScript")
SaveManager:SetFolder("MiniWarScript/Main")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Mini War Auto-Farm",
    Content = "Script Overhaul Loaded Successfully!",
    Duration = 5
})
