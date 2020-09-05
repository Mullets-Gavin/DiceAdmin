--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: Dice Admin is an admin script with PlayingCards
--]]

--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
    cache[serviceName] = game:GetService(serviceName)
    return cache[serviceName]
end})

--// variables
local Player = Services['Players'].LocalPlayer
local PlayerScripts = Player:WaitForChild('PlayerScripts')

local Commands = require(script:WaitForChild('Modules'):WaitForChild('Cmds'))
local ChatMain = require(PlayerScripts:WaitForChild('ChatScript'):WaitForChild('ChatMain'))
local Cmds = Commands.Admin

local Toggle = script.Parent:WaitForChild('Toggle')
local MobileBar = script.Parent:WaitForChild('MobileBar')
local Console = script.Parent:WaitForChild('Console')
local Command = Console:WaitForChild('Command')
local Help = Console:WaitForChild('Help')
local Output = Console:WaitForChild('Output')
local Line = script:WaitForChild('Elements'):WaitForChild('Feed')

local Libraries = {}
Libraries.DiceAdmin = nil
Libraries.DiceAssignSizes = nil
Libraries.DiceOutput = nil

local Configs = {}
Configs.Name = 'DiceUI'
Configs.LogLimit = 150
Configs.Timeout = 1
Configs.Cache = {}
Configs.Interface = {}
Configs.Buttons = {
	['Default'] = {
		['Position'] = UDim2.new(0, 60, 0, 4);
		['Core'] = nil;
		['Value'] = 0;
	};
	['Chat'] = {
		['Position'] = UDim2.new(0, 104, 0, 4);
		['Core'] = Enum.CoreGuiType.Chat;
		['Value'] = 1;
	};
}

local Logs = {}
Logs.Feed = {}
Logs.Elements = {}
Logs.Last = nil
Logs.Count = 0

--// functions
local function FilterMsg(message,color)
	if Logs.Last == message then
		Logs.Count = Logs.Count + 1
	else
		Logs.Last = message
		Logs.Count = 1
	end
	if table.find(Configs.Cache,string.lower(message)) then return false end
	table.insert(Configs.Cache,string.lower(message))
	coroutine.wrap(function()
		wait(Configs.Timeout)
		table.remove(Configs.Cache,table.find(Configs.Cache,string.lower(message)))
	end)()
	if Libraries.DiceOutput then
		for index,remove in pairs(Libraries.DiceOutput.Filter) do
			if string.sub(message,1,#remove) == remove then
				message = string.sub(message,#remove + 1)
				if Commands.Toggles['Reverso'] and color == Color3.new(1, 1, 1) then
					message = string.reverse(string.sub(message,3))
					message = '> '..message
				end
				return message,Logs.Count
			end
		end
	end
	if Commands.Toggles['Reverso'] and color == Color3.new(1, 1, 1) then
		message = string.reverse(string.sub(message,3))
		message = '> '..message
	end
	return message,Logs.Count
end

local function CreateFeed(contents)
	local message,dupe = FilterMsg(contents['Text'],contents['Color'])
	if not message then return end
	if dupe > 1 then
		local getOld = Logs.Elements[#Logs.Elements]
		if getOld then
			getOld.Multiple.Visible = true
			getOld.Multiple.Text = ' (x'..dupe..')'
			getOld.Multiple.Size = UDim2.new(0, getOld.Multiple.TextBounds.X, 0, 20)
		end
	else
		local color = contents['Color']
		local feed = Line:Clone()
		feed.Text = message
		feed.TextColor3 = color
		feed.Parent = Output
		local getFrame = Services['TextService']:GetTextSize(message,feed.TextSize,feed.Font,feed.AbsoluteSize)
		feed.Size = UDim2.new(0, getFrame.X, 0, getFrame.Y)
		feed.Visible = true
		table.insert(Logs.Elements,feed)
		if #Logs.Elements > Configs.LogLimit then
			local getOld = Logs.Elements[1]
			getOld:Destroy()
			table.remove(Logs.Elements,1)
		end
	end
	Output.CanvasSize = UDim2.new(5, 0, 0, Output.UIListLayout.AbsoluteContentSize.Y + Output.UIPadding.PaddingBottom.Offset)
	Output.CanvasPosition = Vector2.new(0, Output.CanvasSize.Y.Offset)
end

local function ResetFeed()
	for index,element in pairs(Logs.Elements) do
		element:Destroy()
	end
	Logs.Elements = {}
	CreateFeed({
		['Text'] = 'Welcome to Playing Cards, by Mullet Mafia Dev';
		['Color'] = Color3.fromRGB(255, 255, 0);
	})
end

local function CreateArgs(message)
	local argCount = 0
	local cmdArgs = {}
	for index in string.gmatch(message,'[%w%-]+') do
		argCount = argCount + 1
		cmdArgs[argCount] = index
	end
	return cmdArgs
end

local function ExecuteCommands(message)
	if string.lower(message) == 'reset' then ResetFeed() return false end
	for cmd,func in pairs(Cmds) do
		if string.match(message, "[%w_]+") == cmd then
			local run = func(CreateArgs(message))
			return run
		end
	end
	return false
end

local function CreateHelp(cmd)
	CreateFeed({
		['Text'] = 'Welcome to Playing Cards, by Mullet Mafia Dev';
		['Color'] = Color3.fromRGB(255, 255, 0);
	})
	if cmd then
		CreateFeed({
			['Text'] = '> help';
			['Color'] = Color3.fromRGB(255, 255, 255);
		})
		CreateFeed({
			['Text'] = '[00]: reset';
			['Color'] = Color3.fromRGB(78, 187, 255);
		})
		if Libraries.DiceAdmin then
			Libraries.DiceAdmin:Network('Admin','help')
		end
	end
end

local function IsMobile()
	if Services['UserInputService'].TouchEnabled and not Services['UserInputService'].KeyboardEnabled then
		return true
	end
	return false
end

local function EnableConsole()
	if IsMobile() then
		Console.AnchorPoint = Vector2.new(0.5, 1)
		Console.Size = UDim2.new(1, 0, 1, -36)
		Console.Position = UDim2.new(0.5, 0, 1, 0)
		MobileBar.Visible = true
	end
	Console.Visible = not Console.Visible
	if Console.Visible then
		Services['RunService'].Heartbeat:Wait()
		Output.CanvasPosition = Vector2.new(0, Output.CanvasSize.Y.Offset)
		if not IsMobile() then
			Command:CaptureFocus()
		else
			local GetUI = Player:WaitForChild('PlayerGui')
			for index,ui in pairs(GetUI:GetChildren()) do
				if ui:IsA('ScreenGui') and ui.Name ~= Configs.Name then
					if Configs.Interface[ui] == nil then
						Configs.Interface[ui] = ui.Enabled
					end
					ui.Enabled = false
				end
			end
		end
	elseif IsMobile() then
		MobileBar.Visible = false
		for ui,value in pairs(Configs.Interface) do
			ui.Enabled = value
		end
	end
end

local function UpdateToggle()
	local currentValue = 0
	for index,topbar in pairs(Configs.Buttons) do
		if topbar['Core'] then
			local getCore = Services['StarterGui']:GetCoreGuiEnabled(topbar['Core'])
			if getCore then
				currentValue = currentValue + 1
			end
		end
	end
	for index,topbar in pairs(Configs.Buttons) do
		if topbar['Value'] == currentValue then
			Toggle.Position = topbar['Position']
			Toggle.Visible = true
			break
		end
	end
end

CreateHelp()
UpdateToggle()

Toggle.Button.MouseEnter:Connect(function()
	local Cover = Toggle:FindFirstChild('Cover')
	if Cover then
		Cover.ImageTransparency = 0.9
	end
end)
Toggle.Button.MouseLeave:Connect(function()
	local Cover = Toggle:FindFirstChild('Cover')
	if Cover then
		Cover.ImageTransparency = 1
	end
end)
Toggle.Button.MouseButton1Click:Connect(function()
	EnableConsole()
end)
Services['UserInputService'].TouchTap:Connect(function(positions)
	local GetStart = Toggle.AbsolutePosition
	local GetEnd = GetStart + Toggle.AbsoluteSize
	for index,tap in pairs(positions) do
		local X,Y = false,false
		if tap.X >= GetStart.X and tap.X <= GetEnd.X then X = true end
		if tap.Y >= GetStart.Y and tap.Y <= GetEnd.Y then Y = true end
		if Y and X then EnableConsole() break end
	end
end)

ChatMain.CoreGuiEnabled:connect(function()
	UpdateToggle()
end)

Help.MouseButton1Click:Connect(function()
	CreateHelp(true)
end)

Command.FocusLost:Connect(function(enter)
	if enter then
		local message = Command.Text
		if Libraries.DiceAdmin then
			if string.sub(message,1,#Libraries.DiceAdmin.Prefix) == Libraries.DiceAdmin.Prefix then message = string.sub(message,#Libraries.DiceAdmin.Prefix + 1) end
		end
		if message == '' or message == ' ' then return end
		local contents = {
			['Text'] = '> '..message;
			['Color'] = Color3.fromRGB(255, 255, 255);
		}
		CreateFeed(contents)
		local isCmd = ExecuteCommands(message)
		if not isCmd and Libraries.DiceAdmin then
			Libraries.DiceAdmin:Network('Admin',message)
		end
		Command.Text = ''
		Services['RunService'].Heartbeat:Wait()
		Command:CaptureFocus()
	end
end)

Services['UserInputService'].InputBegan:Connect(function(input,processed)
	if Libraries.DiceAdmin then
		if input.KeyCode == Libraries.DiceAdmin.Keybind then
			EnableConsole()
		end
	elseif input.KeyCode == Enum.KeyCode.F8 then
		EnableConsole()
	end
end)

coroutine.wrap(function()
	local currentClock = tick()
	while not _G.YieldForDeck and tick() - currentClock < 1 do Services['RunService'].Heartbeat:Wait() end
	if _G.YieldForDeck then
		local LoadLibrary = require(_G.YieldForDeck('PlayingCards'))
		Libraries.DiceAdmin = LoadLibrary('DiceAdmin')
		Libraries.DiceAssignSizes = LoadLibrary('DiceAssignSizes')
		Libraries.DiceOutput = LoadLibrary('DiceOutput')
		---
		Libraries.DiceAssignSizes(Console,1.2,0.35,0.8)
		Libraries.DiceAssignSizes(Console,'Mobile',false)
		---
		Libraries.DiceOutput.Hook(function(contents)
			CreateFeed(contents)
		end)
	else
		Libraries.DiceAdmin = Services['ReplicatedStorage']:WaitForChild('DiceAdmin')
	end
end)()