local SoundService = game:GetService("SoundService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local effectsMod = {}

local function playSound(part)
    -- play a sound upon touching
    local partSound = part:GetAttribute("TouchSound")

    for _, sound in pairs(SoundService:GetChildren()) do
        if sound.Name == partSound then
            sound:Play()
        end
    end
end

local function emitParticles(part, amount)
    -- turn emitter on
    local emitter = part:FindFirstChildOfClass("ParticleEmitter")

    if emitter then
        emitter:Emit(amount)
    end

    return emitter
end

replicatedStorage.Effect.OnClientEvent:Connect(function(part)
    -- apply function with the same name as the parent folder
    
    local folderName = nil
    
    if part.Parent.Name == "Coins" then
        folderName = part.Parent.Parent.Name
    else
        folderName = part.Parent.Name
    end
    
        effectsMod[folderName](part)
    
end)

effectsMod.RewardParts = function(part)
    -- make part transparent and play sound
    part.Transparency = 1
    playSound(part)
end

effectsMod.SpawnParts = function(part)
    -- make checkpoint play sound and emit particles
    playSound(part)
    emitParticles(part, 25)
    part.Material = Enum.Material.Neon

    -- Update stage text
    local player = game.Players.LocalPlayer
    local stageText = player.PlayerGui.Gui.StageText

    -- animate stage text when updated
    local goal = {}
    goal.TextSize = 50
    goal.Rotation = 0
    local tweenInfo = TweenInfo.new(1)
    local tween = TweenService:Create(stageText.StageNumber, tweenInfo, goal)

    stageText.StageNumber.TextTransparency = 0
    stageText.StageTitle.TextTransparency = 0
    stageText.StageNumber.Rotation = 45
    stageText.StageNumber.TextSize = 400
    stageText.StageNumber.Text = part:GetAttribute("Stage")
    tween:Play()
    

    delay(2, function()
        part.Material = Enum.Material.SmoothPlastic
        stageText.StageNumber.TextTransparency = 100
        stageText.StageTitle.TextTransparency = 100
    end)
end

effectsMod.StairParts = function(part)
    delay(1, function()
        part.Transparency = 1
        part.CanCollide = false
    end)

    delay(5, function()
        part.Transparency = 0
        part.CanCollide = true
    end)    
end

local runService = game:GetService("RunService")
local rotParts = {}

local partGroups = {
	workspace.KillParts;
	workspace.DamageParts;
	workspace.SpawnParts;
	workspace.RewardParts;
    workspace.RewardParts.Coins;
    workspace.StairParts;
	workspace.BadgeParts;
	workspace.PurchaseParts;
	workspace.ShopParts;
}

for _, group in pairs(partGroups) do
    -- create a table of parts to be rotated
	for _, part in pairs(group:GetChildren()) do
		if part:IsA("BasePart") or part:IsA("UnionOperation") then
			if part:FindFirstChild("Rotate") then
				table.insert(rotParts, part)
			end
		end
	end
end

runService.RenderStepped:Connect(function(dt)
    -- rotate parts in the table
	for _, part in pairs(rotParts) do
		local rot = part.Rotate.Value
		rot = rot * dt
		rot = rot * ((2 * math.pi) / 360)
		rot = CFrame.Angles(rot.X, rot.Y, rot.Z)
		
		part.CFrame = part.CFrame * rot
	end

    
end)

return effectsMod