return function(lib)
    local tab = lib.Window:CreateTab({Name = "fun", Icon = "history", ImageSource = "Material", ShowTitle = true})
    lib.tabs.fun = tab
    lib.installFeatureTracker(tab, "fun")
    local notif = lib.notif

    tab:CreateSlider({
        Name = "sword fight reach",
        Description = "sets the reach value used by apply sword fight reach. 0-200 studs.",
        Range = {0, 200}, Increment = 5, CurrentValue = 100,
        Callback = function(Value) getgenv().reach = Value end
    }, "SwordFightReach")
    tab:CreateToggle({
        Name = "apply sword fight reach",
        Description = "stretches your equipped tool's handle to the reach value and re-equips it.",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            local speaker = game.Players.LocalPlayer
            if not speaker.Character then return end
            for _, v in pairs(speaker.Character:GetDescendants()) do
                if v:IsA("Tool") and v:FindFirstChild("Handle") then
                    local handle = v.Handle
                    if not handle:FindFirstChild("SelectionBoxCreated") then
                        local a = Instance.new("SelectionBox")
                        a.Name = "selectionboxcreated"; a.Parent = handle; a.Adornee = handle
                    end
                    handle.Massless = true
                    handle.Size = Vector3.new(0.5, 0.5, getgenv().reach or 60)
                    v.GripPos = Vector3.new(0, 0, 0)
                    speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
                end
            end
            notif("sword", "reach applied", 1)
        end
    })
end
