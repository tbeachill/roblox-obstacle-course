local replicatedStorage = game:GetService("ReplicatedStorage")

buttonGuiMod = {}
buttonGroups = {"OpenShop"}

buttonGuiMod.shopClick = function()
    if script.Parent.Shop.Enabled == false then
        script.Parent.Shop.Enabled = true
    else
        script.Parent.Shop.Enabled = false
    end
end

buttonGuiMod.skipStageClick = function(player, promptId)
    replicatedStorage.Purchase:FireServer(promptId)
end


return buttonGuiMod