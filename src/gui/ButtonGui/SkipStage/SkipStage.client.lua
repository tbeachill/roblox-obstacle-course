local replicatedStorage = game:GetService("ReplicatedStorage")
local playerService = game:GetService("Players")

script.Parent.MouseButton1Click:Connect(function(player)
    if playerService.LocalPlayer.leaderstats.Stage.Value == 100 then
        print(player, "tried to buy skip but at final stage.")
    else
        local promptId = 1225857053
        replicatedStorage.Purchase:FireServer(promptId)
    end
end)