g_PluginInfo = {
	Name = "ExecuteCommandBlock",
	Version = "1",
	Date = "2016-01-05",
	SourceLocation = "https://github.com/mathias-github/ExecuteCommandBlock",
	Description = [[A plugin that allows players to execute command blocks in Cuberite. To execute a command block, the player can look at a command block and execute "/executecommandblock" in chat, or specify the exact location where a command block is in the world using "/executecommandblock <x> <y> <z>". There is also a console command, "executecommandblock".]],

	Commands =
	{
		["/executecommandblock"] =
		{
			HelpString = "Executes a command block.",
			Permission = "executecommandblock.command",
			Handler = HandleExecuteCommandBlockCommand,
		},
	},

	ConsoleCommands =
	{
		["executecommandblock"] =
		{
			HelpString = "Executes the command block at the specified location.",
			Handler = HandleConsoleExecuteCommandBlockCommand,
		},
	},
}
