local DataBase = TradeSkillReagentsModules:Create("DataBase");
local Logger = TradeSkillReagentsModules:Import("Logger");

local defaults = {
    global = {
        logLevel = Logger.OFF,
        reagents = {},
    }
}

function dump(t)
    for key, value in pairs(t) do
        print(k.." "..v);
    end
end

function DataBase:Init(addon)
    DataBase.private.addon = addon;

    DataBase.private.addon.db = LibStub("AceDB-3.0"):New("TradeSkillReagentsDB", defaults, true)
end

function DataBase:GetLogLevel()
    return DataBase.private.addon.db.global.logLevel;
end

function DataBase:SetLogLevel(value)
    DataBase.private.addon.db.global.logLevel = value;
end

function DataBase:ShiftReagentValues(skillName)
    local reagentDb = DataBase.private.addon.db.global.reagents;
    
    for reagent, skillTable in pairs(reagentDb) do
        for skill, recipeTable in pairs(skillTable) do
            if (skill == skillName) then
                for recipe, value in pairs(recipeTable) do
                    recipeTable[recipe] = recipeTable[recipe] * 2
                    recipeTable[recipe] = recipeTable[recipe] % 1024
                    
                    if (recipeTable[recipe] == 0) then
                        Logger:Trace("setting "..recipe.." to nil")
                        recipeTable[recipe] = nil
                    end
                end
            end

            if (next(skillTable[skill]) == nil) then
                Logger:Trace("setting "..skill.." to nil")
                skillTable[skill] = nil
            end
        end

        if (next(reagentDb[reagent]) == nil) then
            Logger:Trace("setting "..reagent.." to nil")
            reagentDb[reagent] = nil
        end
    end
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

function DataBase:SetReagentValue(reagent, skill, recipe)
    local reagentDb = DataBase.private.addon.db.global.reagents;

    dictInsert(reagentDb, reagent, {});
    dictInsert(reagentDb[reagent], skill, {});
    valueInsert(reagentDb[reagent][skill], recipe);
end