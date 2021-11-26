local replicatedStorage = game:GetService("ReplicatedStorage")
local playerService = game:GetService("Players")

script.Parent.MouseButton1Click:Connect(function(player)
    local promptId = 1225857033
    replicatedStorage.Purchase:FireServer(promptId)
end)