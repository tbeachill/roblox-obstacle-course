local playerService = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game.Players.LocalPlayer
local character
local humanoid
 
local canDoubleJump = false
local hasDoubleJumped = false
local oldPower
local TIME_BETWEEN_JUMPS = 0.2
local DOUBLE_JUMP_POWER_MULTIPLIER = 1.5
 
function onJumpRequest()
    if not character or not humanoid or not character:IsDescendantOf(workspace) or
     humanoid:GetState() == Enum.HumanoidStateType.Dead then
        return
    end
    
    if canDoubleJump and not hasDoubleJumped and playerService.LocalPlayer.HiddenData.DoubleJump.Value == true then
        hasDoubleJumped = true
        humanoid.JumpPower = oldPower * DOUBLE_JUMP_POWER_MULTIPLIER
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end
 
local function characterAdded(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    hasDoubleJumped = false
    canDoubleJump = false
    oldPower = humanoid.JumpPower
    
    humanoid.StateChanged:connect(function(old, new)
        if new == Enum.HumanoidStateType.Landed then
            canDoubleJump = false
            hasDoubleJumped = false
            humanoid.JumpPower = oldPower
        elseif new == Enum.HumanoidStateType.Freefall then
            wait(TIME_BETWEEN_JUMPS)
            canDoubleJump = true
        end
    end)
end
 
if localPlayer.Character then
    characterAdded(localPlayer.Character)
end
 
localPlayer.CharacterAdded:connect(characterAdded)
UserInputService.JumpRequest:connect(onJumpRequest)