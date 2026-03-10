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

    Logger:Debug(" - Found "..numSkills.." recipes")
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

                            if (reagentName == nil) then
                                Logger.Error("reagent nil");
                                -- Debug.Dump(tradeSkillReagentInfo);
                            else
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
                end

                Logger:Trace(skillName.." : "..Debug:ListToString(reagents));
            end
        end
    end

    return result;
end

-- Enumerates all available recipes and reagents in the current craft
function SkillEnumerator:Craft()
    local craftName = BlizzApi:GetCraftName();
    if (not craftName.success) then
        return;
    end
    
    local craftName = craftName.values[1];
    Logger:Info("Scanning Craft "..craftName)

    local index = 0;
    local result = {};
    
    local numCrafts = BlizzApi:GetNumCrafts();

    if (not numCrafts.success) then
        return result;
    end

    local numSkills = numCrafts.values[1];

    Logger:Debug(" - Found "..numSkills.." recipes")

    for craftRecipeId = 1, numSkills do
        local craftInfo = BlizzApi:GetCraftInfo(craftRecipeId);

        if (craftInfo.success) then
            local skillName = craftInfo.values[1];
            local skillType = craftInfo.values[3];

            if (skillName and IsCraftable(skillType)) then
                local reagents = {}

                local craftNumReagents = BlizzApi:GetCraftNumReagents(craftRecipeId);
                
                if (craftNumReagents.success) then
                    local numReagents = craftNumReagents.values[1];

                    for reagentId = 1, numReagents do
                        local craftReagentInfo = BlizzApi:GetCraftReagentInfo(craftRecipeId, reagentId);
                        
                        if (craftReagentInfo.success) then
                            local reagentName = craftReagentInfo.values[1];

                            if (reagentName == nil) then
                                Logger.Error("reagent nil for "..craftRecipeId.." of "..numSkills.." reagent # "..reagentId.." of "..numReagents);
                                Debug.Dump(craftReagentInfo);
                            else
                                table.insert(reagents, reagentName);

                                result[index] = {
                                    reagent = reagentName,
                                    skill = craftName,
                                    recipe = skillName,
                                }
                                index = index + 1;
                            end
                        end
                    end
                end

                Logger:Trace(skillName.." : "..Debug:ListToString(reagents));
            end
        end
    end

    return result;
end