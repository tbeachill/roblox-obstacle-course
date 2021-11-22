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

replicatedStorage.GamePassPurchase.OnServerEvent:Connect(function(player, gamePassId)
    marketService:PromptGamePassPurchase(player, gamePassId)
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
            wait(2)
            monetisationMod.giveTrail(player, itemName)
        end

        local itemName = dataMod.get(player, "EquippedPet")

        if itemName ~= "" then
            wait(2)
            monetisationMod.givePet(player, itemName)
        end
    end)
end)

monetisationMod.insertTool = function(player, assetId)
    -- load and insert gears from the website
    local asset = insertService:LoadAsset(assetId)
    local tool = asset:FindFirstChildOfClass("Tool")
    print("TOOL", asset)
    tool.Parent = player.Backpack
    asset:Destroy()
end

monetisationMod.giveTool = function(player, itemName)
    -- give player a named tool from replicated storage
    local shopFolder = replicatedStorage.Common.ShopItems
    local tool = shopFolder:FindFirstChild(itemName):Clone()
    tool.Parent = player.Backpack
end

monetisationMod[1217899753] = function(player)
    -- 50 coins
    dataMod.increment(player, "Coins", 50)
    replicatedStorage.ClosePrompt:FireClient(player)
end

monetisationMod[1217942198] = function(player)
    -- skip stage
    dataMod.increment(player, "Stage", 1)
    local newStage = dataMod.get(player, "Stage")
    -- set the number of deaths on the stage to 0
    dataMod.set(player, "StageDeaths", 0)
    replicatedStorage.ClosePrompt:FireClient(player)

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

monetisationMod[1223592115] = function(player)
    -- replay
    dataMod.set(player, "Stage", 1)
    dataMod.set(player, "StageDeaths", 0)
    dataMod.set(player, "Deaths", 0)

    -- teleport to start
    local char = player.Character
    local torso = char:WaitForChild("HumanoidRootPart")

    for _, part in pairs(workspace.SpawnParts:GetChildren()) do
        if part:GetAttribute("Stage") == 1 then
            player.RespawnLocation = part 
            local newStageLoc = part.Position
            torso.CFrame = CFrame.new(newStageLoc, Vector3.new(0,0,0))  * CFrame.new(0,10,0) -- make sure player spawns above part           
        end
    end
end

-- game passes
monetisationMod[25148318] = function(player)
    -- double coins
    dataMod.set(player, "CoinMultiplier", 2)
end

monetisationMod[25225319] = function(player)
    -- double jump
    dataMod.set(player, "DoubleJump", true)
end

monetisationMod[25148457] = function(player)
    -- easy mode
    dataMod.set(player, "EasyMode", true)
end

monetisationMod[25148694] = function(player)
    -- flying carpet
    monetisationMod.giveTool(player, "Flying Carpet")
end

monetisationMod[25148786] = function(player)
    -- gravity coil
    monetisationMod.giveTool(player, "Gravity Coil")
end

monetisationMod[25148946] = function(player)
    -- radio
    monetisationMod.giveTool(player, "Radio")
end

monetisationMod[25148838] = function(player)
    -- speed coil
    monetisationMod.giveTool(player, "Speed Coil")
end

monetisationMod[25148583] = function(player)
    -- VIP
    dataMod.set(player, "VIP", true)
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

local function checkGamePass(player, gamePassId)
    -- check if a player owns a gamepass
	local hasPass = false
 
	-- Check if the player already owns the game pass
	local success, message = pcall(function()
		hasPass = marketService:UserOwnsGamePassAsync(player.UserId, gamePassId)
	end)
 
	if not success then
		warn("Error while checking if player has pass: " .. tostring(message))
		return
	end
 
	if hasPass == true then
		print(player.Name .. " owns the game pass with ID " .. gamePassId)
		-- Assign this player the ability or bonus related to the game pass
		monetisationMod[gamePassId](player)
	end
end

local gamePassTable = {
    25148318;    -- double coins
    25225319;    -- double jump
    25148457;    -- easy mode
    25148694;    -- flying carpet
    25148786;    -- gravity coil
    25148946;    -- radio
    25148838;    -- speed coil
    25148583;    -- vip
}


playerService.PlayerAdded:Connect(function(player)
    -- go through every game pass and pass it to the check function
    wait(3)
    for _, gamePassId in pairs(gamePassTable) do
        checkGamePass(player, gamePassId)
    end
    

end)

return monetisationMod