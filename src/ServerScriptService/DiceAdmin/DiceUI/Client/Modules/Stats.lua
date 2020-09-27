--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: displays ping & fps stats in real time
--]]

--// logic
local Stats = {}
Stats.Updating = false
Stats.Enabled = false
Stats.Paused = false

--// services
local LoadLibrary = require(game:GetService('ReplicatedStorage'):WaitForChild('PlayingCards'))
local Services = setmetatable({}, {__index = function(cache, serviceName)
	cache[serviceName] = game:GetService(serviceName)
	return cache[serviceName]
end})

--// variables
local Player = Services['Players'].LocalPlayer
local PlayerScripts = Player:WaitForChild('PlayerScripts')

local DiceAdmin = LoadLibrary('DiceAdmin')
local ChatMain = require(PlayerScripts:WaitForChild('ChatScript'):WaitForChild('ChatMain'))

local Container = script.Parent.Parent.Parent:WaitForChild('Stats')
local FPS = Container.FPS
local PING = Container.Ping

--// functions
local function Display(state)
	local getChat = Services['StarterGui']:GetCoreGuiEnabled(Enum.CoreGuiType.Chat)
	if getChat then
		Container.Position = UDim2.new(0, 148, 0, 4)
	else
		Container.Position = UDim2.new(0, 104, 0, 4)
	end
	Container.Visible = state
end

local function UpdatePing()
	local start = os.clock()
	DiceAdmin:Network('Ping')
	local ping = math.round((os.clock() - start) * 1000)
	local message = 'PING: '..ping..'ms'
	local getSize = Services['TextService']:GetTextSize(message,PING.Title.TextSize,PING.Title.Font,Vector2.new(1000,PING.Title.TextSize))
	PING.Title.Size = UDim2.new(0, getSize.X, 0, getSize.Y)
	PING.Size = UDim2.new(0, getSize.X + 14, 0, 32)
	PING.Title.Text = message
end

local function UpdateFPS()
	local fps = 1/Services['RunService'].RenderStepped:Wait()
	fps = math.round(fps)
	local message = 'FPS: '..fps
	local getSize = Services['TextService']:GetTextSize(message,FPS.Title.TextSize,FPS.Title.Font,Vector2.new(1000,FPS.Title.TextSize))
	FPS.Title.Size = UDim2.new(0, getSize.X, 0, getSize.Y)
	FPS.Size = UDim2.new(0, getSize.X + 14, 0, 32)
	FPS.Title.Text = message
end

function Stats:Play()
	if Stats.Enabled and Stats.Paused then
		Stats.Paused = false
	end
end

function Stats:Pause()
	if Stats.Enabled then
		Stats.Paused = true
	end
end

function Stats:Shutdown()
	if Stats.Enabled then
		Stats.Enabled = false
		Stats.Paused = false
		Display(false)
	end
end

function Stats:Launch()
	if not Stats.Enabled then
		Stats.Enabled = true
		Display(true)
		coroutine.wrap(function()
			while Stats.Enabled do
				if not Stats.Paused then
					UpdatePing()
					UpdateFPS()
				end
				wait(0.5)
			end
		end)()
	end
end

ChatMain.CoreGuiEnabled:connect(function()
	Display(false)
end)

return Stats