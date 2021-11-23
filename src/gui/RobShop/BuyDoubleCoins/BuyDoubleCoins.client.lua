local replicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.MouseButton1Click:Connect(function(player)
    local gamePassId = 25148318
    replicatedStorage.GamePassPurchase:FireServer(gamePassId)
end)

