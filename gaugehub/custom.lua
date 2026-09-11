return function(lib)
    local CustomTab = lib.Window:CreateTab({Name = "custom", Icon = "extension", ImageSource = "Material", ShowTitle = true})
    lib.tabs.custom = CustomTab
    lib.installFeatureTracker(CustomTab, "custom")
    CustomTab:CreateLabel({Text = "custom features u ask the ai for (e.g, make me fly)", Style = 1})
end
