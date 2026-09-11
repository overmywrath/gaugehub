return function(lib)
    if not lib.isCamp then return end
    local tab = lib.Window:CreateTab({Name = "main", Icon = "view_in_ar", ImageSource = "Material", ShowTitle = true})
    lib.tabs.camp_main = tab
    lib.installFeatureTracker(tab, "main", "camp")
    local notif = lib.notif
    local touchPart = lib.touchPart
    local ReplicatedStorage = lib.wsReplicatedStorage

    getgenv().usernameEnabled = false
    getgenv().usernameOriginals = getgenv().usernameOriginals or {}
    getgenv().usernameConns = getgenv().usernameConns or {}
    getgenv().usernamePlayerAddedConn = nil

    local function applyUsernameTag(plr)
        if not getgenv().usernameEnabled then return end
        task.spawn(function()
            for _ = 1, 30 do
                if not getgenv().usernameEnabled then return end
                local char = plr.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    if head then
                        local nameTag = head:FindFirstChild("NameGUI")
                        if nameTag then
                            local sector = nameTag:FindFirstChild("Sector")
                            if sector then
                                local nameLbl = sector:FindFirstChild("name")
                                if nameLbl and nameLbl:IsA("TextLabel") then
                                    if not getgenv().usernameOriginals[nameLbl] then
                                        getgenv().usernameOriginals[nameLbl] = nameLbl.Text
                                    end
                                    local orig = getgenv().usernameOriginals[nameLbl]
                                    if not nameLbl.Text:find("%(" .. plr.Name .. "%)") then
                                        nameLbl.Text = orig .. " (" .. plr.Name .. ")"
                                    end
                                    return
                                end
                            end
                        end
                    end
                end
                task.wait(0.2)
            end
        end)
    end

    local function watchPlayer(plr)
        if getgenv().usernameConns[plr] then
            pcall(function() getgenv().usernameConns[plr]:Disconnect() end)
        end
        local conn = plr.CharacterAdded:Connect(function()
            if getgenv().usernameEnabled then applyUsernameTag(plr) end
        end)
        getgenv().usernameConns[plr] = conn
        applyUsernameTag(plr)
    end

    tab:CreateToggle({
        Name = "show usernames",
        Description = "appends each player's username to their name tag above their head. persists through respawns.",
        CurrentValue = false,
        Callback = function(Value)
            getgenv().usernameEnabled = Value
            if Value then
                for _, plr in ipairs(game.Players:GetPlayers()) do watchPlayer(plr) end
                if not getgenv().usernamePlayerAddedConn then
                    getgenv().usernamePlayerAddedConn = game.Players.PlayerAdded:Connect(function(plr)
                        if getgenv().usernameEnabled then watchPlayer(plr) end
                    end)
                end
                notif("usernames", "on", 1)
            else
                for lbl, txt in pairs(getgenv().usernameOriginals) do
                    if lbl and lbl.Parent then lbl.Text = txt end
                end
                for _, conn in pairs(getgenv().usernameConns) do
                    pcall(function() conn:Disconnect() end)
                end
                getgenv().usernameConns = {}
                if getgenv().usernamePlayerAddedConn then
                    pcall(function() getgenv().usernamePlayerAddedConn:Disconnect() end)
                    getgenv().usernamePlayerAddedConn = nil
                end
                notif("usernames", "off", 1)
            end
        end
    })
    tab:CreateToggle({
        Name = "jesus mode",
        Description = "toggles collision on the camp lake water so you can walk on it.",
        CurrentValue = false,
        Callback = function(Value)
            workspace.Map["Roblox Drama: Camp"].Map.Lake.Water.CanCollide = Value
            notif("jesus mode", Value and "on" or "off", 1)
        end
    }, "JesusMode")
    tab:CreateToggle({
        Name = "water god mode",
        Description = "destroys the underwater damage trigger so you can stay submerged without damage.",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            workspace.Map["Roblox Drama: Camp"].Sand.TouchInterest:Destroy()
            notif("water god", "on", 1)
        end
    })
    tab:CreateToggle({
        Name = "destroy barriers",
        Description = "removes all glass barriers and the campfire touch trigger.",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            if workspace:FindFirstChild("Glass") then
                for _, v in pairs(workspace.Glass:GetChildren()) do
                    if v:IsA("BasePart") then v:Destroy() end
                end
                local campfire = workspace.Glass:FindFirstChild("Campfire")
                if campfire and campfire:FindFirstChild("TouchInterest") then
                    campfire.TouchInterest:Destroy()
                end
            end
            notif("barriers", "destroyed", 1)
        end
    })
    tab:CreateToggle({
        Name = "notify votes",
        Description = "shows a notification whenever someone casts a vote.",
        CurrentValue = false,
        Callback = function(Value)
            lib.setVoteDetection(Value)
            if Value then
                if not lib.getVoteConnection() then lib.setVoteConnection(lib.monitorVotes()) end
                notif("votes", "notifications on", 1)
            else
                local c = lib.getVoteConnection()
                if c then c:Disconnect(); lib.setVoteConnection(nil) end
                notif("votes", "notifications off", 1)
            end
        end
    }, "NotifyVotes")
    tab:CreateToggle({
        Name = "expose votes",
        Description = "broadcasts every vote to public chat.",
        CurrentValue = false,
        Callback = function(Value)
            lib.setVoteDetection(Value)
            if Value then
                if not lib.getVoteConnection() then lib.setVoteConnection(lib.chatVotes()) end
                notif("votes", "exposing", 1)
            else
                local c = lib.getVoteConnection()
                if c then c:Disconnect(); lib.setVoteConnection(nil) end
                notif("votes", "stopped", 1)
            end
        end
    }, "ExposeVotes")
    tab:CreateToggle({
        Name = "get statue",
        Description = "destroys the glass cage, then touches the bag and safety statue to collect them.",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            local glass = workspace:FindFirstChild("Glass")
            if glass then
                for _, v in pairs(glass:GetChildren()) do
                    if v:IsA("BasePart") then v:Destroy() end
                end
            end
            local bag = workspace.Idols:FindFirstChild("Bag")
            if bag then touchPart(bag:FindFirstChild("hit")) end
            task.wait()
            local idol = workspace.Idols:FindFirstChild("SafetyStatue")
            if idol then touchPart(idol:FindFirstChild("hit")) end
            notif("statue", "collected", 1)
        end
    })
    tab:CreateToggle({
        Name = "who has statue",
        Description = "shows which player currently holds the safety statue.",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            local getValue = ReplicatedStorage.Season.Twists.Idol.Value
            local whoHas = ReplicatedStorage.Season.Players[getValue].Value
            notif("statue", whoHas .. " has the statue", 1)
        end
    })
end