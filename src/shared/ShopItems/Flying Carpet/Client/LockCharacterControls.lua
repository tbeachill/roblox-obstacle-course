local preventJump

local function toggleCharacterSounds(player, enabled)
	local playerScripts = player:FindFirstChild('PlayerScripts')
	if not playerScripts then return end
	local soundScript = playerScripts:FindFirstChild('RbxCharacterSounds')
	if not soundScript then return end
	soundScript.Disabled = not enabled
end

return function(player, lock)
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChild('Humanoid')
	if not humanoid then return end
	local hrp = character:FindFirstChild('HumanoidRootPart')
	if not hrp then return end

	humanoid.Sit = lock
	humanoid.WalkSpeed = lock and 0 or game.StarterPlayer.CharacterWalkSpeed
	humanoid.AutoRotate = not lock
	
	hrp.Velocity = Vector3.new(0, 0, 0)
	hrp.RotVelocity = Vector3.new(0, 0, 0)		
	
	toggleCharacterSounds(player, not lock)
	if lock then
		for _, child in pairs(hrp:GetChildren()) do
			if child.ClassName == 'Sound' then
				if child.IsPlaying then
					child:Stop()
				end
			end
		end
		
		preventJump = humanoid.Changed:Connect(function(Property)
			if Property ==  "Jump" then humanoid.Jump = false end
		end)
	else
		if preventJump then preventJump:Disconnect() end
		humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end	
end