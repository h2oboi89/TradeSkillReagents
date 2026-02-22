local Query = TradeSkillReagentsModules:Create("Query");

local Logger = TradeSkillReagentsModules:Import("Logger");
local DataBase = TradeSkillReagentsModules:Import("DataBase");

local TRADE_SKILL_REAGENTS_QUERY = "TRADE_SKILL_REAGENTS_QUERY";
local TRADE_SKILL_REAGENTS_RESPONSE = "TRADE_SKILL_REAGENTS_RESPONSE";

-- listens for and responds to queries from other addons
function Query:Init(addon)
    Query.private.addon = addon;

    Query.private.addon:RegisterMessage(TRADE_SKILL_REAGENTS_QUERY, Query.OnQuery);
end

function Query:DeInit()
    Query.private.addon:UnregisterMessage(TRADE_SKILL_REAGENTS_QUERY);
end

function Query:OnQuery(messageName, itemName)
    Logger.Debug(itemName.." was queried");
    local response = { 
        itemName = itemName,
        tradeSkills = {},
    };

    local skills = DataBase:GetReagentSkills(itemName);

    for _, skill in ipairs(skills) do
        table.insert(response.tradeSkills, skill);
    end

    Logger.Debug("sending response for "..itemName);
    Query.private.addon:SendMessage(TRADE_SKILL_REAGENTS_RESPONSE, response);
end