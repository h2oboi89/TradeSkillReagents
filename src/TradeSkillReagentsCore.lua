TradeSkillReagents = LibStub("AceAddon-3.0"):NewAddon("TradeSkillReagents", 
                                                      "AceConsole-3.0",
                                                      "AceEvent-3.0")

local defaults = {
    global = {
        debug = true,
        reagents = {},
    }
}

function TradeSkillReagents:Debug(message)
    if (TradeSkillReagents.db.global.debug) then
        TradeSkillReagents:Print(message)
    end
end

function TradeSkillReagents:OnInitialize()
    TradeSkillReagents.db = LibStub("AceDB-3.0"):New("TradeSkillReagentsDB", defaults, true)

    TradeSkillReagents:Debug("on init")
end

function TradeSkillReagents:OnEnable()
    TradeSkillReagents:Debug("on enabled")

    TradeSkillReagents:RegisterEvent("TRADE_SKILL_SHOW", OnTradeSkillShow)
    TradeSkillReagents:RegisterEvent("CRAFT_SHOW", OnCraftShow)
end

local function dictInsert(dict, key, value)
    if dict[key] then 
        return
    end

    dict[key] = value
end

local function valueInsert(dict, key)
    if dict[key] then
        dict[key] = dict[key] + 1
    else
        dict[key] = 1
    end
end

function OnTradeSkillShow()
    TradeSkillReagents:Debug("tradeskill opened")
    local tradeskillName, _, _, _ = GetTradeSkillLine()
    -- TradeSkillReagents:Debug(tradeskillName)
    for id=1,GetNumTradeSkills() do
        local skillName, skillType, _, _, _, _ = GetTradeSkillInfo(id);
        if (skillName and skillType ~= "header") then
            -- TradeSkillReagents:Debug(skillName)
            for i=1, GetTradeSkillNumReagents(id) do
                local reagentName, _, _, _ = GetTradeSkillReagentInfo(id, i);
                -- TradeSkillReagents:Debug(" - "..reagentName)
                
                dictInsert(TradeSkillReagents.db.global.reagents, reagentName, {})
                dictInsert(TradeSkillReagents.db.global.reagents[reagentName], tradeskillName, {})
                valueInsert(TradeSkillReagents.db.global.reagents[reagentName][tradeskillName], skillName)
                TradeSkillReagents:Debug(reagentName.." "..tradeskillName.." "..skillName)
            end
        end
    end
end

function OnCraftShow()
    TradeSkillReagents:Debug("craft opened")
    local craftNameString = GetCraftName();
    -- TradeSkillReagents:Debug(craftNameString)
    for id=1,GetNumCrafts() do
        local craftName, craftSubSpellName, craftType, _, _, _, _ = GetCraftInfo(id);
        if (craftName and craftType ~= "header") then
            -- TradeSkillReagents:Debug(craftName)
            for i=1, GetCraftNumReagents(id) do
                local reagentName, _, _, _ = GetCraftReagentInfo(id, i);
                -- TradeSkillReagents:Debug(" - "..reagentName)
                
                dictInsert(TradeSkillReagents.db.global.reagents, reagentName, {})
                dictInsert(TradeSkillReagents.db.global.reagents[reagentName], craftNameString, {})
                valueInsert(TradeSkillReagents.db.global.reagents[reagentName][craftNameString], craftName)
                TradeSkillReagents:Debug(reagentName.." "..craftNameString.." "..craftName)
            end
        end
    end
end