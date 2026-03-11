local BlizzApi = TradeSkillReagentsModules:Create("BlizzApi");

local Logger = TradeSkillReagentsModules:Import("Logger");

function checkListForNil(list)
    for _, v in ipairs(list) do
        if v == nil then
            return false;
        end
    end

    return true;
end

function BlizzApi:GetTradeSkillLine()
    local retOk, r1, r2, r3 = pcall(GetTradeSkillLine);

    if (not retOk) then
        local error = r1 or "unknown";
        Logger.Error("Error: "..error);
        return { success = false, values = {}, error = error };
    end

    local tradeskillName = r1;
    local currentLevel = r2;
    local maxLevel = r3;

    local result = {
        values = { },
        error = nil,
    };

    table.insert(result.values, tradeskillName);
    table.insert(result.values, currentLevel);
    table.insert(result.values, maxLevel);

    result.success = checkListForNil(result.values);

    return result;
end

function BlizzApi:GetNumTradeSkills()
    local retOk, r1 = pcall(GetNumTradeSkills);

    if (not retOk) then
        local error = r1 or "unknown";
        Logger.Error("Error: "..error);
        return { success = false, values = {}, error = error };
    end

    local numSkills = r1;

    return {
        success = true,
        values = { numSkills },
        error = nil,
    };
end

function BlizzApi:GetTradeSkillInfo(skillIndex)
    local retOk, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11 = pcall(GetTradeSkillInfo, skillIndex);

    if (not retOk) then
        local error = r1 or "unknown";
        Logger.Error("Error: "..error);
        return { success = false, values = {}, error = error };
    end

    local skillName = r1;
    local skillType = r2;
    local numAvailable = r3;
    local isExpanded = r4;
    local altVerb = r5;
    local numSkillUps = r6;
    local indentLevel = r7;
    local showProgressBar = r8;
    local currentRank = r9;
    local maxRank = r10;
    local startingRank = r11;

    local result = {
        values = { },
        error = nil,
    };

    table.insert(result.values, skillName);
    table.insert(result.values, skillType);
    table.insert(result.values, numAvailable);
    table.insert(result.values, isExpanded);
    table.insert(result.values, altVerb);
    table.insert(result.values, numSkillUps);
    table.insert(result.values, indentLevel);
    table.insert(result.values, showProgressBar);
    table.insert(result.values, currentRank);
    table.insert(result.values, maxRank);
    table.insert(result.values, startingRank);

    result.success = checkListForNil(result.values);

    return result;
end

function BlizzApi:GetTradeSkillNumReagents(tradeSkillRecipeId)
    local retOk, r1 = pcall(GetTradeSkillNumReagents, tradeSkillRecipeId);

    if (not retOk) then
        local error = r1 or "unknown";
        Logger.Error("Error: "..error);
        return { success = false, values = {}, error = error };
    end

    local numReagents = r1;

    return {
        success = true,
        values = { numReagents },
        error = nil,
    };
end

function BlizzApi:GetTradeSkillReagentInfo(tradeSkillRecipeId, reagentId)
    local retOk, r1, r2, r3, r4 = pcall(GetTradeSkillReagentInfo, tradeSkillRecipeId, reagentId);

    if (not retOk) then
        local error = r1 or "unknown";
        Logger.Error("Error: "..error);
        return { success = false, values = {}, error = error };
    end

    local reagentName = r1;
    local reagentTexture = r2;
    local reagentCount = r3;
    local playerReagentCount = r4;

    local result = {
        values = { },
        error = nil,
    };

    table.insert(result.values, reagentName);
    table.insert(result.values, reagentTexture);
    table.insert(result.values, reagentCount);
    table.insert(result.values, playerReagentCount);

    result.success = checkListForNil(result.values);

    return result;
end

function BlizzApi:GetCraftName()
    local retOk, r1 = pcall(GetCraftName);

    if (not retOk) then
        local error = r1 or "unknown";
        Logger.Error("Error: "..error);
        return { success = false, values = {}, error = error };
    end

    local craftName = r1;

    local result = {
        values = { },
        error = nil,
    };

    table.insert(result.values, craftName);

    result.success = checkListForNil(result.values);

    return result;
end

function BlizzApi:GetNumCrafts()
    local retOk, r1 = pcall(GetNumCrafts);

    if (not retOk) then
        local error = r1 or "unknown";
        Logger.Error("Error: "..error);
        return { success = false, values = {}, error = error };
    end

    local numSkills = r1;

    return {
        success = true,
        values = { numSkills },
        error = nil,
    };
end

function BlizzApi:GetCraftInfo(skillIndex)
    local retOk, r1, r2, r3, r4, r5, r6, r7 = pcall(GetCraftInfo, skillIndex);

    if (not retOk) then
        local error = r1 or "unknown";
        Logger.Error("Error: "..error);
        return { success = false, values = {}, error = error };
    end
    
    local craftName = r1;
    local craftSubSpellName = r2 or "";
    local craftType = r3;
    local numAvailable = r4;
    local isExpanded = r5;
    local trainingPointCost = r6;
    local requiredLevel = r7;

    local result = {
        values = { },
        error = nil,
    };

    table.insert(result.values, craftName);
    table.insert(result.values, craftSubSpellName);
    table.insert(result.values, craftType);
    table.insert(result.values, numAvailable);
    table.insert(result.values, isExpanded);
    table.insert(result.values, trainingPointCost);
    table.insert(result.values, requiredLevel);

    result.success = checkListForNil(result.values);

    return result;
end

function BlizzApi:GetCraftNumReagents(craftRecipeId)
    local retOk, r1 = pcall(GetCraftNumReagents, craftRecipeId);

    if (not retOk) then
        local error = r1 or "unknown";
        Logger.Error("Error: "..error);
        return { success = false, values = {}, error = error };
    end

    local numReagents = r1;

    return {
        success = true,
        values = { numReagents },
        error = nil,
    };
end

function BlizzApi:GetCraftReagentInfo(craftRecipeId, reagentId)
    local retOk, r1, r2, r3, r4 = pcall(GetCraftReagentInfo, craftRecipeId, reagentId);

    if (not retOk) then
        local error = r1 or "unknown";
        Logger.Error("Error: "..error);
        return { success = false, values = {}, error = error };
    end

    local reagentName = r1;
    local reagentTexture = r2;
    local reagentCount = r3;
    local playerReagentCount = r4;

    local result = {
        values = { },
        error = nil,
    };

    table.insert(result.values, reagentName);
    table.insert(result.values, reagentTexture);
    table.insert(result.values, reagentCount);
    table.insert(result.values, playerReagentCount);

    result.success = checkListForNil(result.values);

    return result;
end