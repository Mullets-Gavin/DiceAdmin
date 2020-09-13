--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: Dice Admin is an admin script with PlayingCards
--]]

--[[
	[DOCUMENTATION]:
	https://github.com/Mullets-Gavin/DiceAdmin
]]--

--// logic
local DiceAdmin = {}
DiceAdmin.Keybind = Enum.KeyCode.F8
DiceAdmin.Admins = {46522586,38162374,5520567,22119678}
DiceAdmin.GroupID = 5018486
DiceAdmin.GroupRole = 230
DiceAdmin.Prefix = '-'
DiceAdmin.Commands = nil
DiceAdmin.Information = nil

--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
    cache[serviceName] = game:GetService(serviceName)
    return cache[serviceName]
end})

--// variables
local IsStudio = Services['RunService']:IsStudio()
local IsServer = Services['RunService']:IsServer()
local IsClient = Services['RunService']:IsClient()

local Interface = script:FindFirstChild('DiceUI')
local Modules = script:FindFirstChild('Modules')
local Network = script:FindFirstChild('Network')
local MsgService,Manager; do
	MsgService = require(Modules:WaitForChild('MsgService'))
	Manager = require(Modules:WaitForChild('Manager'))
end

--// functions
local function CreateArgs(message)
	local argCount = 0
	local cmdArgs = {}
	for index in string.gmatch(message,'[%w%-]+') do
		argCount = argCount + 1
		cmdArgs[argCount] = index
	end
	return cmdArgs
end

local function ExecuteCmd(speaker,message)
	for cmd,func in pairs(DiceAdmin.Commands) do
		if string.match(message, "[%w_]+") == cmd then
			func(speaker,CreateArgs(message),message)
		end
	end
end

function DiceAdmin.Launch(plr)
	if not table.find(DiceAdmin.Admins,plr.UserId) and not IsStudio then return end
	if IsServer then
		local UI = Interface:Clone()
		UI.Parent = plr:WaitForChild('PlayerGui')
		plr.Chatted:Connect(function(message)
			local newCmd = message
			if string.sub(newCmd,1,1) == DiceAdmin.Prefix then
				ExecuteCmd(plr.Name,string.sub(newCmd,2))
			end
		end)
	end
end

function DiceAdmin:Network(type,message,plr)
	if IsServer then
		if type == 'Admin' then
			if not table.find(DiceAdmin.Admins,plr.UserId) and not IsStudio then return end
			local newCmd = DiceAdmin.Prefix..message
			if string.sub(newCmd,1,1) == DiceAdmin.Prefix then
				ExecuteCmd(plr.Name,string.sub(newCmd,2))
			end
		end
	elseif IsClient then
		if type == 'Admin' then
			Network.Command:FireServer(type,message)
		elseif type == 'Info' then
			return Network.Info:InvokeServer()
		elseif type == 'Ping' then
			return Network.Ping:InvokeServer()
		end
	end
	return false
end

function DiceAdmin:Initialize()
	Services['Players'].PlayerAdded:Connect(function(Plr)
		DiceAdmin.Launch(Plr)
	end)
	for _,Plr in pairs(Services['Players']:GetPlayers()) do
		DiceAdmin.Launch(Plr)
	end
end

Manager.wrap(function()
	if IsServer then
		local currentClock = os.clock()
		while not _G.YieldForDeck and os.clock() - currentClock < 1 do Manager.wait() end
		if _G.YieldForDeck then
			local LoadLibrary = require(_G.YieldForDeck('PlayingCards'))
			DiceAdmin.Information = LoadLibrary('Information')
		else
			script.Parent = Services['ReplicatedStorage']
		end
		DiceAdmin.Commands = require(Modules.Commands)
		Interface.Parent = Services['ServerScriptService']
		Network.Command.OnServerEvent:Connect(function(plr,type,message)
			DiceAdmin:Network(type,message,plr)
		end)
		Network.Ping.OnServerInvoke = function()
			return true
		end
		Network.Info.OnServerInvoke = function()
			if DiceAdmin.Information then
				return DiceAdmin.Information:Retrieve()
			end
			return {}
		end
		MsgService:ConnectKey('MafiaChat',function(message)
			print(message)
		end)
	end
end)

return DiceAdmin