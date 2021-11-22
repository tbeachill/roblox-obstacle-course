local SoundService = game:GetService("SoundService")
local backgroundMusic = SoundService.BackgroundMusic
local replicatedStorage = game:GetService("ReplicatedStorage")
--[[
while true do
    for _, sound in pairs(backgroundMusic:GetChildren()) do
        sound:Play()
        sound.Ended:Wait()
    end
end
]]