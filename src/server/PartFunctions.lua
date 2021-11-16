-- functions specific to certain parts within the game

local playerService = game:GetService("Players")
local badgeService = game:GetService("BadgeService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local marketService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local dataMod = require(script.Parent.Data)
local partFunctionsMod = {}
local partGroups = {
    workspace.KillParts;
    workspace.DamageParts;
    workspace.SpawnParts;
    workspace.RewardParts;
    workspace.StairParts;
    workspace.PurchaseParts;
    workspace.ShopParts;
    workspace.MoveParts;
    workspace.SwingParts;
}
local items = {
    ["Spring Potion"] = {
        Price = 5;
    };
}

local uniqueCode = 0

partFunctionsMod.playerFromHit = function(hit)
    -- takes a single BasePart as an argument and sees if it's a descendent of a player char
    -- if it is both the player and the player char are returned as a tuple, if not, nil
    local char = hit:FindFirstAncestorOfClass("Model")
    local player = playerService:GetPlayerFromCharacter(char)

    return player, char
end

partFunctionsMod.KillParts = function(part)
    -- if a player touches the part, kill the player
    part.Touched:Connect(function(hit)
        local player, char = partFunctionsMod.playerFromHit(hit)
        if player and char.Humanoid.Health > 0 then
            char.Humanoid.Health = 0
        end
    end)
end

partFunctionsMod.DamageParts = function(part)
    -- if a player touches a part, damage them over time by the part attribute 'Damage'
    -- the debounce prevents the code from running until it is reset to false, after a delay
    local debounce = false
    local damage = part:GetAttribute("Damage")  -- changed from part.Damage.Value to part:GetAttribute("Damage")

    part.Touched:Connect(function(hit)
        local player, char = partFunctionsMod.playerFromHit(hit)
    
        if player and not debounce then
            debounce = true
            local hum = char.Humanoid
            hum.Health = hum.Health - damage

            delay(0.1, function()
                debounce = false
            end)
        end
    end)
end

partFunctionsMod.SpawnParts = function(part)
    -- if a player touches a part, check the new checkpoint has a value of 1
    -- more than the current stored stage, then update the players 'Stage' stat
    -- checkpoint parts should contain a 'Stage' attribute
    local stage = part:GetAttribute("Stage")    -- changed from part.Stage.Value to part:GetAttribute("Stage")

    part.Touched:Connect(function(hit)
    local player, char = partFunctionsMod.playerFromHit(hit)
        if player and dataMod.get(player, "Stage") == stage - 1 then
            dataMod.set(player, "Stage", stage)
            replicatedStorage.Effect:FireClient(player, part)

            -- set the spawn location of the player to the checkpoint
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                player.RespawnLocation = part
            end

            -- set the number of deaths on the stage to 0
            dataMod.set(player, "StageDeaths", 0)
        end
    end)
end

partFunctionsMod.RewardParts = function(part)
    -- when touched, check for a CoinTags folder on the player, create if nil
    -- if the coin has not been collected before, award the coin
    local reward = part:GetAttribute("Reward")   -- changed from part.Reward.Value to part:GetAttribute("Value")
    local code = uniqueCode
    uniqueCode = uniqueCode + 1

    part.Touched:Connect(function(hit)
        local player = partFunctionsMod.playerFromHit(hit)
    
        if player then
            local tagFolder = player:FindFirstChild("CoinTags")
            if not tagFolder then
                tagFolder = Instance.new("Folder")
                tagFolder.Name = "CoinTags"
                tagFolder.Parent = player
            end

            if not tagFolder:FindFirstChild(code) then
                dataMod.increment(player, "Coins", reward)
                local codeTag = Instance.new("BoolValue")
                codeTag.Name = code
                codeTag.Parent = tagFolder

                replicatedStorage.Effect:FireClient(player, part)
            end
        end
    end)
end

partFunctionsMod.BadgeParts = function(part)
    -- upon touching, check whether a player has the badge, if not, award the badge
    local badgeId = part:GetAttribute("BadgeId")

    part.Touched:Connect(function(hit)
        local player = partFunctionsMod.playerFromHit(hit)

        if player then
            local key = player.UserId
            local hasBadge = badgeService:UserHasBadgeAsync(key, badgeId)

            if not hasBadge then
                badgeService:AwardBadge(key, badgeId)
            end
        end
    end)
end

partFunctionsMod.PurchaseParts = function(part)
    -- open prompt for purchase when part is touched
    local promptId = part:GetAttribute("PromptId")
    local isProduct = part:GetAttribute("IsProduct")

    part.Touched:Connect(function(hit)
        local player = partFunctionsMod.playerFromHit(hit)
        if player then
            if isProduct then
                marketService:PromptProductPurchase(player, promptId)
            else
                marketService:PromptGamePassPurchase(player, promptId)
            end
        end
    end)
end

partFunctionsMod.ShopParts = function(part)
    -- on touch, check if player has enough coins, if so, give them the item
    local itemName = part.Name
    local item = items[itemName]
    part.Touched:Connect(function(hit)
        local player = partFunctionsMod.playerFromHit(hit)
        
        if player and dataMod.get(player, "Coins") >= item.Price then
            dataMod.increment(player, "Coins", - item.Price)
            local shopFolder = replicatedStorage.Common.ShopItems
            local tool = shopFolder:FindFirstChild(itemName):Clone()

            tool.Parent = player.Backpack
        end
    end)
end

partFunctionsMod.StairParts = function(part)
    -- fire effect event on touch
    part.Touched:Connect(function(hit)
        local player = partFunctionsMod.playerFromHit(hit)
        replicatedStorage.Effect:FireClient(player, part)
    end)
end

partFunctionsMod.MoveParts = function(part)
    -- move parts by a specified distance and direction
    local gyroTween = TweenService:Create(
	    part.BodyGyro,
	    TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true, 1),
	    {CFrame = CFrame.new(0,0,0)}
    )

    local moveDis = part:GetAttribute("Distance")
    local tweenLen = part:GetAttribute("Time")
    local dirDict = {
        ["F"] = Vector3.new(moveDis,0,0),
        ["B"] = Vector3.new(-moveDis,0,0),
        ["L"] = Vector3.new(0,0,moveDis),
        ["R"] = Vector3.new(0,0,-moveDis),
        ["U"] = Vector3.new(0,moveDis,0),
        ["D"] = Vector3.new(0,-moveDis,0), 
    }
    
    local moveTween = TweenService:Create(
        part.BodyPosition,
        TweenInfo.new(tweenLen, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true, 1),
        {Position = part.BodyPosition.Position + dirDict[part:GetAttribute("Direction")] }
    )

gyroTween:Play()
moveTween:Play()
end

for _, group in pairs(partGroups) do
    -- call the function with the same name as each folder and pass along
    -- each part within that folder
    for _, part in pairs(group:GetChildren()) do
        if part:IsA("BasePart") then
            partFunctionsMod[group.Name](part)
        end
        if group == workspace.RewardParts then
            -- if rewards then also apply the the coins subfolder
            for _, part in pairs(group.Coins:GetChildren()) do
                partFunctionsMod[group.Name](part)
            end
        end
    end
end



return partFunctionsMod