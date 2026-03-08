local DataBase = TradeSkillReagentsModules:Create("DataBase");
local Logger = TradeSkillReagentsModules:Import("Logger");

local defaults = {
    global = {
        logLevel = Logger.OFF,
        reagents = {},
    }
}

-- addon database and means of interacting with it.
function DataBase:Init(addon)
    DataBase.private.addon = addon;

    DataBase.private.addon.db = LibStub("AceDB-3.0"):New("TradeSkillReagentsDB", defaults, true)
    if not DataBase.private.addon.db.global.logLevel then
        DataBase:SetLogLevel(Logger.INFO);
    end
end

function DataBase:GetLogLevel()
    return DataBase.private.addon.db.global.logLevel;
end

function DataBase:SetLogLevel(value)
    DataBase.private.addon.db.global.logLevel = value;
end

function dictInsert(dict, key, value)
    if dict[key] == nil then 
        dict[key] = value
    end
end

function valueInsert(list, value)
    for _, v in ipairs(list) do
        if (v == value) then
            return;
        end
    end

    table.insert(list, value);
end

function DataBase:SetReagentValue(reagent, skill, recipe)
    local reagentDb = DataBase.private.addon.db.global.reagents;

    local error = false;
    if (reagent == nil) then
        Logger:Error("reagent is nil");
        error = true;
    end

    if (skill == nil) then
        Logger:Error("skill is nil");
        error = true;
    end

    if (recipe == nil) then
        Logger:Error("recipe is nil");
        erorr = true;
    end

    if (error) then 
        return;
    end

    Logger:Trace(reagent.." "..skill.." "..recipe);

    dictInsert(reagentDb, reagent, {});
    dictInsert(reagentDb[reagent], skill, {});
    valueInsert(reagentDb[reagent][skill], recipe);
end

function DataBase:GetReagentSkills(reagent)
    local reagentDb = DataBase.private.addon.db.global.reagents;

    local skills = {}

    if reagentDb[reagent] then
        for skill, _ in pairs(reagentDb[reagent]) do
            table.insert(skills, skill)
        end
    end

    return skills
end

function DataBase:ResetReagents()
    DataBase.private.addon.db.global.reagents = {};
end