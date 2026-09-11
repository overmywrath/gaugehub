return function(lib)
    if not lib.isCamp then return end
    local tab = lib.Window:CreateTab({Name = "character", Icon = "face", ImageSource = "Material", ShowTitle = true})
    lib.tabs.character = tab
    lib.installFeatureTracker(tab, "character", "camp")
    local notif = lib.notif
    local VerifiedIcon = lib.VerifiedIcon
    local DeveloperIcon = lib.DeveloperIcon

    tab:CreateLabel({Text = "any name works and bypasses the # chat filter (all costs 60 coins).", Style = 1})
    tab:CreateInput({
        Name = "custom character",
        Description = "type any character name and press Enter to send it.",
        PlaceholderText = "character name",
        CurrentValue = "",
        Enter = true,
        Callback = function(Text)
            if game.Players.LocalPlayer.DataStore.Coins.Value > 59 then
                game.ReplicatedStorage.Events.Buy:FireServer("Character", Text)
                notif("character", "sent: " .. Text, 1)
            else
                notif("character", "you need 60 coins", 2)
            end
        end
    }, "CustomCharacter")
    tab:CreateInput({
        Name = "custom character with verified",
        Description = "same as custom character but appends the verified checkmark.",
        PlaceholderText = "character name",
        CurrentValue = "",
        Enter = true,
        Callback = function(Text)
            if game.Players.LocalPlayer.DataStore.Coins.Value > 59 then
                game.ReplicatedStorage.Events.Buy:FireServer("Character", Text .. VerifiedIcon())
                notif("character", "sent: " .. Text, 1)
            else
                notif("character", "you need 60 coins", 2)
            end
        end
    }, "CustomCharacterVerified")
    tab:CreateInput({
        Name = "custom character with moderator",
        Description = "same as custom character but appends [Moderator] to look like staff.",
        PlaceholderText = "character name",
        CurrentValue = "",
        Enter = true,
        Callback = function(Text)
            if game.Players.LocalPlayer.DataStore.Coins.Value > 59 then
                game.ReplicatedStorage.Events.Buy:FireServer("Character", Text .. DeveloperIcon())
                notif("character", "sent: " .. Text, 1)
            else
                notif("character", "you need 60 coins", 2)
            end
        end
    }, "CustomCharacterDeveloper")
    tab:CreateToggle({
        Name = "fake mojo",
        Description = "buys Mojo with the verified checkmark.",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            if game.Players.LocalPlayer.DataStore.Coins.Value > 59 then
                game.ReplicatedStorage.Events.Buy:FireServer("Character", "Mojo" .. VerifiedIcon())
                notif("mojo", "fake mojo sent", 1)
            else
                notif("mojo", "you need 60 coins", 2)
            end
        end
    }, "MojoVerified")
    tab:CreateToggle({
        Name = "server crash comeback",
        Description = "sends a character designed to lag the game when your name is mentioned.",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            if game.Players.LocalPlayer.DataStore.Coins.Value > 59 then
                local success = pcall(function()
                    game.ReplicatedStorage.Events.Buy:FireServer("Character", returnFucker())
                end)
                notif("comeback", success and "game-breaking character sent" or "comeback failed", success and 1 or 2)
            else
                notif("comeback", "you need 60 coins", 2)
            end
        end
    }, "LagCharacter")
    tab:CreateInput({
        Name = "comeback 2",
        Description = "type any name and press Enter, that'll be ur username next comeback",
        PlaceholderText = "character name",
        CurrentValue = "",
        Enter = true,
        Callback = function(Text)
            if game.Players.LocalPlayer.DataStore.Coins.Value > 59 then
                game.ReplicatedStorage.Events.Buy:FireServer("Character", Text)
                notif("comeback 2", "sent: " .. Text, 1)
            else
                notif("comeback 2", "you need 60 coins", 2)
            end
        end
    }, "Comeback2")
    tab:CreateDivider()
    tab:CreateLabel({Text = "free comeback options", Style = 1})
    tab:CreateToggle({
        Name = "male character",
        Description = "youll be named 'Male' next comeback.",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            game.ReplicatedStorage.Events.Buy:FireServer("Gender", "Male")
            notif("gender", "male set", 1)
        end
    })
    tab:CreateToggle({
        Name = "female character",
        Description = "youll be named 'Female' next comeback.",
        CurrentValue = false,
        Callback = function(Value)
            if not Value then return end
            game.ReplicatedStorage.Events.Buy:FireServer("Gender", "Female")
            notif("gender", "female set", 1)
        end
    })
end
