return function(lib)
    if not lib.isExpedition then return end
    local tab = lib.Window:CreateTab({Name = "expedition", Icon = "airplay", ImageSource = "Material", ShowTitle = true})
    lib.tabs.expedition = tab
    lib.installFeatureTracker(tab, "expedition", "expedition")
    local notif = lib.notif
    local wsLocalPlayer = lib.wsLocalPlayer

    tab:CreateSection("misc")
    tab:CreateToggle({
        Name = "teleport to expedition lobby",
        Description = "instant teleport back to the expedition lobby (use during meatball).",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            local root = wsLocalPlayer.Character and wsLocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = CFrame.new(-77, -28, -904); notif("teleport", "to expedition lobby", 1) end
        end
    })
end