
local function formatTable(table, indent)
    local output = "\n"

    if indent == nil then
        indent = 0
    end

    for key, value in pairs(table) do
        output = output .. string.rep("\t", indent) .. key .. ": "

        if type(value) == "boolean" then
            output = output .. (value and "true" or "false") .. "\n"
        elseif type(value) == "table" then
            output = output .. formatTable(value, indent + 1)
        else
            output = output .. value .. "\n"
        end
    end

    return output
end

local function printValue(value)
    local output

    if value == nil then
        output = "nil"
    elseif type(value) == "boolean" then
        output = (value and "true" or "false")
    elseif type(value) == "table" then
        output = formatTable(value, 0)
    else
        output = value
    end

    print(output)
end

return {
    print = printValue
}