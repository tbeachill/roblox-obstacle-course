-- tasks to run upon player spawn
local playerService = game:GetService("Players")
local marketService = game:GetService("MarketplaceService")
local monetisationMod = require(script.Parent.Monetisation)
local dataMod = require(script.Parent.Data)
local spawnParts = workspace.SpawnParts
local initialiseMod = {}
local gamePassTable = {
    25384011;    -- double coins
    25384019;    -- double jump
    25384030;    -- easy mode
    25384046;    -- flying carpet
    25384051;    -- gravity coil
    25384057;    -- radio
    25384062;    -- speed coil
    25384070;    -- vip
}

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

playerService.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        wait(1)
        -- check players game passes
        for _, gamePassId in pairs(gamePassTable) do
            checkGamePass(player, gamePassId)
        end

        -- give a player a pet or trail if they own one
        local itemName = dataMod.get(player, "EquippedTrail")

        if itemName ~= "" then
            monetisationMod.giveTrail(player, itemName)
        end

        local itemName = dataMod.get(player, "EquippedPet")

        if itemName ~= "" then
            monetisationMod.givePet(player, itemName)
        end

    end)
end)

return initialiseMod