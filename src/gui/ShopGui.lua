local replicatedStorage = game:GetService("ReplicatedStorage")
shopGuiMod = {}

shopGuiMod.closeClick = function()
    script.Parent.Shop.Enabled = false
end

shopGuiMod.purchaseClick = function(player, promptId)
    replicatedStorage.Purchase:FireServer(promptId)
end

return shopGuiMod