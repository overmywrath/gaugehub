return function(lib)
    if not lib.isMovies then return end
    local tab = lib.Window:CreateTab({Name = "movies", Icon = "add_to_home_screen", ImageSource = "Material", ShowTitle = true})
    lib.tabs.movies = tab
    lib.installFeatureTracker(tab, "movies", "movies")
    local notif = lib.notif
    local wsLocalPlayer = lib.wsLocalPlayer

    tab:CreateSection("misc")
    tab:CreateToggle({
        Name = "teleport to lobby",
        Description = "instant teleport to the lobby (use during medical or western challenges).",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            local root = wsLocalPlayer.Character and wsLocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = CFrame.new(-684, -70, -637); notif("teleport", "to lobby", 1) end
        end
    })
end