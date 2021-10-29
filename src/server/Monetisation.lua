-- monetisation functions

local playerService = game:GetService("Players")
local dataService = game:GetService("DataStoreService")
local collectionService = game:GetService("CollectionService")
local insertService = game:GetService("InsertService")
local marketService = game:GetService("MarketplaceService")
local dataMod = require(script.Parent.Data)
local PurchaseHistory = dataService:GetDataStore("PurchaseHistory")
local monetisationMod = {}

monetisationMod.insertTool = function(player, assetId)
    -- load and insert gears from the website
    local asset = insertService:LoadAsset(assetId)
    local tool = asset:FindFirstChildOfClass("Tool")
    tool.Parent = player.Backpack
    asset:Destroy()
end
--[[
monetisationMod[000000] = function(player)
    -- add badges for purchase

    --tool 1
    monetisationMod.insertTool(player, 00000000)
end

monetisationMod[000000] = function(player)
    -- add badges for purchase

    --tool 2
    monetisationMod.insertTool(player, 00000000)
end

monetisationMod[000000] = function(player)
    -- add badges for purchase

    --tool 3
    monetisationMod.insertTool(player, 00000000)
end
]]
monetisationMod[000000] = function(player)
    -- add badges for purchase

    --100 coins
    dataMod.increment(player, "Coins", 100)
end


marketService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
    -- detect when player has finished interacting with the prompt
    -- and if they have purchased an item
    if wasPurchased then
        collectionService:AddTag(player, gamePassId)
        monetisationMod[gamePassId](player)
    end
end)

function marketService.ProcessReceipt(receiptInfo)
    -- check that product was granted successfully
    local playerProductKey = receiptInfo.PlayerId .. ":" .. receiptInfo.PurchaseId

    if PurchaseHistory:GetAsync(playerProductKey) then
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    local player = playerService:GetPlayerByUserId(receiptInfo.PlayerId)

    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    PurchaseHistory:SetAsync(playerProductKey, true)

    return Enum.ProductPurchaseDecision.PurchaseGranted
end

marketService.PromptProductPurchaseFinished:Connect(function(playerId, productId, wasPurchased)
    -- fire an event when a product prompt is closed
    if wasPurchased then
        local player = playerService:GetPlayerByUserId(playerId)
        monetisationMod[productId](player)
    end
end)

return monetisationMod