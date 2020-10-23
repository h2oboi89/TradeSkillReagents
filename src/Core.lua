TradeSkillReagents = LibStub("AceAddon-3.0"):NewAddon("TradeSkillReagents", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")

local debug = false

function TradeSkillReagents:Debug(message)
    if debug then self:Print(message) end
end

function TradeSkillReagents:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("TradeSkillReagentsDB")
end

function TradeSkillReagents:OnEnable()
    -- NOTE: this fires twice when window is opened
    self:RegisterEvent("TRADE_SKILL_LIST_UPDATE")

    self:RawHookScript(GameTooltip, "OnTooltipSetItem", "AttachTooltip")
    self:RawHookScript(ItemRefTooltip, "OnTooltipSetItem", "AttachTooltip")
end

function TradeSkillReagents:TRADE_SKILL_LIST_UPDATE()
    self:ProcessRecipes()
end

function TradeSkillReagents:ProcessRecipes()
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
    
    local categories = {}
    
    for _, categoryID in pairs({C_TradeSkillUI.GetCategories()}) do
        categories[categoryID] = C_TradeSkillUI.GetCategoryInfo(categoryID).name
    end
    
    if not db["reagents"] then db["reagents"] = {} end

    db = db.reagents

    local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs()

    for key, recipeID in pairs(recipeIDs) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)

        local categoryInfo = C_TradeSkillUI.GetCategoryInfo(recipeInfo.categoryID)
        local category = categories[categoryInfo.parentCategoryID]

        if not category then
            category = categories[categoryInfo.categoryID]
        end

        category = profession .. " - " .. category

        for reagentIndex = 1, C_TradeSkillUI.GetRecipeNumReagents(recipeID) do
            local reagentName = C_TradeSkillUI.GetRecipeReagentInfo(recipeID, reagentIndex)
            
            if reagentName then 
                db[reagentName] = db[reagentName] or {}
                
                if not db[reagentName][category] then
                    db[reagentName][category] = true
                end
            end
        end
    end
end

function TradeSkillReagents:AttachTooltip(tooltip, ...)
    if IsShiftKeyDown() then return end

    itemName, _ = tooltip:GetItem();

    local db = self.db.global.reagents

    if not db or not db[itemName] then return end

    for profession, needed in pairs(db[itemName]) do
        if needed then
            tooltip:AddLine(profession, 0, 1, 1)
        end
    end
end
