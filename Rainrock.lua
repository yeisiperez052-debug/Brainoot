-- AutoFarm con patrulla automática
local points = {
    Vector3.new(0, 10, 0),  -- Punto 1
    Vector3.new(20, 10, 0), -- Punto 2
    Vector3.new(0, 10, 20), -- Punto 3
    Vector3.new(-20, 10, 0) -- Punto 4
}

while wait(3) do
    for _, point in pairs(points) do
        -- Teletransportarse al punto
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(point)
        wait(1)
        
        -- Hacer click en todo alrededor
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:FindFirstChildOfClass("ClickDetector") then
                fireclickdetector(obj:FindFirstChildOfClass("ClickDetector"))
                wait(0.2)
            end
        end
    end
end
