local replicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.MouseButton1Click:Connect(function(player)
    local promptId = 1217942198
    replicatedStorage.Purchase:FireServer(promptId)
end)

replicatedStorage.PromptSkip.OnClientEvent:Connect(function(player)
    -- when a player dies enough times on a stage, show prompt to skip
    
        
            script.Parent.Parent.Parent.Enabled = true
        
    
end)