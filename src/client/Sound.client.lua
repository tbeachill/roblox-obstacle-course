local SoundService = game:GetService("SoundService")
local pianoNotes = SoundService.Notes
local replicatedStorage = game:GetService("ReplicatedStorage")

replicatedStorage.PianoNote.OnClientEvent:Connect(function(touchNote)
    for _, note in pairs(pianoNotes:GetChildren()) do
        if note.Name == touchNote then
            note:Play()
        end
    end
end)

--[[
while true do
    for _, sound in pairs(backgroundMusic:GetChildren()) do
        sound:Play()
        sound.Ended:Wait()
    end
end
]]