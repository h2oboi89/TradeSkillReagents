local SkillEnumerator = TradeSkillReagentsModules:Create("SkillEnumerator");

local BlizzApi = TradeSkillReagentsModules:Import("BlizzApi");
local Logger = TradeSkillReagentsModules:Import("Logger");
local Debug = TradeSkillReagentsModules:Import("Debug");

-- means of enumerating recipes and reagents

function IsCraftable(skillType)
    return skillType == "trivial" or skillType == "easy" or skillType == "medium" or skillType == "optimal" or skillType == "difficult";
end

-- Enumerates all available recipes and reagents in the current tradeskill
function SkillEnumerator:TradeSkill()
    local tradeSkillLine = BlizzApi:GetTradeSkillLine();
    if (not tradeSkillLine.success) then
        return;
    end
    
    local tradeskillName = tradeSkillLine.values[1];
    Logger:Info("Scanning Trade Skill "..tradeskillName)
    
    local index = 0;
    local result = {};
    
    local numTradeSkills = BlizzApi:GetNumTradeSkills();

    if (not numTradeSkills.success) then
        return result;
    end

    local numSkills = numTradeSkills.values[1];

    Logger:Debug(" - Found "..numSkills.." skills")
    for tradeSkillRecipeId = 1, numSkills do
        local tradeSkillInfo = BlizzApi:GetTradeSkillInfo(tradeSkillRecipeId);

        if (tradeSkillInfo.success) then
            local skillName = tradeSkillInfo.values[1];
            local skillType = tradeSkillInfo.values[2];
            
            if (skillName and IsCraftable(skillType)) then
                
                local reagents = {}

                local tradeSkillNumReagents = BlizzApi:GetTradeSkillNumReagents(tradeSkillRecipeId);
                
                if (tradeSkillNumReagents.success) then
                    local numReagents = tradeSkillNumReagents.values[1];
                    
                    for reagentId = 1, numReagents do
                        local tradeSkillReagentInfo = BlizzApi:GetTradeSkillReagentInfo(tradeSkillRecipeId, reagentId);

                        if (tradeSkillReagentInfo.success) then
                            local reagentName = tradeSkillReagentInfo.values[1];

                            table.insert(reagents, reagentName);

                            result[index] = {
                                reagent = reagentName,
                                skill = tradeskillName,
                                recipe = skillName,
                            }
                            index = index + 1;
                        end
                    end
                end

                Logger:Trace(skillName.." : "..Debug:ListToString(reagents));
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