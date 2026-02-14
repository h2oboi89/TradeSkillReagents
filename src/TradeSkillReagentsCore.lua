TradeSkillReagents = LibStub("AceAddon-3.0"):NewAddon("TradeSkillReagents", 
                                                      "AceConsole-3.0",
                                                      "AceEvent-3.0",
                                                      "AceHook-3.0")

local DataBase = TradeSkillReagentsModules:Import("DataBase");
local Logger = TradeSkillReagentsModules:Import("Logger");
local SkillEnumerator = TradeSkillReagentsModules:Import("SkillEnumerator");
local Options = TradeSkillReagentsModules:Import("Options");

-- Events
local TRADE_SKILL_SHOW = "TRADE_SKILL_SHOW";
local CRAFT_SHOW = "CRAFT_SHOW";

function TradeSkillReagents:OnInitialize()
    DataBase:Init(TradeSkillReagents);
    DataBase:SetLogLevel(Logger.INFO);

    Logger:Init(TradeSkillReagents);
    Logger:Debug("on init");

    Options:Init();
end

function TradeSkillReagents:OnEnable()
    Logger:Debug("on enabled");

    TradeSkillReagents:RegisterEvent(TRADE_SKILL_SHOW, TradeSkillReagents.OnTradeSkillShow);
    TradeSkillReagents:RegisterEvent(CRAFT_SHOW, TradeSkillReagents.OnCraftShow);

    TradeSkillReagents:HookScript(GameTooltip, "OnToolTipSetItem", TradeSkillReagents.AddTradeSkillTooltipInfo)
    TradeSkillReagents:HookScript(ItemRefTooltip, "OnToolTipSetItem", TradeSkillReagents.AddTradeSkillTooltipInfo)
end

function TradeSkillReagents:OnDisable()
    Logger:Debug("on disabled");

    TradeSkillReagents:UnregisterEvent(TRADE_SKILL_SHOW);
    TradeSkillReagents:UnregisterEvent(CRAFT_SHOW);
end

function TradeSkillReagents:AddTradeSkillTooltipInfo()
    local name, _ = self:GetItem()

    local skills = DataBase:GetReagentSkills(name)

    for _, skill in ipairs(skills) do
        self:AddLine(skill)
    end
end

function TradeSkillReagents:OnTradeSkillShow()
    local tradeskillName, _, _, _ = GetTradeSkillLine()
    Logger:Info("Scanning "..tradeskillName)
    DataBase:ShiftReagentValues(tradeskillName)

    local count = 0;
    for _, value in pairs(SkillEnumerator:TradeSkill()) do
        local reagent = value.reagent;
        local skill = value.skill;
        local recipe = value.recipe;

        DataBase:SetReagentValue(reagent, skill, recipe);
        count = count + 1;
    end

    Logger:Info("Scanned "..count.." reagents");
end

function TradeSkillReagents:OnCraftShow()
    local craftName = GetCraftName();
    Logger:Info("Scanning "..craftName)
    DataBase:ShiftReagentValues(craftName)

    local count = 0;
    for _, value in pairs(SkillEnumerator:Craft()) do
        local reagent = value.reagent;
        local skill = value.skill;
        local recipe = value.recipe;
        
        DataBase:SetReagentValue(reagent, skill, recipe);
        count = count + 1;
    end

    Logger:Info("Scanned "..count.." reagents");
end
