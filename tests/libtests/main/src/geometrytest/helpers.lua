local helpers = {}

function helpers.assertIncorrectCreation(class, className, variables, default, useNegative)

    badValues = {"1", false, math.huge, -math.huge, math.huge / math.huge}

    if default == nil then
        default = 0
    end

    -- sometimes negative values are allowed, so this is optional
    if useNegative or useNegative == nil then
        table.insert(badValues, -1)
    end

    for _, badValue in ipairs(badValues) do

        local params = {}
        for i, var in ipairs(variables) do
            params[i] = default
        end

        for i, var in ipairs(variables) do
            params[i] = badValue

            success, result = pcall(class, unpack(params))
            if success then
                error(className .. "." .. var .. " incorrectly created with " .. tostring(badValue))
            end

            params[i] = default
        end
    end
end

return helpers
