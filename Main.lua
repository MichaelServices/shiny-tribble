local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local PlayerGui = player:WaitForChild("PlayerGui")

-- FOV Tween
TweenService:Create(camera, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    FieldOfView = 120
}):Play()

-- Apply visual enhancements
local function applyVisualEnhancements()
    Lighting.Technology = Enum.Technology.Future
    Lighting.GlobalShadows = true
    Lighting.EnvironmentDiffuseScale = 0.5
    Lighting.EnvironmentSpecularScale = 1
    Lighting.Ambient = Color3.fromRGB(33, 33, 33)
    Lighting.OutdoorAmbient = Color3.fromRGB(80, 80, 80)
    Lighting.Brightness = 3

    -- Bloom Effect
    if not Lighting:FindFirstChildOfClass("BloomEffect") then
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 1.5
        bloom.Threshold = 0.8
        bloom.Size = 56
        bloom.Parent = Lighting
    end

    -- Color Correction
    if not Lighting:FindFirstChildOfClass("ColorCorrectionEffect") then
        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Brightness = 0.1
        colorCorrection.Contrast = 0.2
        colorCorrection.Saturation = 0.3
        colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
        colorCorrection.Parent = Lighting
    end

    -- Sun Rays Effect
    if not Lighting:FindFirstChildOfClass("SunRaysEffect") then
        local sunRays = Instance.new("SunRaysEffect")
        sunRays.Intensity = 0.15
        sunRays.Spread = 0.6
        sunRays.Parent = Lighting
    end

    -- Depth of Field
    if not Lighting:FindFirstChildOfClass("DepthOfFieldEffect") then
        local dof = Instance.new("DepthOfFieldEffect")
        dof.FarIntensity = 0.05
        dof.FocusDistance = 300
        dof.InFocusRadius = 100
        dof.NearIntensity = 0.05
        dof.Parent = Lighting
    end
end
applyVisualEnhancements()

-- Notification system setup
local NOTIFICATION_LIFETIME = 3
local SLIDE_TIME = 0.4
local FADE_TIME = 0.3
local SPACING = 10
local notifications = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NotificationGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local container = Instance.new("Frame")
container.Name = "NotificationContainer"
container.Size = UDim2.new(0.3, 0, 1, 0)
container.Position = UDim2.new(0.65, 0, 0, 10)
container.BackgroundTransparency = 1
container.Parent = screenGui

-- Roundify function for corners
local function roundify(obj)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = obj
end

-- Rearrange notifications when they slide in/out
local function rearrangeNotifications()
    for i, notif in ipairs(notifications) do
        local targetY = (i - 1) * (40 + SPACING)
        TweenService:Create(notif, TweenInfo.new(0.3), {
            Position = UDim2.new(1, -10, 0, targetY)
        }):Play()
    end
end

-- Show notifications with smooth animations
local function showNotification(message, notifColor)
    local notif = Instance.new("TextLabel")
    notif.Text = message
    notif.Size = UDim2.new(1, -20, 0, 40)
    notif.Position = UDim2.new(1, 100, 0, 0)
    notif.BackgroundColor3 = notifColor or Color3.fromRGB(30, 30, 30)
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.Font = Enum.Font.Gotham
    notif.TextScaled = true
    notif.BackgroundTransparency = 0.2
    notif.BorderSizePixel = 0
    notif.AnchorPoint = Vector2.new(1, 0)
    notif.ZIndex = 2
    notif.TextWrapped = true
    notif.TextXAlignment = Enum.TextXAlignment.Left
    notif.TextYAlignment = Enum.TextYAlignment.Center
    notif.Parent = container
    roundify(notif)

    -- Slide in the notification
    table.insert(notifications, notif)
    rearrangeNotifications()

    TweenService:Create(notif, TweenInfo.new(SLIDE_TIME), {
        Position = UDim2.new(1, -10, 0, (#notifications - 1) * (40 + SPACING))
    }):Play()

    -- Fade in and out with delay
    TweenService:Create(notif, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.8
    }):Play()

    -- Handle notification lifetime
    task.delay(NOTIFICATION_LIFETIME, function()
        TweenService:Create(notif, TweenInfo.new(SLIDE_TIME), {
            Position = UDim2.new(1, 100, 0, notif.Position.Y.Offset)
        }):Play()

        task.wait(SLIDE_TIME)
        notif:Destroy()

        -- Clean up notification list and rearrange
        for i, v in ipairs(notifications) do
            if v == notif then
                table.remove(notifications, i)
                break
            end
        end
        rearrangeNotifications()
    end)
end

-- Show initial notifications
task.wait(1)
showNotification("FOV set to 120.", Color3.fromRGB(50, 50, 255))  -- Blue notification
task.wait(1)
showNotification("Visual quality enhanced.", Color3.fromRGB(50, 255, 50))  -- Green notification
task.wait(1)
showNotification("Thanks for using my script!", Color3.fromRGB(255, 165, 0))  -- Orange notification
