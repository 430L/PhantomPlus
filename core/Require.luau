local Players = game:GetService("Players")
local LocalPlayer = (function()
	local LocalPlayer = Players.LocalPlayer
	return (LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")):WaitForChild("MenuScreenGui", 9e9) and LocalPlayer
end)()

local ns__require
if typeof(getrenv or get_renv) == "function" then
	local Success, Environment = pcall(getrenv or get_renv)
	ns__require = Success and Environment.shared and Environment.shared.require
end

local ns__Modules, ExecutorName = nil, identifyexecutor and (identifyexecutor()) or (getexecutorname and (getexecutorname()))
if typeof(ns__require) ~= "function" then
	local ns__Count = 0
	while true do
		if ns__Count >= 10 then
			break
		end

		local ReplicationInterface = ns__Modules and ns__Modules.ReplicationInterface
		if ReplicationInterface and ReplicationInterface.operateOnAllEntries then
			break
		end

		for _,Value in next, (getgc or get_gc)(true) do
			if type(Value) == "table" and rawget(Value, "ScreenCull") and rawget(Value, "NetworkClient") then
				ns__Modules = {}
				for Name, Data in next, Value do
					ns__Modules[Name] = type(Data) == "table" and Data.module or Data
				end
			end
		end

		ns__Count += 1
		task.wait(0.5)
	end

	if not ns__Modules  then
		getgenv().ns__PhantomWare__Executed = false
		pcall(setfflag or set_fflag, "DebugRunParallelLuaOnMainThread", "True")
		LocalPlayer:Kick("Error while accessing Game Modules, try rejoining through the desktop app, if this issue persists, please make a ticket in the discord server immediately.\ndiscord.gg/DwRT2nH93D" .. (ExecutorName and (" | " .. ExecutorName) or ""))
		return pcall(setclipboard, "discord.gg/DwRT2nH93D")
	end

	ns__require = function(Name)
		return ns__Modules[Name]
	end
elseif not ns__require then
	getgenv().ns__PhantomWare__Executed = false
	pcall(setfflag or set_fflag, "DebugRunParallelLuaOnMainThread", "True")
	LocalPlayer:Kick("Error while accessing Game Modules, try rejoining through the desktop app, if this issue persists, please make a ticket in the discord server immediately.\ndiscord.gg/DwRT2nH93D" .. (ExecutorName and (" | " .. ExecutorName) or ""))
	return pcall(setclipboard, "discord.gg/DwRT2nH93D")
end

return {GetModule = function(Module)
	local Source = ns__require(Module)
	if not Source then
		local StartTime = os.clock()
		while true do
			if os.clock() - StartTime >= 4 then
				LocalPlayer:Kick("Module Access Timeout, please make a ticket in the discord server immediately.\ndiscord.gg/DwRT2nH93D\nDebug Info: " .. tostring(ExecutorName) .. " | " .. (ns__Modules and "Module Cache" or "Require Function"))
				pcall(setclipboard, "discord.gg/DwRT2nH93D")
				break
			end

			local CurrentSource = ns__require(Module)
			if CurrentSource then
				Source = CurrentSource
				break
			end

			task.wait()
		end
	end
	return Source
end, Players = Players, LocalPlayer = LocalPlayer, Executor = ExecutorName}
