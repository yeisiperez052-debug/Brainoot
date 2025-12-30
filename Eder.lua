-- ============================================
-- AUTO-FARM COMPLETO para My Working Brainrots
-- Versión: Todo-en-Uno Automático
-- ============================================

-- Cargar UI (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Variables esenciales
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- Configuración
local Config = {
    AutoFarm = false,
    AutoBuyBoxes = false,
    AutoSpins = false,
    AutoShop = false,
    AutoClaimRewards = false,
    AntiAFK = false,
    SelectedMutation = "Todas",
    SelectedShopItem = "Mejor",
    FarmSpeed = 50,
    BuyDelay = 3
}

-- Crear ventana
local Window = Rayfield:CreateWindow({
    Name = "My Working Brainrots - AUTO FARM",
    LoadingTitle = "Cargando AutoFarm...",
    LoadingSubtitle = "Activando todas las funciones...",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = false},
    KeySystem = false
})

-- ==================== FUNCIONES DE FARMEO ====================

-- Función PRINCIPAL de autofarm (dinero + todo)
local function AutoFarmMain()
    while Config.AutoFarm and task.wait(0.1) do
        pcall(function()
            -- 1. Buscar y recolectar dinero/monedas
            for _, obj in pairs(Workspace:GetChildren()) do
                if Config.AutoFarm then
                    -- Detectar monedas por nombre
                    if obj.Name:match("Coin") or obj.Name:match("Money") or obj.Name:match("Cash") 
                    or obj.Name:match("Dollar") or obj.Name:match("Gold") then
                        if obj:IsA("Part") or obj:IsA("MeshPart") then
                            local char = LocalPlayer.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.HumanoidRootPart.CFrame = obj.CFrame
                                task.wait(0.05)
                            end
                        end
                    end
                    
                    -- Detectar recolectables flotantes
                    if obj:IsA("Model") and (obj.Name:match("Collect") or obj.Name:match("Collectable")) then
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local hrp = char.HumanoidRootPart
                            local objPos = obj:GetPivot().Position
                            hrp.CFrame = CFrame.new(objPos.X, objPos.Y + 3, objPos.Z)
                            task.wait(0.1)
                        end
                    end
                end
            end
            
            -- 2. Buscar NPCs o estaciones de trabajo para farmear
            for _, npc in pairs(Workspace:GetChildren()) do
                if npc:IsA("Model") and (npc.Name:match("Work") or npc.Name:match("Job") 
                or npc.Name:match("NPC") or npc.Name:match("Vendor")) then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = npc:GetPivot() * CFrame.new(0, 0, -5)
                        task.wait(0.5)
                        
                        -- Intentar interactuar
                        local clickDetector = npc:FindFirstChildOfClass("ClickDetector")
                        if clickDetector then
                            fireclickdetector(clickDetector)
                        end
                    end
                end
            end
        end)
    end
end

-- Función para comprar TODAS las cajas disponibles
local function AutoBuyAllBoxes()
    while Config.AutoBuyBoxes and task.wait(Config.BuyDelay) do
        pcall(function()
            -- Buscar tienda de cajas
            local shopFound = false
            
            -- Buscar en Workspace
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and (obj.Name:match("Box") or obj.Name:match("Crate") 
                or obj.Name:match("Case") or obj.Name:match("Shop") or obj.Name:match("Store")) then
                    shopFound = true
                    
                    -- Teleportar a la tienda
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = obj:GetPivot() * CFrame.new(0, 0, -8)
                        task.wait(0.3)
                        
                        -- Buscar cajas dentro de la tienda
                        for _, box in pairs(obj:GetDescendants()) do
                            if box:IsA("ClickDetector") and Config.AutoBuyBoxes then
                                fireclickdetector(box)
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end
            
            -- Si no encuentra tienda, buscar cajas sueltas
            if not shopFound then
                for _, box in pairs(Workspace:GetDescendants()) do
                    if box:IsA("ClickDetector") and box.Parent and 
                    (box.Parent.Name:match("Box") or box.Parent.Name:match("Crate")) then
                        if Config.SelectedMutation == "Todas" or 
                           box.Parent.Name:find(Config.SelectedMutation) then
                            fireclickdetector(box)
                            task.wait(0.2)
                        end
                    end
                end
            end
        end)
    end
end

-- Función para girar AUTOMÁTICAMENTE
local function AutoSpinWheel()
    while Config.AutoSpins and task.wait(5) do
        pcall(function()
            -- Buscar rueda de giros
            local wheel = Workspace:FindFirstChild("Wheel") or 
                         Workspace:FindFirstChild("Spin") or 
                         Workspace:FindFirstChild("Lucky") or
                         Workspace:FindFirstChild("SpinWheel")
            
            if wheel then
                -- Teleportar a la rueda
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = wheel:GetPivot() * CFrame.new(0
