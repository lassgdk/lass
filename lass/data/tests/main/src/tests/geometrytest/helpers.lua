local helpers = {}

function helpers.assertIncorrectValues(geometryClass, className, variables, default, extraValues)

    local incorrectValues = {"1", false, math.huge, -math.huge, math.huge / math.huge}

    if extraValues then
        for _, extraValue in ipairs(extraValues) do
            table.insert(incorrectValues, extraValue)
        end
    end

    for _, incorrectValue in ipairs(incorrectValues) do

        local params = {}
        for i, _ in ipairs(variables) do
            params[i] = default
        end

        local instance = geometryClass(unpack(params))
        for i, var in ipairs(variables) do

            -- attempt to set a value to something incorrect
            local success, result = pcall(function() instance[var] = incorrectValue end)
            -- debug.log(result)
            if success then
                error(className .. "." .. var .. " incorrectly set to " .. tostring(incorrectValue))
            end

            params[i] = incorrectValue

            -- attempt to make the class with a single incorrect value
            -- need to give unpack the number of variables, because if nil is the default,
            -- the unpack will potentially skip the nil values which can cause problems
            success, result = pcall(geometryClass, unpack(params, 1, #variables))
            -- debug.log(result)
            if success then
                error(className .. "." .. var .. " incorrectly created with " .. tostring(incorrectValue))
            end

            params[i] = default
        end
    end
end

return helpers
