local Debug = TradeSkillReagentsModules:Create("Debug");

local Logger = TradeSkillReagentsModules:Import("Logger");

local function dump(t, indent)
    indent = indent or ""
    local currentIndent = indent;
    Logger:Debug(currentIndent.."{");
    indent = indent .. "  ";
    for k, v in pairs(t) do
        local formatting = indent .. "[" .. tostring(k) .. "] = "
        if type(v) == "table" then
            Logger:Debug(formatting)
            dump(v, indent .. "  ") -- Recurse with increased indent
        else
            Logger:Debug(formatting .. tostring(v))
        end
    end
    Logger:Debug(currentIndent.."}");
end

function Debug:Dump(table)
    dump(table);
end

function Debug:ListToString(list)
    local result = "[ ";

    for i, v in ipairs(list) do
        result = result..v..", ";
    end

    result = result.." ]";

    return result;
end