local m = {}

function m.searchTreeDepth(list, value, depth)

    if depth == nil then
        depth = 1
    end

    for i, entity in ipairs(list) do

        if entity == value then
            return depth
        else
            local found = m.searchTreeDepth(entity.children, value, depth+1)
            if found then
                return found
            end
        end
    end
end

function m.searchTreeCount(list, value, count)

    if count == nil then
        count = 0
    end

    for i, entity in ipairs(list) do

        if entity == value then
            count = count + 1
        end
        count = m.searchTreeCount(entity.children, value, count)

    end

    return count
end

function m.numTreeNodes(entity)

    local count = 0

    for i, child in ipairs(entity.children) do
        count = count + 1 + m.numTreeNodes(child)
    end

    return count
end

return m