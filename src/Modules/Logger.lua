
local Logger = TradeSkillReagentsModules:Create("Logger");

Logger.TRACE = 0;
Logger.DEBUG = 1;
Logger.INFO = 2;
Logger.WARN = 3;
Logger.ERROR = 4;
Logger.FATAL = 5;
Logger.OFF = 6;

function Logger:Init(addon)
    Logger.private.addon = addon;
end

function Logger:LogForLevel(message, level)
    if (level >= Logger.private.addon:GetLogLevel()) then
        Logger.private.addon:Print(message)
    end
end

function Logger:Trace(message)
    Logger:LogForLevel(message, Logger.TRACE);
end

function Logger:Debug(message)
    Logger:LogForLevel(message, Logger.DEBUG);
end

function Logger:Info(message)
    Logger:LogForLevel(message, Logger.INFO);
end