local helpers = {}

local function repr(x)

    if type(x) == "string" then
        return string.format("%q", x)
    else
        return tostring(x)
    end

end

local function assertIncorrectCreation(i, var, incorrectValue, params, geometryClass, numVars, className)

    params[i] = incorrectValue

    -- attempt to make the class with a single incorrect value
    -- need to give unpack the number of variables, because if nil is the default,
    -- the unpack will potentially skip the nil values which can cause problems
    local success, result = pcall(geometryClass, unpack(params, 1, numVars))
    -- debug.log(result)
    if success then
        error(className .. "." .. var .. " incorrectly created with " .. repr(incorrectValue))
    end

    -- params[i] = default
end

local function assertIncorrectSetting(var, incorrectValue, params, geometryClass, className)

    local instance = geometryClass(unpack(params))
    local varName = var

    -- if var points us to a subvalue, dig it out
    if type(var) == "table" then
        varName = ""
        for j = 1, #var - 1 do
            varName = varName .. var[j] .. "."
            instance = instance[var[j]]
        end
        varName = varName .. var[#var]
    end
    
    local success, result = pcall(function() instance[var] = incorrectValue end)
    -- attempt to set a value to something incorrect
    -- debug.log(result)
    if success then
        error(className .. "." .. varName .. " incorrectly set to " .. repr(incorrectValue))
    end
end

function helpers.assertIncorrectRunner(testType, geometryClass, className, variables, default, extraValues)

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

        for i, var in ipairs(variables) do

            if testType == "creation" then
                assertIncorrectCreation(i, var, incorrectValue, params, geometryClass, #variables, className)
            elseif testType == "setting" then
                assertIncorrectSetting(var, incorrectValue, params, geometryClass, className)
            else
                error("Incorrect test type parameter")
            end

        end
    end

end

return helpers
