local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local PlayerGui = player:WaitForChild("PlayerGui")

TweenService:Create(camera, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	FieldOfView = 120
}):Play()

local function applyVisualEnhancements()
	Lighting.Technology = Enum.Technology.Future
	Lighting.GlobalShadows = true
	Lighting.EnvironmentDiffuseScale = 0.5
	Lighting.EnvironmentSpecularScale = 1
	Lighting.Ambient = Color3.fromRGB(33, 33, 33)
	Lighting.OutdoorAmbient = Color3.fromRGB(80, 80, 80)
	Lighting.Brightness = 3

	if not Lighting:FindFirstChildOfClass("BloomEffect") then
		local bloom = Instance.new("BloomEffect")
		bloom.Intensity = 1.5
		bloom.Threshold = 0.8
		bloom.Size = 56
		bloom.Parent = Lighting
	end

	if not Lighting:FindFirstChildOfClass("ColorCorrectionEffect") then
		local colorCorrection = Instance.new("ColorCorrectionEffect")
		colorCorrection.Brightness = 0.1
		colorCorrection.Contrast = 0.2
		colorCorrection.Saturation = 0.3
		colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
		colorCorrection.Parent = Lighting
	end

	if not Lighting:FindFirstChildOfClass("SunRaysEffect") then
		local sunRays = Instance.new("SunRaysEffect")
		sunRays.Intensity = 0.15
		sunRays.Spread = 0.6
		sunRays.Parent = Lighting
	end

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

local NOTIFICATION_LIFETIME = 3
local SLIDE_TIME = 0.4
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

local function roundify(obj)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = obj
end

local function rearrangeNotifications()
	for i, notif in ipairs(notifications) do
		local targetY = (i - 1) * (40 + SPACING)
		TweenService:Create(notif, TweenInfo.new(0.3), {
			Position = UDim2.new(1, -10, 0, targetY)
		}):Play()
	end
end

local function showNotification(message)
	local notif = Instance.new("TextLabel")
	notif.Text = message
	notif.Size = UDim2.new(1, -20, 0, 40)
	notif.Position = UDim2.new(1, 100, 0, 0)
	notif.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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

	table.insert(notifications, notif)
	rearrangeNotifications()

	TweenService:Create(notif, TweenInfo.new(SLIDE_TIME), {
		Position = UDim2.new(1, -10, 0, ( #notifications - 1 ) * (40 + SPACING))
	}):Play()

	task.delay(NOTIFICATION_LIFETIME, function()
		TweenService:Create(notif, TweenInfo.new(SLIDE_TIME), {
			Position = UDim2.new(1, 100, 0, notif.Position.Y.Offset)
		}):Play()
		task.wait(SLIDE_TIME)
		notif:Destroy()

		for i, v in ipairs(notifications) do
			if v == notif then
				table.remove(notifications, i)
				break
			end
		end
		rearrangeNotifications()
	end)
end

task.wait(1)
showNotification("FOV set to 120.")
task.wait(1)
showNotification("Visual quality enhanced.")
task.wait(1)
showNotification("Thanks for using my script!")
