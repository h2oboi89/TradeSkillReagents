

local Options = TradeSkillReagentsModules:Create("Options");
local Logger = TradeSkillReagentsModules:Import("Logger");
local DataBase = TradeSkillReagentsModules:Import("DataBase");

local options = {
    name = "Trade Skill Reagents",
    type = "group",
    args = {
        mainOptions = {
            type = "group",
            name = "Main",
            order = 0,
            args = {
                logLevel = {
                    name = "Log Level",
                    type = "select",
                    order = 0,
                    values = Logger:GetLogLevels(),
                    get = function() return DataBase:GetLogLevel(); end,
                    set = function(_, value) DataBase:SetLogLevel(value); end,
                    style = "dropdown",
                },
            },
        },
        dangerOptions = {
            type = "group",
            name = "Danger Zone",
            order = 1,
            args = {
                resetReagents = {
                    name = "Reset Database",
                    type = "execute",
                    func = function() DataBase:ResetReagents(); end,
                },
            },
        },
    },
}

function Options:Init()
    LibStub("AceConfig-3.0"):RegisterOptionsTable("TradeSkillReagents", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("TradeSkillReagents", "Trade Skill Reagents")
end
