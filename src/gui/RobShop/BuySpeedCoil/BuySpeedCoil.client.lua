local replicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.MouseButton1Click:Connect(function(player)
    local promptId = 25148838
    replicatedStorage.Purchase:FireServer(promptId)
end)
