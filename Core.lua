-- TODO: Use "AceComm-3.0" as mixin to allow instances to communicate between clients
ReagentProfessions = LibStub("AceAddon-3.0"):NewAddon("ReagentProfessions", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")

local debug = true

local function dump(o)
    if type(o) == 'table' then
        local s = '{ '

        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        
        return s .. '} '
    else
        return tostring(o)
    end
end

function ReagentProfessions:Debug(message)
    if debug then self:Print(message) end
end

function ReagentProfessions:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ReagentProfessionsDB")
end

function ReagentProfessions:OnEnable()
    -- NOTE: this fires twice when window is opened
    self:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
    self:RegisterEvent("PLAYER_LOGOUT")

    self:RawHookScript(GameTooltip, "OnTooltipSetItem", "AttachTooltip")
    self:RawHookScript(ItemRefTooltip, "OnTooltipSetItem", "AttachTooltip")
end

function ReagentProfessions:OnDisable() end

function ReagentProfessions:PLAYER_LOGOUT()
    self:PruneDB()    
end

function ReagentProfessions:PruneDB()
    local db = self.db.global.reagents

    for reagent, professions in pairs(db) do
        local stillNeeded = false

        for profession, needed in pairs(professions) do
            if needed then
                stillNeeded = true
            else
                db[reagent][profession] = nil
            end
        end

        if not stillNeeded then
            db[reagent] = nil
        end
    end
end

function ReagentProfessions:TRADE_SKILL_LIST_UPDATE()
    self:ProcessRecipes()
end

function ReagentProfessions:ProcessRecipes()
    local _, skillLineDisplayName, _, _, _, _, parentSkillLineDisplayName = C_TradeSkillUI.GetTradeSkillLine()

    local profession = "Unknown"

    if not skillLineDisplayName then 
        return
    else
        profession = skillLineDisplayName

        if parentSkillLineDisplayName then
            profession = parentSkillLineDisplayName
        end
    end

    if not C_TradeSkillUI.IsTradeSkillReady() then 
        return 
    end

    local db = self.db.global

    if not db["reagents"] then db["reagents"] = {} end

    db = db.reagents

    for reagent, _ in pairs(db) do
        db[reagent][profession] = false
    end

    local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs()

    for key, recipeID in pairs(recipeIDs) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)

        for reagentIndex = 1, C_TradeSkillUI.GetRecipeNumReagents(recipeID) do
            local reagentName = C_TradeSkillUI.GetRecipeReagentInfo(recipeID, reagentIndex)
            
            if reagentName then 
                db[reagentName] = db[reagentName] or {}
                
                if not db[reagentName][profession] then
                    db[reagentName][profession] = true
                end
            end
        end
    end
end

function ReagentProfessions:AttachTooltip(tooltip, ...)
    if IsShiftKeyDown() then return end

    itemName, _ = tooltip:GetItem();

    local db = self.db.global.reagents

    if not db[itemName] then return end

    for profession, needed in pairs(db[itemName]) do
        if needed then
            tooltip:AddLine(profession, 0, 1, 1)
        end
    end
end
