local replicatedStorage = game:GetService("ReplicatedStorage")
shopGuiMod = {}

shopGuiMod.closeClick = function()
    if script.Parent.Shop == true then
        script.Parent.Shop.Enabled = false
    else 
        if script.Parent.CoinShop.Enabled == true then
            script.Parent.CoinShop.Enabled = false
        end
    end
end

shopGuiMod.changeShopClick = function()
    if script.Parent.CoinShop.Enabled == true then
        script.Parent.CoinShop.Enabled = false
        script.Parent.Shop.Enabled = true
    else
        script.Parent.CoinShop.Enabled = true
        script.Parent.Shop.Enabled = false
    end
    
end

shopGuiMod.purchaseClick = function(player, promptId)
    replicatedStorage.Purchase:FireServer(promptId)
end

shopGuiMod.coinPurchaseClick = function(player, itemName)
    replicatedStorage.CoinPurchase:FireServer(itemName)
end


return shopGuiMod