--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: Dice Admin is an admin script with PlayingCards
--]]

--// logic
local Cmds = {}
Cmds.CommandList = nil
Cmds.DataStore = nil
Cmds.LoadString = nil

--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
    cache[serviceName] = game:GetService(serviceName)
    return cache[serviceName]
end})

--// variables
local Modules = script.Parent
local repr = require(Modules:WaitForChild('repr'))
local MsgService = require(Modules:WaitForChild('MsgService'))
local Manager = require(Modules:WaitForChild('Manager'))

--// functions
local function Print(arg1,arg2,arg3,arg4)
	print('[DICE ADMIN]: Command:',arg1,'| Target:',arg2,'| Speaker:',arg3,'|',arg4)
end

local function Warn(arg1,arg2,arg3,arg4)
	warn('[DICE ADMIN]: Command:',arg1,'| Target:',arg2,'| Speaker:',arg3,'|',arg4)
end

local function GetPlayer(compareText,userID)
	if userID and tonumber(compareText) then
		if Services['Players']:GetNameFromUserIdAsync(compareText) then
			return tonumber(compareText)
		end
	end
	if tonumber(compareText) and not userID then
		local getPlr = Services['Players']:GetPlayerByUserId(compareText)
		if getPlr then
			return getPlr
		end
	end
	local closestTable = {
		['User'] = '';
		['Count'] = 0;
	}
	for Index,Compare in pairs(Services['Players']:GetPlayers()) do
		local compareName = string.match(string.lower(Compare.Name),string.lower(compareText))
		if compareName then
			if #compareName > closestTable['Count'] then
				closestTable['User'] = Compare
				closestTable['Count'] = #compareName
			end
		end
	end
    if closestTable['Count'] == 0 and closestTable['User'] == '' then
		return false
	else
		if userID then
			return closestTable['User'].UserId
		else
			return closestTable['User']
		end
	end
end

local function ClearPlayer(message,userID)
	local findPlr = GetPlayer(userID,false)
	if findPlr then
		findPlr:Kick(message)
		return
	end
	local MessageReplies,MessageData,MessageOptional = Cmds.MsgService.RepliesAsync(userID)
	if MessageReplies then
		MessageOptional:Disconnect()
		return
	else
		MessageData:Disconnect()
	end
	return
end

local Commands = {
	-- IN GAME DOCUMENTATION
	['help'] = function(speaker,cmdArgs,fullMsg)
		local COMMAND = cmdArgs[1]
		if COMMAND == 'help' then
			local counter = 0
			for index,cmds in pairs(Cmds.CommandList) do
				counter = counter + 1
				print('['..string.format('%02.f',counter)..']:',index)
				Services['RunService'].Heartbeat:Wait()
			end
		end
	end;
	-- BASIC ADMIN
	['re'] = function(speaker,cmdArgs,fullMsg)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 're' then
			local targetPlayer = GetPlayer(TARGET)
			if targetPlayer and targetPlayer.Character then
				local currentpos = targetPlayer.Character.HumanoidRootPart.Position
				targetPlayer:LoadCharacter()
				wait()
				targetPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(currentpos)
				Print(COMMAND,targetPlayer.Name,speaker,'Successful')
				return
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer.Name,speaker,'Failed')
			end
			return
		end
	end;
	['spawn'] = function(speaker,cmdArgs,fullMsg)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'spawn' then
			local targetPlayer = GetPlayer(TARGET)
			if targetPlayer then
				targetPlayer:LoadCharacter()
				Print(COMMAND,targetPlayer.Name,speaker,'Successful')
				return
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer.Name,speaker,'Failed')
			end
			return
		end
	end;
	['heal'] = function(speaker,cmdArgs,fullMsg)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'heal' then
			local targetPlayer = GetPlayer(TARGET)
			if targetPlayer and targetPlayer.Character then
				local humanoid = targetPlayer.Character:FindFirstChild('Humanoid')
				if humanoid then
					humanoid.Health = humanoid.MaxHealth
					Print(COMMAND,targetPlayer.Name,speaker,'Successful')
					return
				end
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer.Name,speaker,'Failed')
			end
			return
		end
	end;
	['kill'] = function(speaker,cmdArgs,fullMsg)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'kill' then
			local targetPlayer = GetPlayer(TARGET)
			if targetPlayer and targetPlayer.Character then
				local humanoid = targetPlayer.Character:FindFirstChild('Humanoid')
				if humanoid then
					humanoid.Health = 0
					Print(COMMAND,targetPlayer.Name,speaker,'Successful')
					return
				end
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer.Name,speaker,'Failed')
			end
			return
		end
	end;
	['say'] = function(speaker,cmdArgs,fullMsg)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'say' then
			local txt = string.sub(fullMsg,#COMMAND + 2)
			if txt then
				local parse = '[CHAT]['..speaker..']: '..txt
				MsgService:FireEvent('MafiaChat',parse)
				Services['RunService'].Heartbeat:Wait()
				print(parse)
				return
			end
			if not txt then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,txt,speaker,'Failed')
			end
			return
		end
	end;
	['m'] = function(speaker,cmdArgs,fullMsg)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'm' then
			local txt = string.sub(fullMsg,#COMMAND + 2)
			if txt then
				local message = Instance.new('Message')
				message.Text = txt
				message.Parent = Services['Workspace']
				Print(COMMAND,txt,speaker,'Successful')
				wait(10)
				message:Destroy()
				return
			end
			if not txt then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,txt,speaker,'Failed')
			end
			return
		end
	end;
	['h'] = function(speaker,cmdArgs,fullMsg)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'h' then
			local txt = string.sub(fullMsg,#COMMAND + 2)
			if txt then
				local hint = Instance.new('Hint')
				hint.Text = txt
				hint.Parent = Services['Workspace']
				Print(COMMAND,txt,speaker,'Successful')
				wait(10)
				hint:Destroy()
				return
			end
			if not txt then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,txt,speaker,'Failed')
			end
			return
		end
	end;
	['tip'] = function(speaker,cmdArgs,fullMsg)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'tip' then
			local txt = string.sub(fullMsg,#COMMAND + 2)
			if txt then
				local hint = Instance.new('Hint')
				hint.Text = txt
				hint.Parent = Services['Workspace']
				Print(COMMAND,txt,speaker,'Successful')
				return
			end
			if not txt then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,txt,speaker,'Failed')
			end
			return
		end
	end;
	['to'] = function(speaker,cmdArgs,fullMsg)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'to' then
			local targetPlayer = GetPlayer(TARGET)
			local speakerPlayer = GetPlayer(speaker)
			if targetPlayer and targetPlayer.Character and speakerPlayer and speakerPlayer.Character then
				local targetHRP = targetPlayer.Character:FindFirstChild('HumanoidRootPart')
				local speakerHRP = speakerPlayer.Character:FindFirstChild('HumanoidRootPart')
				if targetHRP and speakerHRP then
					speakerPlayer.Character.Humanoid.Jump = true
					speakerHRP.CFrame = (targetHRP.CFrame * CFrame.Angles(0,math.rad(90),0) * CFrame.new(5+.2,0,0))*CFrame.Angles(0,math.rad(90),0)
					Print(COMMAND,targetPlayer.Name,speaker,'Successful')
					return
				end
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer.Name,speaker,'Failed')
			end
			return
		end
	end;
	['bring'] = function(speaker,cmdArgs,fullMsg)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'bring' then
			local targetPlayer = GetPlayer(TARGET)
			local speakerPlayer = GetPlayer(speaker)
			if targetPlayer and targetPlayer.Character and speakerPlayer and speakerPlayer.Character then
				local targetHRP = targetPlayer.Character:FindFirstChild('HumanoidRootPart')
				local speakerHRP = speakerPlayer.Character:FindFirstChild('HumanoidRootPart')
				if targetHRP and speakerHRP then
					targetPlayer.Character.Humanoid.Jump = true
					targetHRP.CFrame = (speakerHRP.CFrame * CFrame.Angles(0,math.rad(90),0) * CFrame.new(5+.2,0,0))*CFrame.Angles(0,math.rad(90),0)
					Print(COMMAND,targetPlayer.Name,speaker,'Successful')
					return
				end
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer.Name,speaker,'Failed')
			end
			return
		end
	end;
	['health'] = function(speaker,cmdArgs,fullMsg)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		local VALUE = cmdArgs[3]
		if COMMAND == 'health' then
			local targetPlayer = GetPlayer(TARGET)
			if targetPlayer and targetPlayer.Character and tonumber(VALUE) then
				local humanoid = targetPlayer.Character:FindFirstChild('Humanoid')
				if humanoid then
					humanoid.MaxHealth = VALUE
					humanoid.Health = VALUE
					Print(COMMAND,targetPlayer.Name,speaker,'Successful')
					return
				end
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer.Name,speaker,'Failed')
			end
			return
		end
	end;
	['speed'] = function(speaker,cmdArgs,fullMsg)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		local VALUE = cmdArgs[3]
		if COMMAND == 'speed' then
			local targetPlayer = GetPlayer(TARGET)
			if targetPlayer and targetPlayer.Character and tonumber(VALUE) then
				local humanoid = targetPlayer.Character:FindFirstChild('Humanoid')
				if humanoid then
					humanoid.WalkSpeed = VALUE
					Print(COMMAND,targetPlayer.Name,speaker,'Successful')
					return
				end
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer.Name,speaker,'Failed')
			end
			return
		end
	end;
	['jump'] = function(speaker,cmdArgs,fullMsg)
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		local VALUE = cmdArgs[3]
		if COMMAND == 'jump' then
			local targetPlayer = GetPlayer(TARGET)
			if targetPlayer and targetPlayer.Character and tonumber(VALUE) then
				local humanoid = targetPlayer.Character:FindFirstChild('Humanoid')
				if humanoid then
					humanoid.JumpPower = VALUE
					Print(COMMAND,targetPlayer.Name,speaker,'Successful')
					return
				end
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer.Name,speaker,'Failed')
			end
			return
		end
	end;
	-- DATASTORES
	['load'] = function(speaker,cmdArgs,fullMsg)
		if not Cmds.DataStore then return end
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'load' then
			local targetPlayer = GetPlayer(TARGET,true)
			if Cmds.DataStore:LoadData(targetPlayer) then
				Print(COMMAND,targetPlayer,speaker,'Successful')
				return
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer,speaker,'Failed')
			end
			return
		end
	end;
	['save'] = function(speaker,cmdArgs,fullMsg)
		if not Cmds.DataStore then return end
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'save' then
			local targetPlayer = GetPlayer(TARGET,true)
			if Cmds.DataStore:GetData(targetPlayer) then
				if Cmds.DataStore:SaveData(targetPlayer) then
					Print(COMMAND,targetPlayer,speaker,'Successful')
					return
				end
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer,speaker,'Failed')
			end
			return
		end
	end;
	['clear'] = function(speaker,cmdArgs,fullMsg)
		if not Cmds.DataStore then return end
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'clear' then
			local targetPlayer = GetPlayer(TARGET,true)
			if Cmds.DataStore:GetData(targetPlayer) then
				print('[DICE ADMIN]:','Processing & removing data')
				Cmds.DataStore:RemoveData(targetPlayer)
				ClearPlayer('\nCleared data',targetPlayer)
				Print(COMMAND,targetPlayer,speaker,'Successful')
				return
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer,speaker,'Failed')
			end
			return
		end
	end;
	['read'] = function(speaker,cmdArgs,fullMsg)
		if not Cmds.DataStore then return end
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		local STAT = cmdArgs[3]
		if COMMAND == 'read' then
			local targetPlayer = GetPlayer(TARGET,true)
			local grabData = Cmds.DataStore:GetData(targetPlayer,STAT)
			if targetPlayer and STAT then
				print('['..STAT..']:')
				Services['RunService'].Heartbeat:Wait()
				print(repr(grabData))
				Services['RunService'].Heartbeat:Wait()
				Print(COMMAND,targetPlayer,speaker,'Successful')
				return
			elseif targetPlayer and STAT == nil then
				local name
				local success,err = pcall(function()
					name = Services['Players']:GetNameFromUserIdAsync(tonumber(targetPlayer))
				end)
				name = name and name..' | '..targetPlayer or targetPlayer
				print('['..name..']:')
				Services['RunService'].Heartbeat:Wait()
				for index,data in pairs(grabData) do
					if index == '___PlayingCards' then continue end
					local grabStat = Cmds.DataStore:GetData(targetPlayer,index)
					print(index..':')
					Services['RunService'].Heartbeat:Wait()
					print(repr(grabStat))
					Services['RunService'].Heartbeat:Wait()
				end
				Services['RunService'].Heartbeat:Wait()
				Cmds.DataStore:CalculateSize(targetPlayer)
				Services['RunService'].Heartbeat:Wait()
				Print(COMMAND,targetPlayer,speaker,'Successful')
				return
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer,speaker,'Failed')
			end
			return
		end
	end;
	['change'] = function(speaker,cmdArgs,fullMsg)
		if not Cmds.DataStore then return end
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		local STAT = cmdArgs[3]
		local VALUE = cmdArgs[4]
		if COMMAND == 'change' then
			local targetPlayer = GetPlayer(TARGET,true)
			if Cmds.DataStore:GetData(targetPlayer,STAT) then
				Cmds.DataStore:UpdateData(targetPlayer,STAT,VALUE)
				Print(COMMAND,targetPlayer,speaker,'Successful')
				return
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer,speaker,'Failed')
			end
			return
		end
	end;
	['increment'] = function(speaker,cmdArgs,fullMsg)
		if not Cmds.DataStore then return end
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		local STAT = cmdArgs[3]
		local VALUE = cmdArgs[4]
		if COMMAND == 'increment' then
			local targetPlayer = GetPlayer(TARGET,true)
			if Cmds.DataStore:GetData(targetPlayer,STAT) then
				if tonumber(VALUE) then
					Cmds.DataStore:IncrementData(targetPlayer,STAT,tonumber(VALUE))
					Print(COMMAND,targetPlayer,speaker,'Successful')
					return
				end
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer,speaker,'Failed')
			end
			return
		end
	end;
	['ban'] = function(speaker,cmdArgs,fullMsg)
		if not Cmds.DataStore then return end
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'ban' then
			local targetPlayer = GetPlayer(TARGET,true)
			local GetBans = Cmds.DataStore:GetGlobals('Bans')
			if not table.find(GetBans,tonumber(targetPlayer)) then
				table.insert(GetBans,tonumber(targetPlayer))
				local loadFile,savedFile = Cmds.DataStore:UpdateGlobals('Bans',GetBans)
				if savedFile then
					ClearPlayer('\nBanned',tonumber(targetPlayer))
					Print(COMMAND,targetPlayer,speaker,'Successful')
					return
				end
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer,speaker,'Failed')
			end
			return
		end
	end;
	['unban'] = function(speaker,cmdArgs,fullMsg)
		if not Cmds.DataStore then return end
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'unban' then
			local targetPlayer = GetPlayer(TARGET,true)
			local GetBans = Cmds.DataStore:GetGlobals('Bans')
			if table.find(GetBans,tonumber(targetPlayer)) then
				table.remove(GetBans,table.find(GetBans,tonumber(targetPlayer)))
				local loadFile,savedFile = Cmds.DataStore:UpdateGlobals('Bans',GetBans)
				if savedFile then
					Print(COMMAND,targetPlayer,speaker,'Successful')
					return
				end
			end
			if not targetPlayer then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,targetPlayer,speaker,'Failed')
			end
			return
		end
	end;
	-- LOADSTRING LoadString
	['run'] = function(speaker,cmdArgs,fullMsg)
		if not Cmds.LoadString then return end
		local COMMAND = cmdArgs[1]
		local TARGET = cmdArgs[2]
		if COMMAND == 'run' then
			local txt = string.sub(fullMsg,#COMMAND + 2)
			if txt then
				Cmds.LoadString:Execute(txt)
				Services['RunService'].Heartbeat:Wait()
				Print(COMMAND,txt,speaker,'Successful')
				return
			end
			if not txt then 
				Warn(COMMAND,'N/A',speaker,'Failed')
			else
				Warn(COMMAND,txt,speaker,'Failed')
			end
			return
		end
	end;
	-- CLIENT ONLY
	['fps'] = function()
		warn('[DICE ADMIN]:','You can only use this command in the console!')
	end;
	['fov'] = function()
		warn('[DICE ADMIN]:','You can only use this command in the console!')
	end;
	['ping'] = function()
		warn('[DICE ADMIN]:','You can only use this command in the console!')
	end;
	['noclip'] = function()
		warn('[DICE ADMIN]:','You can only use this command in the console!')
	end;
	['server'] = function()
		warn('[DICE ADMIN]:','You can only use this command in the console!')
	end;
	['reverso'] = function()
		warn('[DICE ADMIN]:','You can only use this command in the console!')
	end;
	['stats'] = function()
		warn('[DICE ADMIN]:','You can only use this command in the console!')
	end;
	['memory'] = function()
		warn('[DICE ADMIN]:','You can only use this command in the console!')
	end;
}
Cmds.CommandList = Commands

coroutine.wrap(function()
	local currentClock = os.clock()
	while not _G.YieldForDeck and os.clock() - currentClock < 1 do Services['RunService'].Heartbeat:Wait() end
	if _G.YieldForDeck then
		local LoadLibrary = require(_G.YieldForDeck('PlayingCards'))
		Cmds.DataStore = LoadLibrary('DiceDataStore')
		Cmds.LoadString = LoadLibrary('LoadString')
	end
end)()

return Commands