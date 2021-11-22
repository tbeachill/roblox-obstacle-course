local playerService = game:GetService("Players")
local player = playerService.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local tool = script.Parent
local mouse = player:GetMouse()

tool.Equipped:Connect(function()
	char.Humanoid.WalkSpeed = 32
end)

tool.Unequipped:Connect(function()
	char.Humanoid.WalkSpeed = 16
end)