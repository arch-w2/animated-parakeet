print("⏳ [lvs] Iniciando la carga de WindUI...")

-- 1. Cargar la última versión de WindUI desde el repositorio oficial
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- 2. Crear la ventana principal con tu configuración
local Window = WindUI:CreateWindow({
    Title = "lvs",
    Icon = "sparkles",
    Author = "by dss",
    Folder = "MiMenuConfig",
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark",
    Transparent = false,
    Resizable = true,
})

-- Notificación de bienvenida al cargar el menú
WindUI:Notify({
    Title = "📁 Menú Cargado",
    Content = "lvs by dss se ha iniciado correctamente.",
    Icon = "folder-check",
    Duration = 4,
})

-- ==========================================
-- SERVICIOS Y VARIABLES GLOBALES
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50

-- Estados del Jugador
local velocidadActiva = false
local valorVelocidad = 50
local saltoActivo = false
local valorSalto = 100

-- Estados Visuales (ESP)
local espNombres = false
local espVida = false
local espDistancia = false
local espColor = Color3.fromRGB(0, 145, 255)
local espObjects = {}

local scriptCargado = false

-- ==========================================
-- FUNCIÓN PARA CREAR EL VISUAL DE CADA JUGADOR
-- ==========================================
local function LimpiarVisual(player)
    if espObjects[player] then
        if espObjects[player].Billboard then
            espObjects[player].Billboard:Destroy()
        end
        espObjects[player] = nil
    end
end

local function CrearVisualParaJugador(player)
    if player == LocalPlayer then return end
    LimpiarVisual(player)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "LVS_Visual"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 55)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.ResetOnSpawn = false -- Evita que se borre al morir
    billboard.Enabled = false

    -- 1. Nombre del jugador
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
    nameLabel.TextColor3 = espColor
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.Parent = billboard

    -- 2. Contenedor de Barra de Vida con valores a ambos lados
    local healthContainer = Instance.new("Frame")
    healthContainer.Name = "HealthContainer"
    healthContainer.Size = UDim2.new(1, 0, 0, 16)
    healthContainer.Position = UDim2.new(0, 0, 0, 20)
    healthContainer.BackgroundTransparency = 1
    healthContainer.Parent = billboard

    -- Valor izquierdo (Vida actual)
    local leftVal = Instance.new("TextLabel")
    leftVal.Name = "LeftVal"
    leftVal.Size = UDim2.new(0, 34, 1, 0)
    leftVal.Position = UDim2.new(0, 0, 0, 0)
    leftVal.BackgroundTransparency = 1
    leftVal.Text = "100"
    leftVal.TextColor3 = Color3.fromRGB(255, 255, 255)
    leftVal.TextStrokeTransparency = 0.3
    leftVal.Font = Enum.Font.GothamBold
    leftVal.TextSize = 11
    leftVal.TextXAlignment = Enum.TextXAlignment.Right
    leftVal.Parent = healthContainer

    -- Fondo de la barra central
    local barBg = Instance.new("Frame")
    barBg.Name = "BarBg"
    barBg.Size = UDim2.new(0, 116, 0, 6)
    barBg.Position = UDim2.new(0.5, 0, 0.5, 0)
    barBg.AnchorPoint = Vector2.new(0.5, 0.5)
    barBg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    barBg.BorderSizePixel = 0
    barBg.Parent = healthContainer

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = barBg

    local barFill = Instance.new("Frame")
    barFill.Name = "BarFill"
    barFill.Size = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(51, 199, 89)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = barFill

    -- Valor derecho (Vida máxima)
    local rightVal = Instance.new("TextLabel")
    rightVal.Name = "RightVal"
    rightVal.Size = UDim2.new(0, 34, 1, 0)
    rightVal.Position = UDim2.new(1, -34, 0, 0)
    rightVal.BackgroundTransparency = 1
    rightVal.Text = "100"
    rightVal.TextColor3 = Color3.fromRGB(255, 255, 255)
    rightVal.TextStrokeTransparency = 0.3
    rightVal.Font = Enum.Font.GothamBold
    rightVal.TextSize = 11
    rightVal.TextXAlignment = Enum.TextXAlignment.Left
    rightVal.Parent = healthContainer

    -- 3. Distancia en metros
    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.Size = UDim2.new(1, 0, 0, 16)
    distLabel.Position = UDim2.new(0, 0, 0, 38)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "[0m]"
    distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    distLabel.TextStrokeTransparency = 0.3
    distLabel.Font = Enum.Font.GothamMedium
    distLabel.TextSize = 11
    distLabel.Parent = billboard

    espObjects[player] = {
        Billboard = billboard,
        NameLabel = nameLabel,
        HealthContainer = healthContainer,
        LeftVal = leftVal,
        RightVal = rightVal,
        BarFill = barFill,
        DistLabel = distLabel
    }
end

for _, plr in ipairs(Players:GetPlayers()) do
    CrearVisualParaJugador(plr)
end

Players.PlayerAdded:Connect(CrearVisualParaJugador)
Players.PlayerRemoving:Connect(LimpiarVisual)

-- ==========================================
-- BUCLE 1: MANTENER VELOCIDAD Y SALTO AL MORIR
-- ==========================================
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid and humanoid.Health > 0 then
        if velocidadActiva and humanoid.WalkSpeed ~= valorVelocidad then
            humanoid.WalkSpeed = valorVelocidad
        end

        if saltoActivo then
            humanoid.UseJumpPower = true
            if humanoid.JumpPower ~= valorSalto then
                humanoid.JumpPower = valorSalto
            end
        end
    end
end)

-- Función para restaurar los valores normales al apagar los toggles
local function ReiniciarValoresJugador(tipo)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if tipo == "Velocidad" or tipo == "Todo" then
        humanoid.WalkSpeed = DEFAULT_WALKSPEED
    end
    if tipo == "Salto" or tipo == "Todo" then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = DEFAULT_JUMPPOWER
    end
end

-- ==========================================
-- BUCLE 2: VISUALES PERSISTENTES AL MORIR/REAPARECER
-- ==========================================
RunService.RenderStepped:Connect(function()
    local algunoActivo = espNombres or espVida or espDistancia
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not espObjects[player] or not espObjects[player].Billboard or not espObjects[player].Billboard.Parent then
                if not espObjects[player] or not espObjects[player].Billboard then
                    CrearVisualParaJugador(player)
                end
            end

            local data = espObjects[player]
            local char = player.Character
            local head = char and char:FindFirstChild("Head")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if data and algunoActivo and char and head and hum and hum.Health > 0 then
                if data.Billboard.Parent ~= head then
                    data.Billboard.Parent = head
                end
                data.Billboard.Enabled = true

                -- Actualizar Nombre y Color
                data.NameLabel.Visible = espNombres
                data.NameLabel.TextColor3 = espColor

                -- Actualizar Barra de Vida y números de ambos lados
                data.HealthContainer.Visible = espVida
                if espVida then
                    local hp = math.floor(hum.Health)
                    local maxHp = math.floor(hum.MaxHealth)
                    local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)

                    data.LeftVal.Text = tostring(hp)
                    data.RightVal.Text = tostring(maxHp)
                    data.BarFill.Size = UDim2.new(ratio, 0, 1, 0)
                    data.BarFill.BackgroundColor3 = Color3.fromHSV(ratio * 0.33, 0.85, 0.95)
                end

                -- Actualizar Distancia
                data.DistLabel.Visible = espDistancia
                if espDistancia and myRoot and root then
                    local dist = math.floor((myRoot.Position - root.Position).Magnitude)
                    data.DistLabel.Text = "[" .. tostring(dist) .. "m]"
                end
            elseif data and data.Billboard then
                data.Billboard.Enabled = false
            end
        end
    end
end)

-- 3. Crear pestañas (Tabs) con iconos
local TabInicio = Window:Tab({
    Title = "menú principal",
    Icon = "house",
})

local TabJugador = Window:Tab({
    Title = "Jugador",
    Icon = "user",
})

local TabVisual = Window:Tab({
    Title = "Visual",
    Icon = "eye",
})

local TabAjustes = Window:Tab({
    Title = "Ajustes",
    Icon = "settings",
})

-- ==========================================
-- PESTAÑA: MENÚ PRINCIPAL
-- ==========================================
local SeccionInfo = TabInicio:Section({
    Title = "Información",
    Icon = "info",
})

SeccionInfo:Paragraph({
    Title = "Bienvenido a lvs",
    Desc = "Script creado by dss. Todas las funciones incluyen bucles automáticos anti-muerte.",
})

local SeccionAcciones = TabInicio:Section({
    Title = "Acciones Rápidas",
    Icon = "zap",
})

SeccionAcciones:Button({
    Title = "Probar Aviso",
    Desc = "Envía un aviso en pantalla",
    Icon = "bell",
    Callback = function()
        WindUI:Notify({
            Title = "📁 Aviso",
            Content = "Opción activada ✅",
            Icon = "check-circle",
            Duration = 3,
        })
    end,
})

SeccionAcciones:Input({
    Title = "Mensaje Personalizado",
    Desc = "Escribe un texto y presiona Enter",
    Placeholder = "Escribe aquí...",
    InputIcon = "message-square",
    Flag = "InputMensaje",
    Callback = function(texto)
        if texto ~= "" then
            WindUI:Notify({
                Title = "📁 Texto Enviado",
                Content = "Opción activada ✅ (" .. texto .. ")",
                Icon = "send",
                Duration = 3,
            })
        end
    end,
})

-- ==========================================
-- PESTAÑA: JUGADOR
-- ==========================================
local SeccionMovimiento = TabJugador:Section({
    Title = "Habilidades (Con Bucle)",
    Icon = "activity",
})

local ToggleVelocidad = SeccionMovimiento:Toggle({
    Title = "Activar Modo Rápido",
    Desc = "Bucle activo; al desactivar reinicia a 16",
    Icon = "flame",
    Value = false,
    Flag = "ToggleVelocidad",
    Callback = function(estado)
        velocidadActiva = estado
        if not estado then
            ReiniciarValoresJugador("Velocidad")
        end

        if scriptCargado then
            WindUI:Notify({
                Title = "📁 Velocidad",
                Content = estado and "Opción activada ✅" or "Valores reiniciados 🔄",
                Icon = estado and "check" or "rotate-ccw",
                Duration = 2,
            })
        end
    end,
})

local SliderVelocidad = SeccionMovimiento:Slider({
    Title = "Velocidad de Caminata",
    Step = 1,
    Flag = "SliderVelocidad",
    Value = {
        Min = 16,
        Max = 100,
        Default = 50,
    },
    Callback = function(valor)
        valorVelocidad = valor
    end,
})

local ToggleSalto = SeccionMovimiento:Toggle({
    Title = "Activar Súper Salto",
    Desc = "Bucle activo; al desactivar reinicia a 50",
    Icon = "arrow-up-circle",
    Value = false,
    Flag = "ToggleSalto",
    Callback = function(estado)
        saltoActivo = estado
        if not estado then
            ReiniciarValoresJugador("Salto")
        end

        if scriptCargado then
            WindUI:Notify({
                Title = "📁 Súper Salto",
                Content = estado and "Opción activada ✅" or "Valores reiniciados 🔄",
                Icon = estado and "check" or "rotate-ccw",
                Duration = 2,
            })
        end
    end,
})

local SliderSalto = SeccionMovimiento:Slider({
    Title = "Fuerza de Salto",
    Step = 5,
    Flag = "SliderSalto",
    Value = {
        Min = 50,
        Max = 250,
        Default = 100,
    },
    Callback = function(valor)
        valorSalto = valor
    end,
})

SeccionMovimiento:Button({
    Title = "Reiniciar Todo el Jugador",
    Desc = "Apaga los bucles y restaura valores normales",
    Icon = "rotate-ccw",
    Callback = function()
        velocidadActiva = false
        saltoActivo = false
        ToggleVelocidad:Set(false)
        ToggleSalto:Set(false)
        SliderVelocidad:Set(DEFAULT_WALKSPEED)
        SliderSalto:Set(DEFAULT_JUMPPOWER)
        ReiniciarValoresJugador("Todo")

        WindUI:Notify({
            Title = "📁 Jugador Reiniciado",
            Content = "Todos los valores volvieron a la normalidad 🔄",
            Icon = "refresh-cw",
            Duration = 3,
        })
    end,
})

-- ==========================================
-- PESTAÑA: VISUAL (ICONO EYE)
-- ==========================================
local SeccionESP = TabVisual:Section({
    Title = "Visuales en Tiempo Real (Con Bucle)",
    Icon = "scan-eye",
})

SeccionESP:Toggle({
    Title = "Nombres (Names)",
    Desc = "Sigue funcionando aunque los jugadores mueran",
    Icon = "tag",
    Value = false,
    Flag = "ToggleNames",
    Callback = function(estado)
        espNombres = estado
        if scriptCargado then
            WindUI:Notify({
                Title = "📁 Visual - Nombres",
                Content = estado and "Opción activada ✅" or "Opción desactivada ❌",
                Icon = estado and "check" or "x",
                Duration = 2,
            })
        end
    end,
})

SeccionESP:Toggle({
    Title = "Barra de Vida (Health Bar)",
    Desc = "Barra con vida actual/máxima que persiste al reaparecer",
    Icon = "heart-pulse",
    Value = false,
    Flag = "ToggleHealth",
    Callback = function(estado)
        espVida = estado
        if scriptCargado then
            WindUI:Notify({
                Title = "📁 Visual - Vida",
                Content = estado and "Opción activada ✅" or "Opción desactivada ❌",
                Icon = estado and "check" or "x",
                Duration = 2,
            })
        end
    end,
})

SeccionESP:Toggle({
    Title = "Distancia",
    Desc = "Muestra los metros en tiempo real",
    Icon = "ruler",
    Value = false,
    Flag = "ToggleDistancia",
    Callback = function(estado)
        espDistancia = estado
        if scriptCargado then
            WindUI:Notify({
                Title = "📁 Visual - Distancia",
                Content = estado and "Opción activada ✅" or "Opción desactivada ❌",
                Icon = estado and "check" or "x",
                Duration = 2,
            })
        end
    end,
})

-- ==========================================
-- PESTAÑA: AJUSTES
-- ==========================================
local SeccionVisual = TabAjustes:Section({
    Title = "Apariencia",
    Icon = "palette",
})

SeccionVisual:Dropdown({
    Title = "Seleccionar Tema",
    Flag = "DropdownTema",
    Values = { 
        "Dark", "Light", "Rose", "Plant", "Red", 
        "Indigo", "Sky", "Violet", "Amber", "Emerald", 
        "Midnight", "Crimson", "MonokaiPro", "CottonCandy", 
        "Mellowsi", "Rainbow" 
    },
    Value = "Dark",
    Callback = function(temaSeleccionado)
        WindUI:SetTheme(temaSeleccionado)
        if scriptCargado then
            WindUI:Notify({
                Title = "📁 Apariencia",
                Content = "Opción activada ✅ (Tema: " .. temaSeleccionado .. ")",
                Icon = "palette",
                Duration = 2,
            })
        end
    end,
})

SeccionVisual:Colorpicker({
    Title = "Color de Resaltado / Nombres",
    Desc = "Cambia el color de los nombres en Visual",
    Default = Color3.fromRGB(0, 145, 255),
    Flag = "ColorPersonalizado",
    Callback = function(color)
        espColor = color
        if scriptCargado then
            WindUI:Notify({
                Title = "📁 Color",
                Content = "Opción activada ✅",
                Icon = "droplet",
                Duration = 2,
            })
        end
    end,
})

local SeccionConfig = TabAjustes:Section({
    Title = "Configuración Guardada",
    Icon = "save",
})

local Config = Window.ConfigManager and Window.ConfigManager:CreateConfig("ConfigPrincipal", true)

SeccionConfig:Button({
    Title = "Guardar Configuración",
    Desc = "Guarda todos los ajustes actuales",
    Icon = "download",
    Callback = function()
        if Config then
            Config:Save()
            WindUI:Notify({
                Title = "📁 Configuración",
                Content = "Opción activada ✅ (Guardado)",
                Icon = "file-check",
                Duration = 2.5,
            })
        end
    end,
})

SeccionConfig:Button({
    Title = "Cargar Configuración",
    Desc = "Restaura los últimos ajustes guardados",
    Icon = "upload",
    Callback = function()
        if Config then
            Config:Load()
            WindUI:Notify({
                Title = "📁 Configuración",
                Content = "Opción activada ✅ (Cargado)",
                Icon = "folder-open",
                Duration = 2.5,
            })
        end
    end,
})

-- Seleccionar la primera pestaña al abrir
Window:SelectTab(1)

task.delay(0.5, function()
    scriptCargado = true
end)

print("✅ [lvs] WindUI cargado y bucles activos correctamente.")
