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
                    desc = "Sets the verbosity of output from the addon.",
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
                    desc = "WARNING: resets addon to default. Will need to rescan all Trade Skills to relearn reagents.",
                    func = function() DataBase:ResetReagents(); end,
                    confirm = function() return "Are you sure? All reagent data will be lost."; end,
                },
            },
        },
    },
}

function Options:Init()
    LibStub("AceConfig-3.0"):RegisterOptionsTable("TradeSkillReagents", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("TradeSkillReagents", "Trade Skill Reagents")
end
