TradeSkillReagents = LibStub("AceAddon-3.0"):NewAddon("TradeSkillReagents",
                                                      "AceConsole-3.0",
                                                      "AceEvent-3.0",
                                                      "AceHook-3.0",
                                                      "AceTimer-3.0")

local defaults = {
    global = {
        version = false,
        options = {
            debug = false,
            tooltip = {
                disable = false,
                useSingleColor = true,
                singleColor = {r = 0, g = 1, b = 1, a = 1},
                tradeSkills = {}
            }
        },
        reagents = {},
    }
}

local options = {
    name = "Trade Skill Reagents",
    type = "group",
    handler = TradeSkillReagents,
    args = {
        colors = {
            name = "Colors",
            type = "group",
            inline = true,
            order = 0,
            args = {
                useSingleColor = {
                    name = "Use single color for trade skills in tooltips",
                    desc = "Uncheck to use different colors for each trade skill",
                    type = "toggle",
                    order = 0,
                    set = "SetOptionsSingleColorToggle",
                    get = "GetOptionsSingleColorToggle"
                },
                singleColor = {
                    name = "Single Color",
                    type = "color",
                    order = 1,
                    set = "SetOptionsSingleColor",
                    get = "GetOptionsSingleColor"
                },
                tradeSkills = {
                    name = "Trade Skill Colors",
                    type = "group",
                    inline = true,
                    disabled = "GetOptionsTradeSkillsColorsDisabled",
                    order = -1,
                    args = {}
                }
            }
        },
        disableTooltip = {
            name = "Disable tooltip",
            desc = "Check to disable tooltip if Trade Skill Reagents is being used by another addon",
            type = "toggle",
            order = 1,
            set = "SetOptionsDisableTooltip",
            get = "GetOptionsDisableTooltip"
        },
        debug = {
            name = "Debug",
            desc = "Enables debug print statements",
            type = "toggle",
            set = "SetOptionsDebug",
            get = "GetOptionsDebug",
            order = -1
        }
    }
}

local scannedTradeSkills = {}
local maxScansPerLogin = 5

local function dictInsert(dict, key, value)
    if dict[key] then return end

    dict[key] = value
end

local function valueInsert(dict, key)
    if dict[key] then
        dict[key] = dict[key] + 1
    else
        dict[key] = 1
    end
end

local function removeKey(tbl, key)
    local prunedTable = {}

    for k, v in pairs(tbl) do 
        if k ~= key then prunedTable[k] = v end
    end

    return prunedTable
end

local function deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepCopy(orig_key)] = deepCopy(orig_value)
        end
        setmetatable(copy, deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

local function dump(o)
    if type(o) == 'table' then
        local s = '{ '

        for k, v in pairs(o) do
            if type(k) == 'table' then k = dump(k) end
            if type(k) ~= 'number' then k = '"' .. k .. '"' end

            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end

        return s .. '} '
    else
        return tostring(o)
    end
end

local function tableLength(tbl)
    local getN = 0

    for n in pairs(tbl) do getN = getN + 1 end

    return getN
end

local function addOnVersion()
    return tonumber(GetAddOnMetadata("TradeSkillReagents", "Version"))
end

local function isVersionNewer(db, version)
    -- no version set (1.0 or fresh DB)
    if not db.global.version then return true end

    -- major version change
    if (math.floor(version) - math.floor(db.global.version) >= 1) then
        return true
    end

    return false
end

function TradeSkillReagents:Debug(message)
    if self.db.options.debug then self:Print(message) end
end

function TradeSkillReagents:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("TradeSkillReagentsDB", defaults, true)

    local version = addOnVersion()

    if isVersionNewer(self.db, version) then
        self:ResetDB(version)
    end

    self.db.global.version = version

    self.db = self.db.global

    self:AddTradeSkillColorOptions()

    LibStub("AceConfig-3.0"):RegisterOptionsTable("TradeSkillReagents", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("TradeSkillReagents",
                                                    "Trade Skill Reagents")
end

function TradeSkillReagents:ResetDB(version)
    if self.db.global.version then
        if math.floor(self.db.global.version) == 2 and math.floor(version) == 3 then
            self:MigrateDB(version)
            return
        else
            self:Print("newer version detected ( v" .. self.db.global.version ..
                       " -> v" .. version .. " ), resetting database")
        end
    else
        self:Print("no version detected, starting new database ( v" ..
                       version .. " )")
    end

    self.db.global.options = deepCopy(defaults.global.options)
    self.db.global.reagents = deepCopy(defaults.global.reagents)
end

function TradeSkillReagents:MigrateDB(version)
    self:Print("newer version detected ( v" .. self.db.global.version ..
                       " -> v" .. version .. " ), migrating database")

    for reagents, tradeSkills in pairs(self.db.global.reagents) do
        for tradeSkill, categories in pairs(tradeSkills) do
            local updatedTradeSkill = {}

            for _, category in ipairs(tradeSkills[tradeSkill]) do
                updatedTradeSkill[category] = 1
            end

            tradeSkills[tradeSkill] = updatedTradeSkill
        end
    end
end

function TradeSkillReagents:AddTradeSkillColorOptions()
    local tradeSkillOptions = options.args.colors.args.tradeSkills.args

    for tradeSkill, _ in pairs(self.db.options.tooltip.tradeSkills) do
        tradeSkillOptions[tradeSkill] = {
            name = tradeSkill,
            type = "color",
            set = "SetOptionsTradeSkillColor",
            get = "GetOptionsTradeSkillColor"
        }
    end
end

-- HACK to get GameTooltip:GetItem to work in TradeSkill UI for recipe reagents
-- local GameTooltipSetRecipeReagentItem = GameTooltip.SetRecipeReagentItem
-- function GameTooltip:SetRecipeReagentItem(...)
--     local link = C_TradeSkillUI.GetRecipeReagentItemLink(...)
--     if link then return self:SetHyperlink(link) end
--     return GameTooltipSetRecipeReagentItem(self, ...)
-- end

function TradeSkillReagents:OnEnable()
    self:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
    self:RegisterMessage("TRADE_SKILL_REAGENTS_QUERY")

    self:HookScript(GameTooltip, "OnToolTipSetItem", "AddTradeSkillTooltipInfo")
    self:HookScript(ItemRefTooltip, "OnToolTipSetItem",
                    "AddTradeSkillTooltipInfo")
end

function TradeSkillReagents:TRADE_SKILL_REAGENTS_QUERY(messageName, itemName)
    local response = {itemName = itemName}

    local tradeSkills = self.db.reagents[itemName]

    if tradeSkills then response.tradeSkills = deepCopy(tradeSkills) end

    self:SendMessage("TRADE_SKILL_REAGENTS_QUERY_RESPONSE", response)
end

function TradeSkillReagents:TRADE_SKILL_LIST_UPDATE()
    if self.ScanTimer then return end

    self.ScanTimer = self:ScheduleTimer(function() self:ProcessRecipes() end, 1)
end

local function getTradeSkillName()
    local _, skillLineDisplayName, _, _, _, _, parentSkillLineDisplayName =
        C_TradeSkillUI.GetTradeSkillLine()

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

function TradeSkillReagents:PruneDB(scannedTradeSkill)
    local prunable = {}

    for reagent, tradeSkills in pairs(self.db.reagents) do
        for tradeSkill, categories in pairs(tradeSkills) do
            if tradeSkill == scannedTradeSkill then
                for category, v in pairs(categories) do
                    categories[category] = (v * 2) % 256

                    if categories[category] == 0 then
                        dictInsert(prunable, reagent, {})
                        dictInsert(prunable[reagent], tradeSkill, category)

                        self:Print(reagent .. " (" .. tradeSkill .. " - " ..
                                    category .. ") will be pruned")
                    end
                end
            end
        end
    end

    for reagent, tradeSkills in pairs(prunable) do
        for tradeSkill, category in pairs(tradeSkills) do
            local prunedCategories = removeKey(self.db.reagents[reagent][tradeSkill], category)

            if tableLength(prunedCategories) == 0 then
                self.db.reagents = removeKey(self.db.reagents, reagent)
            else
                self.db.reagents[reagent][tradeSkill] = prunedCategories
            end
        end
    end
end

function TradeSkillReagents:ShouldScan(tradeSkill)
    local timesScanned = scannedTradeSkills[tradeSkill]

    if timesScanned == nil then
        timesScanned = 0
    end

    if timesScanned == maxScansPerLogin then
        self:Debug(tradeSkill .. " already scanned")
        return false
    end

    timesScanned = timesScanned + 1

    scannedTradeSkills[tradeSkill] = timesScanned

    self:Debug("Scanning " .. tradeSkill .. " [ Scan " .. timesScanned .. " of " .. maxScansPerLogin .. "]")

    return true
end

function TradeSkillReagents:ProcessRecipes()
    self.ScanTimer = nil

    local tradeSkill = getTradeSkillName()

    if not tradeSkill or not C_TradeSkillUI.IsTradeSkillReady() then return end

    if not self:ShouldScan(tradeSkill) then return end

    self:PruneDB(tradeSkill)

    local categories = getTradeSkillCategories()

    local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs()
    local recipeCount = 0
    local reagentCount = 0

    for _, recipeID in ipairs(recipeIDs) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)

        local category = getTradeSkillCategoryName(categories,
                                                   recipeInfo.categoryID)

        for reagentIndex = 1, C_TradeSkillUI.GetRecipeNumReagents(recipeID) do
            local reagentName = C_TradeSkillUI.GetRecipeReagentInfo(recipeID,
                                                                    reagentIndex)

            if reagentName then
                dictInsert(self.db.reagents, reagentName, {})
                dictInsert(self.db.reagents[reagentName], tradeSkill, {})
                valueInsert(self.db.reagents[reagentName][tradeSkill], category)

                reagentCount = reagentCount + 1
            end
        end

        recipeCount = recipeCount + 1
    end

    if reagentCount > 0 then
        dictInsert(self.db.options.tooltip.tradeSkills, tradeSkill,
                   deepCopy(defaults.global.options.tooltip.singleColor))
    end

    self:Debug("Done scanning " .. tradeSkill .. " ( " .. recipeCount ..
                   " recipes | " .. reagentCount .. " reagents )")
end

function TradeSkillReagents:GetTooltipColor(tradeSkill)
    if self.db.options.tooltip.useSingleColor then
        return self.db.options.tooltip.singleColor
    else
        return self.db.options.tooltip.tradeSkills[tradeSkill]
    end
end

function TradeSkillReagents:AddTradeSkillTooltipInfo(tooltip)
    if IsShiftKeyDown() or self.db.options.tooltip.disable then return end

    local itemName, itemLink = tooltip:GetItem()

    if not self.db.reagents[itemName] then return end

    local lines = {}

    for tradeSkill, categories in pairs(self.db.reagents[itemName]) do
        for category, _ in pairs(categories) do
            table.insert(lines, {
                text = tradeSkill .. " - " .. category,
                tradeSkill = tradeSkill
            })
        end
    end

    table.sort(lines, function(a, b) return a.text < b.text end)

    for _, line in ipairs(lines) do
        local color = self:GetTooltipColor(line.tradeSkill)
        tooltip:AddLine(line.text, color.r, color.g, color.b)
    end
end

function TradeSkillReagents:SetOptionsDebug(info, value)
    self.db.options.debug = value
end

function TradeSkillReagents:GetOptionsDebug(info) return self.db.options.debug end

function TradeSkillReagents:SetOptionsDisableTooltip(info, value)
    self.db.options.tooltip.disable = value
end

function TradeSkillReagents:GetOptionsDisableTooltip(info)
    return self.db.options.tooltip.disable
end

function TradeSkillReagents:SetOptionsSingleColorToggle(info, value)
    self.db.options.tooltip.useSingleColor = value
end

function TradeSkillReagents:GetOptionsSingleColorToggle(info)
    return self.db.options.tooltip.useSingleColor
end

function TradeSkillReagents:SetOptionsSingleColor(info, r, g, b, a)
    self.db.options.tooltip.singleColor = {r = r, g = g, b = b, a = a}
end

function TradeSkillReagents:GetOptionsSingleColor(info)
    local color = self.db.options.tooltip.singleColor
    return color.r, color.g, color.b, color.a
end

function TradeSkillReagents:GetOptionsTradeSkillsColorsDisabled(info)
    return self.db.options.tooltip.useSingleColor
end

function TradeSkillReagents:SetOptionsTradeSkillColor(info, r, g, b, a)
    local tradeSkill = info[#info]
    self.db.options.tooltip.tradeSkills[tradeSkill] =
        {r = r, g = g, b = b, a = a}
end

function TradeSkillReagents:GetOptionsTradeSkillColor(info)
    local tradeSkill = info[#info]
    local color = self.db.options.tooltip.tradeSkills[tradeSkill]
    return color.r, color.g, color.b, color.a
end
