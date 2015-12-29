local helpers = {}

function helpers.assertIncorrectValues(geometryClass, className, variables, default, useNegative)

    local badValues = {"1", false, math.huge, -math.huge, math.huge / math.huge}

    -- sometimes negative values are allowed, so this is optional
    if useNegative then
        table.insert(badValues, -1)
    end

    for _, badValue in ipairs(badValues) do

        local params = {}
        for i, _ in ipairs(variables) do
            params[i] = default
        end

        local instance = geometryClass(unpack(params))
        for i, var in ipairs(variables) do

            -- attempt to set a value to something incorrect
            local success, result = pcall(function() instance[var] = badValue end)
            -- debug.log(result)
            if success then
                error(className .. "." .. var .. " incorrectly set to " .. tostring(badValue))
            end

            params[i] = badValue

            -- attempt to make the class with a single incorrect value
            -- need to give unpack the number of variables, because if nil is the default,
            -- the unpack will potentially skip the nil values which can cause problems
            success, result = pcall(geometryClass, unpack(params, 1, #variables))
            -- debug.log(result)
            if success then
                error(className .. "." .. var .. " incorrectly created with " .. tostring(badValue))
            end

            params[i] = default
        end
    end
end

return helpers
