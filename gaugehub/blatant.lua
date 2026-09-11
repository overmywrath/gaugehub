return function(lib)
    local tab = lib.Window:CreateTab({Name = "blatant", Icon = "dangerous", ImageSource = "Material", ShowTitle = true})
    lib.tabs.blatant = tab
    lib.installFeatureTracker(tab, "blatant")
    local notif = lib.notif
    local wsLocalPlayer = lib.wsLocalPlayer

    tab:CreateToggle({
        Name = "no clip",
        Description = "sets every part of your character to non-collidable.",
        CurrentValue = false,
        Callback = function(Value)
            getgenv().utilityNoclip = Value
            notif("noclip", Value and "on" or "off", 1)
        end
    }, "UtilityNoclip")
    tab:CreateToggle({
        Name = "reset character",
        Description = "instantly kills your character.",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            local humanoid = wsLocalPlayer.Character and wsLocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.Health = 0; notif("reset", "respawning", 1) end
        end
    })
    tab:CreateToggle({
        Name = "god mode",
        Description = "client-side infinite health.",
        CurrentValue = false,
        Callback = function(Value)
            getgenv().godMode = Value
            notif("god mode", Value and "on" or "off", 1)
        end
    }, "GodMode")
    tab:CreateToggle({
        Name = "find statue",
        Description = "teleports you to the safety statue.",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            local idols = workspace:FindFirstChild("Idols")
            local statue = idols and idols:FindFirstChild("SafetyStatue")
            local hit = statue and statue:FindFirstChild("hit")
            local root = wsLocalPlayer.Character and wsLocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hit and root then root.CFrame = hit.CFrame; notif("statue", "found", 1)
            else notif("statue", "not found", 2) end
        end
    })
    tab:CreateToggle({
        Name = "find bag",
        Description = "teleports you to the idol bag.",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            local idols = workspace:FindFirstChild("Idols")
            local bag = idols and idols:FindFirstChild("Bag")
            local hit = bag and bag:FindFirstChild("hit")
            local root = wsLocalPlayer.Character and wsLocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hit and root then root.CFrame = hit.CFrame; notif("bag", "found", 1)
            else notif("bag", "not found", 2) end
        end
    })
    tab:CreateToggle({
        Name = "find challenge finish",
        Description = "teleports you to the first challenge finish pad found.",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            local a = workspace:FindFirstChild("Assets")
            local root = wsLocalPlayer.Character and wsLocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if a and root then
                for _, challenge in ipairs(a:GetChildren()) do
                    local finish = challenge:FindFirstChild("Finish")
                    if finish and finish:IsA("BasePart") then root.CFrame = finish.CFrame; notif("finish", "teleported", 1); break end
                end
            end
        end
    })

    lib.RunService.Stepped:Connect(function()
        if getgenv().utilityNoclip then
            local character = wsLocalPlayer.Character
            if character then
                for _, object in ipairs(character:GetDescendants()) do
                    if object:IsA("BasePart") then object.CanCollide = false end
                end
            end
        end
        if getgenv().godMode then
            local character = wsLocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.MaxHealth = math.huge; humanoid.Health = math.huge end
        end
    end)
end