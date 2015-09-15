-- class.lua
-- Compatible with Lua 5.1 (not 5.0).
-- http://lua-users.org/wiki/SimpleLuaClasses
-- with modifications by decky coss (http://cosstropolis.com)

require("lass.stdext")
local class = {}

local function callable(v)
    return type(v) == "function" or (type(v) == "table" and v.__call)
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
            if v ~= nil then
                return v
            elseif c.__genericget then
                return c.__genericget(self, key)
            end
        end
    end

    -- enable setters
    c.__newindex = function(self, key, value)
        if c.__set[key] then
            c.__set[key](self, value)
        elseif c.__genericset then
            c.__genericset(self, key, value)
        else
            rawset(self, key, value)
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

    -- expose a constructor which can be called by <classname>(<args>)
    local mt = {}
    mt.__call = function(self, ...)

        --when a callable table is called, the table itself is passed as the first argument.
        --we don't want to pass the class to its own constructor, so we erase self
        self = {}
        setmetatable(self,c)
        self.class = c
        init(self,...)

        return self
    end

    -- the class looks for any undefined keys in its superclass
    mt.__index = c.base

    -- automatically wrap all class functions to prevent infinite self.base loops
    mt.__newindex = function(self, key, value)

        if type(value) == "function" then
            rawset(self, key, function(first, ...)
                if type(first) == "table" and first.base == self then

                    -- temporarily change base to prevent loop
                    first.base = self.base
                    local r = table.pack(value(first, ...))

                    -- revert base and return everything
                    -- (setting to nil allows object to get .base from the __index)
                    first.base = nil
                    return unpack(r)
                else
                    return value(first, ...)
                end
            end)
        else
            rawset(self, key, value)
        end
    end

    c.init = function(obj, ...)
        --prevent infinitely recursive self.base.init() calls
        if obj then
            obj.base = c.base
        end

        -- init would not normally return a value, but no reason to forbid it...
        local r = init(obj, ...)

        -- revert base to nil, so it can be retrieved from __index
        if obj then
            obj.base = nil
        end

        return r
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

function class.addkey(myclass, key, value, inheritReference)

    myclass[key] = value
    if inheritReference == false and type(value) == "table" then
        myclass.__protected[key] = true
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

return class
