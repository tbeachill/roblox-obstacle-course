local replicatedStorage = game:GetService("ReplicatedStorage")

replicatedStorage.VIPTeleport.OnClientEvent:Connect(function(player)
    script.Parent.Visible = true
    script.Parent.Active = true
    script.Parent.Selectable = true
end)

script.Parent.MouseButton1Click:Connect(function(player)
    if script.Parent.Image == "rbxassetid://8071468278" then
        -- teleport to VIP area
        replicatedStorage.Teleport:FireServer(true)
        script.Parent.Image = "rbxassetid://8071468076"
        script.Parent.HoverImage = "rbxassetid://8071490884"
    else
        -- teleport to stage
        replicatedStorage.Teleport:FireServer(false)
        script.Parent.Image = "rbxassetid://8071468278"
        script.Parent.HoverImage = "rbxassetid://8071491053"
    end
end)