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
    ["Bee Pet"] = {
        Price = 100;
    };
    ["Pink Slime Pet"] = {
        Price = 75;
    };
    ["Blue Slime Pet"] = {
        Price = 75;
    };
    ["Green Slime Pet"] = {
        Price = 75;
    };
}

replicatedStorage.Purchase.OnServerEvent:Connect(function(player, promptId)
    marketService:PromptProductPurchase(player, promptId)
end)

monetisationMod.givePet = function(player, itemName)
    -- give a specified pet to a specified player

    local char = player.Character
    local shopFolder = replicatedStorage.Common.ShopItems

    for _, part in pairs(char.HumanoidRootPart:GetChildren()) do
        -- remove any current pets
        if part:IsA("Model") then
            part:Destroy()
        end
    end

    local pet = shopFolder:FindFirstChild(itemName):Clone()
    pet.Parent = char.HumanoidRootPart
    
    pet.PrimaryPart.BodyPosition.Position = char.HumanoidRootPart.Position
    local attachmentCharacter = Instance.new("Attachment")
    attachmentCharacter.Visible = false
    attachmentCharacter.Parent = char.HumanoidRootPart
    attachmentCharacter.Position = Vector3.new(0,0,0)  --Distance from player

    local attachmentPet = Instance.new("Attachment")
    attachmentPet.Visible = false
    attachmentPet.Parent = pet.PrimaryPart

    local alignOrientation = Instance.new("AlignOrientation")
    alignOrientation.MaxTorque = 2500
    alignOrientation.Attachment0 = attachmentPet
    alignOrientation.Attachment1 = attachmentCharacter
    alignOrientation.Responsiveness = 25
    alignOrientation.Parent = pet

    dataMod.set(player, "EquippedPet", itemName)
end

monetisationMod.giveTrail = function(player, itemName)
    -- remove any current trails
    local char = player.Character

    for _, part in pairs(char.HumanoidRootPart:GetChildren()) do
        -- remove any current trails
        if part:IsA("Trail") then
            part:Destroy()
        end
    end
    -- attach new trail
    local shopFolder = replicatedStorage.Common.ShopItems
    local trail = shopFolder:FindFirstChild(itemName):Clone()
    trail.Attachment0 = char.HumanoidRootPart.RootRigAttachment
	trail.Attachment1 = char.Head.NeckRigAttachment
	trail.Parent = char.HumanoidRootPart

    -- add trail status to stats
    dataMod.set(player, "EquippedTrail", itemName)
end

replicatedStorage.CoinPurchase.OnServerEvent:Connect(function(player, itemName)
    -- When player purchases an item with coins
    local item = items[itemName]

    if player and dataMod.get(player, "Coins") >= item.Price then
        dataMod.increment(player, "Coins", - item.Price)
        print(player, "bought", itemName, "for", item.Price, "coins.")
        local shopFolder = replicatedStorage.Common.ShopItems

        if shopFolder:FindFirstChild(itemName):IsA("Tool") then -- condition if item is a tool
            local tool = shopFolder:FindFirstChild(itemName):Clone()
            tool.Parent = player.Backpack
        else
            if shopFolder:FindFirstChild(itemName):IsA("Trail") then -- condition if item is a trail
                monetisationMod.giveTrail(player, itemName)
            else 
                if shopFolder:FindFirstChild(itemName):IsA("Model") then   -- condition if item is a pet
                    monetisationMod.givePet(player, itemName)
                end
            end
        end
    else
        replicatedStorage.NotEnoughCoins:FireClient(player)
    end
end)

playerService.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Check pet and trail status and equip
        local shopFolder = replicatedStorage.Common.ShopItems
        local char = player.Character 
        local itemName = dataMod.get(player, "EquippedTrail")

        if itemName ~= "" then
            wait(3)
            monetisationMod.giveTrail(player, itemName)
        end

        local itemName = dataMod.get(player, "EquippedPet")

        if itemName ~= "" then
            wait(3)
            monetisationMod.givePet(player, itemName)
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