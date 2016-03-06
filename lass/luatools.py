from __future__ import unicode_literals
import lupa

def luaTableToDict(table, runtime=None):
	"""
	recursively (deep) convert lua table to dictionary

	params:
		table: lupa.LuaTable
		runtime: lupa.LuaRuntime
			if runtime is specified, the function will attempt to find the
			metatables. if found, each dict will include the metatable dict
			under the key "__metatable".
	"""

	if lupa.lua_type(table) != "table":
		return table

	d = {}

	if runtime:
		getmetatable = runtime.eval("getmetatable")

	for k, v in table.items():
		d[k] = luaTableToDict(v)
		if runtime:
			mt = getmetatable(table)
			if mt:
				d["__metatable"] = luaTableToDict(mt, runtime)

	return d

def luaTableToList(table, runtime=None):

	if lupa.lua_type(table) != "table":
		return TypeError("table must be Lua table")

	l = []

	for i, v in ipairs(table):
		l.append(luaTableToDict(v, runtime))

	return l

def ipairs(table):

	i = 1
	try:
		node = table[i]
	except (KeyError, IndexError):
		return

	while node:
		yield i, node

		i += 1
		try:
			node = table[i]
		except (KeyError, IndexError):
			break
