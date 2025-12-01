local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local dashSpeed = 120
local dashTime = 0.35
local hitboxSize = Vector3.new(6, 6, 6)
local damage = 40

local function doLoopDash(player)
	local char = player.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	-- mini user cut (ارتفاع بسيط)
	root.CFrame = root.CFrame * CFrame.new(0, 3, 0)
	task.wait(0.1)

	-- dash + نزول تحت
	local startTime = tick()
	while tick() - startTime < dashTime do
		root.Velocity = root.CFrame.LookVector * dashSpeed + Vector3.new(0, -100, 0)
		task.wait()
	end

	-- عمل hitbox أثناء الداش
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

	-- تدمير الأشخاص اللي يلمسهم
	local connection
	connection = hitbox.Touched:Connect(function(hit)
		local enemy = hit.Parent
		if enemy and enemy ~= char and enemy:FindFirstChildOfClass("Humanoid") then
			enemy:FindFirstChildOfClass("Humanoid"):TakeDamage(damage)
		end
	end)

	task.wait(0.2)
	hitbox:Destroy()
	if connection then connection:Disconnect() end

	-- يرجع اللاعب فوق بسرعة
	root.Velocity = Vector3.new(0, 160, 0)
end

-- مثال زر تشغيل داخل اللعبة
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		task.wait(2)
		-- تقدر تغيّر F وتخليه افنت زر من داخل لعبتك
		char:WaitForChild("HumanoidRootPart")

		local UIS = game:GetService("UserInputService")
		UIS.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if input.KeyCode == Enum.KeyCode.F then
				doLoopDash(player)
			end
		end)
	end)
end)
