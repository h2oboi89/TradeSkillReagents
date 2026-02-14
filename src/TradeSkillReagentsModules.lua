TradeSkillReagentsModules = {}

local modules = {}

function TradeSkillReagentsModules:Create(name)
    if (not modules[name]) then
        modules[name] = { private = {} }
    end
    return modules[name]
end

function TradeSkillReagentsModules:Import(name)
    return TradeSkillReagentsModules:Create(name)
end