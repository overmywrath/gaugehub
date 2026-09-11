local function notif(title, text, type)
    local notifiSound
    local notifiIcon
    local color
    if type == 1 then
        notifiSound = "rbxassetid://97881181065416"
        notifiIcon = "rbxassetid://6023426926"
        color = Color3.fromRGB(72, 199, 142)
    elseif type == 2 then
        notifiSound = "rbxassetid://91730465068215"
        notifiIcon = "rbxassetid://17182092132"
        color = Color3.fromRGB(255, 0, 0)
    else
        notifiSound = "rbxassetid://97881181065416"
        notifiIcon = "rbxassetid://6023426926"
        color = Color3.fromRGB(72, 199, 142)
    end
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local playerGui = player:WaitForChild("PlayerGui")
    local function startHamAndCheeseToastie()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "hottoastnotifyznc"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.DisplayOrder = 100
        screenGui.Parent = playerGui
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 80)
        frame.Position = UDim2.new(-1, -20, 0, 20)
        frame.AnchorPoint = Vector2.new(0, 0)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BackgroundTransparency = 0.1
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Parent = screenGui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        local shadow = Instance.new("ImageLabel")
        shadow.Size = UDim2.new(1, 24, 1, 24)
        shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://6014261993"
        shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        shadow.ImageTransparency = 0.5
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(49, 49, 450, 450)
        shadow.ZIndex = -1
        shadow.Parent = frame
        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 4, 1, 0)
        accent.Position = UDim2.new(0, 0, 0, 0)
        accent.BackgroundColor3 = color
        accent.BorderSizePixel = 0
        accent.ZIndex = 2
        accent.Parent = frame
        local accentCorner = Instance.new("UICorner")
        accentCorner.CornerRadius = UDim.new(0, 8)
        accentCorner.Parent = accent
        local contentContainer = Instance.new("Frame")
        contentContainer.Size = UDim2.new(1, -16, 1, 0)
        contentContainer.Position = UDim2.new(0, 16, 0, 0)
        contentContainer.BackgroundTransparency = 1
        contentContainer.Parent = frame
        local iconSize = 20
        local iconContainer = Instance.new("Frame")
        iconContainer.Size = UDim2.new(0, iconSize, 0, iconSize)
        iconContainer.Position = UDim2.new(0, 8, 0, 0.5 * frame.Size.Y.Offset - iconSize/2)
        iconContainer.BackgroundTransparency = 1
        iconContainer.Parent = frame
        local iconImage = Instance.new("ImageLabel")
        iconImage.Size = UDim2.new(1, 0, 1, 0)
        iconImage.BackgroundTransparency = 1
        iconImage.Image = notifiIcon
        iconImage.ImageColor3 = color
        iconImage.Parent = iconContainer
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -40, 0, 24)
        titleLabel.Position = UDim2.new(0, 32, 0, 8)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.TextSize = 16
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.Text = title
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
        titleLabel.Parent = contentContainer
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Size = UDim2.new(1, -40, 1, -48)
        messageLabel.Position = UDim2.new(0, 32, 0, 32)
        messageLabel.BackgroundTransparency = 1
        messageLabel.Font = Enum.Font.SourceSans
        messageLabel.TextSize = 14
        messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        messageLabel.Text = text
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.TextYAlignment = Enum.TextYAlignment.Top
        messageLabel.TextWrapped = true
        messageLabel.Parent = contentContainer
        local progressBarContainer = Instance.new("Frame")
        progressBarContainer.Size = UDim2.new(1, 0, 0, 3)
        progressBarContainer.Position = UDim2.new(0, 0, 1, -3)
        progressBarContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        progressBarContainer.BackgroundTransparency = 0.7
        progressBarContainer.BorderSizePixel = 0
        progressBarContainer.ZIndex = 5
        progressBarContainer.Parent = frame
        local progressBar = Instance.new("Frame")
        progressBar.Size = UDim2.new(1, 0, 1, 0)
        progressBar.BackgroundColor3 = color
        progressBar.BorderSizePixel = 0
        progressBar.ZIndex = 6
        progressBar.Parent = progressBarContainer
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 20, 0, 20)
        }):Play()
        TweenService:Create(progressBar, TweenInfo.new(5, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0)
        }):Play()
        task.delay(5, function()
            TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 20, 0, 20)
            }):Play()
            task.delay(0.5, function() screenGui:Destroy() end)
        end)
        local sound = Instance.new("Sound")
        sound.SoundId = notifiSound
        sound.Volume = 0.5
        sound.Parent = screenGui
        sound:Play()
    end
    if not player.Character then player.CharacterAdded:Wait() end
    startHamAndCheeseToastie()
end

if game.PlaceId ~= 4939362930 then
    notif("gaugehub", "...", 1)
    wait(2)
    notif("gaugehub", "gaugehub only works in total roblox drama", 2)
    return
end

if getgenv().GaugeHubLoaded then return end
getgenv().GaugeHubLoaded = true

local BASE = "https://raw.githubusercontent.com/overmywrath/gaugehub/refs/heads/main/"
local function loadmod(name)
    local ok, result = pcall(function()
        local src = game:HttpGet(BASE .. name .. ".lua", true)
        return loadstring(src)()
    end)
    if not ok then
        warn("[GaugeHub] failed to load module '" .. name .. "': " .. tostring(result))
        return nil
    end
    return result
end

local lib = loadmod("lib")
if not lib then return end
lib.notif = notif

local MODULES = { "search", "custom", "ai", "character", "camp_main", "movies", "expedition", "closet", "blatant", "fun", "auto" }
for _, name in ipairs(MODULES) do
    local fn = loadmod(name)
    if type(fn) == "function" then
        local ok, err = pcall(fn, lib)
        if not ok then warn("[GaugeHub] module '" .. name .. "' errored: " .. tostring(err)) end
    end
end

lib.finishSearch()

task.spawn(function()
    pcall(function()
        local src = game:HttpGet("https://raw.githubusercontent.com/overmywrath/gaugehub/refs/heads/main/bonus/commands.lua", true)
        if src and src ~= "" then
            local fn = loadstring(src)
            if fn then fn() end
        end
    end)
end)

getgenv().GaugeHubReload = function()
    getgenv().GaugeHubLoaded = nil
end
