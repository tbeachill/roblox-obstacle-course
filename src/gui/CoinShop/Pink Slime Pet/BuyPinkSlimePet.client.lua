local replicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.MouseButton1Click:Connect(function(player)
    local promptId = "Pink Slime Pet"
    replicatedStorage.CoinPurchase:FireServer(promptId) 
end)

replicatedStorage.NotEnoughCoins.OnClientEvent:Connect(function(player)
    script.Parent.Parent.NotEnoughCoins.Enabled = true
end)