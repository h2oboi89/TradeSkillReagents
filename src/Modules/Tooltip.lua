local ToolTip = TradeSkillReagentsModules:Create("ToolTip");

local Logger = TradeSkillReagentsModules:Import("Logger");
local DataBase = TradeSkillReagentsModules:Import("DataBase");

function ToolTip:Init(addon)
    ToolTip.private.addon = addon;

    ToolTip.private.addon.HookScript(GameTooltip, "OnToolTipSetItem", ToolTip.AddTradeSkillTooltipInfo)
    ToolTip.private.addon.HookScript(ItemRefTooltip, "OnToolTipSetItem", ToolTip.AddTradeSkillTooltipInfo)
end

function ToolTip:AddTradeSkillTooltipInfo()
    local name, _ = self:GetItem()

    local skills = DataBase:GetReagentSkills(name)

    for _, skill in ipairs(skills) do
        self:AddLine(skill)
    end
end