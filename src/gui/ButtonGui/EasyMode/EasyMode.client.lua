local replicatedStorage = game:GetService("ReplicatedStorage")
local playerService = game:GetService("Players")

replicatedStorage.EasyModeToggle.OnClientEvent:Connect(function(buttonId)
    -- if no button id is providedm display the turn off button, otherwise display the appropriate one
    if buttonId == nil then
        script.Parent.Visible = true
        script.Parent.Active = true
        script.Parent.Selectable = true
    else
        script.Parent.Image = buttonId
        script.Parent.Visible = true
        script.Parent.Active = true
        script.Parent.Selectable = true
    end

end)

script.Parent.MouseButton1Click:Connect(function(player)
    if script.Parent.Image == "rbxassetid://8071468630" then
        script.Parent.Image = "rbxassetid://8071468488"
        replicatedStorage.EasyModeServerToggle:FireServer(player)
    else
        script.Parent.Image = "rbxassetid://8071468630"
        replicatedStorage.EasyModeServerToggle:FireServer(player)
    end
end)