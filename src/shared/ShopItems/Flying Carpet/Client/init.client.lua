local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local ContextActionService = game:GetService('ContextActionService')
local LockCharacterControls = require(script:WaitForChild('LockCharacterControls'))

local camera = workspace.CurrentCamera
local tool = script.Parent
local billboard = tool:WaitForChild('CircularProgress')
local progressVal = billboard:WaitForChild('Progress'):WaitForChild('Percentage')
local Triggered = tool:WaitForChild('Triggered')

billboard.Enabled = false

local function tweenFOV()
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local zoomOut = TweenService:Create(camera, tweenInfo, {FieldOfView = 100})
	zoomOut:Play()
	zoomOut.Completed:Wait()
	
	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
	local zoomIn = TweenService:Create(camera, tweenInfo, {FieldOfView = 70})
	zoomIn:Play()
end

local function onActivate()
	if not tool.Enabled then return end
	tool.Enabled = false
	Triggered:FireServer()

	-- go supersonic
	local normalSpeed = tool:GetAttribute('SpeedZ')
	tool:SetAttribute('SpeedZ', normalSpeed * tool:GetAttribute('SonicMultiplier'))
	tweenFOV()
	wait(1)

	-- reset back to normal	
	tool:SetAttribute('SpeedZ', normalSpeed)	
	
	-- show cooldown bar
	local t = os.clock()
	progressVal.Value = 0
	billboard.Enabled = true
	
	while progressVal.Value < 100 do
		progressVal.Value = 100 * (os.clock()-t) / tool:GetAttribute('SonicCooldown')
		wait()
	end
	
	billboard.Enabled = false		
	tool.Enabled = true
end

local function onEquipped()
	wait(0.1)
	
	local character = tool.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end
	local humanoid = character:FindFirstChild('Humanoid')
	if not humanoid then return end
	local hrp = character:FindFirstChild('HumanoidRootPart')
	if not hrp then return end
	local animator = humanoid:FindFirstChild('Animator')
	if not animator then return end
	
	ContextActionService:BindAction('Sonic Boom', onActivate, true, Enum.KeyCode.E, Enum.UserInputType.MouseButton1)
	ContextActionService:SetPosition('Sonic Boom', UDim2.new(0.2, 0, 0.2, 0))
	
	local function isAlive()
		return (((character and character.Parent and humanoid and humanoid.Parent and humanoid.Health > 0 and hrp and hrp.Parent) and true) or false)
	end
	
	local function cloneToHRP(className)
		local bodyMover = script:FindFirstChildOfClass(className)		
		local clone = bodyMover:Clone()
		clone.Parent = hrp
		return clone
	end
	
	local function sit(bool)
		if not tool:GetAttribute('Sit') then return end
		humanoid.Sit = bool
	end
	
	billboard.Enabled = progressVal.Value < 100
	billboard.Adornee = hrp	
	LockCharacterControls(player, true)
	sit(true)
	
	local spin = cloneToHRP('BodyGyro')
	local power = cloneToHRP('BodyVelocity')
	local hold = cloneToHRP('BodyPosition')
	local holdPos = hrp.Position
	
	local function freezeInPlace()
		hold.MaxForce = Vector3.new(1, 1, 1) * hold.P
		power.MaxForce = Vector3.new(0, 0, 0)
		holdPos = tool:GetAttribute('DownDriftPatch') and holdPos or hrp.Position
		hold.Position = holdPos
	end
	
	local function allowMovement()
		if holdPos then
			holdPos = nil
		end	
		hold.MaxForce = Vector3.new(0, 0, 0)
		power.MaxForce = Vector3.new(1, 1, 1) * power.P
	end
	
	while isAlive() and tool.Parent == character do				
		local newVelocity = Vector3.new()
		local camCF = camera.CFrame		

		local forwardVector = camCF:VectorToWorldSpace(Vector3.new(0, 0, -1))
		local sideVector = camCF:VectorToWorldSpace(Vector3.new(-1, 0, 0))

		local direction = humanoid.MoveDirection
		local currentOrientation = CFrame.new(Vector3.new(), camCF.LookVector*Vector3.new(1,0,1))
		local localControlVector = currentOrientation:VectorToObjectSpace(direction)

		newVelocity += ((forwardVector * tool:GetAttribute('SpeedZ') * -localControlVector.z) or newVelocity)
		newVelocity += ((sideVector * tool:GetAttribute('SpeedX') * -localControlVector.x) or newVelocity)
		
		spin.CFrame = CFrame.new(Vector3.new(), forwardVector)
		if newVelocity.magnitude < 1 then
			freezeInPlace()
		else			
			allowMovement()
		end

		power.Velocity = newVelocity
		wait(1/60)
	end
	
	spin:Destroy()
	power:Destroy()
	hold:Destroy()
	LockCharacterControls(player, false)
	ContextActionService:UnbindAction('Sonic Boom')
	billboard.Enabled = false
end

tool.Equipped:Connect(onEquipped)