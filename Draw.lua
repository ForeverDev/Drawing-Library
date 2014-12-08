local module = {}

local meta = {}
meta.__index = meta

function remove_element(array, elem)
	for i, v in pairs(array) do
		if v == elem then
			table.remove(array, i)
		end
	end
end

function meta:kill()
	for i, v in ipairs(self) do
		v:Destroy()
	end
	self = nil
end

function meta:is(...)
	for i, v in ipairs{...} do
		if self.instanceof == v then
			return true
		end
	end
	return false
end

function meta:repoint(x, y)
	if self:is("line") then
		local start = Vector2.new(x, y)
		local finish = Vector2.new(self.x_start, self.y_start)
		local distance = finish - start
		local index = 0
		for i = 1, math.sqrt(distance.X^2 + distance.Y^2), math.sqrt(2) do
			index = index + 1
			local this = self[index]
			local current = start + ((finish - start).unit * i)
			if this then
				this.Position = UDim2.new(0, current.X, 0, current.Y)
			else
				local node = Instance.new("Frame", self.parent)
				node.Size = UDim2.new(0, 2, 0, 2)
				node.Position = UDim2.new(0, current.X, 0, current.Y)
				node.BorderSizePixel = 0
				node.BackgroundColor3 = Color3.new(0, 0, 0)
				for key, prop in pairs(self.flags) do
					node[key] = prop
				end
				table.insert(self, node)
			end
		end
		for i = index + 1, #self do
			if self[i] then
				self[i]:Destroy()
				table.remove(self, i)
			end
		end
	end
end

function module.line(x1, y1, x2, y2, parent, flags, return_without_meta)
	local start = Vector2.new(x1, y1)
	local finish = Vector2.new(x2, y2)
	local distance = finish - start
	local nodes = {}
	nodes.instanceof = "line"
	nodes.x_start = x1
	nodes.y_start = y1
	nodes.flags = flags or {}
	nodes.parent = parent or script.Parent
	for i = 1, math.sqrt(distance.X^2 + distance.Y^2), math.sqrt(2) do
		local current = start + ((finish - start).unit * i)
		local node = Instance.new("Frame", parent or script.Parent)
		node.Size = UDim2.new(0, 2, 0, 2)
		node.Position = UDim2.new(0, current.X, 0, current.Y)
		node.BorderSizePixel = 0
		node.BackgroundColor3 = Color3.new(0, 0, 0)
		for i, v in pairs(flags or {}) do
			node[i] = v
		end
		table.insert(nodes, node)
	end
	return return_without_meta and nodes or setmetatable(nodes, meta)
end

function module.func(x1, y1, x2, y2, parent, flags, func)
	local start = Vector2.new(x1, y1)
	local finish = Vector2.new(x2, y2)
	local distance = finish - start
	local nodes = {}
	nodes.instanceof = "func"
	for i = 1, math.sqrt(distance.X^2 + distance.Y^2) do
		local current = start + ((finish - start).unit * i)
		local node = Instance.new("Frame", parent or script.Parent)
		node.Size = UDim2.new(0, 2, 0, 2)
		node.Position = UDim2.new(0, current.X, 0, current.Y + func(current.X))
		node.BorderSizePixel = 0
		node.BackgroundColor3 = Color3.new(0, 0, 0)
		for i, v in pairs(flags or {}) do
			node[i] = v
		end
		table.insert(nodes, node)
	end
	return setmetatable(nodes, meta)
end

function module.polygon(nodes, parent, flags)
	local lines = {}
	for i = 1, #nodes, 2 do
		for i, v in ipairs(module.line(nodes[i], nodes[i + 1], nodes[i + 2], nodes[i + 3], parent, flags, true)) do
			table.insert(lines, v)
		end
	end
	lines.instanceof = "polygon"
	return setmetatable(lines, meta)
end

return module
