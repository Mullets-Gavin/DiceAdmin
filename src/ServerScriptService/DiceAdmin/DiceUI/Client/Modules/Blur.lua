--// logic
local Blur = {}
Blur.Cache = nil
Blur.Size = 25
Blur.Delay = 0.2

--// services
local Services = setmetatable({}, {__index = function(cache, serviceName)
	cache[serviceName] = game:GetService(serviceName)
	return cache[serviceName]
end})

--// functions
local function GetBlur()
	if not Blur.Cache then
		local new = Instance.new('BlurEffect')
		new.Size = 0
		new.Enabled = false
		new.Parent = Services['Lighting']
		Blur.Cache = new
	end
	return Blur.Cache
end

function Blur.Enable(state)
	local get = GetBlur()
	if state then
		get.Enabled = true
		local tweenSize = Services['TweenService']:Create(get,TweenInfo.new(Blur.Delay),{Size = Blur.Size})
		tweenSize:Play()
	else
		local tweenSize = Services['TweenService']:Create(get,TweenInfo.new(Blur.Delay),{Size = 0})
		tweenSize:Play()
		tweenSize.Completed:Wait()
		get.Enabled = false
	end
end

return Blur