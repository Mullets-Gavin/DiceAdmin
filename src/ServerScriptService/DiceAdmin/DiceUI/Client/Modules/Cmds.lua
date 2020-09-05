--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: Dice Admin is an admin script with PlayingCards
--]]

--// logic
local Commands = {}
Commands.Toggles = {}
Commands.Connections = {}
Commands.DiceAdmin = nil
Commands.LoadLibrary = nil
Commands.NoClip = require(script.Parent:WaitForChild('NoClip'))
Commands.Stats = require(script.Parent:WaitForChild('Stats'))

--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
    cache[serviceName] = game:GetService(serviceName)
    return cache[serviceName]
end})

--// variables
local Player = Services['Players'].LocalPlayer

--// functions
local function Print(arg1,arg2,arg3,arg4)
	print('[ADMIN]: Command:',arg1,'| Target:',arg2,'| Speaker:',arg3,'|',arg4)
end

local function Warn(arg1,arg2,arg3,arg4)
	warn('[ADMIN]: Command:',arg1,'| Target:',arg2,'| Speaker:',arg3,'|',arg4)
end

Commands.Admin = {
	['fov'] = function(cmdArgs)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'fov' then
			TARGET = TARGET or 70
			local Camera = Services['Workspace'].CurrentCamera
			Camera.FieldOfView = tonumber(TARGET)
			Print(COMMAND,TARGET,Player.Name,'Successful')
			return true
		end
		Warn(COMMAND,TARGET,Player.Name,'Failed')
		return false
	end;
	['fps'] = function(cmdArgs)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'fps' then
			TARGET = TARGET or 4
			TARGET = math.clamp(TARGET,1,99)
			local totals = 0
			local logs = {}
			for index = 1,TARGET do
				local fps = 1/Services['RunService'].RenderStepped:Wait()
				fps = math.round(fps)
				print('Test',string.format('%02.f',index)..':',fps..' FPS')
				table.insert(logs,fps)
				totals = totals + fps
				Services['RunService'].Heartbeat:Wait()
			end
			table.sort(logs, function(a, b) return a > b end)
			print('Results:','Min:',logs[#logs]..' FPS','| Max:',logs[1]..' FPS','| Average:',string.format('%.3f',tostring(totals/TARGET))..' FPS')
			Print(COMMAND,TARGET,Player.Name,'Successful')
			return true
		end
		Warn(COMMAND,TARGET,Player.Name,'Failed')
		return false
	end;
	['ping'] = function(cmdArgs)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'ping' then
			TARGET = TARGET or 4
			TARGET = math.clamp(TARGET,1,99)
			local totals = 0
			local logs = {}
			for index = 1,TARGET do
				local start = tick()
				Commands.DiceAdmin:Network('Ping')
				local ping = math.round((tick() - start) * 1000)
				print('Test',string.format('%02.f',index)..':',tostring(ping)..'ms')
				table.insert(logs,ping)
				totals = totals + ping
				Services['RunService'].Heartbeat:Wait()
			end
			table.sort(logs, function(a, b) return a > b end)
			print('Results:','Min:',logs[#logs]..'ms','| Max:',logs[1]..'ms','| Average:',string.format('%.3f',tostring(totals/TARGET))..'ms')
			Print(COMMAND,TARGET,Player.Name,'Successful')
			return true
		end
		Warn(COMMAND,TARGET,Player.Name,'Failed')
		return false
	end;
	['noclip'] = function(cmdArgs)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'noclip' then
			TARGET = TARGET or 'on'
			if TARGET == 'on' then
				Commands.NoClip.Enable()
			elseif TARGET == 'off' then
				Commands.NoClip.Disable()
			end
			Print(COMMAND,TARGET,Player.Name,'Successful')
			return true
		end
		Warn(COMMAND,TARGET,Player.Name,'Failed')
		return false
	end;
	['reverso'] = function(cmdArgs)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'reverso' then
			TARGET = TARGET or 'on'
			if TARGET == 'on' then
				Commands.Toggles['Reverso'] = true
			elseif TARGET == 'off' then
				Commands.Toggles['Reverso'] = false
			end
			Print(COMMAND,TARGET,Player.Name,'Successful')
			return true
		end
		Warn(COMMAND,TARGET,Player.Name,'Failed')
		return false
	end;
	['server'] = function(cmdArgs)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'server' then
			TARGET = 'Retrieved'
			local getInfo = Commands.DiceAdmin:Network('Info')
			print('Game:',getInfo['Name'])
			print('Creator:',getInfo['Creator'])
			print('Server Version:',getInfo['Version'])
			print('Game Version:',getInfo['Updated'])
			print('Outdated:',getInfo['Outdated'])
			print('Server ID:',getInfo['Server'])
			Print(COMMAND,TARGET,Player.Name,'Successful')
			return true
		end
		Warn(COMMAND,TARGET,Player.Name,'Failed')
		return false
	end;
	['stats'] = function(cmdArgs)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'stats' then
			if string.lower(TARGET) == 'launch' then
				Commands.Stats:Launch()
				Print(COMMAND,TARGET,Player.Name,'Successful')
				return true
			elseif string.lower(TARGET) == 'shutdown' then
				Commands.Stats:Shutdown()
				Print(COMMAND,TARGET,Player.Name,'Successful')
				return true
			elseif string.lower(TARGET) == 'pause' then
				Commands.Stats:Pause()
				Print(COMMAND,TARGET,Player.Name,'Successful')
				return true
			elseif string.lower(TARGET) == 'play' then
				Commands.Stats:Play()
				Print(COMMAND,TARGET,Player.Name,'Successful')
				return true
			end
		end
		Warn(COMMAND,TARGET,Player.Name,'Failed')
		return false
	end;
	['memory'] = function(cmdArgs)
		if not Commands.LoadLibrary then return end
		local COMMAND = cmdArgs[1]
		if COMMAND == 'memory' then
			local getMem = Commands.LoadLibrary('___PlayingCards')
			Print(COMMAND,getMem..' kilobytes',Player.Name,'Successful')
			return true
		end
		Warn(COMMAND,'N/A',Player.Name,'Failed')
		return false
	end;
	['test'] = function(cmdArgs)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'test' then
			TARGET = 'completed'
			Print(COMMAND,TARGET,Player.Name,'Successful')
			return true
		end
		Warn(COMMAND,TARGET,Player.Name,'Failed')
		return false
	end;
}

coroutine.wrap(function()
	local currentClock = tick()
	while not _G.YieldForDeck and tick() - currentClock < 1 do Services['RunService'].Heartbeat:Wait() end
	if _G.YieldForDeck then
		Commands.LoadLibrary = require(_G.YieldForDeck('PlayingCards'))
		Commands.DiceAdmin = Commands.LoadLibrary('DiceAdmin')
	else
		Commands.DiceAdmin = Services['ReplicatedStorage']:WaitForChild('DiceAdmin')
	end
end)()

return Commands