-- Script completo para "My Working Brainrots"
-- Título: Soy para Francisco
-- Interfaz: Kavo UI
-- Funciones: Auto-Farm + Auto-Spin

-- Cargar Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Soy para Francisco", "DarkTheme")

-- Variables globales
local activoAutoFarm = false
local activoAutoSpin = false
local player = game:GetService("Players").LocalPlayer

-- ===== DETECCIÓN AUTOMÁTICA DE EVENTOS =====
print("=== Iniciando detección automática ===")

-- Función para encontrar eventos
local function encontrarEventos()
    local eventos = {
        comprar = nil,
        abrir = nil,
        girar = nil
    }
    
    -- Buscar en todo el juego
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local nombre = string.lower(obj.Name)
            
            -- Evento de compra
            if string.find(nombre, "buy") or string.find(nombre, "purchase") or string.find(nombre, "compra") then
                if not eventos.comprar then
                    eventos.comprar = obj
                    print("[✓] Evento COMPRAR: " .. obj:GetFullName())
                end
            end
            
            -- Evento de abrir
            if string.find(nombre, "open") or string.find(nombre, "abrir") or string.find(nombre, "unbox") then
                if not eventos.abrir then
                    eventos.abrir = obj
                    print("[✓] Evento ABRIR: " .. obj:GetFullName())
                end
            end
            
            -- Evento de girar
            if string.find(nombre, "spin") or string.find(nombre, "wheel") or string.find(nombre, "gira") or string.find(nombre, "rueda") then
                if not eventos.girar then
                    eventos.girar = obj
                    print("[✓] Evento GIRAR: " .. obj:GetFullName())
                end
            end
        end
        
        -- También buscar RemoteFunctions
        if obj:IsA("RemoteFunction") then
            local nombre = string.lower(obj.Name)
            if string.find(nombre, "spin") and not eventos.girar then
                eventos.girar = obj
                print("[✓] RemoteFunction GIRAR: " .. obj:GetFullName())
            end
        end
    end
    
    return eventos
end

-- Función para encontrar objetos en el workspace
local function encontrarObjetos()
    local objetos = {
        cajas = nil,
        rueda = nil,
        area = nil,
        tienda = nil
    }
    
    -- Buscar en workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        local nombre = string.lower(obj.Name)
        
        -- Buscar área de cajas
        if (string.find(nombre, "box") or string.find(nombre, "crate") or string.find(nombre, "caja")) 
        and not string.find(nombre, "open") then
            if obj:IsA("Model") or obj:IsA("Part") then
                objetos.cajas = obj.Parent
                print("[✓] Área de CAJAS: " .. obj:GetFullName())
            end
        end
        
        -- Buscar rueda de giro
        if string.find(nombre, "wheel") or string.find(nombre, "spin") or string.find(nombre, "rueda") then
            if obj:IsA("Model") or obj:IsA("Part") then
                objetos.rueda = obj
                print("[✓] RUEDA encontrada: " .. obj:GetFullName())
            end
        end
        
        -- Buscar área para colocar
        if string.find(nombre, "place") or string.find(nombre, "area") or string.find(nombre, "spot") then
            if obj:IsA("Part") then
                objetos.area = obj
                print("[✓] Área de COLOCACIÓN: " .. obj:GetFullName())
            end
        end
        
        -- Buscar tienda
        if string.find(nombre, "shop") or string.find(nombre, "store") or string.find(nombre, "tienda") then
            if obj:IsA("Model") then
                objetos.tienda = obj
                print("[✓] TIENDA: " .. obj:GetFullName())
            end
        end
    end
    
    return objetos
end

-- Detectar al inicio
local eventos = encontrarEventos()
local objetos = encontrarObjetos()

-- ===== INTERFAZ KAVO UI =====
-- Pestaña principal: Auto-Farm
local MainTab = Window:NewTab("Auto-Farm")
local AutoFarmSection = MainTab:NewSection("Compra y Apertura de Cajas")
local ConfigSection = MainTab:NewSection("Configuración")

-- Pestaña secundaria: Auto-Spin
local SpinTab = Window:NewTab("Auto-Spin")
local AutoSpinSection = SpinTab:NewSection("Giro Automático")

-- Pestaña de utilidades
local UtilTab = Window:NewTab("Utilidades")
local UtilSection = UtilTab:NewSection("Herramientas")
local InfoSection = UtilTab:NewSection("Información")

-- ===== FUNCIONES PRINCIPALES =====
-- Función mejorada para comprar
local function comprarCaja()
    if eventos.comprar then
        if eventos.comprar:IsA("RemoteEvent") then
            eventos.comprar:FireServer()
            return true
        elseif eventos.comprar:IsA("RemoteFunction") then
            eventos.comprar:InvokeServer()
            return true
        end
    end
    
    -- Método alternativo: Buscar botones de compra
    for _, gui in pairs(player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") and (string.find(string.lower(gui.Text), "buy") 
           or string.find(string.lower(gui.Name), "buy")) then
            gui:Fire("Click")
            return true
        end
    end
    
    -- Método alternativo 2: Buscar en la tienda
    if objetos.tienda then
        for _, part in pairs(objetos.tienda:GetDescendants()) do
            if part:IsA("Part") and part:FindFirstChild("ClickDetector") then
                fireclickdetector(part.ClickDetector)
                return true
            end
        end
    end
    
    return false
end

-- Función para abrir caja
local function abrirCaja(caja)
    if eventos.abrir then
        eventos.abrir:FireServer(caja)
        return true
    end
    
    -- Buscar proximity prompt en la caja
    for _, prompt in pairs(caja:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            fireproximityprompt(prompt)
            return true
        end
    end
    
    -- Click en la caja si tiene ClickDetector
    for _, click in pairs(caja:GetDescendants()) do
        if click:IsA("ClickDetector") then
            fireclickdetector(click)
            return true
        end
    end
    
    return false
end

-- Función para girar
local function girarRueda()
    if eventos.girar then
        if eventos.girar:IsA("RemoteEvent") then
            eventos.girar:FireServer()
            return true
        elseif eventos.girar:IsA("RemoteFunction") then
            eventos.girar:InvokeServer()
            return true
        end
    end
    
    -- Método alternativo: Buscar rueda física
    if objetos.rueda then
        -- Buscar proximity prompt
        for _, prompt in pairs(objetos.rueda:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                fireproximityprompt(prompt)
                return true
            end
        end
        
        -- Buscar ClickDetector
        for _, click in pairs(objetos.rueda:GetDescendants()) do
            if click:IsA("ClickDetector") then
                fireclickdetector(click)
                return true
            end
        end
    end
    
    -- Método alternativo 2: Buscar en UI
    for _, gui in pairs(player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") and (string.find(string.lower(gui.Text), "spin") 
           or string.find(string.lower(gui.Name), "spin")) then
            gui:Fire("Click")
            return true
        end
    end
    
    return false
end

-- ===== ELEMENTOS DE LA INTERFAZ =====
-- Toggle para Auto-Farm
AutoFarmSection:NewToggle("Activar Auto-Farm", "Compra, coloca y abre cajas automáticamente", function(estado)
    activoAutoFarm = estado
    
    if estado then
        print("[AutoFarm] ACTIVADO - Iniciando...")
        
        spawn(function()
            while activoAutoFarm do
                -- PASO 1: COMPRAR
                print("[AutoFarm] Intentando comprar caja...")
                if comprarCaja() then
                    print("[AutoFarm] ✓ Caja comprada")
                else
                    print("[AutoFarm] ✗ No se pudo comprar caja")
                end
                
                wait(3) -- Esperar que aparezca la caja
                
                -- PASO 2: BUSCAR Y PROCESAR CAJAS
                if objetos.cajas then
                    local cajasEncontradas = 0
                    
                    for _, caja in pairs(objetos.cajas:GetChildren()) do
                        if caja:IsA("Model") and (caja.Name:find("Box") or caja.Name:find("Crate")) then
                            cajasEncontradas = cajasEncontradas + 1
                            
                            -- Colocar en área si existe
                            if objetos.area then
                                pcall(function()
                                    if caja.PrimaryPart then
                                        caja:SetPrimaryPartCFrame(objetos.area.CFrame + Vector3.new(0, 2, 0))
                                        print("[AutoFarm] ✓ Caja colocada")
                                    end
                                end)
                            end
                            
                            wait(2) -- Esperar para abrir
                            
                            -- Abrir caja
                            print("[AutoFarm] Intentando abrir caja...")
                            if abrirCaja(caja) then
                                print("[AutoFarm] ✓ Caja abierta")
                            else
                                print("[AutoFarm] ✗ No se pudo abrir caja")
                            end
                        end
                    end
                    
                    if cajasEncontradas == 0 then
                        print("[AutoFarm] No se encontraron cajas")
                    end
                else
                    print("[AutoFarm] No se encontró área de cajas")
                end
                
                -- Esperar antes de repetir
                wait(8)
            end
            print("[AutoFarm] DESACTIVADO")
        end)
    else
        print("[AutoFarm] Desactivado por el usuario")
    end
end)

-- Toggle para Auto-Spin
AutoSpinSection:NewToggle("Activar Auto-Spin", "Gira automáticamente la rueda", function(estado)
    activoAutoSpin = estado
    
    if estado then
        print("[AutoSpin] ACTIVADO - Iniciando...")
        
        spawn(function()
            while activoAutoSpin do
                print("[AutoSpin] Intentando girar...")
                
                if girarRueda() then
                    print("[AutoSpin] ✓ Giro exitoso")
                else
                    print("[AutoSpin] ✗ No se pudo girar")
                end
                
                -- Esperar cooldown (5 segundos para testing, 86400 para 24h real)
                wait(5)
            end
            print("[AutoSpin] DESACTIVADO")
        end)
    else
        print("[AutoSpin] Desactivado por el usuario")
    end
end)

-- ===== BOTONES DE PRUEBA =====
AutoFarmSection:NewButton("Test: Comprar 1 Caja", "Prueba manual de compra", function()
    if comprarCaja() then
        Library:CreateNotification("Éxito", "Caja comprada manualmente", "Ok")
    else
        Library:CreateNotification("Error", "No se pudo comprar", "Ok")
    end
end)

AutoFarmSection:NewButton("Test: Abrir Cajas", "Abre todas las cajas disponibles", function()
    local abiertas = 0
    if objetos.cajas then
        for _, caja in pairs(objetos.cajas:GetChildren()) do
            if caja:IsA("Model") then
                if abrirCaja(caja) then
                    abiertas = abiertas + 1
                end
                wait(0.5)
            end
        end
    end
    Library:CreateNotification("Resultado", "Cajas abiertas: " .. abiertas, "Ok")
end)

AutoSpinSection:NewButton("Test: Girar 1 Vez", "Prueba manual de giro", function()
    if girarRueda() then
        Library:CreateNotification("Éxito", "Giro manual exitoso", "Ok")
    else
        Library:CreateNotification("Error", "No se pudo girar", "Ok")
    end
end)

-- ===== CONFIGURACIÓN =====
local delayFarm = 10
ConfigSection:NewSlider("Delay Auto-Farm", "Tiempo entre ciclos", 60, 5, function(valor)
    delayFarm = valor
    Library:CreateNotification("Config", "Delay ajustado a " .. valor .. "s", "Ok")
end)

local delaySpin = 5
ConfigSection:NewSlider("Delay Auto-Spin", "Tiempo entre giros", 60, 1, function(valor)
    delaySpin = valor
    Library:CreateNotification("Config", "Delay giro ajustado a " .. valor .. "s", "Ok")
end)

-- ===== HERRAMIENTAS =====
UtilSection:NewButton("Redetectar Eventos", "Busca eventos automáticamente", function()
    eventos = encontrarEventos()
    objetos = encontrarObjetos()
    Library:CreateNotification("Detección", "Eventos y objetos actualizados", "Ok")
end)

UtilSection:NewButton("Ver Eventos Detectados", "Muestra en consola", function()
    print("=== EVENTOS DETECTADOS ===")
    print("Comprar:", eventos.comprar and eventos.comprar:GetFullName() or "No encontrado")
    print("Abrir:", eventos.abrir and eventos.abrir:GetFullName() or "No encontrado")
    print("Girar:", eventos.girar and eventos.girar:GetFullName() or "No encontrado")
    print("========================")
end)

UtilSection:NewButton("Ver Objetos Detectados", "Muestra en consola", function()
    print("=== OBJETOS DETECTADOS ===")
    print("Cajas:", objetos.cajas and objetos.cajas:GetFullName() or "No encontrado")
    print("Rueda:", objetos.rueda and objetos.rueda:GetFullName() or "No encontrado")
    print("Área:", objetos.area and objetos.area:GetFullName() or "No encontrado")
    print("Tienda:", objetos.tienda and objetos.tienda:GetFullName() or "No encontrado")
    print("========================")
end)

UtilSection:NewButton("⛔ Detener Todo", "Detiene todas las funciones", function()
    activoAutoFarm = false
    activoAutoSpin = false
    Library:CreateNotification("Sistema", "Todo detenido", "Ok")
    print("=== TODO DETENIDO ===")
end)

-- ===== INFORMACIÓN =====
InfoSection:NewLabel("Script: Soy para Francisco")
InfoSection:NewLabel("Juego: My Working Brainrots")
InfoSection:NewLabel("Versión: 2.0")
InfoSection:NewParagraph("Instrucciones", [[
1. Usa "Redetectar Eventos" si no funciona
2. Prueba primero con los botones TEST
3. Ajusta los delays según necesites
4. Usa "Detener Todo" para parar emergencia
]])

-- ===== INICIALIZACIÓN =====
print("==========================================")
print("     SOY PARA FRANCISCO - CARGADO")
print("   My Working Brainrots Auto Script")
print("==========================================")
print("Auto-Farm: Compra → Coloca → Abre")
print("Auto-Spin: Giro automático")
print("==========================================")
print("Interfaz activa - Listo para usar")

Library:CreateNotification(
    "Bienvenido",
    "Script 'Soy para Francisco' cargado\nMy Working Brainrots",
    "Ok"
)
