replicatedStorage = game:GetService("ReplicatedStorage")

replicatedStorage.WrongWay.OnClientEvent:Connect(function(player)
    script.Parent.Enabled = true
    wait(3)
    script.Parent.Enabled = false
end)