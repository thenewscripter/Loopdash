local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local dashSpeed = 120
local dashTime = 0.35
local hitboxSize = Vector3.new(6,6,6)
local damage = 40
local rotationSpeed = 10

local sideDashCooldown = 2
local frontDashCooldown = 5

local dashEnabled = true
local lastSideDash = 0
local lastFrontDash = 0

-- ScreenGui
local gui = Instance.new("ScreenGui", PlayerGui)
gui.ResetOnSpawn = false

-- Buttons
local function createButton(name, text, pos)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0,100,0,50)
	btn.Position = pos
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Parent = gui
	return btn
end

local frontBtn = createButton("FrontDash", "Front Dash", UDim2.new(0.1,0,0.8,0))
local sideBtn = createButton("SideDash", "Side Dash", UDim2.new(0.3,0,0.8,0))
local toggleBtn = createButton("ToggleDash", "Dash On/Off", UDim2.new(0.5,0,0.8,0))

-- Closest player
local function getClosestPlayer()
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
	local root = char.HumanoidRootPart
	local closest = nil
	local shortestDistance = math.huge
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
			if dist < shortestDistance then
				shortestDistance = dist
				closest = p
			end
		end
	end
	return closest
end

-- Dash function
local function doLoopDash(isFrontDash)
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	local cooldown = isFrontDash and frontDashCooldown or sideDashCooldown
	local lastDash = isFrontDash and lastFrontDash or lastSideDash
	if tick() - lastDash < cooldown then return end

	if isFrontDash then
		lastFrontDash = tick()
	else
		lastSideDash = tick()
	end

	local target = isFrontDash and getClosestPlayer()
	local startTime = tick()

	local hitbox = Instance.new("Part")
	hitbox.Size = hitboxSize
	hitbox.Transparency = 1
	hitbox.CanCollide = false
	hitbox.Anchored = false
	hitbox.Parent = workspace

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hitbox
	weld.Part1 = root
	weld.Parent = hitbox

	local connection
	connection = hitbox.Touched:Connect(function(hit)
		local enemy = hit.Parent
		if enemy and enemy ~= char and enemy:FindFirstChildOfClass("Humanoid") then
			enemy:FindFirstChildOfClass("Humanoid"):TakeDamage(damage)
		end
	end)

	while tick() - startTime < dashTime do
		if isFrontDash and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			local dir = (target.Character.HumanoidRootPart.Position - root.Position).Unit
			root.Velocity = dir * dashSpeed + Vector3.new(0,-50,0)
			root.CFrame = CFrame.lookAt(root.Position, target.Character.HumanoidRootPart.Position) * CFrame.Angles(0, math.rad(rotationSpeed),0)
		else
			root.Velocity = root.CFrame.LookVector * dashSpeed + Vector3.new(0,-50,0)
			root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(rotationSpeed),0)
		end
		RunService.Heartbeat:Wait()
	end

	hitbox:Destroy()
	if connection then connection:Disconnect() end
	root.Velocity = Vector3.new(0,160,0)
end

-- Button events
frontBtn.MouseButton1Click:Connect(function()
	if dashEnabled then
		doLoopDash(true)
	end
end)

sideBtn.MouseButton1Click:Connect(function()
	if dashEnabled then
		doLoopDash(false)
	end
end)

toggleBtn.MouseButton1Click:Connect(function()
	dashEnabled = not dashEnabled
	if dashEnabled then
		toggleBtn.Text = "Dash On"
	else
		toggleBtn.Text = "Dash Off"
	end
end)
