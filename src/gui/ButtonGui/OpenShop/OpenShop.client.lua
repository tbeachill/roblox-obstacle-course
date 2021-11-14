script.Parent.MouseButton1Click:Connect(function(player)
    if script.Parent.Parent.Parent.ShopGui.Enabled == true then
        script.Parent.Parent.Parent.ShopGui.Enabled = false
        script.Parent.Parent.Parent.RobShop.Enabled = false
        script.Parent.Parent.Parent.CoinShop.Enabled = false
        script.Parent.Parent.Parent.ShopGui.ShopFrame.RobuxTab.Image = "rbxassetid://7998047814"
        script.Parent.Parent.Parent.ShopGui.ShopFrame.CoinTab.Image = "rbxassetid://7998049435"
    else
        script.Parent.Parent.Parent.ShopGui.Enabled = true
        script.Parent.Parent.Parent.RobShop.Enabled = true
        script.Parent.Parent.Parent.ShopGui.ShopFrame.RobuxTab.Image = "rbxassetid://7998067185"
    end
end)