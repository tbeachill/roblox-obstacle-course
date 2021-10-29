local SoundService = game:GetService("SoundService")
local coinDirectory = workspace.RewardParts.Coins;
local coinEffectsMod = {}
local coinFunctions = {'collect', 'spin', 'float'}

coinEffectsMod.collect = function(part)
    local db = true
    part.Touched:connect(function(hit)
        if hit.Parent:FindFirstChild("Humanoid") ~= nil then
            if db == true then
                db = false
                part.Transparency = 1
                SoundService.CoinCollect:Play()
                part.Sparkles:Remove()
                part.Transparency = 1
            end
        end	
    end)
end

coinEffectsMod.float = function(part)
    while true do 
        for i =1,4 do
            part.CFrame = part.CFrame + Vector3.new (0, 0.1, 0)
            wait(0.01)
        end	
        for i =1,4 do
            part.CFrame = part.CFrame + Vector3.new (0, -0.1, 0)
            wait(0.01)
        end
        wait(0.01)
    end
end

coinEffectsMod.spin = function(part)
    while wait() do
        part.CFrame = part.CFrame * CFrame.fromEulerAnglesXYZ(0, 0.05, 0)
    end
end

for _, func in pairs(coinFunctions) do
    print(func)
    -- call each function and pass along
    -- each part within the coin folder
    for _, part in pairs(coinDirectory:GetChildren()) do
        if part:IsA("BasePart")  then
            coinEffectsMod[func](part)
        end
    end
end


return coinEffectsMod
