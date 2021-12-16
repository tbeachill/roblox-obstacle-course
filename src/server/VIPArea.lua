local VIPMod = {}

VIPMod.click = function()
    workspace.VIP.Button.ClickDetector.MaxActivationDistance = 0
    workspace.VIP.Button.Color = Color3.new(1, 1, 1)
    local x = math.random(5)

    if x == 1 then
        workspace.VIP.Floor.ParticleEmitter.Enabled = true
        workspace.VIP.Floor.ParticleEmitter2.Enabled = true
        wait(5)
        workspace.VIP.Floor.ParticleEmitter.Enabled = false
        workspace.VIP.Floor.ParticleEmitter2.Enabled = false
    elseif x == 2 then
        workspace.VIP.Floor.Color = Color3.new(1, 0.235294, 0.235294)
        workspace.VIP.Wall.Color = Color3.new(1, 0.235294, 0.235294)
        wait(5)
        workspace.VIP.Floor.Color = Color3.new(0.741176, 0.698039, 1)
        workspace.VIP.Wall.Color = Color3.new(0.741176, 0.698039, 1)
    elseif x == 3 then
        workspace.VIP.Floor.Color = Color3.new(0.235294, 1, 0.337254)
        workspace.VIP.Wall.Color = Color3.new(0.235294, 1, 0.337254)
        wait(5)
        workspace.VIP.Floor.Color = Color3.new(0.741176, 0.698039, 1)
        workspace.VIP.Wall.Color = Color3.new(0.741176, 0.698039, 1)
    elseif x == 4 then
        workspace.VIP.Floor.Color = Color3.new(0.921568, 1, 0.235294)
        workspace.VIP.Wall.Color = Color3.new(0.921568, 1, 0.235294)
        wait(5)
        workspace.VIP.Floor.Color = Color3.new(0.741176, 0.698039, 1)
        workspace.VIP.Wall.Color = Color3.new(0.741176, 0.698039, 1)
    elseif x == 5 then
        workspace.VIP.Floor.ParticleEmitter3.Enabled = true
        workspace.VIP.Floor.ParticleEmitter4.Enabled = true
        wait(5)
        workspace.VIP.Floor.ParticleEmitter3.Enabled = false
        workspace.VIP.Floor.ParticleEmitter4.Enabled = false
    end

    workspace.VIP.Button.ClickDetector.MaxActivationDistance = 32
    workspace.VIP.Button.Color = Color3.new(0.741176, 0.698039, 1)
end

return VIPMod