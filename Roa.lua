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
end-- Simple Fly + AutoClick
local player = game.Players.LocalPlayer
local char = player.Character
local root = char.HumanoidRootPart

-- Fly Script Simple
local fly = Instance.new("BodyVelocity", root)
fly.MaxForce = Vector3.new(0, 9e9, 0)
fly.Velocity = Vector3.new(0, 25, 0) -- Sube rápido

-- Buscar y hacer todo
while wait(2) do
    -- Primero buscar cajas
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:FindFirstChildOfClass("ClickDetector") then
            -- Volar al objeto
            root.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
            wait(0.3)
            
            -- Hacer click
            fireclickdetector(obj:FindFirstChildOfClass("ClickDetector"))
            print("🎯 Click en: " .. obj.Name)
            wait(0.5)
        end
    end
    
    -- Volar a tienda si existe
    local shop = workspace:FindFirstChild("Shop") or workspace:FindFirstChild("Tienda")
    if shop then
        root.CFrame = shop.CFrame + Vector3.new(0, 5, 0)
        wait(1)
    end
  end-- AutoFarm con Vuelo - My Working Brainrots
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Activar vuelo
loadstring(game:HttpGet("https://raw.githubusercontent.com/XRoLLu/V Hub/main/Fly"))()
-- O usa este fly simple:
local flying = false
function toggleFly()
    flying = not flying
    if flying then
        local BodyGyro = Instance.new("BodyGyro", HumanoidRootPart)
        local BodyVelocity = Instance.new("BodyVelocity", HumanoidRootPart)
        BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        
        game:GetService("RunService").RenderStepped:Connect(function()
            if flying then
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                local cam = workspace.CurrentCamera.CFrame
                local moveX = 0
                local moveY = 0
                local moveZ = 0
                
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
                    moveZ = -50
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
                    moveZ = 50
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
                    moveX = -50
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
                    moveX = 50
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                    moveY = 50
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveY = -50
                end
                
                BodyVelocity.Velocity = cam.LookVector * moveZ + cam.RightVector * moveX + Vector3.new(0, moveY, 0)
                BodyGyro.CFrame = cam
            end
        end)
    else
        for _, v in pairs(HumanoidRootPart:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then
                v:Destroy()
            end
        end
    end
end

-- Función para teletransportarse a objeto
function teleportTo(obj)
    if obj and obj:IsA("BasePart") then
        HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
    elseif obj and obj:IsA("Model") then
        local primary = obj:FindFirstChild("PrimaryPart") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
        if primary then
            HumanoidRootPart.CFrame = primary.CFrame + Vector3.new(0, 3, 0)
        end
    end
    task.wait(0.3)
end

-- Buscar todos los objetos clickeables
function getClickableObjects()
    local objects = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        local click = obj:FindFirstChildOfClass("ClickDetector")
        if click and (obj.Name:find("Box") or obj.Name:find("Caja") or obj.Name:find("Shop") 
           or obj.Name:find("Tienda") or obj.Name:find("Wheel") or obj.Name:find("Ruleta")
           or obj.Name:find("Buy") or obj.Name:find("Spin")) then
            table.insert(objects, obj)
        end
    end
    return objects
end

-- AutoFarm principal
task.wait(2)
toggleFly() -- Activar vuelo automático

while task.wait(1) do
    pcall(function()
        print("🔍 Buscando objetos...")
        local objects = getClickableObjects()
        
        for _, obj in pairs(objects) do
            -- Volar/teletransportarse al objeto
            teleportTo(obj)
            
            -- Hacer click
            local click = obj:FindFirstChildOfClass("ClickDetector")
            if click then
                fireclickdetector(click)
                print("✅ Interactuado: " .. obj.Name)
                task.wait(0.5)
                
                -- Si es ruleta, esperar más
                if obj.Name:find("Wheel") or obj.Name:find("Ruleta") then
                    task.wait(3)
                end
            end
        end
        
        print("🔄 Ciclo completado - " .. os.date("%X"))
    end)
    end
