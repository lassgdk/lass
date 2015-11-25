local operators = {}

function operators.nilOr(a, b)
	if a == nil then
		return b
	else
		return a
	end
end

return operators
