local playerService = game:GetService("Players")
local player = playerService.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local tool = script.Parent
gravityDivider = 1.4

-- record the current state of the tool
tool.Equipped:Connect(function()
	script.Parent.Handle.CFrame = CFrame.new(0,0,90)
	local bodyForce = Instance.new("BodyForce")

	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Massless = true
		end
	end
 
	bodyForce.Force = Vector3.new(0, (workspace.Gravity * char.HumanoidRootPart:GetMass()) / gravityDivider, 0)
	bodyForce.Parent = char.HumanoidRootPart
end)

tool.Unequipped:Connect(function()
	if char.HumanoidRootPart:FindFirstChild("BodyForce") then
		char.HumanoidRootPart["BodyForce"]:Destroy()
	end
end)