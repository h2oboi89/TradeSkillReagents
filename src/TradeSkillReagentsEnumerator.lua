local Enumerator = TradeSkillReagentsModules:Create("Enumerator");

local Logger = TradeSkillReagentsModules:Import("Logger");

function Enumerator:TradeSkill()
    local tradeskillName, _, _, _ = GetTradeSkillLine()
    Logger:Debug("tradeskill opened "..tradeskillName)

    local index = 0;
    local result = {};

    for id=1,GetNumTradeSkills() do
        local skillName, skillType, _, _, _, _ = GetTradeSkillInfo(id);
        if (skillName and skillType ~= "header") then
            Logger:Trace(skillName)
            for i=1, GetTradeSkillNumReagents(id) do
                local reagentName, _, _, _ = GetTradeSkillReagentInfo(id, i);
                Logger:Trace(" - "..reagentName)

                result[index] = {
                    reagent = reagentName,
                    skill = tradeskillName,
                    recipe = skillName,
                }
                index = index + 1;
                
                Logger:Trace(reagentName.." "..tradeskillName.." "..skillName)
            end
        end
    end

    return result;
end

function Enumerator:Craft()
    local craftNameString = GetCraftName();
    Logger:Debug("craft opened: "..craftNameString)

    local index = 0;
    local result = {};

    for id=1,GetNumCrafts() do
        local craftName, craftSubSpellName, craftType, _, _, _, _ = GetCraftInfo(id);
        if (craftName and craftType ~= "header") then
            Logger:Trace(craftName)
            for i=1, GetCraftNumReagents(id) do
                local reagentName, _, _, _ = GetCraftReagentInfo(id, i);
                Logger:Trace(" - "..reagentName)
                
                result[index] = {
                    reagent = reagentName,
                    skill = craftNameString,
                    recipe = craftName,
                }
                index = index + 1;
                
                Logger:Trace(reagentName.." "..craftNameString.." "..craftName)
            end
        end
    end

    return result;
end