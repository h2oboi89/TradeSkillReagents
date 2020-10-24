TradeSkillReagents = LibStub("AceAddon-3.0"):NewAddon("TradeSkillReagents", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

local defaults = {
    global = {
        version = false,
        options = {
            debug = false
        },
        reagents = {}
    }
}

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
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

local function addOnVersion() return tonumber(GetAddOnMetadata("TradeSkillReagents", "Version")) end

local function isVersionNewer(db, version)
    -- no version set (1.0 or fresh DB)
    if not db.global.version then return true end
    
    -- major version change
    if (math.floor(version) - math.floor(db.global.version) >= 1) then return true end

    return false
end

function TradeSkillReagents:Debug(message)
    if self.db.options.debug then self:Print(message) end
end

function TradeSkillReagents:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("TradeSkillReagentsDB", defaults, true)

    local version = addOnVersion()

    if isVersionNewer(self.db, version) then
        if self.db.global.version then
            self:Print("newer version detected ( v" .. self.db.global.version .. " -> v" .. version .. " ), resetting database")
        else
            self:Print("no version detected, starting new database ( v" .. version .. " )")
        end

        self.db.global.version = version
        self.db.global.options = deepcopy(defaults.global.options)
        self.db.global.reagents = deepcopy(defaults.global.reagents)
    end

    self.db = self.db.global

    self.db.options.debug = true
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

local function getTradeSkillName()
    local _, skillLineDisplayName, _, _, _, _, parentSkillLineDisplayName = C_TradeSkillUI.GetTradeSkillLine()
    
    local tradeSkillName = nil

    if not skillLineDisplayName then 
        return
    else
        tradeSkillName = skillLineDisplayName

        if parentSkillLineDisplayName then
            tradeSkillName = parentSkillLineDisplayName
        end
    end

    return tradeSkillName
end

local function getTradeSkillCategories()
    local categories = {}
    
    for _, categoryID in pairs({C_TradeSkillUI.GetCategories()}) do
        categories[categoryID] = C_TradeSkillUI.GetCategoryInfo(categoryID).name
    end

    return categories
end

local function getTradeSkillCategoryName(categories, categoryID)
    local categoryInfo = C_TradeSkillUI.GetCategoryInfo(categoryID)
    local categoryName = categories[categoryInfo.parentCategoryID]

    if not categoryName then
        categoryName = categories[categoryInfo.categoryID]
    end

    return categoryName
end

local function addIfNew(tbl, value)
    local exists = false
    for _, v in ipairs(tbl) do
        if v == value then exists = true end
    end

    if not exists then table.insert(tbl, value) end
end

function TradeSkillReagents:ProcessRecipes()
    self.ScanTimer = nil

    local tradeSkill = getTradeSkillName()
    
    if not tradeSkill or not C_TradeSkillUI.IsTradeSkillReady() then 
        return 
    end

    self:Debug("Scanning " .. tradeSkill)

    local db = self.db.reagents

    local categories = getTradeSkillCategories()
    
    local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs()
    local recipeCount = 0
    local reagentCount = 0

    for _, recipeID in ipairs(recipeIDs) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)

        local category = getTradeSkillCategoryName(categories, recipeInfo.categoryID)

        for reagentIndex = 1, C_TradeSkillUI.GetRecipeNumReagents(recipeID) do
            local reagentName = C_TradeSkillUI.GetRecipeReagentInfo(recipeID, reagentIndex)
            
            if reagentName then 
                db[reagentName] = db[reagentName] or {}
                db[reagentName][tradeSkill] = db[reagentName][tradeSkill] or {}
                addIfNew(db[reagentName][tradeSkill], category)
                
                reagentCount = reagentCount + 1
            end
        end

        recipeCount = recipeCount + 1
    end

    self:Debug("Done scanning " .. tradeSkill .. " ( " .. recipeCount .. " recipes | " .. reagentCount .. " reagents )")
end

function TradeSkillReagents:AttachTooltip(tooltip, ...)
    if IsShiftKeyDown() then return end

    local itemName, _ = tooltip:GetItem();

    local db = self.db.reagents

    if not db[itemName] then return end

    local lines = {}

    for tradeSkill, categories in pairs(db[itemName]) do
        for _, category in ipairs(categories) do
            table.insert(lines, tradeSkill .. " - " .. category)
        end
    end

    table.sort(lines)

    for _, line in ipairs(lines) do
        tooltip:AddLine(line , 0, 1, 1)
    end
end
