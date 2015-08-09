-- class.lua
-- Compatible with Lua 5.1 (not 5.0).
-- http://lua-users.org/wiki/SimpleLuaClasses
-- with modifications by decky coss (http://cosstropolis.com)

local class = {}

local function callable(v)
    return type(v) == "function" or (type(v) == "table" and v.__call)
end

function class.define(base, init)
    local c = {}     -- a new class instance
    if not init and type(base) == 'function' then
        init = base
        base = nil
    elseif type(base) == 'table' then
     -- our new class is a shallow copy of the base class!
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
            -- else
                -- c[k] = v
            end
        end
        c.base = base
    end
    -- the class will be the metatable for all its objects,
    -- and they will look up their methods in it.
    c.__index = c

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

                    local b = first.base

                    -- temporarily change base to prevent loop
                    first.base = self.base
                    local r = table.pack(value(first, ...))

                    -- revert base and return everything
                    first.base = b
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
        --prevent infinitely recursive self.base.init() calls,
        --and give the object a reference to its class's superclass
        if obj then
            obj.base = c.base
        end
        init(obj, ...)
    end

    c.instanceof = function(self, klass)
        local m = getmetatable(self)
        while m do 
            if m == klass then return true end
            m = m.base
        end
        return false
    end

    setmetatable(c, mt)

    if c.__protected then
        local protected = {}
        for k,v in pairs(c.__protected) do
            c.__protected[k] = v
        end
    else
        c.__protected = {}
    end

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

    if not (type(object) == "table" and object.instanceof) then
        return false
    else
        for _, cl in ipairs({...}) do
            if object:instanceof(cl) then return cl end
        end
        return false
    end
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
