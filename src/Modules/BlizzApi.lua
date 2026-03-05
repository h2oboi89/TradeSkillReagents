local BlizzApi = TradeSkillReagentsModules:Create("BlizzApi");

local Logger = TradeSkillReagentsModules:Import("Logger");

function BlizzApi:GetTradeSkillLine()
    local retOk, r1, r2, r3 = pcall(GetTradeSkillLine);

    if (not retOk) then
        local error = r1;
        Logger.Error("Error: "..error);
        return { success = false, values = {}, error = error };
    end

    local tradeskillName = r1;
    local currentLevel = r2;
    local maxLevel = r3;

    return {
        success = true, 
        values = { tradeskillName, currentLevel, maxLevel },
        error = nil,
    };
end

function BlizzApi:GetNumTradeSkills()
    local retOk, r1 = pcall(GetNumTradeSkills);

    if (not retOk) then
        local error = r1;
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
        local error = r1;
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

    return {
        success = true,
        values = { skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps, indentLevel, showProgressBar, currentRank, maxRank, startingRank },
        error = nil,
    };
end

function BlizzApi:GetTradeSkillNumReagents(tradeSkillRecipeId)
    local retOk, r1 = pcall(GetTradeSkillNumReagents, tradeSkillRecipeId);

    if (not retOk) then
        local error = r1;
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
        local error = r1;
        Logger.Error("Error: "..error);
        return { success = false, values = {}, error = error };
    end

    local reagentName = r1;
    local reagentTexture = r2;
    local reagentCount = r3;
    local playerReagentCount = r4;

    return {
        success = true,
        values = { reagentName, reagentTexture, reagentCount, playerReagentCount },
        error = nil,
    };
end