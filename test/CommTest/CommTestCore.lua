CommTest = LibStub("AceAddon-3.0"):NewAddon("CommTest", 
                                            "AceConsole-3.0",
                                            "AceEvent-3.0")

function CommTest:OnInitialize()
    -- Registers "/commtest" as a slash command
    self:RegisterChatCommand("commtest", CommTest.QueryItem)
    self:Print("commtest on init")
end

function CommTest:OnEnable()
    -- Registers response message from Trade Skill Reagents addon
    self:RegisterMessage("TRADE_SKILL_REAGENTS_RESPONSE")
    self:Print("commtest on enable")
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
--   tradeSkills = { ... }  -- list of trade skills names (IE: Tailoring)
-- }
function CommTest:TRADE_SKILL_REAGENTS_QUERY_RESPONSE(messageName, response)
    self:Print("Receiving " .. response.itemName)

    if response.tradeSkills then
        for _, tradeSkill in ipairs(response.tradeSkills) do
            self:Print(" - " .. tradeSkill)
        end
    else
        self:Print("  No trade skill info")
    end
end
