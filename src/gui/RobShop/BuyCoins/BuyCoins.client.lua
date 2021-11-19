local replicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.MouseButton1Click:Connect(function(player)
    local promptId = 1217899753
    replicatedStorage.Purchase:FireServer(promptId)
end)

