-- TODO: Use "AceComm-3.0" as mixin to allow instances to communicate between clients
ReagentProfessions = LibStub("AceAddon-3.0"):NewAddon("ReagentProfessions", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")

local debug = true

function ReagentProfessions:Debug(message)
    if debug then print(message) end
end

function ReagentProfessions:OnInitialize()
    -- Code that you want to run when the addon is first loaded goes here.
    self.db = LibStub("AceDB-3.0"):New("ReagentProfessionsDB")
end

function ReagentProfessions:OnEnable()
    -- Called when the addon is enabled
    self:Debug("ReagentProfessions enabled!")

    -- self:RegisterEvent("TRADE_SKILL_SHOW")
    self:RegisterEvent("TRADE_SKILL_LIST_UPDATE")

    self:RawHookScript(GameTooltip, "OnTooltipSetItem", "AttachTooltip")
    self:RawHookScript(ItemRefTooltip, "OnTooltipSetItem", "AttachTooltip")
end

function ReagentProfessions:OnDisable()
    -- Called when the addon is disabled
    self:Debug("ReagentProfessions disabled!")
end

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

function ReagentProfessions:TRADE_SKILL_SHOW()
    self:Debug("ReagentProfessions trade skill show fired!")
    self:ProcessRecipes()
end

function ReagentProfessions:TRADE_SKILL_LIST_UPDATE()
    self:Debug("ReagentProfessions trade skill list update fired!")
    self:ProcessRecipes()
end

function ReagentProfessions:ProcessRecipes()
    local _, skillLineDisplayName, _, _, _, _, parentSkillLineDisplayName = C_TradeSkillUI.GetTradeSkillLine()

    -- TODO: use timer to queue up reading recipes

    local profession = "Unknown"

    if not skillLineDisplayName then 
        self:Debug("no skill in queue") 
        return 
    else
        profession = skillLineDisplayName

        self:Debug(skillLineDisplayName)

        if parentSkillLineDisplayName then
            profession = parentSkillLineDisplayName

            self:Debug("parent: " .. parentSkillLineDisplayName)
        end
    end

    if not C_TradeSkillUI.IsTradeSkillReady() then 
        self:Debug("trade skill not ready")
        return 
    end

    local db = self.db.global

    for reagent, _ in pairs(db) do
        db[reagent][profession] = false
    end

    local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs()

    self:Debug(#recipeIDs)

    for key, recipeID in pairs(recipeIDs) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)

        -- self:Debug("processing " .. recipeID .. " " .. recipeInfo.name)

        for reagentIndex = 1, C_TradeSkillUI.GetRecipeNumReagents(recipeID) do
            local reagentName = C_TradeSkillUI.GetRecipeReagentInfo(recipeID, reagentIndex)
            
            if reagentName then 
                db[reagentName] = db[reagentName] or {}
                
                if not db[reagentName][profession] then
                    db[reagentName][profession] = true
                end
            else
                self:Debug("no reagent name for " .. recipeInfo.name .. " " .. reagentIndex)
            end
        end
    end
end

function ReagentProfessions:AttachTooltip(tooltip, ...)
    if IsShiftKeyDown() then return end

    itemName, _ = tooltip:GetItem();

    local db = self.db.global

    if not db[itemName] then return end

    for profession, needed in pairs(db[itemName]) do
        if needed then
            tooltip:AddLine(profession, 0, 1, 1)
        end
    end
end
