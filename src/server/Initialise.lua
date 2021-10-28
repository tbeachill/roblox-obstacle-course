-- general tasks that are not specific to a system to run upon player spawn

local playerService = game:GetService("Players")
local dataMod = require(script.Parent.Data)
local spawnParts = workspace.SpawnParts
local initialiseMod = {}

local function getStage(stageNum)
    -- return the corresponding part for a stage spawn point that is specified as an argument
    for _, stagePart in pairs(spawnParts:GetChildren()) do
        if stagePart.Stage.Value == stageNum then
            return stagePart
        end
    end
end

playerService.PlayerAdded:Connect(function(player)
    -- set the CFrame of the character to the CFrame of the spawn point, with an offset
    player.CharacterAdded:Connect(function(char)
        local stageNum = dataMod.get(player, "Stage")
        local spawnPoint = getStage(stageNum)
        char:SetPrimaryPartCFrame(spawnPoint.CFrame * CFrame.new(0, 3, 0))
    end)
end)