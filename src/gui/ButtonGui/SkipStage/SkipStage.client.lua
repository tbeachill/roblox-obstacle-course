local replicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.MouseButton1Click:Connect(function(player)
    local promptId = 1217942198
    replicatedStorage.Purchase:FireServer(promptId)
end)