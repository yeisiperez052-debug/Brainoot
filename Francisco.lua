-- Script para "My Working Brainrots"
-- Título: Soy para Francisco

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Soy para Francisco", "DarkTheme")

-- Tabs
local MainTab = Window:NewTab("Auto-Farm")
local SpinTab = Window:NewTab("Auto-Spin")

-- Sections
local AutoFarmSection = MainTab:NewSection("Auto Comprar y Abrir Cajas")
local AutoSpinSection = SpinTab:NewSection("Girar Automáticamente")

-- Variables
local activoAutoFarm = false
local activoAutoSpin = false

-- Función para encontrar cajas en el juego (debes ajustar nombres)
local function encontrarCajas()
    -- Ejemplo: busca modelos llamados "Box" o "Crate" en el workspace
    local cajas = workspace:FindFirstChild("Boxes") or workspace:FindFirstChild("Crates")
    if cajas then
        return cajas:GetChildren()
    end
    return {}
end

-- Función para comprar cajas (ajusta según el juego)
local function comprarCaja()
    -- Ejemplo: fire a remote event o click en un botón
    local evento = game:GetService("ReplicatedStorage"):FindFirstChild("BuyBox")
    if evento then
        evento:FireServer()
    end
end

-- Función para colocar caja en el área designada
local function colocarCaja(caja)
    local area = workspace:FindFirstChild("PlaceArea")
    if area then
        caja.CFrame = area.CFrame + Vector3.new(0, 2, 0)
    end
end

-- Función para abrir caja
local function abrirCaja(caja)
    local evento = game:GetService("ReplicatedStorage"):FindFirstChild("OpenBox")
    if evento then
        evento:FireServer(caja)
    end
end

-- AUTO FARM
AutoFarmSection:NewToggle("Activar Auto-Farm", "Compra, coloca y abre cajas automáticamente", function(estado)
    activoAutoFarm = estado
    while activoAutoFarm do
        -- 1. Comprar caja
        comprarCaja()
        wait(1)

        -- 2. Encontrar caja recién comprada (última en workspace)
        local cajas = encontrarCajas()
        if #cajas > 0 then
            local ultimaCaja = cajas[#cajas]
            colocarCaja(ultimaCaja)
            wait(1)
            abrirCaja(ultimaCaja)
        end

        -- 3. Esperar antes de repetir (ajusta tiempo)
        wait(5)
    end
end)

-- AUTO SPIN
AutoSpinSection:NewToggle("Activar Auto-Spin", "Gira automáticamente la rueda diaria o de evento", function(estado)
    activoAutoSpin = estado
    while activoAutoSpin do
        local rueda = workspace:FindFirstChild("SpinWheel") or workspace:FindFirstChild("DailySpin")
        if rueda then
            local evento = rueda:FindFirstChild("Spin")
            if evento then
                evento:FireServer()
            end
        end
        wait(5) -- Espera 5 segundos entre giros (ajustable)
    end
end)

-- Añadir más opciones si necesitas
AutoFarmSection:NewButton("Test Comprar Caja", "Prueba comprar una caja manual", function()
    comprarCaja()
end)

AutoSpinSection:NewButton("Test Girar", "Prueba girar manual", function()
    local evento = workspace:FindFirstChild("SpinWheel"):FindFirstChild("Spin")
    if evento then
        evento:FireServer()
    end
end)

print("Script 'Soy para Francisco' cargado exitosamente.")
