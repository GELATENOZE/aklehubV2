local vu1 = Instance.new("ScreenGui")
vu1.Name = "FRONT_EVILL_GUI"
vu1.Parent = game.CoreGui
vu1.ResetOnSpawn = false

local vu2 = game:GetService("Players")
local vu3 = game:GetService("ReplicatedStorage")
local vu4 = game:GetService("RunService")
local vu5 = game:GetService("TweenService")
local vu6 = game:GetService("Workspace")
local vu183 = game:GetService("UserInputService")

local vu7 = vu2.LocalPlayer

local FlyEnabled = false
local FlySpeed = 16
local FlyConnection = nil
local flyBV = nil
local flyBG = nil

local function toggleFly()
    if not vu7.Character then return end
    
    FlyEnabled = not FlyEnabled
    
    if FlyEnabled then
        flyBV = Instance.new("BodyVelocity")
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBV.P = 10000
        
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBG.P = 10000
        
        local humanoidRootPart = vu7.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            flyBV.Parent = humanoidRootPart
            flyBG.Parent = humanoidRootPart
        end
        
        FlyConnection = vu4.Heartbeat:Connect(function()
            if not FlyEnabled or not vu7.Character then
                return
            end
            
            local humanoidRootPart = vu7.Character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart or not flyBV or not flyBG then return end
            
            local direction = Vector3.new(0, 0, 0)
            
            if vu183:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + (humanoidRootPart.CFrame.LookVector * FlySpeed)
            end
            if vu183:IsKeyDown(Enum.KeyCode.S) then
                direction = direction + (humanoidRootPart.CFrame.LookVector * -FlySpeed)
            end
            
            if vu183:IsKeyDown(Enum.KeyCode.A) then
                direction = direction + (humanoidRootPart.CFrame.RightVector * -FlySpeed)
            end
            if vu183:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + (humanoidRootPart.CFrame.RightVector * FlySpeed)
            end
            
            flyBV.Velocity = direction
            
            flyBG.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector)
        end)
    else
        if flyBV then 
            flyBV:Destroy()
            flyBV = nil
        end
        if flyBG then 
            flyBG:Destroy()
            flyBG = nil
        end
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
    end
end

local vu8 = {}
vu8.__index = vu8

function vu8.new()
    local v9 = setmetatable({}, vu8)
    v9.originalPosition = nil
    v9.isRandomTeleporting = false
    v9.teleportConnection = nil
    v9.mapBounds = {
        min = Vector3.new(-500, 0, -500),
        max = Vector3.new(500, 200, 500)
    }
    return v9
end

function vu8.saveOriginalPosition(p10)
    if vu7.Character and vu7.Character:FindFirstChild("HumanoidRootPart") then
        p10.originalPosition = vu7.Character.HumanoidRootPart.CFrame
    end
end

function vu8.getRandomMapPosition(p11)
    local v12 = math.random(p11.mapBounds.min.X, p11.mapBounds.max.X)
    local v13 = math.random(p11.mapBounds.min.Z, p11.mapBounds.max.Z)
    local v14 = math.random(10, 100)
    return Vector3.new(v12, v14, v13)
end

function vu8.startRandomTeleport(pu15)
    if not pu15.isRandomTeleporting then
        pu15:saveOriginalPosition()
        pu15.isRandomTeleporting = true
        pu15.teleportConnection = vu4.Heartbeat:Connect(function()
            if vu7.Character and vu7.Character:FindFirstChild("HumanoidRootPart") then
                local v16 = pu15:getRandomMapPosition()
                vu7.Character.HumanoidRootPart.CFrame = CFrame.new(v16)
            end
            wait(0.1)
        end)
    end
end

function vu8.stopRandomTeleport(p17)
    if p17.isRandomTeleporting then
        p17.isRandomTeleporting = false
        if p17.teleportConnection then
            p17.teleportConnection:Disconnect()
            p17.teleportConnection = nil
        end
        if p17.originalPosition and vu7.Character and vu7.Character:FindFirstChild("HumanoidRootPart") then
            vu7.Character.HumanoidRootPart.CFrame = p17.originalPosition
        end
    end
end

function vu8.isActive(p18)
    return p18.isRandomTeleporting
end

local vu19 = {}
vu19.__index = vu19

function vu19.new()
    local v20 = setmetatable({}, vu19)
    v20.isProtecting = false
    v20.protectionConnection = nil
    v20.targetPlayer = nil
    return v20
end

function vu19.setTarget(p21)
    p21.targetPlayer = nil
end

function vu19.startProtection(pu22)
    if pu22.isProtecting then
        return
    elseif pu22.targetPlayer then
        pu22.isProtecting = true
        pu22.protectionConnection = vu4.Heartbeat:Connect(function()
            if pu22.targetPlayer and pu22.targetPlayer.Character then
                local v23 = pu22.targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local v24 = vu7.Character
                if v24 then
                    v24 = vu7.Character:FindFirstChild("HumanoidRootPart")
                end
                if v23 and v24 then
                    local v25 = v23.Position - v23.CFrame.LookVector * 3
                    v24.CFrame = CFrame.new(v25, v23.Position)
                end
            else
                pu22:stopProtection()
            end
        end)
    end
end

function vu19.stopProtection(p26)
    p26.isProtecting = false
    if p26.protectionConnection then
        p26.protectionConnection:Disconnect()
        p26.protectionConnection = nil
    end
end

function vu19.toggle(p27)
    if p27.isProtecting then
        p27:stopProtection()
    else
        p27:startProtection()
    end
    return p27.isProtecting
end

function vu19.isActive(p28)
    return p28.isProtecting
end

local vu29 = {}
vu29.__index = vu29

function vu29.new()
    return setmetatable({}, vu29)
end

function vu29.hasBomb(_)
    if not vu7.Character then
        return false
    end
    local v30, v31, v32 = pairs(vu7.Character:GetChildren())
    while true do
        local v33
        v32, v33 = v30(v31, v32)
        if v32 == nil then
            break
        end
        if v33:IsA("Tool") and (v33.Name:lower():find("bomb") or (v33.Name:lower():find("tnt") or v33.Name:lower():find("explosive"))) then
            return true, v33
        end
    end
    
    local v34, v35, v36 = pairs(vu7.Backpack:GetChildren())
    while true do
        local v37
        v36, v37 = v34(v35, v36)
        if v36 == nil then
            break
        end
        if v37:IsA("Tool") and (v37.Name:lower():find("bomb") or (v37.Name:lower():find("tnt") or v37.Name:lower():find("explosive"))) then
            return true, v37
        end
    end
    return false
end

local vu38 = {}
vu38.__index = vu38

function vu38.new(p39)
    local v40 = setmetatable({}, vu38)
    v40.bombDetector = p39
    v40.autoTransferEnabled = false
    v40.transferConnection = nil
    v40.targetPlayer = nil
    v40.originalPosition = nil
    v40.transferDelay = 0.1
    return v40
end

function vu38.setTarget(p41)
    p41.targetPlayer = nil
end

function vu38.teleportToPlayer(_, p42)
    if vu7.Character and vu7.Character:FindFirstChild("HumanoidRootPart") then
        if p42 and p42.Character and p42.Character:FindFirstChild("HumanoidRootPart") then
            local v43 = p42.Character.HumanoidRootPart.Position
            local v44 = v43 + p42.Character.HumanoidRootPart.CFrame.LookVector * -2
            vu7.Character.HumanoidRootPart.CFrame = CFrame.new(v44, v43)
            wait(0.2)
            if p42.Character and p42.Character:FindFirstChild("Head") then
                vu7.Character.HumanoidRootPart.CFrame = CFrame.lookAt(vu7.Character.HumanoidRootPart.Position, p42.Character.Head.Position)
            end
        end
    end
end

function vu38.transferBomb(p45, pu46)
    if pu46 and pu46.Character then
        if vu7.Character and vu7.Character:FindFirstChild("HumanoidRootPart") then
            p45.originalPosition = vu7.Character.HumanoidRootPart.CFrame
        end
        
        wait(p45.transferDelay)
        
        p45:teleportToPlayer(pu46)
        
        local v47, v48 = p45.bombDetector:hasBomb()
        if v47 then
            v48.Parent = pu46.Character
        end
        
        spawn(function()
            local v49 = vu3
            local v50, v51, v52 = pairs(v49:GetDescendants())
            while true do
                local vu53
                v52, vu53 = v50(v51, v52)
                if v52 == nil then
                    break
                end
                if vu53:IsA("RemoteEvent") then
                    local v54 = vu53.Name:lower()
                    if v54:find("bomb") or (v54:find("give") or (v54:find("pass") or (v54:find("transfer") or v54:find("hot")))) then
                        pcall(function()
                            vu53:FireServer(pu46)
                            vu53:FireServer(pu46.Character)
                            vu53:FireServer(pu46.Character.Head)
                            vu53:FireServer({
                                player = pu46,
                                target = pu46
                            })
                        end)
                    end
                end
            end
            
            local v55 = vu6
            local v56, v57, v58 = pairs(v55:GetDescendants())
            while true do
                local vu59
                v58, vu59 = v56(v57, v58)
                if v58 == nil then
                    break
                end
                if vu59:IsA("RemoteEvent") then
                    local v60 = vu59.Name:lower()
                    if v60:find("bomb") or (v60:find("give") or (v60:find("pass") or (v60:find("transfer") or v60:find("hot")))) then
                        pcall(function()
                            vu59:FireServer(pu46)
                            vu59:FireServer(pu46.Character.Head)
                        end)
                    end
                end
            end
        end)
        
        wait(0.01)
        
        if p45.originalPosition and vu7.Character and vu7.Character:FindFirstChild("HumanoidRootPart") then
            vu7.Character.HumanoidRootPart.CFrame = p45.originalPosition
        end
    end
end

function vu38.getClosestPlayer(p61)
    if p61.targetPlayer and p61.targetPlayer.Character and p61.targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return p61.targetPlayer
    end
    
    if not (vu7.Character and vu7.Character:FindFirstChild("HumanoidRootPart")) then
        return nil
    end
    
    local v62 = math.huge
    local v63 = vu7.Character.HumanoidRootPart.Position
    local v64 = vu2
    local v65, v66, v67 = pairs(v64:GetPlayers())
    local v68 = nil
    while true do
        local v69
        v67, v69 = v65(v66, v67)
        if v67 == nil then
            break
        end
        if v69 ~= vu7 and v69.Character and v69.Character:FindFirstChild("HumanoidRootPart") then
            local v70 = (v69.Character.HumanoidRootPart.Position - v63).Magnitude
            if v70 < v62 then
                v68 = v69
                v62 = v70
            end
        end
    end
    return v68
end

function vu38.getRandomPlayer(p71)
    local players = {}
    local v72, v73, v74 = pairs(vu2:GetPlayers())
    while true do
        local v75
        v74, v75 = v72(v73, v74)
        if v74 == nil then
            break
        end
        if v75 ~= vu7 and v75.Character and v75.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(players, v75)
        end
    end
    
    if #players > 0 then
        return players[math.random(1, #players)]
    end
    return nil
end

function vu38.giveBombToClosest(p76)
    local v77 = p76:getClosestPlayer()
    if v77 then
        p76:transferBomb(v77)
    end
end

function vu38.giveBombToRandom(p78)
    local v79 = p78:getRandomPlayer()
    if v79 then
        p78:transferBomb(v79)
    end
end

function vu38.toggleAutoTransfer(pu80)
    pu80.autoTransferEnabled = not pu80.autoTransferEnabled
    if pu80.autoTransferEnabled then
        pu80.transferConnection = vu4.Heartbeat:Connect(function()
            wait(0.1)
            if pu80.bombDetector:hasBomb() then
                pu80:giveBombToRandom()
            end
        end)
    elseif pu80.transferConnection then
        pu80.transferConnection:Disconnect()
        pu80.transferConnection = nil
    end
    return pu80.autoTransferEnabled
end

local vu74 = {}
vu74.__index = vu74

function vu74.new()
    local v75 = setmetatable({}, vu74)
    v75.espEnabled = false
    v75.espConnections = {}
    return v75
end

function vu74.createESP(p76, p77)
    if p77 and p77.Character and p77.Character:FindFirstChild("HumanoidRootPart") then
        local vu78 = p77.Character
        if not vu78:FindFirstChild("WireframeESP") then
            local vu79 = Instance.new("Folder")
            vu79.Name = "WireframeESP"
            vu79.Parent = vu78
            
            local v80 = vu78:FindFirstChild("UpperTorso") and {
                "Head",
                "UpperTorso",
                "LowerTorso",
                "LeftUpperArm",
                "LeftLowerArm",
                "LeftHand",
                "RightUpperArm",
                "RightLowerArm",
                "RightHand",
                "LeftUpperLeg",
                "LeftLowerLeg",
                "LeftFoot",
                "RightUpperLeg",
                "RightLowerLeg",
                "RightFoot"
            } or {
                "Head",
                "Torso",
                "Left Arm",
                "Right Arm",
                "Left Leg",
                "Right Leg",
                "HumanoidRootPart"
            }
            
            local v81, v82, v83 = ipairs(v80)
            while true do
                local v84
                v83, v84 = v81(v82, v83)
                if v83 == nil then
                    break
                end
                local v85 = vu78:FindFirstChild(v84)
                if v85 and v85:IsA("BasePart") then
                    local v86 = Instance.new("SelectionBox")
                    v86.Name = "ESP_" .. v84
                    v86.Adornee = v85
                    v86.Color3 = Color3.fromRGB(0, 0, 150)
                    v86.LineThickness = 0.1
                    v86.Transparency = 0.1
                    v86.Parent = vu79
                end
            end
            
            local v87 = {
                folder = vu79,
                connection = vu78.AncestryChanged:Connect(function()
                    if not vu78.Parent then
                        vu79:Destroy()
                        connection:Disconnect()
                    end
                end)
            }
            p76.espConnections[p77] = v87
        end
    else
        return
    end
end

function vu74.toggleESP(pu88)
    pu88.espEnabled = not pu88.espEnabled
    if pu88.espEnabled then
        local v89 = vu2
        local v90, v91, v92 = pairs(v89:GetPlayers())
        while true do
            local vu93
            v92, vu93 = v90(v91, v92)
            if v92 == nil then
                break
            end
            if vu93 ~= vu7 then
                if vu93.Character then
                    pu88:createESP(vu93)
                end
                vu93.CharacterAdded:Connect(function()
                    wait(0.3)
                    if pu88.espEnabled then
                        pu88:createESP(vu93)
                    end
                end)
            end
        end
        
        vu2.PlayerAdded:Connect(function(pu94)
            if pu88.espEnabled then
                pu94.CharacterAdded:Connect(function()
                    wait(0.3)
                    if pu88.espEnabled then
                        pu88:createESP(pu94)
                    end
                end)
            end
        end)
    else
        local v95, v96, v97 = pairs(pu88.espConnections)
        while true do
            local v98
            v97, v98 = v95(v96, v97)
            if v97 == nil then
                break
            end
            if v98.folder then
                v98.folder:Destroy()
            end
            if v98.connection then
                v98.connection:Disconnect()
            end
        end
        pu88.espConnections = {}
    end
    return pu88.espEnabled
end

local vu99 = {}
vu99.__index = vu99

function vu99.new()
    return setmetatable({}, vu99)
end

function vu99.findByName(_, p100)
    if p100 == "" then
        return nil
    end
    local v101 = p100:lower()
    local v102 = math.huge
    local v103 = vu2
    local v104, v105, v106 = pairs(v103:GetPlayers())
    local v107 = nil
    while true do
        local v108
        v106, v108 = v104(v105, v106)
        if v106 == nil then
            break
        end
        if v108 ~= vu7 then
            local v109 = v108.Name:lower()
            local v110 = (v108.DisplayName or ""):lower()
            if v109:find(v101, 1, true) or v110:find(v101, 1, true) then
                local v111 = math.abs(#v109 - #v101)
                if v111 < v102 then
                    v107 = v108
                    v102 = v111
                end
            end
        end
    end
    return v107
end

local vu112 = {}
vu112.__index = vu112

function vu112.new()
    local v113 = setmetatable({}, vu112)
    v113.iceFixEnabled = false
    v113.iceFixConnection = nil
    return v113
end

function vu112.fixIceParts(_)
    if vu7.Character then
        local v114 = vu7.Character
        local v115 = v114:FindFirstChild("Humanoid")
        local v116 = v114:FindFirstChild("HumanoidRootPart")
        if v115 and v116 then
            v115.WalkSpeed = 16
            v115.JumpPower = 50
            v116.AssemblyLinearVelocity = Vector3.new(0, v116.AssemblyLinearVelocity.Y, 0)
            v116.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            local v117, v118, v119 = pairs(v114:GetChildren())
            while true do
                local v120
                v119, v120 = v117(v118, v119)
                if v119 == nil then
                    break
                end
                if v120:IsA("BasePart") then
                    v120.AssemblyLinearVelocity = Vector3.new(0, v120.AssemblyLinearVelocity.Y, 0)
                    v120.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    if v120.Material == Enum.Material.Ice then
                        v120.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.5, 0, 1, 1)
                    end
                end
            end
        end
        
        local v121 = vu6
        local v122, v123, v124 = pairs(v121:GetDescendants())
        while true do
            local v125
            v124, v125 = v122(v123, v124)
            if v124 == nil then
                break
            end
            if v125:IsA("BasePart") and v125.Name:lower():find("ice") then
                v125.CanTouch = false
                v125.CustomPhysicalProperties = PhysicalProperties.new(0.7, 1, 0, 1, 1)
            end
        end
    end
end

function vu112.toggle(pu126)
    pu126.iceFixEnabled = not pu126.iceFixEnabled
    if pu126.iceFixEnabled then
        pu126.iceFixConnection = vu4.Heartbeat:Connect(function()
            pu126:fixIceParts()
        end)
    elseif pu126.iceFixConnection then
        pu126.iceFixConnection:Disconnect()
        pu126.iceFixConnection = nil
    end
    return pu126.iceFixEnabled
end

local vu127 = {}
vu127.__index = vu127

function vu127.new()
    return setmetatable({}, vu127)
end

function vu127.giveTool(_, pu128)
    local v129, v130, v131 = pairs(vu7.Backpack:GetChildren())
    while true do
        local v132
        v131, v132 = v129(v130, v131)
        if v131 == nil then
            break
        end
        if v132.Name == "ClickTarget" then
            v132:Destroy()
        end
    end
    
    local v133, v134, v135 = pairs(vu7.Character:GetChildren())
    while true do
        local v136
        v135, v136 = v133(v134, v135)
        if v135 == nil then
            break
        end
        if v136.Name == "ClickTarget" then
            v136:Destroy()
        end
    end
    
    local vu137 = Instance.new("Tool")
    vu137.Name = "ClickTarget"
    vu137.RequiresHandle = false
    vu137.TextureId = "rbxassetid://13769558274"
    vu137.ToolTip = "Choose Player"
    vu137.Activated:Connect(function()
        local v138 = vu7:GetMouse().Target
        local v139 = nil
        if v138 and v138.Parent then
            if v138.Parent:IsA("Model") then
                v139 = vu2:GetPlayerFromCharacter(v138.Parent)
            elseif v138.Parent:IsA("Accessory") then
                v139 = vu2:GetPlayerFromCharacter(v138.Parent.Parent)
            end
            if v139 and v139 ~= vu7 then
                pu128(v139)
                vu137:Destroy()
            end
        end
    end)
    vu137.Parent = vu7.Backpack
end

local vu140 = {}
vu140.__index = vu140

function vu140.new()
    return setmetatable({}, vu140)
end

function vu140.detectType(_)
    local v141 = game.Workspace
    return (v141:FindFirstChild("TimeBomb") or (v141:FindFirstChild("Bomb") or v141:FindFirstChild("Map"))) and "TimeBomb" or "Detected"
end

local vu142 = {}
vu142.__index = vu142

function vu142.new()
    local v143 = setmetatable({}, vu142)
    v143.targetPlayer = nil
    v143.targetPlayerName = ""
    v143.bombDetector = vu29.new()
    v143.bombTransfer = vu38.new(v143.bombDetector)
    v143.espController = vu74.new()
    v143.playerSearcher = vu99.new()
    v143.iceFixController = vu112.new()
    v143.targetTool = vu127.new()
    v143.mapDetector = vu140.new()
    v143.movementController = vu8.new()
    v143.protectionController = vu19.new()
    return v143
end

function vu142.setTarget(p144, p145)
    p144.targetPlayer = p145
    p144.targetPlayerName = p145 and (p145.Name or "") or ""
    p144.bombTransfer:setTarget(p145)
    p144.protectionController:setTarget(p145)
end

function vu142.createGUI(pu146)
    local vu147 = Instance.new("Frame")
    vu147.Name = "MainFrame"
    vu147.Parent = vu1
    vu147.Size = UDim2.new(0, 300, 0, 450)
    vu147.Position = UDim2.new(0.5, -150, 0.5, -225)
    vu147.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    vu147.BackgroundTransparency = 0.3
    vu147.BorderSizePixel = 0
    vu147.Active = true
    vu147.Draggable = true
    
    local v148 = Instance.new("UICorner")
    v148.CornerRadius = UDim.new(0, 10)
    v148.Parent = vu147
    
    local v149 = Instance.new("TextLabel")
    v149.Name = "TitleLabel"
    v149.Parent = vu147
    v149.Size = UDim2.new(1, 0, 0, 40)
    v149.Position = UDim2.new(0, 0, 0, 0)
    v149.BackgroundTransparency = 1
    v149.Text = "Ankle Bomb - by gelatenoze" 
    v149.TextColor3 = Color3.fromRGB(255, 255, 255)
    v149.TextSize = 18
    v149.TextScaled = true
    v149.Font = Enum.Font.GothamBold
    
    local v150 = Instance.new("Frame")
    v150.Size = UDim2.new(0.9, 0, 0, 35)
    v150.Position = UDim2.new(0.05, 0, 0, 50)
    v150.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    v150.BorderSizePixel = 0
    v150.Parent = vu147
    
    local v151 = Instance.new("UICorner")
    v151.CornerRadius = UDim.new(0, 8)
    v151.Parent = v150
    
    local vu152 = Instance.new("TextBox")
    vu152.Size = UDim2.new(0.7, 0, 1, 0)
    vu152.Position = UDim2.new(0, 5, 0, 0)
    vu152.BackgroundTransparency = 1
    vu152.Text = ""
    vu152.PlaceholderText = "Enter player name..."
    vu152.TextColor3 = Color3.fromRGB(255, 255, 255)
    vu152.TextSize = 14
    vu152.Font = Enum.Font.Gotham
    vu152.Parent = v150
    
    local v153 = Instance.new("TextButton")
    v153.Size = UDim2.new(0.25, 0, 0.8, 0)
    v153.Position = UDim2.new(0.72, 0, 0.1, 0)
    v153.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    v153.BorderSizePixel = 0
    v153.Text = "Set Target"
    v153.TextColor3 = Color3.fromRGB(255, 255, 255)
    v153.TextSize = 12
    v153.Font = Enum.Font.Gotham
    v153.Parent = v150
    
    local v154 = Instance.new("UICorner")
    v154.CornerRadius = UDim.new(0, 6)
    v154.Parent = v153
    
    v153.MouseButton1Click:Connect(function()
        local v155 = vu152.Text:gsub("%s+", "")
        if v155 == "" then
            pu146:setTarget(nil)
        else
            local v156 = pu146.playerSearcher:findByName(v155)
            if v156 then
                pu146:setTarget(v156)
                vu152.Text = v156.Name
            end
        end
    end)
    
    local v158 = {
        {
            name = "ESP Players",
            func = function()
                pu146.espController:toggleESP()
            end,
            color = Color3.fromRGB(50, 50, 50)
        },
        {
            name = "Give Bomb (target random)",
            func = function()
                pu146.bombTransfer:giveBombToRandom()
            end,
            color = Color3.fromRGB(50, 50, 50)
        },
        {
            name = "Auto Transfer (work 50/50)",
            func = function()
                pu146.bombTransfer:toggleAutoTransfer()
            end,
            color = Color3.fromRGB(50, 50, 50)
        },
        {
            name = "speed hack",
            func = function()
                toggleFly()
            end,
            color = Color3.fromRGB(50, 50, 50)
        }
    }
    
    local v159, v160, v161 = ipairs(v158)
    while true do
        local v162, vu163 = v159(v160, v161)
        if v162 == nil then
            break
        end
        v161 = v162
        
        local vu164 = Instance.new("TextButton")
        vu164.Name = "Button" .. v162
        vu164.Parent = vu147
        vu164.Size = UDim2.new(0.9, 0, 0, 40)
        vu164.Position = UDim2.new(0.05, 0, 0, 100 + (v162 - 1) * 50)
        vu164.BackgroundColor3 = vu163.color
        vu164.BackgroundTransparency = 0.2
        vu164.BorderSizePixel = 0
        vu164.Text = vu163.name
        vu164.TextColor3 = Color3.fromRGB(255, 255, 255)
        vu164.TextSize = 14
        vu164.Font = Enum.Font.Gotham
        
        local v165 = Instance.new("UICorner")
        v165.CornerRadius = UDim.new(0, 8)
        v165.Parent = vu164
        
        vu164.MouseEnter:Connect(function()
            vu5:Create(vu164, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1
            }):Play()
        end)
        
        vu164.MouseLeave:Connect(function()
            vu5:Create(vu164, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.2
            }):Play()
        end)
        
        vu164.MouseButton1Click:Connect(function()
            spawn(vu163.func)
        end)
    end
    
    local flyControlsLabel = Instance.new("TextLabel")
    flyControlsLabel.Size = UDim2.new(0.9, 0, 0, 20)
    flyControlsLabel.Position = UDim2.new(0.05, 0, 0, 310)
    flyControlsLabel.BackgroundTransparency = 1
    flyControlsLabel.Text = "speed Controls: a+w or d+w"
    flyControlsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    flyControlsLabel.TextSize = 12
    flyControlsLabel.Font = Enum.Font.Gotham
    flyControlsLabel.Parent = vu147
    
    local vu166 = Instance.new("TextLabel")
    vu166.Size = UDim2.new(0.9, 0, 0, 25)
    vu166.Position = UDim2.new(0.05, 0, 0, 380)
    vu166.BackgroundTransparency = 1
    vu166.Text = "Target: None"
    vu166.TextColor3 = Color3.fromRGB(67, 75, 77)
    vu166.TextSize = 12
    vu166.Font = Enum.Font.Gotham
    vu166.Parent = vu147
    
    vu4.Heartbeat:Connect(function()
        if pu146.targetPlayer then
            vu166.Text = "Target: " .. pu146.targetPlayer.Name
            if not pu146.targetPlayer.Parent then
                pu146:setTarget(nil)
            end
        else
            vu166.Text = "Target: None / GivtBomb...AnitBomb"
        end
    end)
    
    local vu167 = Instance.new("TextButton")
    vu167.Name = "ToggleButton"
    vu167.Parent = vu1
    vu167.Size = UDim2.new(0, 120, 0, 35)
    vu167.Position = UDim2.new(0, 10, 0, 10)
    vu167.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    vu167.BackgroundTransparency = 0.2
    vu167.BorderSizePixel = 0
    vu167.Text = "Ankle Bomb"
    vu167.TextColor3 = Color3.fromRGB(255, 255, 255)
    vu167.TextSize = 14
    vu167.Font = Enum.Font.GothamBold
    vu167.Active = true
    vu167.Draggable = true
    
    local v168 = Instance.new("UICorner")
    v168.CornerRadius = UDim.new(0, 8)
    v168.Parent = vu167
    
    local vu169 = true
    vu167.MouseButton1Click:Connect(function()
        vu169 = not vu169
        if vu169 then
            vu147:TweenPosition(UDim2.new(0.5, -150, 0.5, -225), "Out", "Quad", 0.3, true)
            vu147.Visible = true
        else
            vu147:TweenPosition(UDim2.new(0.5, -150, 1.2, 0), "In", "Quad", 0.3, true, function()
                vu147.Visible = false
            end)
        end
    end)
    
    vu167.MouseEnter:Connect(function()
        vu5:Create(vu167, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        }):Play()
    end)
    
    vu167.MouseLeave:Connect(function()
        vu5:Create(vu167, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        }):Play()
    end)
end

function vu142.initialize(p170)
    p170:createGUI()
end

local mainController = vu142.new()
mainController:initialize()

local function checkForBomb()
    while true do
        wait(0.1)
        local hasBomb = mainController.bombDetector:hasBomb()
        if hasBomb and mainController.bombTransfer.autoTransferEnabled then
            mainController.bombTransfer:giveBombToRandom()
        end
    end
end

spawn(checkForBomb)
--script by gelatenoze tt:@helpbrovatafakyouduing
