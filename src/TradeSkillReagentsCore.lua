TradeSkillReagents = LibStub("AceAddon-3.0"):NewAddon("TradeSkillReagents", 
                                                      "AceConsole-3.0",
                                                      "AceEvent-3.0",
                                                      "AceHook-3.0")

local DataBase = TradeSkillReagentsModules:Import("DataBase");
local Logger = TradeSkillReagentsModules:Import("Logger");
local Options = TradeSkillReagentsModules:Import("Options");
-- local Query = TradeSkillReagentsModules:Import("Query");
local ToolTip = TradeSkillReagentsModules:Import("ToolTip");
local TradeSkills = TradeSkillReagentsModules:Import("TradeSkills");

function TradeSkillReagents:OnInitialize()
    DataBase:Init(TradeSkillReagents);
    Logger:Init(TradeSkillReagents);
    Logger:Debug("on init");

    Options:Init();
end

function TradeSkillReagents:OnEnable()
    Logger:Debug("on enabled");
    
    -- Query:Init(TradeSkillReagents);
    ToolTip:Init(TradeSkillReagents);
    TradeSkills:Init(TradeSkillReagents);
end

function TradeSkillReagents:OnDisable()
    Logger:Debug("on disabled");

    Query:DeInit();
    TradeSkills:DeInit();
end
