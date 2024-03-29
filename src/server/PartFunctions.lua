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
    workspace.AlwaysKillParts;
    workspace.DamageParts;
    workspace.SpawnParts;
    workspace.RewardParts;
    workspace.StairParts;
    workspace.PurchaseParts;
    workspace.ShopParts;
    workspace.MoveParts;
    workspace.SwingParts;
    workspace.ShootParts;
    workspace.DisappearParts;
    workspace.PianoParts;
}

local badges = {
    [10] = 2124867973,
    [20] = 2124867974,
    [30] = 2124867975,
    [40] = 2124867976,
    [50] = 2124867977,
    [60] = 2124867978,
    [70] = 2124867979,
    [80] = 2124867980,
    [90] = 2124867981,
    [100] = 2124867982,
}

local items = {
    ["Spring Potion"] = {
        Price = 5;
    };
}

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
        if player and char.Humanoid.Health > 0 and dataMod.get(player, "EasyMode") == false then
            char.Humanoid.Health = 0
        end
    end)
end

partFunctionsMod.AlwaysKillParts = function(part)
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
            if char:FindFirstChildOfClass("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead then
                dataMod.set(player, "Stage", stage)
                replicatedStorage.Effect:FireClient(player, part)

                -- set the spawn location of the player to the checkpoint
                if char:FindFirstChildOfClass("Humanoid") then
                    player.RespawnLocation = part
                end

                -- set the number of deaths on the stage to 0
                dataMod.set(player, "StageDeaths", 0)
                
                -- show the replay button if at final stage
                if stage % 10 == 0 then
                    if stage == 100 then
                        partFunctionsMod.awardBadge(player, stage)
                        player.PlayerGui.Gui.FinishedScreen.Enabled = true
                    else
                        partFunctionsMod.awardBadge(player, stage)
                    end
                end
            end
        else
            if player and dataMod.get(player, "Stage") == stage + 1 then
                replicatedStorage.WrongWay:FireClient(player)
            end
        end
    end)
end

partFunctionsMod.RewardParts = function(part)
    -- when touched, check for a CoinTags folder on the player, create if nil
    -- if the coin has not been collected before, award the coin
    local reward = part:GetAttribute("Reward")   -- changed from part.Reward.Value to part:GetAttribute("Value")

    part.Touched:Connect(function(hit)
        local player = partFunctionsMod.playerFromHit(hit)
        local code = part:GetAttribute("CoinCode")
    
        if player then
            local coinTags = dataMod.get(player, "CoinTags")
            
            if coinTags[code] == false then
                if code <= 50 and code > 0 then
                    local coinMultiplier = dataMod.get(player, "CoinMultiplier")
                    reward = reward * coinMultiplier
                    dataMod.increment(player, "Coins", reward)
                    dataMod.set(player, "CoinTags", true, code)

                    replicatedStorage.Effect:FireClient(player, part)
                end
            end
        end
    end)
end

partFunctionsMod.awardBadge = function(player, stage)
    local badgeId = badges[stage]
	-- Fetch badge information
	local success, badgeInfo = pcall(function()
		return badgeService:GetBadgeInfoAsync(badgeId)
	end)
	if success then
		-- Confirm that badge can be awarded
		if badgeInfo.IsEnabled then
			-- Award badge
			local awarded, errorMessage = pcall(function()
				badgeService:AwardBadge(player.UserId, badgeId)
			end)
			if not awarded then
				warn("Error while awarding badge:", errorMessage)
			end
		end
	else
		warn("Error while fetching badge info!")
	end
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

    if part:GetAttribute("Kill") == true then
        part.Touched:Connect(function(hit)
            local player, char = partFunctionsMod.playerFromHit(hit)
            if player and char.Humanoid.Health > 0 and dataMod.get(player, "EasyMode") == false then
                char.Humanoid.Health = 0
            end
        end)
    end

    gyroTween:Play()
    moveTween:Play()
end

partFunctionsMod.ShootParts = function(part)
    local i = 1
    local dirDict = {
        Vector3.new(0,0,200),
        Vector3.new(-200,0,200),
        Vector3.new(-200,0,00),
        Vector3.new(-200,0,-200),
        Vector3.new(0,0,-200),
        Vector3.new(200,0,-200),
        Vector3.new(200,0,0),
        Vector3.new(200,0,200),
    }

    spawn(function()
        while true do
            local projectile, projectile2 = Instance.new("Part"), Instance.new("Part")
            projectile.Parent, projectile2.Parent = workspace.ShootParts, workspace.ShootParts
            projectile.Shape, projectile2.Shape = Enum.PartType.Ball, Enum.PartType.Ball
            projectile.CFrame, projectile2.CFrame = part.CFrame + Vector3.new(0,-5,0), part.CFrame + Vector3.new(0,-5,0)
            projectile.CanCollide, projectile2.CanCollide = false, false
            projectile.Color, projectile2.Color = Color3.new(0.992156, 0.301960, 0.301960), Color3.new(0.992156, 0.301960, 0.301960)
            projectile.Material, projectile2.Material = Enum.Material.Neon, Enum.Material.Neon

            local velocity, velocity2 = Instance.new("BodyVelocity"), Instance.new("BodyVelocity")
            velocity.P, velocity2.P = math.huge, math.huge
            velocity.Parent, velocity2.Parent = projectile, projectile2
            velocity.MaxForce, velocity2.MaxForce = Vector3.new(9999, 9999, 9999), Vector3.new(9999, 9999, 9999)
            velocity.Velocity = Vector3.new(1,0,1) * dirDict[i]
            velocity2.Velocity = Vector3.new(1,0,1) * dirDict[i+4]
            
            projectile.Touched:Connect(function(hit)
                local player, char = partFunctionsMod.playerFromHit(hit)
                if player and char.Humanoid.Health > 0 and dataMod.get(player, "EasyMode") == false and dataMod.get(player, "Stage") == 99 then
                    char.Humanoid.Health = 0
                end

                if hit.Name == "Thin Flat Ring Mesh" then
                    wait(0.05)
                    projectile:Destroy()
                end
            end)

            projectile2.Touched:Connect(function(hit)
                local player, char = partFunctionsMod.playerFromHit(hit)
                if player and char.Humanoid.Health > 0 and dataMod.get(player, "EasyMode") == false and dataMod.get(player, "Stage") == 99 then
                    char.Humanoid.Health = 0
                end

                if hit.Name == "Thin Flat Ring Mesh" then
                    wait(0.05)
                    projectile2:Destroy()
                end
            end)

            wait(0.5)
            if i ~= 4 then
                i = i + 1
            else
                i = 1
            end
        end
    end)
end

partFunctionsMod.DisappearParts = function(part)
    -- parts disappear and reappear
    spawn(function()

        local curOrder = 1

        while true do
            for _, item in pairs(workspace.DisappearParts:GetChildren()) do
                if item:GetAttribute("Order") == curOrder then
                    item.Color = Color3.new(1, 0.384313, 0.384313)
                end
            end

            wait(1.5)

            for _, item in pairs(workspace.DisappearParts:GetChildren()) do
                if item:GetAttribute("Order") == curOrder then
                    item.Color = Color3.new(1, 0.384313, 0.384313)
                    item.CanCollide = false
                    item.Transparency = 1
                else
                    if item:GetAttribute("Order") == 1 then
                        item.Color = Color3.new(0.564705, 0.949019, 1)
                        item.CanCollide = true
                        item.Transparency = 0
                    else
                        item.Color = Color3.new(0.890196, 0.654901, 1)
                        item.CanCollide = true
                        item.Transparency = 0
                    end
                end
            end

            wait(2)

            for _, item in pairs(workspace.DisappearParts:GetChildren()) do
                if item:GetAttribute("Order") == 1 then
                    item.Color = Color3.new(0.564705, 0.949019, 1)
                    item.CanCollide = true
                    item.Transparency = 0
                else
                    item.Color = Color3.new(0.890196, 0.654901, 1)
                    item.CanCollide = true
                    item.Transparency = 0
                end
            end

            wait(2)

            if curOrder == 1 then
                curOrder = 2
            else
                curOrder = 1
            end
        end
    end)
end

partFunctionsMod.PianoParts = function(part)
    -- when a player touches a piano key, play a note
    part.Touched:Connect(function(hit)
        local player, char = partFunctionsMod.playerFromHit(hit)
        local touchNote = part:GetAttribute("Note")
        replicatedStorage.PianoNote:FireClient(player, touchNote)
    end)
end

for _, group in pairs(partGroups) do
    -- call the function with the same name as each folder and pass along
    -- each part within that folder
    print(group)
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