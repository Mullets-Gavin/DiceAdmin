--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: Dice Admin is an admin script with PlayingCards
--]]

--[[
	[DOCUMENTATION]:
	https://github.com/Mullets-Gavin/Mullet-Mafia/blob/master/DICEADMIN.md
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
local Interface = script:FindFirstChild('DiceUI')
local Modules = script:FindFirstChild('Modules')
local Network = script:FindFirstChild('Network')

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
	if not table.find(DiceAdmin.Admins,plr.UserId) and not Services['RunService']:IsStudio() then return end
	if Services['RunService']:IsServer() then
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
	if Services['RunService']:IsServer() then
		if not table.find(DiceAdmin.Admins,plr.UserId) and not Services['RunService']:IsStudio() then return end
		local newCmd = DiceAdmin.Prefix..message
		if string.sub(newCmd,1,1) == DiceAdmin.Prefix then
			ExecuteCmd(plr.Name,string.sub(newCmd,2))
		end
	elseif Services['RunService']:IsClient() then
		if type == 'Admin' then
			Network.Command:FireServer(type,message)
		elseif type == 'Info' then
			return Network.Info:InvokeServer()
		elseif type == 'Ping' then
			return Network.Ping:InvokeServer()
		end
	end
end

function DiceAdmin:Initialize()
	Services['Players'].PlayerAdded:Connect(function(Plr)
		DiceAdmin.Launch(Plr)
	end)
	for _,Plr in pairs(Services['Players']:GetPlayers()) do
		DiceAdmin.Launch(Plr)
	end
end

if Services['RunService']:IsServer() then
	local currentClock = tick()
	while not _G.YieldForDeck and tick() - currentClock < 1 do Services['RunService'].Heartbeat:Wait() end
	if _G.YieldForDeck then
		local LoadLibrary = require(_G.YieldForDeck('PlayingCards'))
		DiceAdmin.Information = LoadLibrary('Information',true)
		script.Parent = _G.YieldForDeck('DeckClient')
	else
		script.Parent = Services['ReplicatedStorage']
	end
	DiceAdmin.Commands = require(Modules.Commands)
	Modules.Parent = Services['ServerScriptService']
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
end

return DiceAdmin