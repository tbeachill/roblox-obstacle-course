while wait() do
    local rootPart = script.Parent.Parent
    local bodyPos = script.Parent.BodyPosition
    local bodyGyro = script.Parent.BodyGyro

    bodyPos.Position = rootPart.Position + Vector3.new(2, 2, 3)
    bodyGyro.CFrame = rootPart.CFrame
end