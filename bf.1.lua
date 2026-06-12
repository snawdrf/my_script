local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = nil
local InterfaceManager = nil
pcall(function()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/SaveManager.lua"))()
end)
pcall(function()
    InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/InterfaceManager.lua"))()
end)

local Window = Fluent:CreateWindow({
    Title = "BloxFruits Hub - Ultimate Edition (FULL)",
    SubTitle = "by Gemini CLI",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main Farm", Icon = "home" }),
    Combat = Window:AddTab({ Title = "Combat/PVP", Icon = "sword" }),
    Quest = Window:AddTab({ Title = "Item Quests", Icon = "scroll" }),
    SeaEvent = Window:AddTab({ Title = "Sea Events", Icon = "compass" }),
    Raid = Window:AddTab({ Title = "Dungeon/Raid", Icon = "zap" }),
    Fruit = Window:AddTab({ Title = "Devil Fruit", Icon = "apple" }),
    ESP = Window:AddTab({ Title = "Visuals/ESP", Icon = "eye" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "bar-chart" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Global State
_G.AutoFarm = false
_G.AutoNearestFarm = false
_G.AutoMasteryFarm = false
_G.AutoBossFarm = false
_G.AutoMaterialFarm = false
_G.AutoQuest = true
_G.BringMob = true
_G.FastAttack = true
_G.AutoHaki = false
_G.WeaponSelect = "Melee"
_G.FarmMode = "Level Farm"
_G.MasterySelect = "Melee"
_G.MasteryIslandSelect = "Current Location"
_G.MaterialSelect = "Bones"
_G.AutoDriveBoat = false
_G.SelectedDangerLevel = "Level 6"
_G.SelectedBoat = "PirateBrigade"
_G.AutoTweenToPlayer = false
_G.Disable3D = false
_G.AutoSpinGacha = false

_G.TargetPlayer = nil
_G.AutoPvP = false
_G.Aimbot = false
_G.KillAura = false

_G.AutoSaber = false
_G.AutoRengoku = false

_G.AutoSeaBeast = false
_G.AutoShark = false
_G.AutoPiranha = false
_G.AutoTerrorshark = false
_G.AutoGhostShip = false

_G.AutoRaid = false
_G.AutoAwaken = false
_G.RaidType = "Flame"

_G.AutoFarmFruit = false
_G.AutoStoreFruit = false

_G.ESPPlayer = false
_G.ESPChest = false
_G.ESPFruit = false
_G.ESPFlower = false
_G.ESPMob = false
_G.ESPIsland = false

_G.AutoStats = false
_G.StatType = "Melee"

_G.SafeFarm = true
_G.AntiAFK = true
_G.NoClip = false
_G.InfiniteJump = false

-- World Detection
local World1, World2, World3 = false, false, false
if game.PlaceId == 2753915549 then World1 = true
elseif game.PlaceId == 4442272183 then World2 = true
elseif game.PlaceId == 7449423635 then World3 = true end

-- Anti-Ban / Safety Bypass
if getrawmetatable and setreadonly and newcclosure then
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = tostring(self)
            if remoteName == "TeleportDetect" or remoteName == "CHECKER_1" or remoteName == "BANREMOTE" or remoteName == "CHECKER" or remoteName == "GUI_CHECK" or remoteName == "OneMoreTime" or remoteName == "checkingSPEED" or remoteName == "PERMAIDBAN" or remoteName == "KICKREMOTE" or remoteName == "BR_KICKPC" or remoteName == "BR_KICKMOBILE" then
                return nil
            end
        end
        if method == "Kick" then
            return wait(9e9)
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end

-- Safe Farm local script removal loop
task.spawn(function()
    while task.wait(1) do
        if _G.SafeFarm then
            pcall(function()
                if LocalPlayer.Character then
                    for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("LocalScript") and (v.Name == "General" or v.Name == "Shiftlock" or v.Name == "FallDamage" or v.Name == "4444" or v.Name == "CamBob" or v.Name == "JumpCD" or v.Name == "Looking" or v.Name == "Run") then
                            v:Destroy()
                        end
                    end
                end
                for _, v in ipairs(LocalPlayer.PlayerScripts:GetDescendants()) do
                    if v:IsA("LocalScript") and (v.Name == "RobloxMotor6DBugFix" or v.Name == "Clans" or v.Name == "Codes" or v.Name == "CustomForceField" or v.Name == "MenuBloodSp" or v.Name == "PlayerList") then
                        v:Destroy()
                    end
                end
            end)
        end
    end
end)

-- NPC Data Table (Extracted and Fixed)
local QuestData = {
    Sea1 = {
        {MinLevel = 1, MaxLevel = 9, Mon = "Bandit", Quest = "BanditQuest1", QuestLv = 1, QPos = CFrame.new(1059, 16, 1550), MPos = CFrame.new(1045, 27, 1560)},
        {MinLevel = 10, MaxLevel = 14, Mon = "Monkey", Quest = "JungleQuest", QuestLv = 1, QPos = CFrame.new(-1598, 35, 153), MPos = CFrame.new(-1448, 67, 11)},
        {MinLevel = 15, MaxLevel = 29, Mon = "Gorilla", Quest = "JungleQuest", QuestLv = 2, QPos = CFrame.new(-1598, 35, 153), MPos = CFrame.new(-1129, 40, -525)},
        {MinLevel = 30, MaxLevel = 39, Mon = "Pirate", Quest = "BuggyQuest1", QuestLv = 1, QPos = CFrame.new(-1141, 4, 3831), MPos = CFrame.new(-1103, 13, 3896)},
        {MinLevel = 40, MaxLevel = 59, Mon = "Brute", Quest = "BuggyQuest1", QuestLv = 2, QPos = CFrame.new(-1141, 4, 3831), MPos = CFrame.new(-1140, 14, 4322)},
        {MinLevel = 60, MaxLevel = 74, Mon = "Desert Bandit", Quest = "DesertQuest", QuestLv = 1, QPos = CFrame.new(894, 5, 4392), MPos = CFrame.new(924, 6, 4481)},
        {MinLevel = 75, MaxLevel = 89, Mon = "Desert Officer", Quest = "DesertQuest", QuestLv = 2, QPos = CFrame.new(894, 5, 4392), MPos = CFrame.new(1608, 8, 4371)},
        {MinLevel = 90, MaxLevel = 99, Mon = "Snow Bandit", Quest = "SnowQuest", QuestLv = 1, QPos = CFrame.new(1389, 88, -1298), MPos = CFrame.new(1354, 87, -1393)},
        {MinLevel = 100, MaxLevel = 119, Mon = "Snowman", Quest = "SnowQuest", QuestLv = 2, QPos = CFrame.new(1389, 88, -1298), MPos = CFrame.new(1201, 144, -1550)},
        {MinLevel = 120, MaxLevel = 149, Mon = "Chief Petty Officer", Quest = "MarineQuest2", QuestLv = 1, QPos = CFrame.new(-5039, 27, 4324), MPos = CFrame.new(-4881, 22, 4273)},
        {MinLevel = 150, MaxLevel = 174, Mon = "Sky Bandit", Quest = "SkyQuest", QuestLv = 1, QPos = CFrame.new(-4839, 716, -2619), MPos = CFrame.new(-4953, 295, -2899)},
        {MinLevel = 175, MaxLevel = 189, Mon = "Dark Master", Quest = "SkyQuest", QuestLv = 2, QPos = CFrame.new(-4839, 716, -2619), MPos = CFrame.new(-5259, 391, -2229)},
        {MinLevel = 190, MaxLevel = 209, Mon = "Prisoner", Quest = "PrisonerQuest", QuestLv = 1, QPos = CFrame.new(5308, 1, 475), MPos = CFrame.new(5098, -0, 474)},
        {MinLevel = 210, MaxLevel = 249, Mon = "Dangerous Prisoner", Quest = "PrisonerQuest", QuestLv = 2, QPos = CFrame.new(5308, 1, 475), MPos = CFrame.new(5654, 15, 866)},
        {MinLevel = 250, MaxLevel = 274, Mon = "Toga Warrior", Quest = "ColosseumQuest", QuestLv = 1, QPos = CFrame.new(-1580, 6, -2986), MPos = CFrame.new(-1820, 51, -2740)},
        {MinLevel = 275, MaxLevel = 299, Mon = "Gladiator", Quest = "ColosseumQuest", QuestLv = 2, QPos = CFrame.new(-1580, 6, -2986), MPos = CFrame.new(-1292, 56, -3339)},
        {MinLevel = 300, MaxLevel = 324, Mon = "Military Soldier", Quest = "MagmaQuest", QuestLv = 1, QPos = CFrame.new(-5313, 10, 8515), MPos = CFrame.new(-5411, 11, 8454)},
        {MinLevel = 325, MaxLevel = 374, Mon = "Military Spy", Quest = "MagmaQuest", QuestLv = 2, QPos = CFrame.new(-5313, 10, 8515), MPos = CFrame.new(-5802, 86, 8828)},
        {MinLevel = 375, MaxLevel = 399, Mon = "Fishman Warrior", Quest = "FishmanQuest", QuestLv = 1, QPos = CFrame.new(61122, 18, 1569), MPos = CFrame.new(60878, 18, 1543)},
        {MinLevel = 400, MaxLevel = 449, Mon = "Fishman Commando", Quest = "FishmanQuest", QuestLv = 2, QPos = CFrame.new(61122, 18, 1569), MPos = CFrame.new(61922, 18, 1493)},
        {MinLevel = 450, MaxLevel = 474, Mon = "God's Guard", Quest = "SkyExp1Quest", QuestLv = 1, QPos = CFrame.new(-4721, 843, -1949), MPos = CFrame.new(-4710, 845, -1927)},
        {MinLevel = 475, MaxLevel = 524, Mon = "Shanda", Quest = "SkyExp1Quest", QuestLv = 2, QPos = CFrame.new(-7859, 5544, -381), MPos = CFrame.new(-7678, 5566, -497)},
        {MinLevel = 525, MaxLevel = 549, Mon = "Royal Squad", Quest = "SkyExp2Quest", QuestLv = 1, QPos = CFrame.new(-7906, 5634, -1411), MPos = CFrame.new(-7624, 5658, -1467)},
        {MinLevel = 550, MaxLevel = 624, Mon = "Royal Soldier", Quest = "SkyExp2Quest", QuestLv = 2, QPos = CFrame.new(-7906, 5634, -1411), MPos = CFrame.new(-7836, 5645, -1790)},
        {MinLevel = 625, MaxLevel = 649, Mon = "Galley Pirate", Quest = "FountainQuest", QuestLv = 1, QPos = CFrame.new(5259, 37, 4050), MPos = CFrame.new(5551, 78, 3930)},
        {MinLevel = 650, MaxLevel = 2500, Mon = "Galley Captain", Quest = "FountainQuest", QuestLv = 2, QPos = CFrame.new(5259, 37, 4050), MPos = CFrame.new(5441, 42, 4950)}
    },
    Sea2 = {
        {MinLevel = 700, MaxLevel = 724, Mon = "Raider", Quest = "Area1Quest", QuestLv = 1, QPos = CFrame.new(-429, 71, 1836), MPos = CFrame.new(-728, 52, 2345)},
        {MinLevel = 725, MaxLevel = 774, Mon = "Mercenary", Quest = "Area1Quest", QuestLv = 2, QPos = CFrame.new(-429, 71, 1836), MPos = CFrame.new(-1004, 80, 1424)},
        {MinLevel = 775, MaxLevel = 799, Mon = "Swan Pirate", Quest = "Area2Quest", QuestLv = 1, QPos = CFrame.new(638, 71, 918), MPos = CFrame.new(1068, 137, 1322)},
        {MinLevel = 800, MaxLevel = 874, Mon = "Factory Staff", Quest = "Area2Quest", QuestLv = 2, QPos = CFrame.new(632, 73, 918), MPos = CFrame.new(73, 81, -27)},
        {MinLevel = 875, MaxLevel = 899, Mon = "Marine Lieutenant", Quest = "MarineQuest3", QuestLv = 1, QPos = CFrame.new(-2440, 71, -3216), MPos = CFrame.new(-2821, 75, -3070)},
        {MinLevel = 900, MaxLevel = 949, Mon = "Marine Captain", Quest = "MarineQuest3", QuestLv = 2, QPos = CFrame.new(-2440, 71, -3216), MPos = CFrame.new(-1861, 80, -3254)},
        {MinLevel = 950, MaxLevel = 974, Mon = "Zombie", Quest = "ZombieQuest", QuestLv = 1, QPos = CFrame.new(-5497, 47, -795), MPos = CFrame.new(-5657, 78, -928)},
        {MinLevel = 975, MaxLevel = 999, Mon = "Vampire", Quest = "ZombieQuest", QuestLv = 2, QPos = CFrame.new(-5497, 47, -795), MPos = CFrame.new(-6037, 32, -1340)},
        {MinLevel = 1000, MaxLevel = 1049, Mon = "Snow Trooper", Quest = "SnowMountainQuest", QuestLv = 1, QPos = CFrame.new(609, 400, -5372), MPos = CFrame.new(549, 427, -5563)},
        {MinLevel = 1050, MaxLevel = 1099, Mon = "Winter Warrior", Quest = "SnowMountainQuest", QuestLv = 2, QPos = CFrame.new(609, 400, -5372), MPos = CFrame.new(1142, 475, -5199)},
        {MinLevel = 1100, MaxLevel = 1124, Mon = "Lab Subordinate", Quest = "IceSideQuest", QuestLv = 1, QPos = CFrame.new(-6064, 15, -4902), MPos = CFrame.new(-5707, 15, -4513)},
        {MinLevel = 1125, MaxLevel = 1174, Mon = "Horned Warrior", Quest = "IceSideQuest", QuestLv = 2, QPos = CFrame.new(-6064, 15, -4902), MPos = CFrame.new(-6341, 15, -5723)},
        {MinLevel = 1175, MaxLevel = 1199, Mon = "Magma Ninja", Quest = "FireSideQuest", QuestLv = 1, QPos = CFrame.new(-5428, 15, -5299), MPos = CFrame.new(-5449, 76, -5808)},
        {MinLevel = 1200, MaxLevel = 1249, Mon = "Lava Pirate", Quest = "FireSideQuest", QuestLv = 2, QPos = CFrame.new(-5428, 15, -5299), MPos = CFrame.new(-5213, 49, -4701)},
        {MinLevel = 1250, MaxLevel = 1274, Mon = "Ship Deckhand", Quest = "ShipQuest1", QuestLv = 1, QPos = CFrame.new(1037, 125, 32911), MPos = CFrame.new(1212, 150, 33059)},
        {MinLevel = 1275, MaxLevel = 1299, Mon = "Ship Engineer", Quest = "ShipQuest1", QuestLv = 2, QPos = CFrame.new(1037, 125, 32911), MPos = CFrame.new(919, 43, 32779)},
        {MinLevel = 1300, MaxLevel = 1324, Mon = "Ship Steward", Quest = "ShipQuest2", QuestLv = 1, QPos = CFrame.new(968, 125, 33244), MPos = CFrame.new(919, 129, 33436)},
        {MinLevel = 1325, MaxLevel = 1349, Mon = "Ship Officer", Quest = "ShipQuest2", QuestLv = 2, QPos = CFrame.new(968, 125, 33244), MPos = CFrame.new(1036, 181, 33315)},
        {MinLevel = 1350, MaxLevel = 1374, Mon = "Arctic Warrior", Quest = "FrostQuest", QuestLv = 1, QPos = CFrame.new(5667, 26, -6486), MPos = CFrame.new(5966, 62, -6179)},
        {MinLevel = 1375, MaxLevel = 1424, Mon = "Snow Lurker", Quest = "FrostQuest", QuestLv = 2, QPos = CFrame.new(5667, 26, -6486), MPos = CFrame.new(5407, 69, -6880)},
        {MinLevel = 1425, MaxLevel = 1449, Mon = "Sea Soldier", Quest = "ForgottenQuest", QuestLv = 1, QPos = CFrame.new(-3054, 235, -10142), MPos = CFrame.new(-3028, 64, -9775)},
        {MinLevel = 1450, MaxLevel = 2500, Mon = "Water Fighter", Quest = "ForgottenQuest", QuestLv = 2, QPos = CFrame.new(-3054, 235, -10142), MPos = CFrame.new(-3352, 285, -10534)}
    },
    Sea3 = {
        {MinLevel = 1500, MaxLevel = 1524, Mon = "Pirate Millionaire", Quest = "PiratePortQuest", QuestLv = 1, QPos = CFrame.new(-290, 42, 5581), MPos = CFrame.new(-245, 47, 5584)},
        {MinLevel = 1525, MaxLevel = 1574, Mon = "Pistol Billionaire", Quest = "PiratePortQuest", QuestLv = 2, QPos = CFrame.new(-290, 42, 5581), MPos = CFrame.new(-187, 86, 6013)},
        {MinLevel = 1575, MaxLevel = 1599, Mon = "Dragon Crew Warrior", Quest = "AmazonQuest", QuestLv = 1, QPos = CFrame.new(5832, 51, -1101), MPos = CFrame.new(6141, 51, -1340)},
        {MinLevel = 1600, MaxLevel = 1624, Mon = "Dragon Crew Archer", Quest = "AmazonQuest", QuestLv = 2, QPos = CFrame.new(5832, 51, -1101), MPos = CFrame.new(6616, 441, 446)},
        {MinLevel = 1625, MaxLevel = 1649, Mon = "Female Islander", Quest = "AmazonQuest2", QuestLv = 1, QPos = CFrame.new(5446, 601, 749), MPos = CFrame.new(4685, 735, 815)},
        {MinLevel = 1650, MaxLevel = 1699, Mon = "Giant Islander", Quest = "AmazonQuest2", QuestLv = 2, QPos = CFrame.new(5446, 601, 749), MPos = CFrame.new(4729, 590, -36)},
        {MinLevel = 1700, MaxLevel = 1724, Mon = "Marine Commodore", Quest = "MarineTreeIsland", QuestLv = 1, QPos = CFrame.new(2180, 27, -6741), MPos = CFrame.new(2286, 73, -7159)},
        {MinLevel = 1725, MaxLevel = 1774, Mon = "Marine Rear Admiral", Quest = "MarineTreeIsland", QuestLv = 2, QPos = CFrame.new(2180, 27, -6741), MPos = CFrame.new(3656, 160, -7001)},
        {MinLevel = 1775, MaxLevel = 1799, Mon = "Fishman Raider", Quest = "DeepForestIsland3", QuestLv = 1, QPos = CFrame.new(-10581, 330, -8761), MPos = CFrame.new(-10407, 331, -8368)},
        {MinLevel = 1800, MaxLevel = 1824, Mon = "Fishman Captain", Quest = "DeepForestIsland3", QuestLv = 2, QPos = CFrame.new(-10581, 330, -8761), MPos = CFrame.new(-10994, 352, -9002)},
        {MinLevel = 1825, MaxLevel = 1849, Mon = "Forest Pirate", Quest = "DeepForestIsland", QuestLv = 1, QPos = CFrame.new(-13234, 331, -7625), MPos = CFrame.new(-13274, 332, -7769)},
        {MinLevel = 1850, MaxLevel = 1899, Mon = "Mythological Pirate", Quest = "DeepForestIsland", QuestLv = 2, QPos = CFrame.new(-13234, 331, -7625), MPos = CFrame.new(-13680, 501, -6991)},
        {MinLevel = 1900, MaxLevel = 1924, Mon = "Jungle Pirate", Quest = "DeepForestIsland2", QuestLv = 1, QPos = CFrame.new(-12680, 389, -9902), MPos = CFrame.new(-12256, 331, -10485)},
        {MinLevel = 1925, MaxLevel = 1974, Mon = "Musketeer Pirate", Quest = "DeepForestIsland2", QuestLv = 2, QPos = CFrame.new(-12680, 389, -9902), MPos = CFrame.new(-13457, 391, -9859)},
        {MinLevel = 1975, MaxLevel = 1999, Mon = "Reborn Skeleton", Quest = "HauntedQuest1", QuestLv = 1, QPos = CFrame.new(-9479, 141, 5566), MPos = CFrame.new(-8763, 165, 6159)},
        {MinLevel = 2000, MaxLevel = 2024, Mon = "Living Zombie", Quest = "HauntedQuest1", QuestLv = 2, QPos = CFrame.new(-9479, 141, 5566), MPos = CFrame.new(-10144, 138, 5838)},
        {MinLevel = 2025, MaxLevel = 2049, Mon = "Demonic Soul", Quest = "HauntedQuest2", QuestLv = 1, QPos = CFrame.new(-9516, 172, 6078), MPos = CFrame.new(-9505, 172, 6158)},
        {MinLevel = 2050, MaxLevel = 2074, Mon = "Posessed Mummy", Quest = "HauntedQuest2", QuestLv = 2, QPos = CFrame.new(-9516, 172, 6078), MPos = CFrame.new(-9582, 6, 6205)},
        {MinLevel = 2075, MaxLevel = 2099, Mon = "Peanut Scout", Quest = "NutsIslandQuest", QuestLv = 1, QPos = CFrame.new(-2104, 38, -10194), MPos = CFrame.new(-2143, 47, -10029)},
        {MinLevel = 2100, MaxLevel = 2124, Mon = "Peanut President", Quest = "NutsIslandQuest", QuestLv = 2, QPos = CFrame.new(-2104, 38, -10194), MPos = CFrame.new(-1859, 38, -10422)},
        {MinLevel = 2125, MaxLevel = 2149, Mon = "Ice Cream Chef", Quest = "IceCreamIslandQuest", QuestLv = 1, QPos = CFrame.new(-820, 65, -10965), MPos = CFrame.new(-872, 65, -10919)},
        {MinLevel = 2150, MaxLevel = 2199, Mon = "Ice Cream Commander", Quest = "IceCreamIslandQuest", QuestLv = 2, QPos = CFrame.new(-820, 65, -10965), MPos = CFrame.new(-558, 112, -11290)},
        {MinLevel = 2200, MaxLevel = 2224, Mon = "Cookie Crafter", Quest = "CakeQuest1", QuestLv = 1, QPos = CFrame.new(-2021, 37, -12028), MPos = CFrame.new(-2374, 37, -12125)},
        {MinLevel = 2225, MaxLevel = 2249, Mon = "Cake Guard", Quest = "CakeQuest1", QuestLv = 2, QPos = CFrame.new(-2021, 37, -12028), MPos = CFrame.new(-1598, 43, -12244)},
        {MinLevel = 2250, MaxLevel = 2274, Mon = "Baking Staff", Quest = "CakeQuest2", QuestLv = 1, QPos = CFrame.new(-1927, 37, -12842), MPos = CFrame.new(-1887, 77, -12998)},
        {MinLevel = 2275, MaxLevel = 2299, Mon = "Head Baker", Quest = "CakeQuest2", QuestLv = 2, QPos = CFrame.new(-1927, 37, -12842), MPos = CFrame.new(-2216, 82, -12869)},
        {MinLevel = 2300, MaxLevel = 2324, Mon = "Cocoa Warrior", Quest = "ChocQuest1", QuestLv = 1, QPos = CFrame.new(233, 29, -12201), MPos = CFrame.new(-21, 80, -12352)},
        {MinLevel = 2325, MaxLevel = 2349, Mon = "Chocolate Bar Battler", Quest = "ChocQuest1", QuestLv = 2, QPos = CFrame.new(233, 29, -12201), MPos = CFrame.new(582, 77, -12463)},
        {MinLevel = 2350, MaxLevel = 2374, Mon = "Sweet Thief", Quest = "ChocQuest2", QuestLv = 1, QPos = CFrame.new(150, 30, -12774), MPos = CFrame.new(165, 76, -12600)},
        {MinLevel = 2375, MaxLevel = 2399, Mon = "Candy Rebel", Quest = "ChocQuest2", QuestLv = 2, QPos = CFrame.new(150, 30, -12774), MPos = CFrame.new(134, 77, -12876)},
        {MinLevel = 2400, MaxLevel = 2424, Mon = "Candy Pirate", Quest = "CandyQuest1", QuestLv = 1, QPos = CFrame.new(-1150, 20, -14446), MPos = CFrame.new(-1310, 26, -14562)},
        {MinLevel = 2425, MaxLevel = 2449, Mon = "Snow Demon", Quest = "CandyQuest1", QuestLv = 2, QPos = CFrame.new(-1150, 20, -14446), MPos = CFrame.new(-880, 71, -14538)},
        {MinLevel = 2450, MaxLevel = 2474, Mon = "Isle Outlaw", Quest = "TikiQuest1", QuestLv = 1, QPos = CFrame.new(-16548.8, 55.6, -172.8), MPos = CFrame.new(-16163.4, 11.9, -99.4)},
        {MinLevel = 2475, MaxLevel = 2499, Mon = "Island Boy", Quest = "TikiQuest1", QuestLv = 2, QPos = CFrame.new(-16548.8, 55.6, -172.8), MPos = CFrame.new(-16736.2, 20.5, -131.7)},
        {MinLevel = 2500, MaxLevel = 2524, Mon = "Sun-kissed Warrior", Quest = "TikiQuest2", QuestLv = 1, QPos = CFrame.new(-16541.0, 54.8, 1051.5), MPos = CFrame.new(-16052.5, 9.8, 1061.9)},
        {MinLevel = 2525, MaxLevel = 2549, Mon = "Isle Champion", Quest = "TikiQuest2", QuestLv = 2, QPos = CFrame.new(-16541.0, 54.8, 1051.5), MPos = CFrame.new(-16940.8, 14.2, 1070.9)},
        {MinLevel = 2550, MaxLevel = 2574, Mon = "Serpent Hunter", Quest = "TikiQuest3", QuestLv = 1, QPos = CFrame.new(-16665.2, 104.6, 1579.7), MPos = CFrame.new(-16442.8, 71.6, 1693.4)},
        {MinLevel = 2575, MaxLevel = 2599, Mon = "Skull Slayer", Quest = "TikiQuest3", QuestLv = 2, QPos = CFrame.new(-16665.2, 104.6, 1579.7), MPos = CFrame.new(-16811.6, 86.1, 1542.2)},
        {MinLevel = 2600, MaxLevel = 2624, Mon = "Reef Bandit", Quest = "SubmergedQuest1", QuestLv = 1, QPos = CFrame.new(11309.1, -2135.3, 9706.6), MPos = CFrame.new(11039.6, -2156.1, 9279.1)},
        {MinLevel = 2625, MaxLevel = 2649, Mon = "Coral Pirate", Quest = "SubmergedQuest1", QuestLv = 2, QPos = CFrame.new(11309.1, -2135.3, 9706.6), MPos = CFrame.new(10646.8, -2087.3, 9304.2)},
        {MinLevel = 2650, MaxLevel = 2674, Mon = "Sea Chanter", Quest = "SubmergedQuest2", QuestLv = 1, QPos = CFrame.new(10533.3, -2029.1, 9940.5), MPos = CFrame.new(10581.5, -2071.7, 10020.7)},
        {MinLevel = 2675, MaxLevel = 2699, Mon = "High Disciple", Quest = "SubmergedQuest3", QuestLv = 1, QPos = CFrame.new(9854.4, -1995.1, 9963.9), MPos = CFrame.new(9854.4, -1995.1, 9963.9)},
        {MinLevel = 2700, MaxLevel = 3000, Mon = "Grand Devotee", Quest = "SubmergedQuest3", QuestLv = 2, QPos = CFrame.new(9854.4, -1995.1, 9963.9), MPos = CFrame.new(9559.2, -1994.4, 9798.7)}
    }
}

-- Island Teleports Coords
local IslandCoords = {
    Sea1 = {
        ["Starter Island"] = CFrame.new(979.79, 16.51, 1429.04),
        ["Marine"] = CFrame.new(-2566.42, 6.85, 2045.25),
        ["Middle Town"] = CFrame.new(-690.33, 15.09, 1582.23),
        ["Jungle"] = CFrame.new(-1612.79, 36.85, 149.12),
        ["Pirate Village"] = CFrame.new(-1181.30, 4.75, 3803.54),
        ["Desert"] = CFrame.new(944.15, 20.91, 4373.30),
        ["Frozen Village"] = CFrame.new(1347.80, 104.66, -1319.73),
        ["Marine Fortress"] = CFrame.new(-4914.82, 50.96, 4281.02),
        ["Colosseum"] = CFrame.new(-1427.62, 7.28, -2792.77),
        ["Skylands"] = CFrame.new(-4869.10, 733.46, -2667.01),
        ["Prison"] = CFrame.new(4875.33, 5.65, 734.85),
        ["Magma Village"] = CFrame.new(-5247.71, 12.88, 8504.96),
        ["Fountain City"] = CFrame.new(5127.12, 59.50, 4105.44)
    },
    Sea2 = {
        ["Cafe"] = CFrame.new(-380.47, 77.22, 255.82),
        ["Kingdom of Rose"] = CFrame.new(-11.31, 29.27, 2771.52),
        ["Dark Arena"] = CFrame.new(3780.03, 22.65, -3498.58),
        ["Mansion"] = CFrame.new(-483.73, 332.03, 595.32),
        ["Green Zone"] = CFrame.new(-2448.53, 73.01, -3210.63),
        ["Factory"] = CFrame.new(424.12, 211.16, -427.54),
        ["Colosseum"] = CFrame.new(-1503.62, 219.79, 1369.31),
        ["Graveyard"] = CFrame.new(-5622.03, 492.19, -781.78),
        ["Snow Mountain"] = CFrame.new(753.14, 408.23, -5274.61),
        ["Hot and Cold"] = CFrame.new(-6127.65, 15.95, -5040.28),
        ["Cursed Ship"] = CFrame.new(923.40, 125.05, 32885.87),
        ["Ice Castle"] = CFrame.new(6148.41, 294.38, -6741.11),
        ["Forgotten Island"] = CFrame.new(-3032.76, 317.89, -10075.37)
    },
    Sea3 = {
        ["Port Town"] = CFrame.new(-290.73, 6.72, 5343.55),
        ["Great Tree"] = CFrame.new(2681.27, 1682.80, -7190.98),
        ["Castle on the Sea"] = CFrame.new(-5074.45, 314.51, -2991.05),
        ["Hydra Island"] = CFrame.new(5228.88, 604.23, 345.04),
        ["Floating Turtle"] = CFrame.new(-13274.52, 531.82, -7579.22),
        ["Haunted Castle"] = CFrame.new(-9515.37, 164.00, 5786.06),
        ["Ice Cream Island"] = CFrame.new(-902.56, 79.93, -10988.84),
        ["Peanut Island"] = CFrame.new(-2062.74, 50.47, -10232.56),
        ["Cake Island"] = CFrame.new(-1884.77, 19.32, -11666.89),
        ["Cocoa Island"] = CFrame.new(87.94, 73.55, -12319.46),
        ["Candy Island"] = CFrame.new(-1014.42, 149.11, -14555.96),
        ["Tiki Outpost"] = CFrame.new(-16641.5, 213.3, 435.3),
        ["Submerged Island"] = CFrame.new(11309.1, -2135.3, 9706.6)
    }
}

local StyleNPCCoords = {
    ["Black Leg"] = CFrame.new(-1289.38, 4.74, 3816.03),
    ["Fishman Karate"] = CFrame.new(60878, 18, 1543),
    ["Electro"] = CFrame.new(-4664.67, 878.02, -1744.11),
    ["Dragon Breath"] = CFrame.new(-932.33, 112.56, 1269.49),
    ["Superhuman"] = CFrame.new(1110.12, 4.75, -5073.38),
    ["Death Step"] = CFrame.new(5569.30, 28.57, -6483.20),
    ["Sharkman Karate"] = CFrame.new(-3056.22, 240.57, -10142.90),
    ["Electric Claw"] = CFrame.new(-16447.1, 71.6, 1693.4),
    ["Dragon Talon"] = CFrame.new(-9510.5, 164.0, 5786.1),
    ["Godhuman"] = CFrame.new(-16665.2, 104.6, 1579.7)
}

local portalRemoteMap = {
    ["Starter Island"] = "Starter Island",
    ["Marine"] = "Marine",
    ["Middle Town"] = "Middle Town",
    ["Jungle"] = "Jungle",
    ["Pirate Village"] = "Pirate Village",
    ["Desert"] = "Desert",
    ["Frozen Village"] = "Frozen Village",
    ["Marine Fortress"] = "Marine Fortress",
    ["Colosseum"] = "Colosseum",
    ["Skylands"] = "Skylands",
    ["Prison"] = "Prison",
    ["Magma Village"] = "Magma Village",
    ["Fountain City"] = "Fountain City",
    ["Cafe"] = "Cafe",
    ["Kingdom of Rose"] = "Kingdom of Rose",
    ["Dark Arena"] = "Dark Arena",
    ["Mansion"] = "Mansion",
    ["Green Zone"] = "Green Zone",
    ["Factory"] = "Factory",
    ["Graveyard"] = "Graveyard",
    ["Snow Mountain"] = "Snow Mountain",
    ["Hot and Cold"] = "Hot and Cold",
    ["Cursed Ship"] = "Cursed Ship",
    ["Ice Castle"] = "Ice Castle",
    ["Forgotten Island"] = "Forgotten Island",
    ["Port Town"] = "Port Town",
    ["Great Tree"] = "Great Tree",
    ["Castle on the Sea"] = "Castle on the Sea",
    ["Hydra Island"] = "Hydra Island",
    ["Floating Turtle"] = "Floating Turtle",
    ["Haunted Castle"] = "Haunted Castle",
    ["Ice Cream Island"] = "Ice Cream Island",
    ["Peanut Island"] = "Peanut Island",
    ["Cake Island"] = "Cake Island",
    ["Cocoa Island"] = "Cocoa Island",
    ["Candy Island"] = "Candy Island",
    ["Tiki Outpost"] = "Tiki Outpost",
    ["Submerged Island"] = "Submerged Island"
}

-- Helpers
local function getLevel()
    return LocalPlayer:WaitForChild("Data"):WaitForChild("Level").Value
end

local currentTween = nil
local function tweenTo(targetCFrame, speed, teleportType)
    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid or humanoid.Health <= 0 then return end
    if currentTween then currentTween:Cancel() end
    speed = speed or 150
    
    -- No-clip characters during farm tweens / island teleports
    if _G.NoClip or _G.AutoFarm or _G.AutoNearestFarm or _G.AutoMasteryFarm or _G.AutoBossFarm or _G.AutoMaterialFarm or _G.autoLawRaid or _G.Auto_Dungeon or _G.TeleportingToIsland or _G.AutoRaid or _G.TeleportingToBeliChest or _G.TeleportingToSpawnedFruit or _G.TeleportingToPlayer then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    if distance < 5 then
        rootPart.CFrame = targetCFrame
        return
    end
    local duration = distance / speed
    currentTween = TweenService:Create(rootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    currentTween:Play()
    
    local completed = false
    local connection
    connection = humanoid.Died:Connect(function()
        if currentTween then currentTween:Cancel() end
        completed = true
    end)
    
    local start = tick()
    while not completed and (tick() - start) < (duration + 0.5) do
        task.wait(0.05)
        -- Cancel teleport tween if toggle is turned off
        if teleportType then
            local shouldCancel = false
            if teleportType == "Island" and not _G.TeleportingToIsland then
                shouldCancel = true
            elseif teleportType == "BeliChest" and not _G.TeleportingToBeliChest then
                shouldCancel = true
            elseif teleportType == "SpawnedFruit" and not _G.TeleportingToSpawnedFruit then
                shouldCancel = true
            elseif teleportType == "Player" and not _G.TeleportingToPlayer then
                shouldCancel = true
            end
            
            if shouldCancel then
                if not _G.AutoFarm and not _G.AutoNearestFarm and not _G.AutoMasteryFarm and not _G.AutoBossFarm and not _G.AutoMaterialFarm and not _G.AutoRaid and not _G.AutoSeaBeast and not _G.AutoGhostShip then
                    if currentTween then currentTween:Cancel() end
                    break
                end
            end
        end
    end
    if connection then connection:Disconnect() end
end

local function teleportToIsland(islandName, targetCF)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local dest = portalRemoteMap[islandName]
    if dest then
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("PortalTeleport", dest)
        end)
        task.wait(0.25)
        if root and (root.Position - targetCF.Position).Magnitude < 150 then
            return
        end
    end
    
    -- Fallback to tween
    tweenTo(targetCF, nil, "Island")
end

local function equipWeapon(overrideWeapon)
    local weaponName = overrideWeapon or _G.WeaponSelect
    local weaponTypeMap = {
        ["Melee"] = "Melee",
        ["Sword"] = "Sword",
        ["Gun"] = "Gun",
        ["Demon Fruit"] = "Blox Fruit"
    }
    
    -- Check if correct weapon is already equipped
    local currentTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if currentTool then
        if currentTool.ToolTip == weaponTypeMap[weaponName] or currentTool.ToolTip == weaponName or currentTool.Name == weaponName then
            return
        end
        LocalPlayer.Character.Humanoid:UnequipTools()
    end
    
    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            if v.ToolTip == weaponTypeMap[weaponName] or v.ToolTip == weaponName or v.Name == weaponName then
                LocalPlayer.Character.Humanoid:EquipTool(v)
                break
            end
        end
    end
end

-- Universal Combat Attack / Aura Engine
local netFolder = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = netFolder:FindFirstChild("RE/RegisterAttack") or netFolder:WaitForChild("RE/RegisterAttack", 2)
local RegisterHit = netFolder:FindFirstChild("RE/RegisterHit") or netFolder:WaitForChild("RE/RegisterHit", 2)

local function performUniversalAura()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local activeTool = character and character:FindFirstChildOfClass("Tool")
    if not rootPart then return end
    
    local targetedList = {}
    local primaryLimb = nil
    
    -- Gather targets (mobs, target player, or sea events)
    if _G.AutoPvP and _G.TargetPlayer then
        local p = Players:FindFirstChild(_G.TargetPlayer)
        local c = p and p.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0 then
            local distance = (rootPart.Position - hrp.Position).Magnitude
            if distance <= 150 then -- Combat range
                table.insert(targetedList, c)
                primaryLimb = hrp
            end
        end
    else
        -- 1. Scan normal enemies
        for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
            if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                local distance = (rootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                if distance <= 65 then
                    table.insert(targetedList, enemy)
                    if not primaryLimb then
                        primaryLimb = enemy:FindFirstChild("LeftUpperArm") or enemy:FindFirstChild("RightUpperArm") or enemy:FindFirstChild("Torso") or enemy:FindFirstChild("UpperTorso") or enemy:FindFirstChild("Head") or enemy.HumanoidRootPart
                    end
                end
            end
        end
        
        -- 2. Scan Sea Beasts
        local sbFolder = Workspace:FindFirstChild("SeaBeasts")
        if sbFolder then
            for _, sb in ipairs(sbFolder:GetChildren()) do
                local sbHrp = sb:FindFirstChild("HumanoidRootPart")
                local sbHum = sb:FindFirstChild("Humanoid") or sb:FindFirstChild("Health")
                local sbHealthVal = sbHum and (sbHum:IsA("Humanoid") and sbHum.Health or sbHum:IsA("ValueBase") and sbHum.Value or 1)
                if sbHrp and sbHealthVal > 0 then
                    local distance = (rootPart.Position - sbHrp.Position).Magnitude
                    if distance <= 500 then
                        table.insert(targetedList, sb)
                        if not primaryLimb then
                            primaryLimb = sbHrp
                        end
                    end
                end
            end
        end
        
        -- 3. Scan Ghost Ships
        local boatsFolder = Workspace:FindFirstChild("Boats")
        if boatsFolder then
            for _, boat in ipairs(boatsFolder:GetChildren()) do
                if boat.Name == "PirateGrandBrigade" or boat.Name == "PirateBrigade" then
                    local engine = boat:FindFirstChild("Engine")
                    if engine then
                        local distance = (rootPart.Position - engine.Position).Magnitude
                        if distance <= 500 then
                            table.insert(targetedList, boat)
                            if not primaryLimb then
                                primaryLimb = engine
                            end
                        end
                    end
                end
            end
        end
    end
    
    if #targetedList > 0 then
        -- Path A: Kitsune / Fruit Transformation CFrame Magnet
        if activeTool == nil or string.find(string.lower(activeTool.Name), "kitsune") or string.find(string.lower(activeTool.Name), "fruit") or (activeTool and activeTool.ToolTip == "Blox Fruit") then
            for _, enemy in ipairs(targetedList) do
                pcall(function()
                    if enemy:FindFirstChild("HumanoidRootPart") and enemy.Name ~= "Sea Beast" and enemy.Name ~= "SeaBeast1" and not string.find(enemy.Name, "Brigade") then
                        enemy.HumanoidRootPart.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3)
                        enemy.Humanoid.PlatformStand = true
                    end
                end)
            end
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0, 0))
                if activeTool then activeTool:Activate() end
            end)
        -- Path B: Standard Melee / Weapons Packet Clustered Aura
        elseif RegisterAttack and RegisterHit and primaryLimb then
            pcall(function()
                RegisterAttack:FireServer(0.4)
                RegisterHit:FireServer(primaryLimb, targetedList)
            end)
        else
            -- Click fallback
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0, 0))
                if activeTool then activeTool:Activate() end
            end)
        end
    end
end

-- Mob Magnet/Bring Logic
local function bringMobs(monName)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, v in ipairs(Workspace.Enemies:GetChildren()) do
        if v.Name == monName and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local distance = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
            if distance <= 200 then
                v.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -15)
                v.Humanoid.PlatformStand = true
                v.HumanoidRootPart.CanCollide = false
            end
        end
    end
end

-- Active Quest Check Helper
local function getQuestProgress()
    local questGui = LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
    if not questGui or not questGui.Visible then return nil end
    for _, child in ipairs(questGui:GetDescendants()) do
        if child:IsA("TextLabel") and child.Name == "Title" then
            local count, name, current, max = string.match(child.Text, "Defeat (%d+) (.-) %((%d+)/(%d+)%)")
            if name and current and max then
                return {
                    MonsterName = name,
                    CurrentKills = tonumber(current),
                    MaxKills = tonumber(max)
                }
            end
        end
    end
    return nil
end

local function checkSeaForMaterial(material)
    if material == "Bones" or material == "Cocoa" or material == "Dragon Scale" then
        return World3, "Sea 3"
    elseif material == "Ectoplasm" or material == "Vampire Fang" or material == "Mystic Droplet" then
        return World2, "Sea 2"
    elseif material == "Fish Tail" then
        return World1, "Sea 1"
    end
    return true, ""
end

-- Comprehensive Auto Farm Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoFarm or _G.AutoNearestFarm or _G.AutoMasteryFarm or _G.AutoBossFarm or _G.AutoMaterialFarm then
            pcall(function()
                if _G.AutoFarm then
                    local currentSea = World1 and QuestData.Sea1 or World2 and QuestData.Sea2 or QuestData.Sea3
                    local level = getLevel()
                    local questInfo = nil
                    
                    for _, d in ipairs(currentSea) do
                        if level >= d.MinLevel and level <= d.MaxLevel then
                            questInfo = d
                            break
                        end
                    end
                    
                    if questInfo then
                        local progress = getQuestProgress()
                        if not progress then
                            -- Take Quest
                            local qCFrame = questInfo.QPos
                            local searchPattern = questInfo.Quest:gsub("Quest%d*", "")
                            local foundNPC = nil
                            for _, obj in ipairs(Workspace:GetChildren()) do
                                if obj:IsA("Model") and string.find(string.lower(obj.Name), string.lower(searchPattern)) and string.find(string.lower(obj.Name), "giver") then
                                    local hrp = obj:FindFirstChild("HumanoidRootPart")
                                    if hrp then foundNPC = hrp.CFrame break end
                                end
                            end
                            if not foundNPC then
                                for _, obj in ipairs(Workspace.NPCs:GetChildren()) do
                                    if obj:IsA("Model") and string.find(string.lower(obj.Name), string.lower(searchPattern)) and string.find(string.lower(obj.Name), "giver") then
                                        local hrp = obj:FindFirstChild("HumanoidRootPart")
                                        if hrp then foundNPC = hrp.CFrame break end
                                    end
                                end
                            end
                            if foundNPC then
                                qCFrame = foundNPC
                            end
                            
                            tweenTo(qCFrame)
                            if (LocalPlayer.Character.HumanoidRootPart.Position - qCFrame.Position).Magnitude < 15 then
                                task.wait(0.2)
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questInfo.Quest, questInfo.QuestLv)
                            end
                        else
                            -- Process Quest Mobs
                            local targetMob = questInfo.Mon
                            local mobFound = false
                            for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
                                if enemy.Name == targetMob and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                                    mobFound = true
                                    if _G.BringMob then bringMobs(targetMob) end
                                    
                                    local offset = CFrame.new(0, 7, 0)
                                    if _G.WeaponSelect == "Sword" then offset = CFrame.new(0, 5, 5) end
                                    
                                    tweenTo(enemy.HumanoidRootPart.CFrame * offset)
                                    equipWeapon()
                                    break
                                end
                            end
                            if not mobFound then
                                tweenTo(questInfo.MPos)
                            end
                        end
                    end
                elseif _G.AutoNearestFarm then
                    -- Farm nearest mob in workspace (limited to 3000 studs range)
                    local nearestMob = nil
                    local minDist = math.huge
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
                            if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                                local dist = (root.Position - enemy.HumanoidRootPart.Position).Magnitude
                                if dist < minDist and dist < 3000 then
                                    minDist = dist
                                    nearestMob = enemy
                                end
                            end
                        end
                        if nearestMob then
                            local offset = CFrame.new(0, 7, 0)
                            if _G.WeaponSelect == "Sword" then offset = CFrame.new(0, 5, 5) end
                            tweenTo(nearestMob.HumanoidRootPart.CFrame * offset)
                            equipWeapon()
                        end
                    end
                elseif _G.AutoMasteryFarm then
                    -- Select target island CFrame for Mastery Farm
                    local targetCF = nil
                    local currentSeaIslands = World1 and IslandCoords.Sea1 or World2 and IslandCoords.Sea2 or IslandCoords.Sea3
                    if _G.MasteryIslandSelect and _G.MasteryIslandSelect ~= "Current Location" then
                        targetCF = currentSeaIslands[_G.MasteryIslandSelect]
                    end
                    
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetCF and root then
                        local distanceToIsland = (root.Position - targetCF.Position).Magnitude
                        if distanceToIsland > 300 then
                            tweenTo(targetCF)
                            task.wait(0.5)
                        end
                    end
                    
                    -- Farm nearest mobs to player
                    local nearestMob = nil
                    local minDist = math.huge
                    root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
                            if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                                local dist = (root.Position - enemy.HumanoidRootPart.Position).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    nearestMob = enemy
                                end
                            end
                        end
                        if nearestMob then
                            local offset = CFrame.new(0, 7, 0)
                            if _G.MasterySelect == "Sword" then offset = CFrame.new(0, 5, 5) end
                            tweenTo(nearestMob.HumanoidRootPart.CFrame * offset)
                            equipWeapon(_G.MasterySelect)
                        else
                            -- Fallback to island center to wait for spawns
                            if targetCF then
                                tweenTo(targetCF)
                            end
                        end
                    end
                elseif _G.AutoBossFarm then
                    -- Farm selected or all bosses
                    local targetBoss = nil
                    for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
                        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            local isMatch = false
                            if _G.BossSelect == "All Bosses" then
                                if enemy.Name == "Cake Queen" or enemy.Name == "Captain Elephant" or enemy.Name == "Beautiful Pirate" or enemy.Name == "Tide Keeper" or enemy.Name == "Saber Expert" or enemy.Name == "Don Swan" then
                                    isMatch = true
                                end
                            elseif enemy.Name == _G.BossSelect then
                                isMatch = true
                            end
                            if isMatch then
                                targetBoss = enemy
                                break
                            end
                        end
                    end
                    if targetBoss then
                        tweenTo(targetBoss.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0))
                        equipWeapon()
                    else
                        local bossSpawns = {
                            ["Cake Queen"] = CFrame.new(-678.5, 381.9, -11114.3),
                            ["Captain Elephant"] = CFrame.new(-13365.5, 321.2, -8485.0),
                            ["Beautiful Pirate"] = CFrame.new(-12142.5, 331.6, -10419.9),
                            ["Tide Keeper"] = CFrame.new(-3352.0, 285.0, -10534.0),
                            ["Saber Expert"] = CFrame.new(-1404.0, 30.0, 3.0),
                            ["Don Swan"] = CFrame.new(-483.7, 332.0, 595.3)
                        }
                        local cf = bossSpawns[_G.BossSelect]
                        if cf then
                            tweenTo(cf)
                        end
                    end
                elseif _G.AutoMaterialFarm then
                    -- Check if player is in the correct sea for material farm
                    local isCorrectSea, seaName = checkSeaForMaterial(_G.MaterialSelect)
                    if not isCorrectSea then
                        Fluent:Notify({
                            Title = "Wrong Sea Required",
                            Content = "Please travel to " .. seaName .. " to farm " .. _G.MaterialSelect,
                            Duration = 5
                        })
                        _G.AutoMaterialFarm = false
                        pcall(function() Options.AutoMaterialFarmToggle:SetValue(false) end)
                        return
                    end
                    
                    local mobName = nil
                    local farmCFrame = nil
                    
                    if _G.MaterialSelect == "Bones" then
                        mobName = "Reborn Skeleton"
                        farmCFrame = CFrame.new(-8826.1, 141.0, 6165.9)
                    elseif _G.MaterialSelect == "Ectoplasm" then
                        mobName = "Ship Deckhand"
                        farmCFrame = CFrame.new(1212.0, 150.8, 33074.0)
                    elseif _G.MaterialSelect == "Cocoa" then
                        mobName = "Cocoa Warrior"
                        farmCFrame = CFrame.new(-21, 80, -12352)
                    elseif _G.MaterialSelect == "Fish Tail" then
                        mobName = "Fishman Warrior"
                        farmCFrame = CFrame.new(60878, 18, 1543)
                    elseif _G.MaterialSelect == "Vampire Fang" then
                        mobName = "Vampire"
                        farmCFrame = CFrame.new(-6037, 32, -1340)
                    elseif _G.MaterialSelect == "Mystic Droplet" then
                        mobName = "Water Fighter"
                        farmCFrame = CFrame.new(-3352, 285, -10534)
                    elseif _G.MaterialSelect == "Dragon Scale" then
                        mobName = "Dragon Crew Warrior"
                        farmCFrame = CFrame.new(6141, 51, -1340)
                    end
                    
                    if mobName and farmCFrame then
                        local mobFound = false
                        for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
                            if enemy.Name == mobName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                                mobFound = true
                                if _G.BringMob then bringMobs(mobName) end
                                local offset = CFrame.new(0, 7, 0)
                                if _G.WeaponSelect == "Sword" then offset = CFrame.new(0, 5, 5) end
                                tweenTo(enemy.HumanoidRootPart.CFrame * offset)
                                equipWeapon()
                                break
                            end
                        end
                        if not mobFound then
                            tweenTo(farmCFrame)
                        end
                    end
                end
            end)
        end
    end
end)

-- Continuous Fast Attack / Aura Loop
task.spawn(function()
    while true do
        task.wait(0.04)
        if (_G.AutoFarm and _G.FastAttack) or _G.AutoNearestFarm or _G.AutoMasteryFarm or _G.AutoBossFarm or _G.AutoMaterialFarm or _G.KillAura or _G.AutoPvP or _G.AutoRaid or _G.AutoSeaBeast or _G.AutoShark or _G.AutoPiranha or _G.AutoTerrorshark or _G.AutoGhostShip then
            pcall(performUniversalAura)
        end
    end
end)

-- Auto Haki Loop
task.spawn(function()
    while true do
        task.wait(3)
        if _G.AutoHaki then
            pcall(function()
                if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("HasBuso") then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
                end
            end)
        end
    end
end)

-- Anti-AFK Logic
task.spawn(function()
    while true do
        task.wait(15)
        if _G.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            end)
        end
    end
end)

-- No-Clip Loop
RunService.Stepped:Connect(function()
    if _G.NoClip or _G.AutoFarm or _G.AutoNearestFarm or _G.AutoMasteryFarm or _G.AutoBossFarm or _G.AutoMaterialFarm or _G.autoLawRaid or _G.Auto_Dungeon then
        pcall(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteJump then
        pcall(function()
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- Item Quests: Saber & Rengoku loops
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoSaber and getLevel() >= 200 then
            pcall(function()
                -- Check plates or summon bosses
                if Workspace.Map.Jungle.Final.Part.Transparency == 0 then
                    if Workspace.Map.Jungle.QuestPlates.Door.Transparency == 0 then
                        -- Steps to step on Jungle Plates
                        local plates = {"Plate1", "Plate2", "Plate3", "Plate4", "Plate5"}
                        for _, name in ipairs(plates) do
                            local button = Workspace.Map.Jungle.QuestPlates[name].Button
                            tweenTo(button.CFrame)
                            task.wait(0.5)
                        end
                    else
                        -- Obtain Relic / Unlock Saber Expert
                        if ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "SickMan") ~= 0 then
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "GetCup")
                            equipWeapon("Cup")
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "FillCup", LocalPlayer.Character:FindFirstChild("Cup"))
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "SickMan")
                        else
                            local richState = ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon")
                            if richState == 0 then
                                -- Kill Mob Leader
                                for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
                                    if enemy.Name == "Mob Leader" and enemy.Humanoid.Health > 0 then
                                        tweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0))
                                        equipWeapon()
                                        break
                                    end
                                end
                            elseif richState == 1 then
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon")
                                equipWeapon("Relic")
                                tweenTo(CFrame.new(-1404, 30, 3))
                            end
                        end
                    end
                else
                    -- Saber Expert Boss Kill
                    for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
                        if enemy.Name == "Saber Expert" and enemy.Humanoid.Health > 0 then
                            tweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0))
                            equipWeapon()
                            break
                        end
                    end
                end
            end)
        end
        
        if _G.AutoRengoku then
            pcall(function()
                if LocalPlayer.Backpack:FindFirstChild("Hidden Key") or LocalPlayer.Character:FindFirstChild("Hidden Key") then
                    equipWeapon("Hidden Key")
                    tweenTo(CFrame.new(6571, 299, -6967))
                else
                    -- Farm mobs to get Hidden Key
                    for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
                        if (enemy.Name == "Snow Lurker" or enemy.Name == "Arctic Warrior") and enemy.Humanoid.Health > 0 then
                            tweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0))
                            equipWeapon()
                            break
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto PvP Target Follow Loop
task.spawn(function()
    while true do
        task.wait()
        if _G.AutoPvP and _G.TargetPlayer then
            pcall(function()
                local p = Players:FindFirstChild(_G.TargetPlayer)
                local c = p and p.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                local hum = c and c:FindFirstChild("Humanoid")
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 and myRoot and myHum then
                    myHum.Sit = false
                    myRoot.CFrame = hrp.CFrame * CFrame.new(0, 5, 2)
                    equipWeapon()
                end
            end)
        end
    end
end)

-- Loop Tween to Player (Every 1s)
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoTweenToPlayer and _G.TargetPlayer then
            pcall(function()
                local p = Players:FindFirstChild(_G.TargetPlayer)
                local c = p and p.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    tweenTo(hrp.CFrame, nil, "Player")
                end
            end)
        end
    end
end)

-- Boat Sailing & Auto Drive Engine
local DangerLevelCoords = {
    ["Level 1"] = CFrame.new(-20500, 10, 438),
    ["Level 2"] = CFrame.new(-23500, 10, 438),
    ["Level 3"] = CFrame.new(-26500, 10, 438),
    ["Level 4"] = CFrame.new(-29500, 10, 438),
    ["Level 5"] = CFrame.new(-32500, 10, 438),
    ["Level 6"] = CFrame.new(-35500, 10, 438),
    ["Level 6+"] = CFrame.new(-39000, 10, 438)
}

local function getMyBoat()
    local boatsFolder = Workspace:FindFirstChild("Boats")
    if boatsFolder then
        for _, boat in ipairs(boatsFolder:GetChildren()) do
            local owner = boat:GetAttribute("Owner") or boat:FindFirstChild("Owner")
            if (owner and tostring(owner) == LocalPlayer.Name) or string.find(boat.Name, LocalPlayer.Name) then
                return boat
            end
        end
        for _, boat in ipairs(boatsFolder:GetChildren()) do
            local seat = boat:FindFirstChildOfClass("VehicleSeat")
            if seat and seat.Occupant == (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")) then
                return boat
            end
        end
        for _, boat in ipairs(boatsFolder:GetChildren()) do
            local seat = boat:FindFirstChildOfClass("VehicleSeat")
            if seat and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if (seat.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 80 then
                    return boat
                end
            end
        end
    end
    return nil
end

local function setBoatAnchored(boat, state)
    if boat and boat.Parent then
        pcall(function()
            for _, part in ipairs(boat:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = state
                    if state then
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                        pcall(function() part.Velocity = Vector3.zero end)
                        pcall(function() part.RotVelocity = Vector3.zero end)
                    end
                end
            end
        end)
    end
end

local boatTween = nil
local currentBoatTarget = nil
local function tweenBoat(boat, seat, targetCFrame, speed)
    speed = speed or 200
    if currentBoatTarget and (currentBoatTarget.Position - targetCFrame.Position).Magnitude < 5 then
        return boatTween
    end
    if boatTween then boatTween:Cancel() end
    
    setBoatAnchored(boat, true)
    currentBoatTarget = targetCFrame
    local distance = (seat.Position - targetCFrame.Position).Magnitude
    local duration = distance / speed
    boatTween = TweenService:Create(seat, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    boatTween:Play()
    return boatTween
end

task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoDriveBoat then
            pcall(function()
                local targetEnemy = nil
                
                -- Check Sea Beasts
                if _G.AutoSeaBeast then
                    local sbFolder = Workspace:FindFirstChild("SeaBeasts")
                    if sbFolder then
                        for _, v in ipairs(sbFolder:GetChildren()) do
                            if v:FindFirstChild("HumanoidRootPart") and (v:FindFirstChild("Health") and v.Health.Value > 0 or v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0) then
                                targetEnemy = v
                                break
                            end
                        end
                    end
                end
                
                -- Check Ghost Ships
                if not targetEnemy and _G.AutoGhostShip then
                    local boatsFolder = Workspace:FindFirstChild("Boats")
                    if boatsFolder then
                        for _, v in ipairs(boatsFolder:GetChildren()) do
                            if (v.Name == "PirateGrandBrigade" or v.Name == "PirateBrigade") and v:FindFirstChild("Engine") then
                                local hum = v:FindFirstChild("Humanoid") or v:FindFirstChild("Health")
                                if not hum or (hum:IsA("Humanoid") and hum.Health > 0) or (hum:IsA("ValueBase") and hum.Value > 0) then
                                    targetEnemy = v
                                    break
                                end
                            end
                        end
                    end
                end
                
                -- Check other enemies
                if not targetEnemy then
                    for _, v in ipairs(Workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            if (_G.AutoShark and v.Name == "Shark") or
                               (_G.AutoPiranha and v.Name == "Piranha") or
                               (_G.AutoTerrorshark and v.Name == "Terrorshark") then
                                  targetEnemy = v
                                  break
                            end
                        end
                    end
                end
                
                if targetEnemy then
                    if boatTween then boatTween:Cancel() boatTween = nil end
                    currentBoatTarget = nil
                    local myBoat = getMyBoat()
                    if myBoat then setBoatAnchored(myBoat, false) end
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.Sit = false
                    end
                else
                    local myBoat = getMyBoat()
                    if not myBoat then
                        if boatTween then boatTween:Cancel() boatTween = nil end
                        currentBoatTarget = nil
                        local buyCF = CFrame.new(-16927.45, 9.08, 433.86)
                        tweenTo(buyCF)
                        if (LocalPlayer.Character.HumanoidRootPart.Position - buyCF.Position).Magnitude < 15 then
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBoat", _G.SelectedBoat or "PirateBrigade")
                            task.wait(1)
                        end
                    else
                        local seat = myBoat:FindFirstChildOfClass("VehicleSeat")
                        if seat then
                            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Sit == false then
                                if boatTween then boatTween:Cancel() boatTween = nil end
                                currentBoatTarget = nil
                                LocalPlayer.Character.HumanoidRootPart.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
                                task.wait(0.5)
                            else
                                local targetCF = DangerLevelCoords[_G.SelectedDangerLevel or "Level 6"]
                                if targetCF then
                                    local dist = (seat.Position - targetCF.Position).Magnitude
                                    if dist > 50 then
                                        tweenBoat(myBoat, seat, targetCF)
                                    else
                                        if boatTween then boatTween:Cancel() boatTween = nil end
                                        currentBoatTarget = nil
                                        setBoatAnchored(myBoat, false)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            if boatTween then boatTween:Cancel() boatTween = nil end
            currentBoatTarget = nil
            local myBoat = getMyBoat()
            if myBoat then setBoatAnchored(myBoat, false) end
        end
    end
end)

-- Sea Events Loop
local function handleSeaEventPlatform(targetCF)
    local platform = Workspace:FindFirstChild("SeaEventPlatform")
    if not platform then
        platform = Instance.new("Part")
        platform.Name = "SeaEventPlatform"
        platform.Size = Vector3.new(40, 2, 40)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 1
        platform.Parent = Workspace
    end
    platform.CFrame = targetCF * CFrame.new(0, -4, 0)
end

local function removeSeaEventPlatform()
    local platform = Workspace:FindFirstChild("SeaEventPlatform")
    if platform then
        platform:Destroy()
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoSeaBeast or _G.AutoShark or _G.AutoPiranha or _G.AutoTerrorshark or _G.AutoGhostShip then
            pcall(function()
                local targetEnemy = nil
                
                -- Scan Sea Beasts
                if _G.AutoSeaBeast then
                    local sbFolder = Workspace:FindFirstChild("SeaBeasts")
                    if sbFolder then
                        for _, v in ipairs(sbFolder:GetChildren()) do
                            if v:FindFirstChild("HumanoidRootPart") and (v:FindFirstChild("Health") and v.Health.Value > 0 or v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0) then
                                targetEnemy = v
                                break
                            end
                        end
                    end
                end
                
                -- Scan Ghost Ships
                if not targetEnemy and _G.AutoGhostShip then
                    local boatsFolder = Workspace:FindFirstChild("Boats")
                    if boatsFolder then
                        for _, v in ipairs(boatsFolder:GetChildren()) do
                            if (v.Name == "PirateGrandBrigade" or v.Name == "PirateBrigade") and v:FindFirstChild("Engine") then
                                local hum = v:FindFirstChild("Humanoid") or v:FindFirstChild("Health")
                                if not hum or (hum:IsA("Humanoid") and hum.Health > 0) or (hum:IsA("ValueBase") and hum.Value > 0) then
                                    targetEnemy = v
                                    break
                                end
                            end
                        end
                    end
                    if not targetEnemy then
                        for _, v in ipairs(Workspace.Enemies:GetChildren()) do
                            if (v.Name == "PirateGrandBrigade" or v.Name == "PirateBrigade") and v:FindFirstChild("Engine") then
                                targetEnemy = v
                                break
                            end
                        end
                    end
                end
                
                -- Scan other enemies (Shark, Terrorshark, Piranha, Sea Beast in Enemies)
                if not targetEnemy then
                    for _, v in ipairs(Workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            if (_G.AutoShark and v.Name == "Shark") or
                               (_G.AutoPiranha and v.Name == "Piranha") or
                               (_G.AutoTerrorshark and v.Name == "Terrorshark") or
                               (_G.AutoSeaBeast and v.Name == "Sea Beast") then
                                  targetEnemy = v
                                  break
                            end
                        end
                    end
                end
                
                if not targetEnemy then
                    for _, v in ipairs(Workspace:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            if (_G.AutoShark and v.Name == "Shark") or
                               (_G.AutoPiranha and v.Name == "Piranha") or
                               (_G.AutoTerrorshark and v.Name == "Terrorshark") or
                               (_G.AutoSeaBeast and v.Name == "Sea Beast") then
                                  targetEnemy = v
                                  break
                            end
                        end
                    end
                end
                
                if targetEnemy then
                    local part = targetEnemy:FindFirstChild("HumanoidRootPart") or targetEnemy:FindFirstChild("Engine") or targetEnemy:FindFirstChild("VehicleSeat")
                    if part then
                        local targetPos = part.CFrame * CFrame.new(0, 50, 0)
                        tweenTo(targetPos)
                        handleSeaEventPlatform(targetPos)
                        equipWeapon()
                    end
                else
                    removeSeaEventPlatform()
                end
            end)
        else
            removeSeaEventPlatform()
        end
    end
end)

-- Dungeon / Raid Loop
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoRaid then
            pcall(function()
                local inRaid = false
                local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
                local timer = mainGui and (mainGui:FindFirstChild("Timer") or (mainGui:FindFirstChild("TopHUDList") and mainGui.TopHUDList:FindFirstChild("RaidTimer")))
                if (timer and timer.Visible) or Workspace["_WorldOrigin"].Locations:FindFirstChild("Island 1") then
                    inRaid = true
                end
                
                if inRaid then
                    local currentIsland = nil
                    for i = 5, 1, -1 do
                        local loc = Workspace["_WorldOrigin"].Locations:FindFirstChild("Island " .. i)
                        if loc then
                            currentIsland = loc
                            break
                        end
                    end
                    
                    local mobFound = false
                    for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
                        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                            if currentIsland and (enemy.HumanoidRootPart.Position - currentIsland.Position).Magnitude < 3000 then
                                mobFound = true
                                tweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0))
                                equipWeapon()
                                break
                            end
                        end
                    end
                    
                    if not mobFound and currentIsland then
                        tweenTo(currentIsland.CFrame * CFrame.new(0, 50, 0))
                    end
                    
                    -- Auto Awaken
                    if _G.AutoAwaken then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("Awakener", "Check")
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("Awakener", "Awaken")
                    end
                end
            end)
        end
    end
end)


-- Devil Fruit Farm & Store
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoFarmFruit then
            pcall(function()
                for _, v in ipairs(Workspace:GetChildren()) do
                    if string.find(v.Name, "Fruit") and v:IsA("Tool") and v:FindFirstChild("Handle") then
                        tweenTo(v.Handle.CFrame)
                        task.wait(0.5)
                    end
                end
            end)
        end
        if _G.AutoStoreFruit then
            pcall(function()
                for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if v:IsA("Tool") and string.find(v.Name, "Fruit") then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", v:GetAttribute("OriginalName") or v.Name, v)
                    end
                end
                for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
                    if v:IsA("Tool") and string.find(v.Name, "Fruit") then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", v:GetAttribute("OriginalName") or v.Name, v)
                    end
                end
            end)
        end
    end
end)

-- Stats Loop
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoStats then
            pcall(function()
                local statTypeMap = {
                    ["Melee"] = "Melee",
                    ["Defense"] = "Defense",
                    ["Sword"] = "Sword",
                    ["Gun"] = "Gun",
                    ["Demon Fruit"] = "Demon Fruit"
                }
                ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", statTypeMap[_G.StatType], 1)
            end)
        end
    end
end)

-- ESP drawing loop
-- ESP drawing logic
local ActiveESPs = {}
local chestsCache = {}
local lastChestScan = 0

local function getChests()
    if tick() - lastChestScan > 5 then
        chestsCache = {}
        pcall(function()
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and string.find(v.Name, "Chest") then
                    table.insert(chestsCache, v)
                end
            end
        end)
        lastChestScan = tick()
    end
    return chestsCache
end

local function applyESP(parent, text, color, key)
    local bill = parent:FindFirstChild("AntigravityESP")
    if not bill then
        bill = Instance.new("BillboardGui")
        bill.Name = "AntigravityESP"
        bill.Size = UDim2.new(1, 200, 1, 30)
        bill.AlwaysOnTop = true
        bill.Adornee = parent
        
        local label = Instance.new("TextLabel", bill)
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.TextStrokeTransparency = 0.5
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextColor3 = color
        
        bill.Parent = parent
        ActiveESPs[key] = bill
    end
    
    local label = bill:FindFirstChildOfClass("TextLabel")
    if label then
        label.Text = text
        label.TextColor3 = color
    end
end

local function removeESP(key)
    local bill = ActiveESPs[key]
    if bill then
        pcall(function() bill:Destroy() end)
        ActiveESPs[key] = nil
    end
end

local function clearAllESP()
    for key, bill in pairs(ActiveESPs) do
        pcall(function() bill:Destroy() end)
    end
    ActiveESPs = {}
end

task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            local myCharacter = LocalPlayer.Character
            local myHead = myCharacter and myCharacter:FindFirstChild("Head")
            if not myHead then return end
            
            local currentTargets = {}
            
            -- Player ESP
            if _G.ESPPlayer then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
                        local head = p.Character.Head
                        local hum = p.Character.Humanoid
                        if hum.Health > 0 then
                            local dist = math.floor((myHead.Position - head.Position).Magnitude)
                            local text = string.format("%s\n[%d studs] hp: %d%%", p.Name, dist, math.floor(hum.Health * 100 / hum.MaxHealth))
                            local color = (p.Team == LocalPlayer.Team) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                            currentTargets[head] = {text = text, color = color}
                        end
                    end
                end
            end
            
            -- Chest ESP
            if _G.ESPChest then
                local chests = getChests()
                for _, v in ipairs(chests) do
                    if v.Parent and v:IsA("BasePart") then
                        local dist = math.floor((myHead.Position - v.Position).Magnitude)
                        local text = string.format("%s [%d studs]", v.Name, dist)
                        local color = Color3.fromRGB(255, 215, 0)
                        currentTargets[v] = {text = text, color = color}
                    end
                end
            end
            
            -- Fruit ESP
            if _G.ESPFruit then
                for _, v in ipairs(Workspace:GetChildren()) do
                    if string.find(v.Name, "Fruit") and v:IsA("Tool") and v:FindFirstChild("Handle") then
                        local handle = v.Handle
                        local dist = math.floor((myHead.Position - handle.Position).Magnitude)
                        local text = string.format("%s [%d studs]", v.Name, dist)
                        local color = Color3.fromRGB(255, 105, 180)
                        currentTargets[handle] = {text = text, color = color}
                    end
                end
            end
            
            -- Flower ESP
            if _G.ESPFlower then
                for _, v in ipairs(Workspace:GetChildren()) do
                    if (v.Name == "Flower1" or v.Name == "Flower2") and v:IsA("BasePart") then
                        local dist = math.floor((myHead.Position - v.Position).Magnitude)
                        local text = string.format("%s [%d studs]", v.Name, dist)
                        local color = (v.Name == "Flower1") and Color3.new(0, 0, 1) or Color3.new(1, 0, 0)
                        currentTargets[v] = {text = text, color = color}
                    end
                end
            end
            
            -- Mob ESP
            if _G.ESPMob then
                for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("Head") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        local head = enemy.Head
                        local dist = math.floor((myHead.Position - head.Position).Magnitude)
                        local text = string.format("%s [Lvl %d] [%d studs]", enemy.Name, enemy.Humanoid:GetAttribute("Level") or 0, dist)
                        local color = Color3.fromRGB(220, 220, 220)
                        currentTargets[head] = {text = text, color = color}
                    end
                end
            end
            
            -- Island ESP
            if _G.ESPIsland then
                local locs = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
                if locs then
                    for _, v in ipairs(locs:GetChildren()) do
                        if v.Name ~= "Sea" and v:IsA("BasePart") then
                            local dist = math.floor((myHead.Position - v.Position).Magnitude)
                            local text = string.format("%s [%d studs]", v.Name, dist)
                            local color = Color3.fromRGB(0, 255, 255)
                            currentTargets[v] = {text = text, color = color}
                        end
                    end
                end
            end
            
            -- Apply and update current targets
            for target, info in pairs(currentTargets) do
                applyESP(target, info.text, info.color, target)
            end
            
            -- Clean up targets that are no longer active or toggled off
            for target, bill in pairs(ActiveESPs) do
                if not currentTargets[target] or not target.Parent then
                    removeESP(target)
                end
            end
        end)
    end
end)

-- Aimbot Loop
task.spawn(function()
    while true do
        task.wait()
        if _G.Aimbot and _G.TargetPlayer then
            pcall(function()
                local p = Players:FindFirstChild(_G.TargetPlayer)
                local c = p and p.Character
                local head = c and c:FindFirstChild("Head")
                if head then
                    Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, head.Position)
                end
            end)
        end
    end
end)


-- ==================== CONFIG & UTILITY FUNCTIONS ====================
local CONFIG_FOLDER = "BloxFruitsHubConfigs"

local function ensureFolder()
    if makefolder then
        pcall(function() makefolder(CONFIG_FOLDER) end)
    end
end

local function getConfigsList()
    local list = {}
    if listfiles then
        pcall(function()
            for _, file in ipairs(listfiles(CONFIG_FOLDER)) do
                local name = file:match("([^/\\]+)$")
                if name and name:match("%.json$") then
                    table.insert(list, name:gsub("%.json$", ""))
                end
            end
        end)
    end
    if #list == 0 then
        list = {"default"}
    end
    return list
end

local function saveConfig(name)
    ensureFolder()
    local configData = {}
    for k, v in pairs(_G) do
        if type(v) == "string" or type(v) == "boolean" or type(v) == "number" then
            if k:find("^Auto") or k:find("Select$") or k:find("Toggle$") or k == "WeaponSelect" or k == "FarmMode" or k == "BossSelect" or k == "SelectedDangerLevel" or k == "SelectedBoat" or k == "Disable3D" or k == "StatType" or k == "SafeFarm" or k == "AntiAFK" or k == "NoClip" or k == "InfiniteJump" then
                configData[k] = v
            end
        end
    end
    
    local success, json = pcall(function() return HttpService:JSONEncode(configData) end)
    if success and json then
        local filePath = CONFIG_FOLDER .. "/" .. name .. ".json"
        pcall(function() writefile(filePath, json) end)
        Fluent:Notify({Title = "Config Saved", Content = "Successfully saved " .. name, Duration = 3})
    else
        Fluent:Notify({Title = "Error", Content = "Failed to encode config to JSON", Duration = 3})
    end
end

local function loadConfig(name)
    ensureFolder()
    local filePath = CONFIG_FOLDER .. "/" .. name .. ".json"
    if isfile and isfile(filePath) then
        local data = readfile(filePath)
        local success, configData = pcall(function() return HttpService:JSONDecode(data) end)
        if success and type(configData) == "table" then
            for k, v in pairs(configData) do
                _G[k] = v
                local option = Options[k]
                if option then
                    pcall(function() option:SetValue(v) end)
                end
            end
            Fluent:Notify({Title = "Config Loaded", Content = "Successfully loaded " .. name, Duration = 3})
            return true
        end
    end
    Fluent:Notify({Title = "Error", Content = "Config file not found or invalid", Duration = 3})
    return false
end

local function disableOtherFarms(except)
    if except ~= "Level" then
        _G.AutoFarm = false
        pcall(function() Options.AutoFarmLevel:SetValue(false) end)
    end
    if except ~= "Nearest" then
        _G.AutoNearestFarm = false
        pcall(function() Options.AutoNearestFarmToggle:SetValue(false) end)
    end
    if except ~= "Mastery" then
        _G.AutoMasteryFarm = false
        pcall(function() Options.AutoMasteryFarmToggle:SetValue(false) end)
    end
    if except ~= "Material" then
        _G.AutoMaterialFarm = false
        pcall(function() Options.AutoMaterialFarmToggle:SetValue(false) end)
    end
    if except ~= "Boss" then
        _G.AutoBossFarm = false
        pcall(function() Options.AutoBossFarmToggle:SetValue(false) end)
    end
end

-- ==================== FLUENT UI SETUP ====================

-- Tab 1: Main Farm
local BasicSection = Tabs.Main:AddSection("Basic Level Farm")
local AutoFarmToggle = Tabs.Main:AddToggle("AutoFarmLevel", {Title = "Auto Farm (Start)", Default = false})
AutoFarmToggle:OnChanged(function(v)
    _G.AutoFarm = v
    if v then disableOtherFarms("Level") end
end)

local NearestFarmToggle = Tabs.Main:AddToggle("AutoNearestFarmToggle", {Title = "Start Nearest Farm", Default = false})
NearestFarmToggle:OnChanged(function(v)
    _G.AutoNearestFarm = v
    if v then disableOtherFarms("Nearest") end
end)

Tabs.Main:AddToggle("AutoQuest", {Title = "Auto Quest", Default = true}):OnChanged(function(v) _G.AutoQuest = v end)
Tabs.Main:AddToggle("BringMob", {Title = "Bring Mobs", Default = true}):OnChanged(function(v) _G.BringMob = v end)
Tabs.Main:AddToggle("FastAttack", {Title = "Fast Attack", Default = true}):OnChanged(function(v) _G.FastAttack = v end)
Tabs.Main:AddToggle("AutoHaki", {Title = "Auto Haki (Buso)", Default = false}):OnChanged(function(v) _G.AutoHaki = v end)

Tabs.Main:AddDropdown("WeaponSelect", {
    Title = "Weapon Select",
    Values = {"Melee", "Sword", "Gun", "Demon Fruit"},
    Default = "Melee",
    Callback = function(v) _G.WeaponSelect = v end
})

-- Section 2: Mastery Farm
local MasterySection = Tabs.Main:AddSection("Mastery Farm Options")
local MasteryToggle = Tabs.Main:AddToggle("AutoMasteryFarmToggle", {Title = "Start Mastery Farm", Default = false})
MasteryToggle:OnChanged(function(v)
    _G.AutoMasteryFarm = v
    if v then disableOtherFarms("Mastery") end
end)

Tabs.Main:AddDropdown("MasterySelect", {
    Title = "Mastery Weapon Select",
    Values = {"Melee", "Sword", "Gun", "Demon Fruit"},
    Default = "Melee",
    Callback = function(v) _G.MasterySelect = v end
})

-- Select target island for Mastery Farm dropdown
local currentSeaIslandsForMastery = World1 and IslandCoords.Sea1 or World2 and IslandCoords.Sea2 or IslandCoords.Sea3
local masteryIslandList = {"Current Location"}
for name, _ in pairs(currentSeaIslandsForMastery) do
    table.insert(masteryIslandList, name)
end

Tabs.Main:AddDropdown("MasteryIslandSelect", {
    Title = "Mastery Island Select",
    Values = masteryIslandList,
    Default = "Current Location",
    Callback = function(v) _G.MasteryIslandSelect = v end
})

-- Section 3: Material Farm
local MaterialSection = Tabs.Main:AddSection("Material Farm Options")
local MaterialToggle = Tabs.Main:AddToggle("AutoMaterialFarmToggle", {Title = "Start Material Farm", Default = false})
MaterialToggle:OnChanged(function(v)
    _G.AutoMaterialFarm = v
    if v then disableOtherFarms("Material") end
end)

Tabs.Main:AddDropdown("MaterialSelect", {
    Title = "Material Select",
    Values = {"Bones", "Ectoplasm", "Cocoa", "Fish Tail", "Vampire Fang", "Mystic Droplet", "Dragon Scale"},
    Default = "Bones",
    Callback = function(v) _G.MaterialSelect = v end
})

-- Section 4: Boss Farm
local BossSection = Tabs.Main:AddSection("Boss Farm Options")
local BossToggle = Tabs.Main:AddToggle("AutoBossFarmToggle", {Title = "Start Boss Farm", Default = false})
BossToggle:OnChanged(function(v)
    _G.AutoBossFarm = v
    if v then disableOtherFarms("Boss") end
end)

Tabs.Main:AddDropdown("BossSelect", {
    Title = "Boss Select",
    Values = {"All Bosses", "Cake Queen", "Captain Elephant", "Beautiful Pirate", "Tide Keeper", "Saber Expert", "Don Swan"},
    Default = "All Bosses",
    Callback = function(v) _G.BossSelect = v end
})


-- Tab 2: Combat / PVP
local playerNames = {}
local function refreshPlayerList()
    playerNames = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(playerNames, p.Name)
        end
    end
end
refreshPlayerList()

local pListDropdown = Tabs.Combat:AddDropdown("SelectPlayer", {
    Title = "Select Target Player",
    Values = playerNames,
    Default = playerNames[1] or "",
    Callback = function(v) _G.TargetPlayer = v end
})

Tabs.Combat:AddButton({
    Title = "Refresh Player List",
    Callback = function()
        refreshPlayerList()
        pListDropdown:SetValues(playerNames)
    end
})

local TweenPlayerToggle = Tabs.Combat:AddToggle("TweenPlayerToggle", {Title = "Tween to Player (Cancelable)", Default = false})
TweenPlayerToggle:OnChanged(function(v)
    _G.TeleportingToPlayer = v
    if v then
        task.spawn(function()
            if _G.TargetPlayer then
                local p = Players:FindFirstChild(_G.TargetPlayer)
                local c = p and p.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    tweenTo(hrp.CFrame, nil, "Player")
                else
                    Fluent:Notify({Title = "Error", Content = "Player character not found", Duration = 3})
                end
            else
                Fluent:Notify({Title = "Error", Content = "Please select a target player first", Duration = 3})
            end
            _G.TeleportingToPlayer = false
            TweenPlayerToggle:SetValue(false)
        end)
    end
end)

Tabs.Combat:AddToggle("LoopTweenPlayerToggle", {Title = "Loop Tween to Player (Every 1s)", Default = false}):OnChanged(function(v)
    _G.AutoTweenToPlayer = v
end)

Tabs.Combat:AddToggle("AutoPvP", {Title = "Auto PVP (Target)", Default = false}):OnChanged(function(v) _G.AutoPvP = v end)
Tabs.Combat:AddToggle("Aimbot", {Title = "Aimbot Target Head", Default = false}):OnChanged(function(v) _G.Aimbot = v end)
Tabs.Combat:AddToggle("KillAura", {Title = "Universal Kill Aura (AoE)", Default = false}):OnChanged(function(v) _G.KillAura = v end)

-- Tab 3: Item Quests
Tabs.Quest:AddToggle("AutoSaber", {Title = "Auto Saber Quest", Default = false}):OnChanged(function(v) _G.AutoSaber = v end)
Tabs.Quest:AddToggle("AutoRengoku", {Title = "Auto Rengoku Quest", Default = false}):OnChanged(function(v) _G.AutoRengoku = v end)

local quests = {
    "Saber", "Pole (V1)", "Bisento", "Saddi", "Wando", "Shisui", 
    "Rengoku", "Dark Coat", "Swan Glasses", "Pale Scarf", 
    "Dark Dagger", "Dragon Trident", "Soul Cane"
}
for _, quest in ipairs(quests) do
    if quest ~= "Saber" and quest ~= "Rengoku" then
        Tabs.Quest:AddButton({
            Title = "Get " .. quest,
            Callback = function()
                Fluent:Notify({Title = "Quest", Content = "Started process for " .. quest, Duration = 3})
                if quest == "Saddi" or quest == "Wando" or quest == "Shisui" then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "1")
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "2")
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "3")
                elseif quest == "Swan Glasses" then
                    -- Don Swan
                    Fluent:Notify({Title = "Info", Content = "Farming Don Swan...", Duration = 3})
                end
            end
        })
    end
end

-- Tab 4: Sea Events
Tabs.SeaEvent:AddToggle("AutoSeaBeast", {Title = "Auto Sea Beast", Default = false}):OnChanged(function(v) _G.AutoSeaBeast = v end)
Tabs.SeaEvent:AddToggle("AutoShark", {Title = "Auto Shark", Default = false}):OnChanged(function(v) _G.AutoShark = v end)
Tabs.SeaEvent:AddToggle("AutoPiranha", {Title = "Auto Piranha", Default = false}):OnChanged(function(v) _G.AutoPiranha = v end)
Tabs.SeaEvent:AddToggle("AutoTerrorshark", {Title = "Auto Terrorshark", Default = false}):OnChanged(function(v) _G.AutoTerrorshark = v end)
Tabs.SeaEvent:AddToggle("AutoGhostShip", {Title = "Auto Ghost Ship", Default = false}):OnChanged(function(v) _G.AutoGhostShip = v end)

local SailingSec = Tabs.SeaEvent:AddSection("Sailing & Danger Zone Farm")

Tabs.SeaEvent:AddToggle("AutoDriveBoat", {Title = "Auto Drive Boat", Default = false}):OnChanged(function(v) _G.AutoDriveBoat = v end)

Tabs.SeaEvent:AddDropdown("DangerLevelSelect", {
    Title = "Sailing Danger Level",
    Values = {"Level 1", "Level 2", "Level 3", "Level 4", "Level 5", "Level 6", "Level 6+"},
    Default = "Level 6",
    Callback = function(v) _G.SelectedDangerLevel = v end
})

Tabs.SeaEvent:AddDropdown("BoatSelect", {
    Title = "Select Boat to Purchase",
    Values = {"Dinghy", "Sloop", "Galleon", "PirateGrandBrigade", "PirateBrigade", "LuxuryBoat", "Enforcer", "SwampBoat", "CyborgBoat"},
    Default = "PirateBrigade",
    Callback = function(v) _G.SelectedBoat = v end
})

Tabs.SeaEvent:AddButton({
    Title = "Buy Selected Boat manually",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBoat", _G.SelectedBoat or "PirateBrigade")
    end
})

-- Tab 5: Dungeon / Raid
local RaidSection = Tabs.Raid:AddSection("Dungeon / Raid Options")

local function startRaidDetector()
    local found = false
    pcall(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ClickDetector") and (v.Parent.Name == "Button" or v.Parent.Name == "Main" or v.Parent.Name == "RaidSummon" or v.Parent.Name == "RaidSummon2" or v.Parent:FindFirstAncestor("RaidSummon") or v.Parent:FindFirstAncestor("RaidSummon2")) then
                fireclickdetector(v)
                found = true
            end
        end
    end)
    if not found then
        pcall(function()
            if World2 then
                fireclickdetector(Workspace.Map.CircleIsland.RaidSummon2.Button.Main.ClickDetector)
            elseif World3 then
                fireclickdetector(Workspace.Map["Boat Castle"].RaidSummon2.Button.Main.ClickDetector)
            end
        end)
    end
end

Tabs.Raid:AddToggle("AutoRaid", {Title = "Auto Next Island & Mobs", Default = false}):OnChanged(function(v) _G.AutoRaid = v end)
Tabs.Raid:AddToggle("AutoAwaken", {Title = "Auto Awaken Fruit", Default = false}):OnChanged(function(v) _G.AutoAwaken = v end)
Tabs.Raid:AddDropdown("SelectRaid", {
    Title = "Select Raid Type",
    Values = {"Flame", "Ice", "Quake", "Light", "Dark", "String", "Rumble", "Magma", "Human: Buddha", "Sand", "Bird: Phoenix"},
    Default = "Flame",
    Callback = function(v) _G.RaidType = v end
})
Tabs.Raid:AddButton({
    Title = "Buy Special Microchip",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc", "Select", _G.RaidType)
    end
})
Tabs.Raid:AddButton({
    Title = "Start Selected Raid",
    Callback = function()
        startRaidDetector()
    end
})

-- Tab 6: Devil Fruit
Tabs.Fruit:AddToggle("AutoFarmFruit", {Title = "Auto Grab Spawned Fruits", Default = false}):OnChanged(function(v) _G.AutoFarmFruit = v end)
Tabs.Fruit:AddToggle("AutoStoreFruit", {Title = "Auto Store Fruits in Backpack", Default = false}):OnChanged(function(v) _G.AutoStoreFruit = v end)
local SpawnedFruitToggle = Tabs.Fruit:AddToggle("SpawnedFruitToggle", {Title = "Teleport to Spawned Fruit (Cancelable)", Default = false})
SpawnedFruitToggle:OnChanged(function(v)
    _G.TeleportingToSpawnedFruit = v
    if v then
        task.spawn(function()
            local foundFruit = nil
            for _, obj in ipairs(Workspace:GetChildren()) do
                if string.find(obj.Name, "Fruit") and obj:IsA("Tool") and obj:FindFirstChild("Handle") then
                    foundFruit = obj.Handle.CFrame
                    break
                end
            end
            if foundFruit then
                tweenTo(foundFruit, nil, "SpawnedFruit")
            else
                Fluent:Notify({Title = "Not Found", Content = "No spawned fruits found in workspace", Duration = 3})
            end
            _G.TeleportingToSpawnedFruit = false
            SpawnedFruitToggle:SetValue(false)
        end)
    end
end)

Tabs.Fruit:AddButton({
    Title = "Random Fruit Gacha (Surprise)",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
    end
})

Tabs.Fruit:AddToggle("AutoSpinGachaToggle", {
    Title = "Auto Spin Gacha (Every 2h)",
    Default = false
}):OnChanged(function(v)
    _G.AutoSpinGacha = v
end)

Tabs.Fruit:AddButton({
    Title = "Open Fruit Dealer Stock",
    Callback = function()
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("GetFruits")
            LocalPlayer.PlayerGui.Main.FruitShop.Visible = true
        end)
    end
})

task.spawn(function()
    while true do
        task.wait(10)
        if _G.AutoSpinGacha then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
            end)
        end
    end
end)

-- Tab 7: Visuals / ESP
Tabs.ESP:AddToggle("ESPPlayer", {Title = "ESP Player", Default = false}):OnChanged(function(v) _G.ESPPlayer = v end)
Tabs.ESP:AddToggle("ESPChest", {Title = "ESP Chest", Default = false}):OnChanged(function(v) _G.ESPChest = v end)
Tabs.ESP:AddToggle("ESPFruit", {Title = "ESP Fruit", Default = false}):OnChanged(function(v) _G.ESPFruit = v end)
Tabs.ESP:AddToggle("ESPFlower", {Title = "ESP Flower", Default = false}):OnChanged(function(v) _G.ESPFlower = v end)
Tabs.ESP:AddToggle("ESPMob", {Title = "ESP Mobs", Default = false}):OnChanged(function(v) _G.ESPMob = v end)
Tabs.ESP:AddToggle("ESPIsland", {Title = "ESP Islands", Default = false}):OnChanged(function(v) _G.ESPIsland = v end)
Tabs.ESP:AddToggle("Disable3DRender", {Title = "Disable 3D Rendering (FPS Booster)", Default = false}):OnChanged(function(v)
    _G.Disable3D = v
    pcall(function()
        game:GetService("RunService"):Set3dRenderingEnabled(not v)
    end)
end)

-- Tab 8: Stats
Tabs.Stats:AddToggle("AutoStats", {Title = "Auto Distribute Stats", Default = false}):OnChanged(function(v) _G.AutoStats = v end)
Tabs.Stats:AddDropdown("StatType", {
    Title = "Select Stat Category",
    Values = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"},
    Default = "Melee",
    Callback = function(v) _G.StatType = v end
})

-- Tab 9: Shop
local hakis = {"Geppo", "Buso", "Soru", "Ken"}
for _, haki in ipairs(hakis) do
    Tabs.Shop:AddButton({
        Title = "Buy " .. haki .. " Haki",
        Callback = function()
            if haki == "Ken" then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("KenTalk", "Buy")
            else
                ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", haki)
            end
        end
    })
end

local selectedStyle = "Black Leg"

Tabs.Shop:AddDropdown("FightingStyleSelect", {
    Title = "Select Fighting Style to Buy",
    Values = {"Black Leg", "Fishman Karate", "Electro", "Dragon Breath", "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw", "Dragon Talon", "Godhuman"},
    Default = "Black Leg",
    Callback = function(v)
        selectedStyle = v
    end
})

local function buyStyleRemote(style)
    local styleMap = {
        ["Black Leg"] = "BuyBlackLeg",
        ["Fishman Karate"] = "BuyFishmanKarate",
        ["Electro"] = "BuyElectro",
        ["Superhuman"] = "BuySuperhuman",
        ["Death Step"] = "BuyDeathStep",
        ["Sharkman Karate"] = "BuySharkmanKarate",
        ["Electric Claw"] = "BuyElectricClaw",
        ["Dragon Talon"] = "BuyDragonTalon",
        ["Godhuman"] = "BuyGodhuman"
    }
    
    if style == "Dragon Breath" then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "1")
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
    elseif styleMap[style] then
        ReplicatedStorage.Remotes.CommF_:InvokeServer(styleMap[style])
    end
end

Tabs.Shop:AddButton({
    Title = "Tween to Teacher & Buy Style",
    Callback = function()
        local cf = StyleNPCCoords[selectedStyle]
        if cf then
            tweenTo(cf)
            task.wait(0.5)
            buyStyleRemote(selectedStyle)
            Fluent:Notify({Title = "Shop", Content = "Attempted to buy " .. selectedStyle, Duration = 3})
        else
            Fluent:Notify({Title = "Error", Content = "NPC Coordinates not found for " .. selectedStyle, Duration = 3})
        end
    end
})

Tabs.Shop:AddButton({
    Title = "Instant Buy Style (Without Tween)",
    Callback = function()
        buyStyleRemote(selectedStyle)
        Fluent:Notify({Title = "Shop", Content = "Attempted instant buy for " .. selectedStyle, Duration = 3})
    end
})

Tabs.Shop:AddDropdown("TeleportTeacher", {
    Title = "Teleport to NPC / Teacher (Sea 3)",
    Values = {
        "Godhuman Teacher (Phoeyu)",
        "Sharkman Karate Teacher",
        "Death Step Teacher",
        "Martial Arts Master",
        "Water Kung-fu Teacher",
        "Mad Scientist",
        "Elite Hunter",
        "Lucien (Fox Lamp)",
        "Aura Editor",
        "Plokster",
        "Butler",
        "Tacomura"
    },
    Default = "",
    Callback = function(selected)
        local teacherCoords = {
            ["Godhuman Teacher (Phoeyu)"] = CFrame.new(-4999.23, 314.01, -3221.57),
            ["Sharkman Karate Teacher"] = CFrame.new(-4971.21, 313.89, -3223.08),
            ["Death Step Teacher"] = CFrame.new(-5045.60, 370.01, -3182.30),
            ["Martial Arts Master"] = CFrame.new(-5004.72, 370.42, -3198.92),
            ["Water Kung-fu Teacher"] = CFrame.new(-5023.91, 371.03, -3191.46),
            ["Mad Scientist"] = CFrame.new(-4996.05, 313.21, -3201.82),
            ["Elite Hunter"] = CFrame.new(-5417.66, 313.06, -2822.91),
            ["Lucien (Fox Lamp)"] = CFrame.new(-5019.16, 314.58, -2812.78),
            ["Aura Editor"] = CFrame.new(-4889.19, 370.66, -2860.43),
            ["Plokster"] = CFrame.new(-5144.68, 314.76, -3166.97),
            ["Butler"] = CFrame.new(-5116.30, 315.66, -3133.61),
            ["Tacomura"] = CFrame.new(-5062.73, 370.66, -3140.33)
        }
        
        local cf = teacherCoords[selected]
        if cf then
            tweenTo(cf)
        end
    end
})

-- Tab 10: Settings / Misc
Tabs.Settings:AddToggle("SafeFarm", {Title = "Safe Farm Mode (Anti-Ban)", Default = true}):OnChanged(function(v) _G.SafeFarm = v end)
Tabs.Settings:AddToggle("AntiAFK", {Title = "Anti-AFK Avoid Kick", Default = true}):OnChanged(function(v) _G.AntiAFK = v end)
Tabs.Settings:AddToggle("NoClip", {Title = "No Clip Walls/Floor", Default = false}):OnChanged(function(v) _G.NoClip = v end)
Tabs.Settings:AddToggle("InfiniteJump", {Title = "Infinite Jump", Default = false}):OnChanged(function(v) _G.InfiniteJump = v end)

Tabs.Settings:AddButton({
    Title = "FPS Boost (Removes Decals & Shadows)",
    Callback = function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("MeshPart") then
                v.Material = Enum.Material.Plastic
            end
            if v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end
        game.Lighting.GlobalShadows = false
        game.Lighting.FogEnd = 100000
        settings().Rendering.QualityLevel = 1
    end
})

local BeliChestToggle = Tabs.Settings:AddToggle("BeliChestToggle", {Title = "Teleport to Castle Diamond Chest (Beli Farm)", Default = false})
BeliChestToggle:OnChanged(function(v)
    _G.TeleportingToBeliChest = v
    if v then
        task.spawn(function()
            tweenTo(CFrame.new(-5234.43, 1086.58, -2578.09), nil, "BeliChest")
            _G.TeleportingToBeliChest = false
            BeliChestToggle:SetValue(false)
        end)
    end
end)

Tabs.Settings:AddButton({
    Title = "Rejoin Current Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

Tabs.Settings:AddButton({
    Title = "Server Hop (Next Active Server)",
    Callback = function()
        local function listServers(cursor)
            local raw = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. ((cursor and "&cursor=" .. cursor) or ""))
            return HttpService:JSONDecode(raw)
        end
        
        local servers = listServers()
        while true do
            for _, v in pairs(servers.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id)
                    return
                end
            end
            if servers.nextPageCursor then
                servers = listServers(servers.nextPageCursor)
            else
                break
            end
        end
    end
})

Tabs.Settings:AddButton({
    Title = "Destroy UI & Stop Scripts",
    Callback = function()
        _G.AutoFarm = false
        _G.AutoNearestFarm = false
        _G.AutoMasteryFarm = false
        _G.AutoBossFarm = false
        _G.AutoMaterialFarm = false
        _G.KillAura = false
        _G.AutoPvP = false
        clearAllESP()
        Window:Destroy()
    end
})

-- World Teleports Dropdown inside Settings tab
local currentSeaIslands = World1 and IslandCoords.Sea1 or World2 and IslandCoords.Sea2 or IslandCoords.Sea3
local islandNames = {}
for name, _ in pairs(currentSeaIslands) do
    table.insert(islandNames, name)
end

Tabs.Settings:AddInput("IslandSearchInput", {
    Title = "Search Target Sea Island",
    Default = "",
    Placeholder = "Type island name...",
    Numeric = false,
    Finished = false,
    Callback = function(v)
        local filtered = {}
        local query = string.lower(v)
        for name, _ in pairs(currentSeaIslands) do
            if query == "" or string.find(string.lower(name), query) then
                table.insert(filtered, name)
            end
        end
        if #filtered == 0 then
            filtered = {"No matches found"}
        end
        pcall(function()
            Options.TeleportIsland:SetValues(filtered)
            Options.TeleportIsland:SetValue(filtered[1])
        end)
    end
})

Tabs.Settings:AddDropdown("TeleportIsland", {
    Title = "Select Target Sea Island",
    Values = islandNames,
    Default = islandNames[1] or "",
    Callback = function(v)
        _G.SelectedTeleportIsland = v
    end
})

local TeleportToggle = Tabs.Settings:AddToggle("TeleportIslandToggle", {Title = "Teleport to Selected Island", Default = false})

TeleportToggle:OnChanged(function(v)
    _G.TeleportingToIsland = v
    if v then
        task.spawn(function()
            local targetCF = currentSeaIslands[_G.SelectedTeleportIsland]
            if targetCF then
                teleportToIsland(_G.SelectedTeleportIsland, targetCF)
            else
                Fluent:Notify({Title = "Error", Content = "Please select an island first", Duration = 3})
            end
            _G.TeleportingToIsland = false
            TeleportToggle:SetValue(false)
        end)
    end
end)

-- World hopping buttons inside Settings tab
for i = 1, 3 do
    Tabs.Settings:AddButton({
        Title = "Teleport to Sea " .. i,
        Callback = function()
            local places = {[1] = 2753915549, [2] = 4442272183, [3] = 7449423635}
            TeleportService:Teleport(places[i], LocalPlayer)
        end
    })
end

-- Offline Custom Configuration Manager UI Section
local ConfigSection = Tabs.Settings:AddSection("Offline Configuration Manager")

local configNameInput = Tabs.Settings:AddInput("ConfigNameInput", {
    Title = "Config File Name",
    Default = "default",
    Placeholder = "Enter config name...",
    Numeric = false,
    Finished = false,
    Callback = function(v) end
})

local configDropdown = Tabs.Settings:AddDropdown("SelectConfig", {
    Title = "Select Config",
    Values = getConfigsList(),
    Default = "default",
    Callback = function(v) end
})

Tabs.Settings:AddButton({
    Title = "Save Config File",
    Callback = function()
        local name = configNameInput.Value
        if name == "" then name = "default" end
        saveConfig(name)
        configDropdown:SetValues(getConfigsList())
    end
})

Tabs.Settings:AddButton({
    Title = "Load Config File",
    Callback = function()
        local name = configDropdown.Value
        if name and name ~= "" then
            loadConfig(name)
        end
    end
})

Tabs.Settings:AddButton({
    Title = "Delete Config File",
    Callback = function()
        local name = configDropdown.Value
        if name and name ~= "" then
            local filePath = CONFIG_FOLDER .. "/" .. name .. ".json"
            pcall(function()
                if delfile then
                    delfile(filePath)
                else
                    writefile(filePath, "")
                end
            end)
            configDropdown:SetValues(getConfigsList())
            Fluent:Notify({Title = "Config Deleted", Content = "Successfully deleted " .. name, Duration = 3})
        end
    end
})

local autoloadToggle = Tabs.Settings:AddToggle("AutoloadConfigToggle", {
    Title = "Autoload Selected Config",
    Default = false
})

autoloadToggle:OnChanged(function(v)
    ensureFolder()
    if v then
        local name = configDropdown.Value or "default"
        pcall(function() writefile(CONFIG_FOLDER .. "/autoload.txt", name) end)
        Fluent:Notify({Title = "Autoload Enabled", Content = "Will autoload " .. name .. " next run.", Duration = 3})
    else
        pcall(function()
            if delfile then delfile(CONFIG_FOLDER .. "/autoload.txt") else writefile(CONFIG_FOLDER .. "/autoload.txt", "") end
        end)
        Fluent:Notify({Title = "Autoload Disabled", Content = "Autoload has been turned off.", Duration = 3})
    end
end)

-- Load config using SaveManager/InterfaceManager if they were loaded successfully
if SaveManager and InterfaceManager then
    pcall(function()
        SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})
        InterfaceManager:SetFolder("BloxFruitsHubConfigs")
        SaveManager:SetFolder("BloxFruitsHubConfigs/game")
        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        SaveManager:BuildConfigSection(Tabs.Settings)
        SaveManager:LoadAutoloadConfig()
    end)
end

-- Custom JSON Autoload Initialization at Startup
task.spawn(function()
    task.wait(2)
    ensureFolder()
    local autoloadFile = CONFIG_FOLDER .. "/autoload.txt"
    if isfile and isfile(autoloadFile) then
        local name = readfile(autoloadFile)
        if name and name ~= "" then
            local loaded = loadConfig(name)
            if loaded then
                pcall(function() autoloadToggle:SetValue(true) end)
                pcall(function() configDropdown:SetValue(name) end)
            end
        end
    end
end)

Window:SelectTab(1)
Fluent:Notify({Title = "BloxFruits Hub", Content = "Ultimate Rebuild Loaded Successfully!", Duration = 5})
