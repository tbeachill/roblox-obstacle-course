-- monetisation functions

local playerService = game:GetService("Players")
local dataService = game:GetService("DataStoreService")
local collectionService = game:GetService("CollectionService")
local insertService = game:GetService("InsertService")
local marketService = game:GetService("MarketplaceService")
local StarterGui = game:GetService("StarterGui")
local replicatedStorage = game:GetService("ReplicatedStorage")
local dataMod = require(script.Parent.Data)
local PurchaseHistory = dataService:GetDataStore("PurchaseHistory")
local monetisationMod = {}
local items = {
    ["Spring Potion"] = {
        Price = 10;
    };
    ["Red Trail"] = {
        Price = 25;
    };
    ["Orange Trail"] = {
        Price = 25;
    };
    ["Blue Trail"] = {
        Price = 25;
    };
    ["Green Trail"] = {
        Price = 25;
    };
    ["Pink Trail"] = {
        Price = 25;
    };
    ["Rainbow Trail"] = {
        Price = 50;
    };
}

replicatedStorage.Purchase.OnServerEvent:Connect(function(player, promptId)
    print(player, promptId)
    marketService:PromptProductPurchase(player, promptId)
end)

replicatedStorage.CoinPurchase.OnServerEvent:Connect(function(player, itemName)
    -- When player purchases an item with coins
    local item = items[itemName]

    if player and dataMod.get(player, "Coins") >= item.Price then
        dataMod.increment(player, "Coins", - item.Price)
        local shopFolder = replicatedStorage.Common.ShopItems

        if shopFolder:FindFirstChild(itemName):IsA("Tool") then -- condition if item is a tool
            local tool = shopFolder:FindFirstChild(itemName):Clone()
            tool.Parent = player.Backpack
        else
            if shopFolder:FindFirstChild(itemName):IsA("Trail") then -- condition if item is a trail
                -- remove any current trails
                local char = player.Character

                for _, part in pairs(char.HumanoidRootPart:GetChildren()) do
                    -- remove any current trails
                    if part:IsA("Trail") then
                        part.Enabled = false
                    end
                end
                -- attach new trail
                local trail = shopFolder:FindFirstChild(itemName):Clone()
                trail.Attachment0 = char.HumanoidRootPart.RootRigAttachment
		        trail.Attachment1 = char.Head.NeckRigAttachment
		        trail.Parent = char.HumanoidRootPart

                -- add trail status to stats
                dataMod.set(player, "EquippedTrail", itemName)
            end
        end
    else
        replicatedStorage.NotEnoughCoins:FireClient(player)
    end
end)

playerService.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
    -- Get equipped trail name and attach that trail to the character on respawn
        local itemName = dataMod.get(player, "EquippedTrail")
        if itemName == "" then
            print("No trail")
        else
            local shopFolder = replicatedStorage.Common.ShopItems
            local char = player.Character

            local trail = shopFolder:FindFirstChild(itemName):Clone()
            trail.Attachment0 = char.HumanoidRootPart.RootRigAttachment
            trail.Attachment1 = char.Head.NeckRigAttachment
            trail.Parent = char.HumanoidRootPart
        end
    end)
end)

monetisationMod.insertTool = function(player, assetId)
    -- load and insert gears from the website
    local asset = insertService:LoadAsset(assetId)
    local tool = asset:FindFirstChildOfClass("Tool")
    tool.Parent = player.Backpack
    asset:Destroy()
end

monetisationMod[1217899753] = function(player)
    dataMod.increment(player, "Coins", 50)
end

monetisationMod[1217942198] = function(player)
    dataMod.increment(player, "Stage", 1)
    local newStage = dataMod.get(player, "Stage")

    -- set the number of deaths on the stage to 0
    dataMod.set(player, "StageDeaths", 0)

    -- teleport to new stage
    local char = player.Character
    local torso = char:WaitForChild("HumanoidRootPart")

    for _, part in pairs(workspace.SpawnParts:GetChildren()) do
        if part:GetAttribute("Stage") == newStage then
            player.RespawnLocation = part 
            local newStageLoc = part.Position
            torso.CFrame = CFrame.new(newStageLoc, Vector3.new(0,0,0))  * CFrame.new(0,10,0) -- make sure player spawns above part           
        end
    end
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