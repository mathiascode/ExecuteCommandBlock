function Initialize(Plugin)
	Plugin:SetName(g_PluginInfo.Name)
	Plugin:SetVersion(g_PluginInfo.Version)

	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	RegisterPluginInfoCommands()
	RegisterPluginInfoConsoleCommands()

	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

function GetPlayerLookPos(Player)
	local World = Player:GetWorld()
	local Start = Player:GetEyePosition()
	local End = Start + Player:GetLookVector() * 150
	local HitCoords = nil
	local Callbacks =
	{
		OnNextBlock = function(BlockPos, BlockType)
			if BlockType ~= E_BLOCK_AIR then
				HitCoords = BlockPos
				return true
			end
		end
	}
	cLineBlockTracer:Trace(World, Callbacks, Start, End)
	return HitCoords
end

function HandleExecuteCommandBlockCommand(Split, Player)
	if Split[2] == nil then
		local LookPos = GetPlayerLookPos(Player)
		local LookingAtCommandBlock = Player:GetWorld():DoWithBlockEntityAt(
			LookPos.x, LookPos.y, LookPos.z,
			function (CommandBlock)
				local ExecuteCommandBlock = tolua.cast(CommandBlock, "cCommandBlockEntity")                             
				ExecuteCommandBlock:Activate()
			end
		)

		if LookingAtCommandBlock then
			Player:SendMessageSuccess("Successfully executed command block")
		else
			Player:SendMessageInfo("You have to look at a command block to execute it")
		end
	elseif Split[2] ~= nil and Split[3] ~= nil and Split[4] ~= nil then
		if tonumber(Split[2]) == nil or tonumber(Split[3]) == nil or tonumber(Split[4]) == nil then
			Player:SendMessageFailure("Invaild coordinates")
			return true
		else
			local IsCommandBlock = Player:GetWorld():DoWithBlockEntityAt(
				Split[2], Split[3], Split[4],
				function (CommandBlock)
					local ExecuteCommandBlock = tolua.cast(CommandBlock, "cCommandBlockEntity")                             
					ExecuteCommandBlock:Activate()
				end
			)

			if IsCommandBlock then
				Player:SendMessageSuccess("Successfully executed command block at [X:" ..Split[2].. ", Y:" ..Split[3].. ", Z:" ..Split[4].. "]")
			else
				Player:SendMessageInfo("No command block was found at [X:" ..Split[2].. ", Y:" ..Split[3].. ", Z:" ..Split[4].. "]")
			end
			return true
		end
	else
		Player:SendMessageInfo("Usage: " ..Split[1].. " <x> <y> <z>")
	end
	return true
end

function HandleConsoleExecuteCommandBlockCommand(Split, Player)
	if Split[2] ~= nil and Split[3] ~= nil and Split[4] ~= nil and Split[5] ~= nil then
		if tonumber(Split[2]) == nil or tonumber(Split[3]) == nil or tonumber(Split[4]) == nil then
			return true, "Invaild coordinates"
		end

		if cRoot:Get():GetWorld(Split[5]) == nil then
			return true, "Invalid world '" .. Split[5] .. "'"
		end

		local IsCommandBlock = cRoot:Get():GetWorld(Split[5]):DoWithBlockEntityAt(
			Split[2], Split[3], Split[4],
			function (CommandBlock)
				local ExecuteCommandBlock = tolua.cast(CommandBlock, "cCommandBlockEntity")                             
				ExecuteCommandBlock:Activate()
			end
		)

		if IsCommandBlock == true then
			return true, "Successfully executed command block at [X:" ..Split[2].. ", Y:" ..Split[3].. ", Z:" ..Split[4].. "] in world \"" ..Split[5].. "\""
		else
			return true, "No command block was found at [X:" ..Split[2].. ", Y:" ..Split[3].. ", Z:" ..Split[4].. "] in world \"" ..Split[5].. "\""
		end
	else
		return true, "Usage: " ..Split[1].. " <x> <y> <z> <world>"
	end
end

function OnDisable()
	LOG("Disabled " .. cPluginManager:GetCurrentPlugin():GetName() .. "!")
end
