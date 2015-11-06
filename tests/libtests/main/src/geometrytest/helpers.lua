local helpers = {}

function helpers.assertIncorrectCreation(class, className, variables, default)

    for _, badValue in ipairs({-1, "1", false, math.huge, -math.huge, math.huge / math.huge}) do

        local params = {}
        for i, var in ipairs(variables) do
            params[i] = default
        end

        for i, var in ipairs(variables) do
            params[i] = badValue

            success = pcall(class, unpack(params))
            if success then
                error(className .. "." .. var .. " incorrectly created with " .. tostring(badValue))
            end

            params[i] = default
        end
    end
end

return helpers
