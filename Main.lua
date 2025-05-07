-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local PlayerGui = player:WaitForChild("PlayerGui")

-- VARIABLES
local activeBlur = Instance.new("BlurEffect", Lighting)
activeBlur.Size = 0
activeBlur.Enabled = false

-- UI BASE
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "VisualSettingsUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- CONTAINER
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 400, 0, 300)
frame.Position = UDim2.new(0.5, -200, 0.5, -150)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.2
frame.Visible = false  -- Initially hidden
frame.ClipsDescendants = true

local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 12)

local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Thickness = 1
uiStroke.Color = Color3.fromRGB(80, 80, 80)

-- DYNAMIC BLUR BACKGROUND (EXTRA POLISH)
local blurGui = Instance.new("Frame", frame)
blurGui.BackgroundTransparency = 1
blurGui.Size = UDim2.new(1, 0, 1, 0)
blurGui.ZIndex = -1

local blurBG = Instance.new("BlurEffect", Lighting)
blurBG.Size = 15
blurBG.Enabled = false

-- FADE-IN WELCOME
local welcome = Instance.new("TextLabel", screenGui)
welcome.Size = UDim2.new(1, 0, 0.15, 0)
welcome.Position = UDim2.new(0, 0, 0.4, 0)
welcome.BackgroundTransparency = 1
welcome.Text = "Welcome to Enhanced Mode"
welcome.TextScaled = true
welcome.TextColor3 = Color3.fromRGB(255, 255, 255)
welcome.Font = Enum.Font.GothamBold

TweenService:Create(welcome, TweenInfo.new(1, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
task.wait(2)
TweenService:Create(welcome, TweenInfo.new(1), {TextTransparency = 1}):Play()

-- TOGGLE GUI WITH TAB KEY
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.Tab and not gameProcessed then
		frame.Visible = not frame.Visible  -- Toggle visibility
		blurBG.Enabled = frame.Visible  -- Toggle blur effect
	end
end)

-- PRESET FUNCTIONS
local function applyPreset(preset)
	if preset == "Realistic" then
		Lighting.Brightness = 3
		Lighting.EnvironmentDiffuseScale = 0.5
		Lighting.EnvironmentSpecularScale = 1
		Lighting.Ambient = Color3.fromRGB(33, 33, 33)
	elseif preset == "Cinematic" then
		Lighting.Brightness = 2
		Lighting.EnvironmentDiffuseScale = 0.2
		Lighting.Ambient = Color3.fromRGB(10, 10, 10)
	elseif preset == "Vibrant" then
		Lighting.Brightness = 4
		Lighting.EnvironmentSpecularScale = 1.5
	elseif preset == "Retro" then
		Lighting.Brightness = 1
		Lighting.Ambient = Color3.fromRGB(128, 64, 64)
	end
end

-- PRESET BUTTONS
local presets = {"Realistic", "Cinematic", "Vibrant", "Retro"}
for i, name in ipairs(presets) do
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0.4, 0, 0, 30)
	btn.Position = UDim2.new(0.05, 0, 0, 40 * i)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = name
	btn.Font = Enum.Font.Gotham
	btn.TextScaled = true
	local uic = Instance.new("UICorner", btn)
	uic.CornerRadius = UDim.new(0, 6)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		applyPreset(name)
	end)
end

-- FOV SLIDER
local fov = 90
local fovSlider = Instance.new("TextButton", frame)
fovSlider.Size = UDim2.new(0.9, 0, 0, 30)
fovSlider.Position = UDim2.new(0.05, 0, 0.8, 0)
fovSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
fovSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
fovSlider.Text = "FOV: " .. fov
fovSlider.Font = Enum.Font.Gotham
fovSlider.TextScaled = true
Instance.new("UICorner", fovSlider)

fovSlider.MouseButton1Click:Connect(function()
	fov += 10
	if fov > 120 then fov = 60 end
	fovSlider.Text = "FOV: " .. fov
	TweenService:Create(camera, TweenInfo.new(0.3), {FieldOfView = fov}):Play()
end)

-- BLUR ON TURNING
local lastRotation = camera.CFrame.LookVector
RunService.RenderStepped:Connect(function()
	local current = camera.CFrame.LookVector
	local angle = math.acos(current:Dot(lastRotation))
	if angle > 0.02 then
		activeBlur.Enabled = true
		activeBlur.Size = math.clamp(angle * 100, 5, 20)
	else
		activeBlur.Enabled = false
	end
	lastRotation = current
end)

-- NOTIFICATIONS
local function showNotification(text)
	local notif = Instance.new("TextLabel", screenGui)
	notif.Size = UDim2.new(0.25, 0, 0, 40)
	notif.Position = UDim2.new(0.7, 0, 0.05, 0)
	notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	notif.TextColor3 = Color3.fromRGB(255, 255, 255)
	notif.Font = Enum.Font.GothamBold
	notif.TextScaled = true
	notif.Text = text
	notif.AnchorPoint = Vector2.new(0.5, 0)
	notif.BackgroundTransparency = 0.2
	Instance.new("UICorner", notif)

	TweenService:Create(notif, TweenInfo.new(0.4), {Position = notif.Position - UDim2.new(0, 0, 0.03, 0)}):Play()
	task.delay(2, function()
		TweenService:Create(notif, TweenInfo.new(0.3), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
		task.wait(0.4)
		notif:Destroy()
	end)
end

-- Example notifications
task.delay(1, function()
	showNotification("FOV set to 90.")
	task.wait(0.6)
	showNotification("Visual Preset GUI ready.")
	task.wait(0.6)
	showNotification("Use Tab to toggle it.")
end)
