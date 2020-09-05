--[[
	@Author: Lucas W. (codes4breakfast)
	@Desc: A No Clip module for DiceAdmin
--]]

local noclipping = false
local player = game:GetService("Players").LocalPlayer
local key_map = {
	[Enum.KeyCode.W] = false,
	[Enum.KeyCode.A] = false,
	[Enum.KeyCode.S] = false,
	[Enum.KeyCode.D] = false,
	[Enum.KeyCode.Q] = false,
	[Enum.KeyCode.Z] = false,
}
local move_dir = Vector3.new(0,0,0)
local max_velocity = 48
local velocity = 0
local accel = 24
local deccel = 48

local function character()
	local c = player.Character
	local h = c:FindFirstChild("Humanoid")
	if h and h.Health > 0 then
		return player.Character
	else
		return nil
	end
end

local function toggle_on()
	local c = character()
	if c then
		c.PrimaryPart.Velocity = Vector3.new(0,0,0)
		c.PrimaryPart.Anchored = true
		c.Humanoid.PlatformStand = true
		noclipping = true
		velocity = 0
	end
end

local function toggle_off()
	noclipping = false
	
	local c = character()
	if c then
		c.PrimaryPart.Velocity = Vector3.new(0,0,0)
		c.PrimaryPart.Anchored = false
		c.Humanoid.PlatformStand = false
	end
end

local function update(dt)
	if not noclipping then return end
	local c = character()
	if not c then return end
	local cam_cf = workspace.CurrentCamera.CFrame
	cam_cf -= cam_cf.p
	c.PrimaryPart.CFrame = cam_cf + (c.PrimaryPart.Position + cam_cf * (move_dir * velocity * dt))
	if move_dir.Magnitude > 0 then
		velocity = math.clamp(velocity + dt * accel, 0, max_velocity)
	else
		velocity = math.clamp(velocity - dt * deccel, 0, max_velocity)
	end
end

local function handle_keypress(io, gpe)
	--if gpe then return end
	if io.UserInputType == Enum.UserInputType.Keyboard and key_map[io.KeyCode] ~= nil then
		key_map[io.KeyCode] = io.UserInputState == Enum.UserInputState.Begin
		
		move_dir = Vector3.new(0,0,0)
		if key_map[Enum.KeyCode.W] then
			move_dir += Vector3.new(0,0,-1)
		end
		if key_map[Enum.KeyCode.S] then
			move_dir += Vector3.new(0,0,1)
		end
		if key_map[Enum.KeyCode.A] then
			move_dir += Vector3.new(-1,0,0)
		end
		if key_map[Enum.KeyCode.D] then
			move_dir += Vector3.new(1,0,0)
		end
		if key_map[Enum.KeyCode.Q] then
			move_dir += Vector3.new(0,1,0)
		end
		if key_map[Enum.KeyCode.Z] then
			move_dir += Vector3.new(0,-1,0)
		end
	end
end

player.CharacterAdded:Connect(function(c)
	toggle_off()
	
	local h = c:WaitForChild("Humanoid", 5)
	if h then
		h.Died:Connect(function()
			toggle_off()
		end)
	end
end)

game:GetService("UserInputService").InputBegan:Connect(handle_keypress)
game:GetService("UserInputService").InputEnded:Connect(handle_keypress)
game:GetService("RunService"):BindToRenderStep("noclip", Enum.RenderPriority.Input.Value+1, update)

local controls = {Enable = toggle_on, Disable = toggle_off}
return controls