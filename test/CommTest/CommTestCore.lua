CommTest = LibStub("AceAddon-3.0"):NewAddon("CommTest", "AceConsole-3.0",
                                            "AceEvent-3.0")

function CommTest:OnInitialize()
    self:RegisterChatCommand("commtest", "QueryItem")
end

function CommTest:OnEnable()
    self:RegisterMessage("TRADE_SKILL_REAGENTS_QUERY_RESPONSE")
end

function CommTest:QueryItem(input)
    self:Print("Sending " .. input)
    self:SendMessage("TRADE_SKILL_REAGENTS_QUERY", input)
end

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
