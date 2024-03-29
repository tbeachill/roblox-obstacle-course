-- chat functions
local chatService = require(game:GetService('ServerScriptService'):WaitForChild('ChatServiceRunner').ChatService)

chatMod = {}

local tags = {
	[194240] = {TagText = "OWNER", TagColor = Color3.fromRGB(255, 59, 59)},
    [274390034] = {TagText = "OWNER", TagColor = Color3.fromRGB(255, 59, 59)},
    ["VIP"] = {TagText = "VIP", TagColor = Color3.fromRGB(241, 140, 72)},
	["DS"] = {TagText = "DS", TagColor = Color3.fromRGB(230, 241, 72)},
}

chatService.SpeakerAdded:Connect(function(playerName)
	local speaker = chatService:GetSpeaker(playerName)
	local player = game.Players[playerName]
	
	if tags[player.UserId] then
		speaker:SetExtraData("Tags", {tags[player.UserId]})
	elseif player.HiddenData.VIP.Value == true then 
        speaker:SetExtraData("Tags", {tags["VIP"]})

	elseif player:IsInGroup(13039075) then
		speaker:SetExtraData("Tags", {tags["DS"]})
    end
end)

return chatMod