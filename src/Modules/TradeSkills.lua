local TradeSkills = TradeSkillReagentsModules:Create("TradeSkills");

local Logger = TradeSkillReagentsModules:Import("Logger");
local DataBase = TradeSkillReagentsModules:Import("DataBase");
local SkillEnumerator = TradeSkillReagentsModules:Import("SkillEnumerator");

local TRADE_SKILL_SHOW = "TRADE_SKILL_SHOW";
local CRAFT_SHOW = "CRAFT_SHOW";

-- Does the scanning of the Trade Skills and Crafts
function TradeSkills:Init(addon)
    TradeSkills.private.addon = addon;

    TradeSkills.private.addon.RegisterEvent(TRADE_SKILL_SHOW, TradeSkills.OnTradeSkillShow);
    TradeSkills.private.addon.RegisterEvent(CRAFT_SHOW, TradeSkills.OnCraftShow);
end

function TradeSkills:DeInit()
    TradeSkills.private.addon.UnregisterEvent(TRADE_SKILL_SHOW);
    TradeSkills.private.addon.UnregisterEvent(CRAFT_SHOW);
end

function TradeSkills:ScanTradeSkill()
    local tradeskillName, _, _, _ = GetTradeSkillLine()
    Logger:Info("Scanning Trade Skill "..tradeskillName)
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

function TradeSkills:OnTradeSkillShow()
    local retOk, error = pcall(TradeSkills.ScanTradeSkill)

    if not retOk then
        Logger.Error(error);
    end
end

function TradeSkills:ScanCraft()
    local craftName = GetCraftName();
    Logger:Info("Scanning Craft "..craftName)
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

function TradeSkills:OnCraftShow()
    local retOk, error = pcall(TradeSkills.ScanCraft)

    if not retOk then
        Logger.Error(error);
    end
end