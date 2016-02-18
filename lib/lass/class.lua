-- class.lua
-- Compatible with Lua 5.1 (not 5.0).
-- http://lua-users.org/wiki/SimpleLuaClasses
-- with modifications by decky coss (http://cosstropolis.com)

require("lass.stdext")
local class = {}

local reserved = {
    base = true,
    class = true,
    __get = true,
    __set = true,
    __protected = true,
}

local accessorReserved = {
    init = true,
    __accessing = true,
    base = true,
    class = true,
    instanceof = true,
    is = true
}

local function isCallable(v)

    if type(v) == "function" then
        return true
    elseif type(v) == "table" then
        mt = getmetatable(v)
        return mt ~= nil and mt.__call ~= nil
    else
        return false
    end
end

--[[
metaclass

the metatable assigned to all classes
]]
class.metaclass = {}

function class.metaclass:__call(...)

    local object = {}
    setmetatable(object, self)

    -- object.class = self

    self.init(object, ...)
    return object

end

function class.metaclass:__index(key)

    --use the base (super) class as the index
    local base = rawget(self, "base")
    if base then
        return base[key]
    end
end

function class.metaclass:__newindex(key, value)
    -- automatically wrap all class functions to prevent infinite self.base loops

    if key == "__get" then
        rawset(self, key, class.GetterTable(self, value))
    elseif key == "__set" then
        rawset(self, key, class.SetterTable(self, value))
    else
        class.bind(self, key, value)
    end
end

--[[
module functions
]]

--[[internal]]

local function defineClass(base, init, noAccessors)
    --[[
        params (signature 1):
            base: the base class
            init: init function
            noAccessors: if true, disable getters and setters
        params (signature 2):
            init: init function
    ]]

    local c = {}     -- a new class instance

    c.__protected = {}

    if not init and type(base) == 'function' then
        init = base
        base = nil
    elseif type(base) == 'table' then
        -- copy protected variables from the superclass
        for k,v in pairs(base) do
            -- protected base class variables are copied instead of referenced
            if base.__protected[k] then
                c[k] = {}
                for k2, v2 in pairs(v) do
                    c[k][k2] = v2
                end
 
                local m = getmetatable(v)
                if m then
                    setmetatable(c[k], m)
                end
            -- elseif k == "__protected" or k == "__get" or k == "__set" then
            elseif k == "__protected" then
                for k2,v2 in pairs(v) do
                    c[k][k2] = v2
                end
            end
        end
        c.base = base
    end

    -- when overriding __index or __newindex, make sure that the new function calls
    -- the original __index or __newindex function.
    -- otherwise, objects won't be able to find class methods, and getters/setters
    -- won't work

    if not noAccessors then

        -- the __index metamethod for objects.
        -- when attempting to index an object, we resolve the lookup in the
        -- following order:
        -- 1. look in the class's getter table
        -- 2. look in the ancestor classes' getter tables
        -- 3. look in the class itself
        -- 4. look in the ancestor classes
        -- 5. run genericget

        c.__index = function(self, key)

            -- first, we attempt to find the key in the object's class's getter
            -- table.
            -- if it isn't found, the getter table will attempt to find it in the
            -- ancestor classes' getter tables
            if not accessorReserved[key] and c.__get[key] then
                return c.__get[key](self)

            else
                -- next, we attempt to find the key on the class itself.
                -- if it isn't found, metaclass.__index will attempt to find it in
                -- the ancestor classes

                -- call metaclass.__index
                local v = c[key]

                -- if the key is found or is a reserved key, then we can stop here
                if v ~= nil or reserved[key] then
                    return v

                -- finally, since all else has failed, we run genericget
                elseif c.__genericget then

                    local r = c.__genericget(self, key)
                    return r
                end
            end
        end

        -- the __newindex metamethod for objects

        c.__newindex = function(self, key, value)
            if not accessorReserved[key] then
                if c.__set[key] then
                    c.__set[key](self, value)
                elseif c.__get[key] then
                    error("attempt to set read-only property '" .. key .. "'")
                elseif c.__genericset then
                    c.__genericset(self, key, value)
                else
                    rawset(self, key, value)
                end
            else
                rawset(self, key, value)
            end
        end
    end

    --if there's still no init, make one
    if not init then
        if base and base.init then
            init = function(obj, ...)
                -- make sure that any stuff from the base class is initialized!
                base.init(obj, ...)
            end
        else
            init = function() end
        end
    end

    c.instanceof = function(self, ...)

        for i, cl in ipairs({...}) do 
            local m = getmetatable(self)
            while m do 
                if m == cl then return cl end
                m = m.base
            end
        end

        return false
    end

    c.is = function(self, other)

        if self ~= other then
            return false
        end

        local __eq = c.__eq
        c.__eq = nil

        local r = self == other

        c.__eq = __eq
        return r
    end

    setmetatable(c, class.metaclass)
    c.init = init

    if not noAccessors then
        c.__get = {}
        c.__set = {}
    end

    return c
end

--[[public]]

function class.define(base, init)
    return defineClass(base, init, false)
end

function class.bind(cl, ...)

    local args = table.pack(...)
    local key, value
    local obj = cl

    if #args == 0 then
        error("key must not be nil")
    elseif args.n <= 2 then
        key = args[1]
        value = args[2]
    else
        --for example, {"__get", "x"} becomes cl.__get.x
        for i = 1, args.n - 2 do
            obj = obj[args[i]]
            key = args[i+1]
        end

        value = args[#args]

        -- debug.log(obj, key, value)
    end

    if type(value) == "function" then
        rawset(obj, key, function(first, ...)
            if type(first) == "table" and first.base == cl then
                -- temporarily change base to prevent loop
                first.base = cl.base
                local r = table.pack(value(first, ...))

                -- revert base and return everything
                first.base = nil
                return unpack(r)
            else
                return value(first, ...)
            end
        end)
    else
        rawset(obj, key, value)
    end
end

function class.instanceof(object, ...)
    -- check if object is an instance of class(es), regardless of its type.
    -- returns false or the first match found

    -- if not (type(object) == "table" and object.instanceof) then
    --     return false
    -- else
    --     for _, cl in ipairs({...}) do
    --         if object:instanceof(cl) then return cl end
    --     end
    --     return false
    -- end

    return type(object) == "table" and object.instanceof and object:instanceof(...)
end

function class.subclassof(myclass, ...)
    -- check if myclass is a subclass of class(es), regardless of its type.
    -- reeturns false or the first match found

    if not (type(myclass) == "table" and myclass.base) then
        return false
    else
        local originalClass = myclass
        for _, cl in ipairs({...}) do

            myclass = originalClass
            while myclass.base ~= nil do
                if myclass.base == cl then
                    return cl
                else
                    myclass = myclass.base
                end
            end
        end
        return false
    end
end

function class.super(object)
    return object.base
end

--deprecated
function class.addkey(myclass, key, value, inheritReference)

    myclass[key] = value
    if inheritReference == false and type(value) == "table" then
        myclass.__protected[key] = true
    end
end

--[[
AccessorTable
]]

class.AccessorTable = defineClass(function(self, cl, t)

    -- crash()

    self.__accessing = cl
    if t then
        assert(type(t) == "table", "t must be table")

        for k, v in pairs(t) do
            if not reserved[k] then
                self[k] = v
            end
        end
    end
end, nil, true)

--[[
GetterTable and SetterTable
]]

for i, cl in ipairs({
    {"GetterTable", "__get"},
    {"SetterTable", "__set"},
}) do
    local accessor = cl[2]
    local newCl = defineClass(class.AccessorTable, nil, true)

    class[cl[1]] = newCl

    rawset(newCl, "__index", function(self, key)

        if accessorReserved[key] then
            return newCl[key]
        end

        -- attempt to find the key in the AccessorTable of the base of the class
        -- that the AccessorTable is attached to
        local base = self.__accessing.base

        if base then
            return base[accessor][key]
        end
    end)

    rawset(newCl, "__newindex", function(self, key, value)
        if not accessorReserved[key] then
            class.bind(self.__accessing, accessor, key, value)
        else
            rawset(self, key, value)
        end
    end)
end

return class