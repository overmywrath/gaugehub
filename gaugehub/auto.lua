return function(lib)
    local tab = lib.Window:CreateTab({Name = "auto", Icon = "autorenew", ImageSource = "Material", ShowTitle = true})
    lib.tabs.auto = tab
    lib.installFeatureTracker(tab, "auto")
    local notif = lib.notif
    local ayaLog = lib.ayaLog
    local touchPart = lib.touchPart

    if lib.isCamp then
        tab:CreateToggle({
            Name = "auto collect",
            Description = "auto-touches every coin in the Coin Hunt map.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().autofarm = Value
                if not Value then return end
                getgenv().ayaSeenCoins = {}
                notif("auto collect", "on", 1)
                task.spawn(function()
                    while getgenv().autofarm do
                        task.wait(0.1)
                        local folder = workspace:FindFirstChild("Assets")
                        folder = folder and folder:FindFirstChild("Coin Hunt")
                        folder = folder and folder:FindFirstChild("Coins")
                        if folder then
                            for _, item in pairs(folder:GetChildren()) do
                                if not getgenv().ayaSeenCoins[item] then
                                    getgenv().ayaSeenCoins[item] = true
                                    touchPart(item)
                                end
                            end
                        end
                    end
                end)
            end
        }, "AutoCollect")
        tab:CreateToggle({
            Name = "instant-eat pancake",
            Description = "continuously fires the pancake ClickDetector and removes AntiAutoclick protection.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().autoEatPancake = Value
                if not Value then return end
                notif("pancake", "auto on", 1)
                task.spawn(function()
                    while getgenv().autoEatPancake do
                        task.wait(0.5)
                        local ps = game:GetService("Players").LocalPlayer.PlayerScripts
                        local sps = game:GetService("StarterPlayer").StarterPlayerScripts
                        if ps:FindFirstChild("AntiAutoclick") then ps.AntiAutoclick:Destroy() end
                        if sps:FindFirstChild("AntiAutoclick") then sps.AntiAutoclick:Destroy() end
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v.Name == game.Players.LocalPlayer.Name and v:FindFirstChild("ClickDetector") then
                                fireclickdetector(v.ClickDetector)
                            end
                        end
                    end
                end)
            end
        })
        tab:CreateToggle({
            Name = "win blockpush!",
            Description = "teleports you and the box onto the finish pad.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().autoBlockPush = Value
                if not Value then return end
                notif("blockpush", "auto on", 1)
                task.spawn(function()
                    while getgenv().autoBlockPush do
                        task.wait(0.3)
                        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if not root then continue end
                        local finish = nil
                        local a = workspace:FindFirstChild("Assets")
                        if a then
                            for _, challenge in ipairs(a:GetChildren()) do
                                local f = challenge:FindFirstChild("Finish")
                                if f and f:IsA("BasePart") then finish = f; break end
                            end
                        end
                        local box = nil
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if v:IsA("BasePart") and v.Name == "SingularBox" and (v.Position - root.Position).Magnitude <= 200 then
                                box = v; break
                            end
                        end
                        if finish and box then
                            local targetPos = finish.Position + Vector3.new(0, 2, 0)
                            box.CFrame = CFrame.new(targetPos)
                            root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                        elseif finish then
                            root.CFrame = finish.CFrame + Vector3.new(0, 3, 0)
                        end
                    end
                end)
            end
        })
        tab:CreateToggle({
            Name = "detect exploiters",
            Description = "scans everyone for abnormal WalkSpeed/JumpPower and logs them.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().detectExploiters = Value
                if not Value then return end
                notif("detector", "on", 1)
                task.spawn(function()
                    while getgenv().detectExploiters do
                        task.wait(3)
                        for _, pl in pairs(game:GetService("Players"):GetPlayers()) do
                            local character = pl.Character
                            if character then
                                local humanoid = character:FindFirstChildOfClass("Humanoid")
                                if humanoid and (humanoid.WalkSpeed > 16 or humanoid.JumpPower > 50) then
                                    ayaLog(pl.Name .. " - Abnormal Movement")
                                end
                            end
                        end
                    end
                end)
            end
        })
        tab:CreateToggle({
            Name = "dodgeball/paintball protection",
            Description = "infinite Health with a HealthChanged guard. don't reset while it's on.",
            CurrentValue = false,
            Callback = function(Value)
                if Value then
                    local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                    local humanoid = character:WaitForChild("Humanoid")
                    getgenv().dodgeballProtect = true
                    humanoid.MaxHealth = math.huge
                    humanoid.Health = math.huge
                    getgenv().dodgeballConn = humanoid.HealthChanged:Connect(function(health)
                        if getgenv().dodgeballProtect and health < math.huge then humanoid.Health = math.huge end
                    end)
                    notif("dodgeball", "protection on", 1)
                else
                    getgenv().dodgeballProtect = false
                    if getgenv().dodgeballConn then getgenv().dodgeballConn:Disconnect(); getgenv().dodgeballConn = nil end
                    local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid.MaxHealth = 100; humanoid.Health = 100 end
                    notif("dodgeball", "protection off", 1)
                end
            end
        })
        tab:CreateToggle({
            Name = "spleef",
            Description = "auto-touches every spleef block. freezes you in place while active.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().autoSpleef = Value
                if not Value then
                    local char = game.Players.LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.Anchored = false end
                    getgenv().spleefAnchored = nil
                    getgenv().spleefAnchorCFrame = nil
                    notif("spleef", "unfrozen", 1)
                    return
                end
                getgenv().ayaSeenSpleef = {}
                getgenv().ayaSpleefCount = 0
                getgenv().ayaLastSpleefSummary = tick()
                local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart")
                getgenv().spleefAnchorCFrame = hrp.CFrame
                getgenv().spleefAnchored = true
                hrp.Anchored = true
                notif("spleef", "frozen + breaking blocks", 1)
                task.spawn(function()
                    while getgenv().autoSpleef do
                        task.wait(0.4)
                        pcall(function()
                            if getgenv().spleefAnchored and getgenv().spleefAnchorCFrame then
                                local c = game.Players.LocalPlayer.Character
                                local r = c and c:FindFirstChild("HumanoidRootPart")
                                if r then r.Anchored = true; r.CFrame = getgenv().spleefAnchorCFrame end
                            end
                            local blocks = workspace.Assets.Spleef.Spleef.SpleefBlocks
                            for _, v in pairs(blocks:GetChildren()) do
                                if not getgenv().ayaSeenSpleef[v] then
                                    getgenv().ayaSeenSpleef[v] = true
                                    getgenv().ayaSpleefCount = getgenv().ayaSpleefCount + 1
                                    touchPart(v)
                                end
                            end
                        end)
                        if tick() - getgenv().ayaLastSpleefSummary >= 5 then
                            getgenv().ayaLastSpleefSummary = tick()
                            ayaLog("spleef broke " .. tostring(getgenv().ayaSpleefCount) .. " blocks")
                        end
                    end
                end)
            end
        })
        tab:CreateToggle({
            Name = "math mania",
            Description = "auto-fills every visible Math Mania answer box with the correct answer.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().autoMathMania = Value
                if not Value then return end
                notif("math mania", "auto on", 1)
                task.spawn(function()
                    while getgenv().autoMathMania do
                        task.wait(0.4)
                        pcall(function()
                            for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.MathMania:GetChildren()) do
                                if v:FindFirstChild("Answer") and v:FindFirstChild("Box") then
                                    if v.Box.Text ~= v.Answer.Value then v.Box.Text = v.Answer.Value end
                                end
                            end
                        end)
                    end
                end)
            end
        })
    end

    if lib.isMovies then
        tab:CreateToggle({
            Name = "remove the annoying monster",
            Description = "destroys every MonsterNPC in the Alien map.",
            CurrentValue = false,
            Callback = function(Value)
                if not Value then return end
                for _, v in pairs(workspace.Assets:GetDescendants()) do
                    if v.Name == "MonsterNPC" then v:Destroy() end
                end
                notif("monster", "removed", 1)
            end
        })
        tab:CreateToggle({
            Name = "instant-eat-bowl",
            Description = "auto-fires the bowl ClickDetector under your name.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().autoEatBowl = Value
                if not Value then return end
                notif("bowl", "auto on", 1)
                task.spawn(function()
                    while getgenv().autoEatBowl do
                        task.wait(0.5)
                        for _, v in pairs(game.Workspace:GetDescendants()) do
                            if v.Name == game.Players.LocalPlayer.Name and v:FindFirstChild("ClickDetector") then
                                fireclickdetector(v.ClickDetector)
                            end
                        end
                    end
                end)
            end
        })
        tab:CreateToggle({
            Name = "auto collect egg",
            Description = "moves the Alien egg to your position every frame.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().autoEgg = Value
                if not Value then return end
                notif("egg", "auto on", 1)
                task.spawn(function()
                    while getgenv().autoEgg do
                        task.wait(0.3)
                        local alien = workspace.Assets:FindFirstChild("Alien")
                        if alien then
                            for _, v in pairs(alien:GetDescendants()) do
                                if v:IsA("TextLabel") then
                                    local playerEntry = game.ReplicatedStorage.Season.Players:FindFirstChild(game.Players.LocalPlayer.Name)
                                    if playerEntry and v.Text == playerEntry.Value then
                                        local target = v.Parent.Parent.Parent
                                        if target:IsA("BasePart") then
                                            target.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                                            target.CanCollide = false
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        })
        tab:CreateToggle({
            Name = "win the pirate challenge",
            Description = "auto-teleports to the MainKey and then to the win pad in a loop.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().autoPirate = Value
                if not Value then return end
                notif("pirate", "auto on", 1)
                task.spawn(function()
                    while getgenv().autoPirate do
                        task.wait(0.5)
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v.Name == "MainKey" then
                                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    if v:IsA("BasePart") then hrp.CFrame = v.CFrame
                                    elseif v:IsA("Model") then hrp.CFrame = v:GetPivot() end
                                end
                                task.wait(0.1)
                            end
                        end
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v.Name == "win" and v:IsA("BasePart") then
                                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then hrp.CFrame = v.CFrame end
                            end
                        end
                    end
                end)
            end
        })
        tab:CreateToggle({
            Name = "kill everyone in beach",
            Description = "clones the pool noodle tool and auto-attacks every other player.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().autoBeachKill = Value
                if not Value then return end
                notif("beach", "auto kill on", 1)
                task.spawn(function()
                    while getgenv().autoBeachKill do
                        task.wait(0.5)
                        pcall(function()
                            local p = game.Players.LocalPlayer
                            local character = p.Character or p.CharacterAdded:Wait()
                            local hrp = character:FindFirstChild("HumanoidRootPart")
                            if not hrp then return end
                            local gear = game.ReplicatedStorage:FindFirstChild("Gear")
                            if gear then
                                for _, v in pairs(gear:GetChildren()) do
                                    if string.lower(v.Name):find("pool") or string.lower(v.Name):find("noodle") then
                                        local mytool = v:Clone(); mytool.Parent = p.Backpack
                                        if mytool.Equip then mytool:Equip() end
                                        break
                                    end
                                end
                            end
                            local tool = character:FindFirstChildOfClass("Tool") or p.Backpack:FindFirstChildOfClass("Tool")
                            if tool and (string.lower(tool.Name):find("pool") or string.lower(tool.Name):find("noodle")) then
                                if tool.Parent ~= character then tool.Parent = character end
                                for _, targetPlayer in pairs(game.Players:GetPlayers()) do
                                    if targetPlayer ~= p and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                        local targetHRP = targetPlayer.Character.HumanoidRootPart
                                        local targetHum = targetPlayer.Character:FindFirstChild("Humanoid")
                                        hrp.CFrame = CFrame.lookAt(targetHRP.Position - targetHRP.CFrame.LookVector * 3, targetHRP.Position)
                                        task.wait()
                                        for _ = 1, 25 do
                                            if not getgenv().autoBeachKill then break end
                                            if not targetPlayer.Character or not targetPlayer.Character.Parent or (targetHum and targetHum.Health <= 0) then break end
                                            hrp.CFrame = CFrame.lookAt(targetHRP.Position - targetHRP.CFrame.LookVector * 3, targetHRP.Position)
                                            task.wait(0.05)
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end)
            end
        })
        tab:CreateToggle({
            Name = "get prehistoric coins",
            Description = "teleports every Coin in the prehistoric map to your position.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().collectPrehistoricCoins = Value
                if not Value then return end
                notif("coins", "on", 1)
                task.spawn(function()
                    while getgenv().collectPrehistoricCoins do
                        task.wait(0.05)
                        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            for _, v in pairs(workspace.Assets:GetDescendants()) do
                                if v.Name == "Coin" and v:IsA("BasePart") then
                                    v.Transparency = 1; v.CanCollide = false; v.Position = root.Position
                                end
                            end
                        end
                    end
                end)
            end
        }, "GetPrehistoricCoins")
        tab:CreateToggle({
            Name = "get guitars",
            Description = "teleports every Gem and Coin in the map to your position.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().collectGuitars = Value
                if not Value then return end
                notif("guitars", "on", 1)
                task.spawn(function()
                    while getgenv().collectGuitars do
                        task.wait(0.05)
                        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            for _, v in pairs(workspace:GetDescendants()) do
                                if (v.Name == "Gem" or v.Name == "Coin") and v:IsA("BasePart") then
                                    v.Transparency = 1; v.Position = root.Position
                                end
                            end
                        end
                    end
                end)
            end
        }, "GetGuitars")
    end

    if lib.isExpedition then
        tab:CreateToggle({
            Name = "win hawaii",
            Description = "auto-fires every Tiki ClickDetector to instantly complete the Hawaii challenge.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().autoHawaii = Value
                if not Value then return end
                notif("hawaii", "auto on", 1)
                task.spawn(function()
                    while getgenv().autoHawaii do
                        task.wait(0.5)
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v.Name == "Tiki" and v:FindFirstChild("ClickDetector") then
                                for _ = 1, 10 do fireclickdetector(v.ClickDetector) end
                            end
                        end
                    end
                end)
            end
        })
        tab:CreateToggle({
            Name = "get clovers",
            Description = "teleports every Gem and Coin in the expedition map to your position.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().collectClovers = Value
                if not Value then return end
                notif("clovers", "on", 1)
                task.spawn(function()
                    while getgenv().collectClovers do
                        task.wait(0.05)
                        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            for _, v in pairs(workspace:GetDescendants()) do
                                if (v.Name == "Gem" or v.Name == "Coin") and v:IsA("BasePart") then
                                    v.Transparency = 1; v.Position = root.Position
                                end
                            end
                        end
                    end
                end)
            end
        }, "GetClovers")
        tab:CreateToggle({
            Name = "get rings",
            Description = "teleports the RingHitbox of each Coin and Gem in Maldives to your position.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().collectRings = Value
                if not Value then return end
                notif("rings", "on", 1)
                task.spawn(function()
                    while getgenv().collectRings do
                        task.wait(0.05)
                        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if not root then continue end
                        local a = workspace:FindFirstChild("Assets")
                        local maldives = a and a:FindFirstChild("Maldives")
                        local coins = maldives and maldives:FindFirstChild("Coins")
                        if not coins then continue end
                        local coinHitbox = coins:FindFirstChild("Coin") and coins.Coin:FindFirstChild("RingHitbox")
                        local gemHitbox = coins:FindFirstChild("Gem") and coins.Gem:FindFirstChild("RingHitbox")
                        if coinHitbox and coinHitbox:IsA("BasePart") then coinHitbox.Position = root.Position end
                        if gemHitbox and gemHitbox:IsA("BasePart") then gemHitbox.Position = root.Position end
                    end
                end)
            end
        }, "GetRings")
        tab:CreateToggle({
            Name = "break amazon",
            Description = "auto-touches every SpleefPart in the Amazon challenge.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().breakAmazon = Value
                if not Value then return end
                getgenv().ayaSeenAmazon = {}
                notif("amazon", "breaking", 1)
                task.spawn(function()
                    while getgenv().breakAmazon do
                        task.wait(0.3)
                        local a = workspace:FindFirstChild("Assets")
                        if a then
                            for _, v in pairs(a:GetDescendants()) do
                                if v.Name == "SpleefPart" and v:IsA("BasePart") and not getgenv().ayaSeenAmazon[v] then
                                    getgenv().ayaSeenAmazon[v] = true
                                    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        firetouchinterest(hrp, v, 0)
                                        task.wait()
                                        firetouchinterest(hrp, v, 1)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        })
        tab:CreateToggle({
            Name = "auto win cheese",
            Description = "auto-teleports you to the CheesePush Finish pad in a loop.",
            CurrentValue = false,
            Callback = function(Value)
                getgenv().autoCheese = Value
                if not Value then return end
                notif("cheese", "auto on", 1)
                task.spawn(function()
                    while getgenv().autoCheese do
                        task.wait(0.3)
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if v:IsA("BasePart") and v.Name == "Cheese" then
                                local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if root and (v.Position - root.Position).Magnitude <= 100 then
                                    local a = workspace:FindFirstChild("Assets")
                                    local france = a and a:FindFirstChild("France")
                                    local cheesePush = france and france:FindFirstChild("CheesePush")
                                    local finish = cheesePush and cheesePush:FindFirstChild("Finish")
                                    if finish then
                                        local target = finish:GetChildren()[4]
                                        if target then
                                            local part = target:IsA("BasePart") and target or target:FindFirstChildWhichIsA("BasePart", true)
                                            if part then
                                                local tpPos = part.Position + Vector3.new(0, 3, 0)
                                                v.Position = tpPos
                                                root.CFrame = CFrame.new(tpPos)
                                            end
                                        end
                                    end
                                    break
                                end
                            end
                        end
                    end
                end)
            end
        })
    end
end
