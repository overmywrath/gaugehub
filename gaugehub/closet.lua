return function(lib)
    local tab = lib.Window:CreateTab({Name = "closet", Icon = "dashboard", ImageSource = "Material", ShowTitle = true})
    lib.tabs.closet = tab
    lib.installFeatureTracker(tab, "closet")
    local notif = lib.notif
    local Luna = lib.Luna
    local wsLocalPlayer = lib.wsLocalPlayer
    local ReplicatedStorage = lib.wsReplicatedStorage
    local RunService = lib.RunService

    tab:CreateLabel({Text = "live game information", Style = 1})
    local livePlayersLabel = tab:CreateLabel({Text = "loading...", Style = 1})
    local liveStatueLabel = tab:CreateLabel({Text = "loading...", Style = 1})
    local livePerformanceLabel = tab:CreateLabel({Text = "loading...", Style = 1})
    local totalTimePlayedLabel = tab:CreateLabel({Text = "total time played: 0s", Style = 1})

    local Players2 = game:GetService("Players")
    local localPlayer = Players2.LocalPlayer
    local selectedPlayer = nil
    local fpsFrames = 0
    local fpsValue = 0
    local fpsClock = os.clock()
    local voteFolder
    local sessionStart = os.clock()
    local totalTimePlayed = 0
    local timeFile = nil
    local lastTimeWrite = 0

    local function formatTime(seconds)
        seconds = math.max(0, math.floor(seconds))
        local days = math.floor(seconds / 86400); seconds = seconds % 86400
        local hours = math.floor(seconds / 3600); seconds = seconds % 3600
        local minutes = math.floor(seconds / 60); seconds = seconds % 60
        if days > 0 then return string.format("%dd %02dh %02dm %02ds", days, hours, minutes, seconds)
        elseif hours > 0 then return string.format("%dh %02dm %02ds", hours, minutes, seconds)
        elseif minutes > 0 then return string.format("%dm %02ds", minutes, seconds) end
        return string.format("%ds", seconds)
    end

    if Luna.Folder and writefile and isfile and readfile then
        timeFile = Luna.Folder .. "/settings/total_time_played.txt"
        pcall(function() if isfile(timeFile) then totalTimePlayed = tonumber(readfile(timeFile)) or 0 end end)
    end

    RunService.Heartbeat:Connect(function()
        fpsFrames = fpsFrames + 1
        local now = os.clock()
        if now - fpsClock >= 1 then fpsValue = fpsFrames; fpsFrames = 0; fpsClock = now end
    end)

    local function getVoteFolder()
        local season = ReplicatedStorage:FindFirstChild("Season")
        local voting = season and season:FindFirstChild("Voting")
        return voting and voting:FindFirstChild("Votes")
    end
    voteFolder = getVoteFolder()

    local utilityPlayerDropdown = tab:CreateDropdown({
        Name = "player",
        Options = {"select player"},
        CurrentOption = {"select player"},
        MultipleOptions = false,
        Callback = function(Value)
            selectedPlayer = type(Value) == "table" and Value[1] or Value
            if selectedPlayer == "select player" then selectedPlayer = nil end
        end
    })
    local function refreshUtilityPlayers()
        local options = {}
        for _, target in ipairs(Players2:GetPlayers()) do
            if target ~= localPlayer then table.insert(options, target.Name) end
        end
        table.sort(options)
        pcall(function()
            utilityPlayerDropdown:Set({Options = (#options > 0 and options or {"select player"}), CurrentOption = {(#options > 0 and options[1] or "select player")}})
        end)
    end
    refreshUtilityPlayers()
    Players2.PlayerAdded:Connect(function() task.wait(1); refreshUtilityPlayers() end)
    Players2.PlayerRemoving:Connect(function() task.wait(0.5); refreshUtilityPlayers() end)

    tab:CreateToggle({
        Name = "teleport to player",
        Description = "teleports you directly to the player selected in the dropdown.",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            local target = Players2:FindFirstChild(selectedPlayer or "")
            local character = localPlayer.Character
            local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if targetRoot and root then root.CFrame = targetRoot.CFrame; notif("teleport", "to " .. target.Name, 1) end
        end
    })
    tab:CreateToggle({
        Name = "spectate",
        Description = "switches your camera to the selected player. turn off to return to yourself.",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                local target = Players2:FindFirstChild(selectedPlayer or "")
                if target and target.Character then
                    local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then workspace.CurrentCamera.CameraSubject = humanoid; notif("spectate", "watching " .. target.Name, 1) end
                end
            else
                local character = localPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid then workspace.CurrentCamera.CameraSubject = humanoid; notif("spectate", "off", 1) end
            end
        end
    }, "UtilitySpectate")
    tab:CreateToggle({
        Name = "anti afk",
        Description = "sends a virtual click every second so the game never kicks you for idling.",
        CurrentValue = false,
        Callback = function(Value)
            getgenv().utilityAntiAFK = Value
            notif("anti afk", Value and "on" or "off", 1)
        end
    }, "UtilityAntiAFK")

    task.spawn(function()
        while task.wait(1) do
            local currentVoteFolder = getVoteFolder()
            if currentVoteFolder and currentVoteFolder ~= voteFolder then voteFolder = currentVoteFolder end
            local playerCount = #Players2:GetPlayers()
            local coins = "unknown"
            pcall(function() coins = tostring(localPlayer.DataStore.Coins.Value) end)
            local statueHolder = "unknown"
            pcall(function()
                local season = ReplicatedStorage:FindFirstChild("Season")
                local twists = season and season:FindFirstChild("Twists")
                local idol = twists and twists:FindFirstChild("Idol")
                local playersFolder = season and season:FindFirstChild("Players")
                local playerValue = idol and playersFolder and playersFolder:FindFirstChild(tostring(idol.Value))
                if playerValue then statueHolder = tostring(playerValue.Value) end
            end)
            local ping = "unknown"
            pcall(function() ping = tostring(math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())) .. " ms" end)
            livePlayersLabel:Set("players: " .. tostring(playerCount) .. "\nCoins: " .. coins)
            liveStatueLabel:Set("statue holder: " .. statueHolder)
            livePerformanceLabel:Set("fps: " .. tostring(fpsValue) .. "\nPing: " .. ping)
            local currentTotalTime = totalTimePlayed + (os.clock() - sessionStart)
            totalTimePlayedLabel:Set("Total Time Played: " .. formatTime(currentTotalTime))
            if timeFile and writefile and currentTotalTime - lastTimeWrite >= 30 then
                lastTimeWrite = currentTotalTime
                pcall(function() writefile(timeFile, tostring(math.floor(currentTotalTime))) end)
            end
            if getgenv().utilityAntiAFK then
                pcall(function()
                    if not getgenv().utilityVirtualUser then getgenv().utilityVirtualUser = game:GetService("VirtualUser") end
                    getgenv().utilityVirtualUser:CaptureController()
                    getgenv().utilityVirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end
    end)
end
