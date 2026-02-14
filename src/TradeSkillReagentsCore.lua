TradeSkillReagents = LibStub("AceAddon-3.0"):NewAddon("TradeSkillReagents", 
                                                      "AceConsole-3.0",
                                                      "AceEvent-3.0")

local DataBase = TradeSkillReagentsModules:Import("DataBase");
local Logger = TradeSkillReagentsModules:Import("Logger");
local SkillEnumerator = TradeSkillReagentsModules:Import("SkillEnumerator");

-- Events
local TRADE_SKILL_SHOW = "TRADE_SKILL_SHOW";
local CRAFT_SHOW = "CRAFT_SHOW";

function TradeSkillReagents:OnInitialize()
    DataBase:Init(TradeSkillReagents);
    -- TODO: set for release (INFO)
    DataBase:SetLogLevel(Logger.DEBUG);

    Logger:Init(TradeSkillReagents);
    Logger:Debug("on init");
end

function TradeSkillReagents:OnEnable()
    Logger:Debug("on enabled");

    TradeSkillReagents:RegisterEvent(TRADE_SKILL_SHOW, OnTradeSkillShow);
    TradeSkillReagents:RegisterEvent(CRAFT_SHOW, OnCraftShow);
end

function TradeSkillReagents:OnDisable()
    Logger:Debug("on disabled");

    TradeSkillReagents:UnregisterEvent(TRADE_SKILL_SHOW);
    TradeSkillReagents:UnregisterEvent(CRAFT_SHOW);
end

function OnTradeSkillShow()
    local tradeskillName, _, _, _ = GetTradeSkillLine()
    Logger:Info("Scanning "..tradeskillName)
    DataBase:ShiftReagentValues(tradeskillName)

    for _, value in pairs(SkillEnumerator:TradeSkill()) do
        local reagent = value.reagent;
        local skill = value.skill;
        local recipe = value.recipe;

        DataBase:SetReagentValue(reagent, skill, recipe);
    end
end

function OnCraftShow()
    local craftName = GetCraftName();
    Logger:Info("Scanning "..craftName)
    DataBase:ShiftReagentValues(craftName)

    for _, value in pairs(SkillEnumerator:Craft()) do
        local reagent = value.reagent;
        local skill = value.skill;
        local recipe = value.recipe;
        
        DataBase:SetReagentValue(reagent, skill, recipe);
    end
end