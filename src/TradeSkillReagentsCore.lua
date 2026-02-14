TradeSkillReagents = LibStub("AceAddon-3.0"):NewAddon("TradeSkillReagents", 
                                                      "AceConsole-3.0",
                                                      "AceEvent-3.0")

local Logger = TradeSkillReagentsModules:Import("Logger");
local Enumerator = TradeSkillReagentsModules:Import("Enumerator");

local defaults = {
    global = {
        logLevel = Logger.DEBUG,
        reagents = {},
    }
}

function TradeSkillReagents:OnInitialize()
    TradeSkillReagents.db = LibStub("AceDB-3.0"):New("TradeSkillReagentsDB", defaults, true)
    Logger:Init(TradeSkillReagents)
    Logger:Debug("on init")
end

function TradeSkillReagents:OnEnable()
    Logger:Debug("on enabled")

    TradeSkillReagents:RegisterEvent("TRADE_SKILL_SHOW", OnTradeSkillShow)
    TradeSkillReagents:RegisterEvent("CRAFT_SHOW", OnCraftShow)
end

function TradeSkillReagents:GetLogLevel()
    return TradeSkillReagents.db.global.logLevel;
end

function dictInsert(dict, key, value)
    if dict[key] then 
        return
    end

    dict[key] = value
end

function valueInsert(dict, key)
    if dict[key] then
        dict[key] = dict[key] + 1
    else
        dict[key] = 1
    end
end

function valueShift(dict, skillName)
    Logger:Info(skillName);
    for reagent, reagentTable in pairs(dict) do
        for skill, skillTable in pairs(reagentTable) do
            if (skill == skillName) then
                for recipe, value in pairs(skillTable) do
                    skillTable[recipe] = skillTable[recipe] * 2
                    skillTable[recipe] = skillTable[recipe] % 1024
                    if (skillTable[recipe] == 0) then
                        skillTable[recipe] = nil
                    end
                end
            end
        end
        -- Logger:Info(next(skillTable))
        -- if next(skillTable) == nil then
        --     reagentTable[skill] = nil
        -- end
    end
    -- if (next(reagentTable) == nil) then
    --     dict[reagent] = nil
    -- end
end

function OnTradeSkillShow()
    local tradeskillName, _, _, _ = GetTradeSkillLine()
    valueShift(TradeSkillReagents.db.global.reagents, tradeskillName);

    for _, value in pairs(Enumerator:TradeSkill()) do
        local reagentName = value.reagent;
        local skill = value.skill;
        local recipe = value.recipe;
        dictInsert(TradeSkillReagents.db.global.reagents, reagentName, {})
        dictInsert(TradeSkillReagents.db.global.reagents[reagentName], skill, {})
        valueInsert(TradeSkillReagents.db.global.reagents[reagentName][skill], recipe)
    end
end

function OnCraftShow()
    local craftName = GetCraftName();
    -- Logger:Info(craftName);
    -- valueShift(TradeSkillReagents.db.global.reagents, craftName);

    for _, value in pairs(Enumerator:Craft()) do
        local reagentName = value.reagent;
        local skill = value.skill;
        local recipe = value.recipe;
        dictInsert(TradeSkillReagents.db.global.reagents, reagentName, {})
        dictInsert(TradeSkillReagents.db.global.reagents[reagentName], skill, {})
        valueInsert(TradeSkillReagents.db.global.reagents[reagentName][skill], recipe)
    end
end