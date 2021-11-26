local replicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.MouseButton1Click:Connect(function(player)
    local promptId = 25384019
    replicatedStorage.Purchase:FireServer(promptId)
end)

