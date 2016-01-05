function Initialize(Plugin)
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")

	-- Sets the name and version of the plugin
	Plugin:SetName(g_PluginInfo.Name)
	Plugin:SetVersion(g_PluginInfo.Version)

	-- Registers the commands found in Info.lua
	RegisterPluginInfoCommands()
	RegisterPluginInfoConsoleCommands()
	
	-- Shows up in console
	LOG("Initialized " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

-- Function that returns the position of the block a player is looking at
function GetLookPosition(Player)
	local Tracer = cTracer(Player:GetWorld()) -- Trace where player is looking (in its current world)
	local StartPosition = Vector3f(Player:GetEyePosition().x, Player:GetEyePosition().y, Player:GetEyePosition().z) -- The tracing starts at the player's eye position
	local LookDirection = Vector3f(Player:GetLookVector().x, Player:GetLookVector().y, Player:GetLookVector().z) -- In which direction is the player looking?
	local MaxLookDistance = 9999 -- From how far away can a player look at a command block and execute it

	Tracer:Trace(StartPosition, LookDirection, MaxLookDistance) -- Start the actual tracing, using the variables above
	return Tracer.BlockHitPosition -- The tracing is done, return the exact position of the block the player is looking at
end

-- Code that handles the /executecommandblock command in-game
function HandleExecuteCommandBlockCommand(Split, Player)
	-- Assuming the player wants to look at a block instead of specifying coordinates manually
	if Split[2] == nil then
		-- Code activated when looking at a command block while executing /executecommandblock
		local LookPosition = GetLookPosition(Player) -- We include the previous function in this code
		local LookingAtCommandBlock = Player:GetWorld():DoWithBlockEntityAt(
			LookPosition.x, LookPosition.y, LookPosition.z, -- Uses the final result of the GetLookPosition function to get the block's position
			function (CommandBlock)
				local ExecuteCommandBlock = tolua.cast(CommandBlock, "cCommandBlockEntity")                             
				ExecuteCommandBlock:Activate() -- Executes the command block
			end
		)

		-- If player is looking at a command block, execute command block and send success message to player
		if LookingAtCommandBlock == true then
			Player:SendMessageSuccess("Successfully executed command block")
			return true
		else
			-- If not, tell the player what to do
			Player:SendMessageInfo("You have to look at a command block to execute it")
			return true
		end
	end


	-- If player has specified coordinates, use the following code instead
	if Split[2] ~= nil and Split[3] ~= nil and Split[4] ~= nil then
		-- If coordinates contain letters or other symbols, show an error
		if tonumber(Split[2]) == nil or tonumber(Split[3]) == nil or tonumber(Split[4]) == nil then
			Player:SendMessageFailure("Invaild coordinates")
			return true
		end

		-- If not, go on
		local IsCommandBlock = Player:GetWorld():DoWithBlockEntityAt(
			Split[2], Split[3], Split[4], -- Uses the coordinates defined manually by the player
			function (CommandBlock)
				local ExecuteCommandBlock = tolua.cast(CommandBlock, "cCommandBlockEntity")                             
				ExecuteCommandBlock:Activate() -- Executes the command block
			end
		)

		-- If the block at the defined coordinates is a command block, execute it and send a success message to the player
		if IsCommandBlock == true then
			Player:SendMessageSuccess("Successfully executed command block at [X:" ..Split[2].. ", Y:" ..Split[3].. ", Z:" ..Split[4].. "]")
			return true
		else
			-- If not, tell the player that no command block was found
			Player:SendMessageInfo("No command block was found at [X:" ..Split[2].. ", Y:" ..Split[3].. ", Z:" ..Split[4].. "]")
			return true
		end
	else
	-- If player hasn't specified all coordinates, show usage info for the command
		Player:SendMessageInfo("Usage: " ..Split[1].. " [<x> <y> <z>]")
		return true
	end
end

-- Code that handles the executecommandblock command in console
function HandleConsoleExecuteCommandBlockCommand(Split, Player)
	if Split[2] ~= nil and Split[3] ~= nil and Split[4] ~= nil and Split[5] ~= nil then
		-- If coordinates contain letters or other symbols, show an error
		if tonumber(Split[2]) == nil or tonumber(Split[3]) == nil or tonumber(Split[4]) == nil then
			return true, "Invaild coordinates"
		end

		-- If world was not found, show an error
		if cRoot:Get():GetWorld(Split[5]) == nil then
			return true, "Invaild world"
		end

		-- If everything is correct, go on
		local IsCommandBlock = cRoot:Get():GetWorld(Split[5]):DoWithBlockEntityAt(
			Split[2], Split[3], Split[4], -- Uses the coordinates defined manually by the player
			function (CommandBlock)
				local ExecuteCommandBlock = tolua.cast(CommandBlock, "cCommandBlockEntity")                             
				ExecuteCommandBlock:Activate() -- Executes the command block
			end
		)

		-- If the block at the defined coordinates is a command block, execute it and return a success message
		if IsCommandBlock == true then
			return true, "Successfully executed command block at [X:" ..Split[2].. ", Y:" ..Split[3].. ", Z:" ..Split[4].. "] in world \"" ..Split[5].. "\""
		else
			-- If not, return an error message
			return true, "No command block was found at [X:" ..Split[2].. ", Y:" ..Split[3].. ", Z:" ..Split[4].. "] in world \"" ..Split[5].. "\""
		end
	else
	-- If not all splits are specified, show usage info
		return true, "Usage: " ..Split[1].. " <x> <y> <z> <world>"
	end
end

-- Shows up in console
function OnDisable()
	LOG("ExecuteCommandBlock is shutting down...")
end
