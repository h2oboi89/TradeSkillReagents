TradeSkillReagents = LibStub("AceAddon-3.0"):NewAddon("TradeSkillReagents", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

local debug = false

function TradeSkillReagents:Debug(message)
    if debug then self:Print(message) end
end

function TradeSkillReagents:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("TradeSkillReagentsDB")
end

function TradeSkillReagents:OnEnable()
    self:RegisterEvent("TRADE_SKILL_LIST_UPDATE")

    self:RawHookScript(GameTooltip, "OnTooltipSetItem", "AttachTooltip")
    self:RawHookScript(ItemRefTooltip, "OnTooltipSetItem", "AttachTooltip")
end

function TradeSkillReagents:TRADE_SKILL_LIST_UPDATE()
    if self.ScanTimer then return end

    self.ScanTimer = self:ScheduleTimer(function () self:ProcessRecipes() end, 1)
end

function TradeSkillReagents:ProcessRecipes()
    self.ScanTimer = nil

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

    self:Print("Scanning " .. profession)

    local db = self.db.global

    for reagent, _ in pairs(db) do
        if db[reagent][profession] then
            db[reagent][profession] = nil
        end
    end
    
    local categories = {}
    
    for _, categoryID in pairs({C_TradeSkillUI.GetCategories()}) do
        categories[categoryID] = C_TradeSkillUI.GetCategoryInfo(categoryID).name
    end
    
    if not db["reagents"] then db["reagents"] = {} end

    db = db.reagents

    local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs()
    local recipeCount = 0
    local reagentCount = 0

    for key, recipeID in pairs(recipeIDs) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)

        local categoryInfo = C_TradeSkillUI.GetCategoryInfo(recipeInfo.categoryID)
        local category = categories[categoryInfo.parentCategoryID]

        if not category then
            category = categories[categoryInfo.categoryID]
        end

        for reagentIndex = 1, C_TradeSkillUI.GetRecipeNumReagents(recipeID) do
            local reagentName = C_TradeSkillUI.GetRecipeReagentInfo(recipeID, reagentIndex)
            
            if reagentName then 
                db[reagentName] = db[reagentName] or {}
                db[reagentName][profession] = db[reagentName][profession] or {}
                db[reagentName][profession][category] = true
                
                reagentCount = reagentCount + 1
            end
        end

        recipeCount = recipeCount + 1
    end

    self:Print("Done scanning " .. profession .. " ( " .. recipeCount .. " recipes | " .. reagentCount .. " reagents )")
end

function TradeSkillReagents:AttachTooltip(tooltip, ...)
    if IsShiftKeyDown() then return end

    local itemName, _ = tooltip:GetItem();

    local db = self.db.global.reagents

    if not db or not db[itemName] then return end

    local lines = {}

    for profession, _ in pairs(db[itemName]) do
        for category, needed in pairs(db[itemName][profession]) do
            if needed then
                table.insert(lines, profession .. " - " .. category)
            end
        end
    end

    table.sort(lines)

    for _, line in ipairs(lines) do
        tooltip:AddLine(line , 0, 1, 1)
    end
end
