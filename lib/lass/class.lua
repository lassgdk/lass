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

local getterTable = {}

-- function getterTable:__newindex(key, value)
--     class.bind(self.__class, key, value)
-- end

--[[
__get can be function
__set can be function or false

MyClass.__get.something = function(self, key, value) end
]]
--the metatable assigned to all classes
class.metaclass = {}

function class.metaclass:__call(...)

    local object = {}
    setmetatable(object, self)

    self.init(object, ...)

    return object

end

function class.metaclass:__index(key)
    --use the base (super) class as the index

    return self.base[key]
end

-- automatically wrap all class functions to prevent infinite self.base loops
function class.metaclass:__newindex(key, value)

    class.bind(self, key, value)

    if type(value) == "function" then
        rawset(self, key, function(first, ...)
            if type(first) == "table" and first.base == self then

                -- temporarily change base to prevent loop
                first.base = self.base
                local r = table.pack(value(first, ...))

                -- revert base and return everything
                first.base = nil
                return unpack(r)
            else
                return value(first, ...)
            end
        end)
    -- elseif key == "__get" then
        -- rawset(self, )
    else
        rawset(self, key, value)
    end
end

function class.define(base, init)

    local c = {}     -- a new class instance
    c.__protected = {}
    c.__get = {}
    c.__set = {}

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
            elseif k == "__protected" or k == "__get" or k == "__set" then
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

    -- the class will be the metatable for all its objects,
    -- and they will look up their methods in it.
    -- this also enables getters
    c.__index = function(self, key)
        if c.__get[key] then
            return c.__get[key](self)
        else
            local v = c[key]
            if v ~= nil or reserved[key] then
                return v
            elseif c.__genericget then

                local r = c.__genericget(self, key)
                return r
            -- else
            --     debug.log("hi")
            --     return c.__genericget(self, key)
            end
        end
    end

    -- enable setters
    c.__newindex = function(self, key, value)
        if c.__set[key] then
            c.__set[key](self, value)
        elseif c.__get[key] then
            error("attempt to set read-only property '" .. key .. "'")
        elseif c.__genericset then
            c.__genericset(self, key, value)
        else
            rawset(self, key, value)
        end
    end

    -- a replacement for __index
    -- c.__genericget = function() end

    -- -- a replacement for __newindex
    -- c.__genericset = function(self, key, value)
    --     rawset(self, key, value)
    -- end

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

    -- expose a constructor which can be called by <classname>(<args>)
    local mt = {}
    mt.__call = function(self, ...)

        local object = {}
        setmetatable(object,c)
        object.class = c
        init(object,...)

        return object
    end

    -- the class looks for any undefined keys in its superclass
    mt.__index = c.base

    -- automatically wrap all class functions to prevent infinite self.base loops
    mt.__newindex = function(self, key, value)
        class.bind(self, key, value)
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

    setmetatable(c, mt)

    --now that the metatable has been applied,
    --this will be wrapped with the func defined in mt.__newindex

    c.init = init

    -- if c.__protected then
    --     local protected = {}
    --     for k,v in pairs(c.base.__protected) do
    --         c.__protected[k] = v
    --     end
    -- else
    --     c.__protected = {}
    -- end

    return c
end

function class.bind(cl, key, value)
    if type(value) == "function" then
        rawset(cl, key, function(first, ...)
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
        rawset(cl, key, value)
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


return class