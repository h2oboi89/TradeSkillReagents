local SkillEnumerator = TradeSkillReagentsModules:Create("SkillEnumerator");

local Logger = TradeSkillReagentsModules:Import("Logger");

-- means of enumerating recipes and reagents

function IsCraftable(skillType)
    return skillType == "trivial" or skillType == "easy" or skillType == "medium" or skillType == "optimal" or skillType == "difficult";
end

-- Enumerates all available recipes and reagents in the current tradeskill
function SkillEnumerator:TradeSkill()
    local tradeskillName, _, _, _ = GetTradeSkillLine()
    Logger:Debug("tradeskill opened "..tradeskillName)
    
    local index = 0;
    local result = {};
    
    local numSkills = GetNumTradeSkills();
    Logger:Trace(" - Found "..numSkills.." skills")
    for id=1, numSkills do
        local skillName, skillType, _, _, _, _ = GetTradeSkillInfo(id);
        if (skillName and IsCraftable(skillType)) then
            local numReagents = GetTradeSkillNumReagents(id);
            Logger:Trace(skillName.." "..numReagents.." with reagents")
            for i=1, numReagents do
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

-- Enumerates all available recipes and reagents in the current craft
function SkillEnumerator:Craft()
    local craftNameString = GetCraftName();
    Logger:Debug("craft opened: "..craftNameString)

    local index = 0;
    local result = {};
    local numCrafts = GetNumCrafts();
    Logger:Trace(" - Found "..numCrafts.." crafts")
    for id=1, numCrafts do
        local craftName, craftSubSpellName, craftType, _, _, _, _ = GetCraftInfo(id);
        if (craftName and IsCraftable(craftType)) then
            local numReagents = GetCraftNumReagents(id);
            Logger:Trace(craftName.." "..numReagents.." with reagents")
            for i=1, numReagents do
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