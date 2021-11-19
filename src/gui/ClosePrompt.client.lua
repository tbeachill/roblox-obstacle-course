local replicatedStorage = game:GetService("ReplicatedStorage")

replicatedStorage.ClosePrompt.OnClientEvent:Connect(function()
    script.Parent.PromptSkip.Enabled = false
    script.Parent.CoinShop.NotEnoughCoins.Enabled = false
end)