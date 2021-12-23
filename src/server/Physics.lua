-- functions determining the games physics
local playerService = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local physicsService = game:GetService("PhysicsService")
local physicsMod = {}

physicsService:CreateCollisionGroup("Players")
physicsService:CollisionGroupSetCollidable("Players", "Players", false) -- stop members of the players
                                                                        -- collision group from colliding
playerService.PlayerAdded:Connect(function(player)
    -- iterate over the BaseParts of a players character and set the collision group
    player.CharacterAdded:Connect(function(char)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                physicsService:SetPartCollisionGroup(part, "Players")
            end
        end
    end)
end)

return physicsMod