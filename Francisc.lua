-- Script completo para "My Working Brainrots"
-- Título: Soy para Francisco
-- Auto-Farm + Auto-Spin

-- Cargar Rayfield UI (mejor interfaz)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Crear ventana
local Window = Rayfield:CreateWindow({
    Name = "Soy para Francisco",
    LoadingTitle = "My Working Brainrots Script",
    LoadingSubtitle = "Cargando...",
    ConfigurationSaving = {
        Enabled = false
    }
})

-- Variables globales
local activoAutoFarm = false
local activoAutoSpin = false
local player = game:GetService("Players").LocalPlayer

-- Función para encontrar eventos automáticamente
local function encontrarEventos()
    local eventos = {
        comprar = nil,
        abrir = nil,
        girar = nil
    }
    
    -- Buscar eventos comunes
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local nombre = obj.Name:lower()
            
            -- Detectar evento de compra
            if nombre:find("buy") or nombre:find("purchase") or nombre:find("compra") then
                if not eventos.comprar then
                    eventos.comprar = obj
                    print("[DEBUG] Evento comprar encontrado: " .. obj:GetFullName())
                end
            end
            
            -- Detectar evento de abrir
            if nombre:find("open") or nombre:find("abrir") or nombre:find("unbox") then
                if not eventos.abrir then
                    eventos.abrir = obj
                    print("[DEBUG] Evento abrir encontrado: " .. obj:GetFullName())
                end
            end
            
            -- Detectar evento de girar
            if nombre:find("spin") or nombre:find("wheel") or nombre:find("gira") or nombre:find("rueda") then
                if not eventos.girar then
                    eventos.girar = obj
                    print("[DEBUG] Evento girar encontrado: " .. obj:GetFullName())
                end
            end
        end
    end
    
    return eventos
end

-- Función para encontrar objetos físicos
local function encontrarObjetos()
    local objetos = {
        cajas = nil,
        rueda = nil,
        areaColocacion = nil
    }
    
    -- Buscar cajas
    for _, obj in pairs(workspace:GetDescendants()) do
        local nombre = obj.Name:lower()
        
        if obj:IsA("Model") or obj:IsA("Part") then
            -- Buscar cajas
            if (nombre:find("box") or nombre:find("crate") or nombre:find("caja")) 
            and not nombre:find("open") then
                objetos.cajas = obj.Parent or workspace
                print("[DEBUG] Cajas encontradas en: " .. obj:GetFullName())
                break
            end
            
            -- Buscar rueda de giro
            if nombre:find("wheel") or nombre:find("spin") or nombre:find("rueda") then
                objetos.rueda = obj
                print("[DEBUG] Rueda encontrada: " .. obj:GetFullName())
            end
            
            -- Buscar área para colocar cajas
            if nombre:find("place") or nombre:find("area") or nombre:find("spot") then
                objetos.areaColocacion = obj
                print("[DEBUG] Área de colocación: " .. obj:GetFullName())
            end
        end
    end
    
    return objetos
end

-- Detectar eventos y objetos al iniciar
local eventos = encontrarEventos()
local objetos = encontrarObjetos()

-- Crear pestaña de Auto-Farm
local TabAutoFarm = Window:CreateTab("Auto-Farm", "rbxassetid://4483345998")
local SeccionAutoFarm = TabAutoFarm:CreateSection("Compra y Apertura Automática")

-- Toggle para Auto-Farm
SeccionAutoFarm:CreateToggle({
    Name = "Activar Auto-Farm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        activoAutoFarm = Value
        
        if Value then
            Rayfield:Notify({
                Title = "Auto-Farm Activado",
                Content = "Comenzando farmeo automático...",
                Duration = 3,
                Image = "rbxassetid://4483345998"
            })
            
            -- Iniciar loop de auto-farm
            spawn(function()
                while activoAutoFarm do
                    -- PASO 1: COMPRAR CAJA
                    if eventos.comprar then
                        eventos.comprar:FireServer()
                        print("[AutoFarm] Caja comprada")
                    else
                        -- Intentar métodos alternativos
                        local compraExitosa = false
                        
                        -- Método A: Buscar botón de compra en la UI
                        for _, gui in pairs(game:GetService("CoreGui"):GetDescendants()) do
                            if gui:IsA("TextButton") and (gui.Name:lower():find("buy") or gui.Text:lower():find("buy")) then
                                fireclickdetector(gui)
                                compraExitosa = true
                                break
                            end
                        end
                        
                        -- Método B: Usar RemoteFunction si existe
                        if not compraExitosa then
                            for _, obj in pairs(game:GetDescendants()) do
                                if obj:IsA("RemoteFunction") and obj.Name:lower():find("buy") then
                                    obj:InvokeServer()
                                    compraExitosa = true
                                    break
                                end
                            end
                        end
                    end
                    
                    wait(2) -- Esperar que aparezca la caja
                    
                    -- PASO 2: ENCONTRAR Y COLOCAR CAJA
                    if objetos.cajas then
                        local cajas = {}
                        
                        -- Buscar todas las cajas recientes
                        for _, caja in pairs(objetos.cajas:GetChildren()) do
                            if caja:IsA("Model") and (caja.Name:find("Box") or caja.Name:find("Crate")) then
                                table.insert(cajas, caja)
                            end
                        end
                        
                        if #cajas > 0 then
                            local ultimaCaja = cajas[#cajas]
                            
                            -- Colocar en área designada si existe
                            if objetos.areaColocacion then
                                pcall(function()
                                    ultimaCaja:SetPrimaryPartCFrame(objetos.areaColocacion.CFrame + Vector3.new(0, 3, 0))
                                end)
                            end
                            
                            wait(3) -- Esperar a que se pueda abrir
                            
                            -- PASO 3: ABRIR CAJA
                            if eventos.abrir then
                                eventos.abrir:FireServer(ultimaCaja)
                                print("[AutoFarm] Caja abierta")
                            else
                                -- Intentar abrir con click si tiene ProximityPrompt
                                for _, prompt in pairs(ultimaCaja:GetDescendants()) do
                                    if prompt:IsA("ProximityPrompt") then
                                        fireproximityprompt(prompt)
                                        break
                                    end
                                end
                            end
                        end
                    end
                    
                    -- ESPERAR ANTES DE REPETIR (ajustable)
                    wait(10)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto-Farm Desactivado",
                Content = "Farmeo detenido",
                Duration = 2,
                Image = "rbxassetid://4483345998"
            })
        end
    end
})

-- Crear pestaña de Auto-Spin
local TabAutoSpin = Window:CreateTab("Auto-Spin", "rbxassetid://4483345998")
local SeccionAutoSpin = TabAutoSpin:CreateSection("Giro Automático")

-- Toggle para Auto-Spin
SeccionAutoSpin:CreateToggle({
    Name = "Activar Auto-Spin",
    CurrentValue = false,
    Flag = "AutoSpinToggle",
    Callback = function(Value)
        activoAutoSpin = Value
        
        if Value then
            Rayfield:Notify({
                Title = "Auto-Spin Activado",
                Content = "Girando automáticamente...",
                Duration = 3,
                Image = "rbxassetid://4483345998"
            })
            
            -- Iniciar loop de auto-spin
            spawn(function()
                while activoAutoSpin do
                    -- INTENTAR DIFERENTES MÉTODOS PARA GIRAR
                    
                    -- Método 1: Usar evento RemoteEvent detectado
                    if eventos.girar then
                        eventos.girar:FireServer()
                        print("[AutoSpin] Girado con evento")
                    end
                    
                    -- Método 2: Buscar rueda física y usar ProximityPrompt
                    if objetos.rueda then
                        for _, prompt in pairs(objetos.rueda:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") then
                                fireproximityprompt(prompt)
                                print("[AutoSpin] Girado con ProximityPrompt")
                                break
                            end
                        end
                    end
                    
                    -- Método 3: Buscar botón en la UI
                    for _, gui in pairs(game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants()) do
                        if gui:IsA("TextButton") and (gui.Name:lower():find("spin") or gui.Text:lower():find("spin")) then
                            fireclickdetector(gui)
                            print("[AutoSpin] Girado con botón UI")
                            break
                        end
                    end
                    
                    -- Método 4: Buscar en Workspace eventos de giro
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("RemoteEvent") and obj.Name:lower():find("spin") then
                            obj:FireServer()
                            print("[AutoSpin] Girado con evento en workspace")
                            break
                        end
                    end
                    
                    -- ESPERAR COOLDOWN (24 horas para giro diario, pero para testing usar menos)
                    wait(5) -- Cambiar a 86400 para 24h reales
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto-Spin Desactivado",
                Content = "Giro automático detenido",
                Duration = 2,
                Image = "rbxassetid://4483345998"
            })
        end
    end
})

-- Crear pestaña de Utilidades
local TabUtilidades = Window:CreateTab("Utilidades", "rbxassetid://4483345998")
local SeccionUtilidades = TabUtilidades:CreateSection("Herramientas")

-- Botón para recargar detección
SeccionUtilidades:CreateButton({
    Name = "🔍 Redetectar Eventos",
    Callback = function()
        eventos = encontrarEventos()
        objetos = encontrarObjetos()
        
        Rayfield:Notify({
            Title = "Detección Completada",
            Content = "Eventos y objetos actualizados",
            Duration = 3,
            Image = "rbxassetid://4483345998"
        })
    end
})

-- Slider para ajustar velocidad
SeccionUtilidades:CreateSlider({
    Name = "Velocidad de Farmeo",
    Range = {1, 30},
    Increment = 1,
    Suffix = "segundos",
    CurrentValue = 10,
    Flag = "FarmSpeed",
    Callback = function(Value)
        -- Esta variable se usaría en los loops (implementación adicional necesaria)
        Rayfield:Notify({
            Title = "Velocidad Ajustada",
            Content = "Nueva velocidad: " .. Value .. " segundos",
            Duration = 2,
            Image = "rbxassetid://4483345998"
        })
    end
})

-- Botón de emergencia para detener todo
SeccionUtilidades:CreateButton({
    Name = "⛔ Detener Todo",
    Callback = function()
        activoAutoFarm = false
        activoAutoSpin = false
        
        Rayfield:Notify({
            Title = "Todo Detenido",
            Content = "Scripts desactivados",
            Duration = 3,
            Image = "rbxassetid://4483345998"
        })
    end
})

-- Pestaña de información
local TabInfo = Window:CreateTab("Información", "rbxassetid://4483345998")
local SeccionInfo = TabInfo:CreateSection("Sobre este Script")

SeccionInfo:CreateLabel("Script: Soy para Francisco")
SeccionInfo:CreateLabel("Juego: My Working Brainrots")
SeccionInfo:CreateLabel("Función: Auto-Farm + Auto-Spin")
SeccionInfo:CreateParagraph("Instrucciones", [[
1. Activa Auto-Farm para comprar/abrir cajas automáticamente
2. Activa Auto-Spin para girar la rueda automáticamente
3. Usa "Redetectar Eventos" si no funciona al principio
4. "Detener Todo" para parar ambos scripts
]])

-- Inicializar
Rayfield:Notify({
    Title = "Script Cargado",
    Content = "Soy para Francisco - Listo para usar",
    Duration = 5,
    Image = "rbxassetid://4483345998"
})

print("====================================")
print("       SOY PARA FRANCISCO")
print("   My Working Brainrots Script")
print("====================================")
print("Auto-Farm: Compra, coloca y abre cajas")
print("Auto-Spin: Gira automáticamente")
print("====================================")
