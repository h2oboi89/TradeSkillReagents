CommTest = LibStub("AceAddon-3.0"):NewAddon("CommTest", "AceConsole-3.0",
                                            "AceEvent-3.0")

function CommTest:OnInitialize()
    -- Registers "/commtest" as a slash command
    self:RegisterChatCommand("commtest", "QueryItem")
end

function CommTest:OnEnable()
    -- Registers response message from Trade Skill Reagents addon
    self:RegisterMessage("TRADE_SKILL_REAGENTS_QUERY_RESPONSE")
end

-- Handles slash command and sends query to Trade Skills Reagents addon
-- Format: "/commTest <item name>" where <item name> is the name of the item ie: Unbroken Fang
function CommTest:QueryItem(input)
    self:Print("Sending " .. input)
    self:SendMessage("TRADE_SKILL_REAGENTS_QUERY", input)
end

-- Handles query response message from Trade Skills Reagents addon
-- Response format:
-- {
--   itemName = <item name> -- same as what was sent in query
--   tradeSkills = {
--     <trade skill> = {    -- ie: Tailoring
--       <category>,        -- ie: Kul Tiran Patterns
--       ...                -- other categories if reagent is used in multiple categories
--     },
--     ...                  -- other trade skills if reagent is used in multiple trade skills
--   }
-- }
-- NOTE: "tradeSkills" may be nil if reagent is not in database. "categories" will always have a value if reagent is in database.
function CommTest:TRADE_SKILL_REAGENTS_QUERY_RESPONSE(messageName, response)
    self:Print("Receiving " .. response.itemName)

    if response.tradeSkills then
        for tradeSkill, categories in pairs(response.tradeSkills) do
            self:Print(" - " .. tradeSkill)

            for _, category in ipairs(categories) do
                self:Print("   - " .. category)
            end
        end
    else
        self:Print("  No trade skill info")
    end
end
