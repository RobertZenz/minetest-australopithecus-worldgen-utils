--[[
Copyright (c) 2015, Robert 'Bobby' Zenz
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]



MaskBasedPlacer = {
	MASK_VALUE_IGNORE = -1,
	
	nodes = {}
}


function MaskBasedPlacer:new()
	local instance = {
		nodes = {},
	}
	
	setmetatable(instance, self)
	self.__index = self
	
	return instance
end


function MaskBasedPlacer.get_surroundings(manipulator, x, z, y)
	-- We are assigning them explicitly because get_node returns
	-- two values, which means that the resulting table might have
	-- 9 values instead of 8, resulting in a broken logic.
	return {
		[1] = manipulator:get_node(x - 1, z + 1, y),
		[2] = manipulator:get_node(x, z + 1, y),
		[3] = manipulator:get_node(x + 1, z + 1, y),
		[4] = manipulator:get_node(x + 1, z, y),
		[5] = manipulator:get_node(x + 1, z - 1, y),
		[6] = manipulator:get_node(x, z - 1, y),
		[7] = manipulator:get_node(x - 1, z - 1, y),
		[8] = manipulator:get_node(x - 1, z, y)
	}
end

function MaskBasedPlacer.mask_equals(current_surroundings, expected_surroundings)
	if type(expected_surroundings) == "table" then
		if expected_surroundings["not"] ~= nil then
			if type(expected_surroundings["not"]) == "table" then
				for key, value in pairs(expected_surroundings["not"]) do
					if value == current_surroundings then
						return false
					end
				end
			else
				if expected_surroundings["not"] == current_surroundings then
					return false
				end
			end
		else
			for key, value in pairs(expected_surroundings) do
				if value == current_surroundings then
					return true
				end
			end
		end
	elseif expected_surroundings ~= MaskBasedPlacer.MASK_VALUE_IGNORE then
		if expected_surroundings ~= current_surroundings then
			return false
		end
	end
	
	return true
end

function MaskBasedPlacer.rotate_rotation(rotation, count)
	rotation = rotation or rotationutil.ROT_0
	
	for counter = 1, count, 1 do
		rotation = rotationutil.increment(rotation)
	end
	
	return rotation
end

function MaskBasedPlacer.test_nodes(definition, node_above, node_below)
	return MaskBasedPlacer.test_node_single(node_above, definition.node_above)
		and MaskBasedPlacer.test_node_single(node_below, definition.node_below)
		and MaskBasedPlacer.test_node_multiple(node_above, definition.nodes_above)
		and MaskBasedPlacer.test_node_multiple(node_below, definition.nodes_below)
		and MaskBasedPlacer.test_node_single_not(node_above, definition.node_not_above)
		and MaskBasedPlacer.test_node_single_not(node_below, definition.node_not_below)
		and MaskBasedPlacer.test_node_multiple_not(node_above, definition.nodes_not_above)
		and MaskBasedPlacer.test_node_multiple_not(node_below, definition.nodes_not_below)
end

function MaskBasedPlacer.test_node_multiple_not(node_to_test, expected_nodes)
	if expected_nodes == nil then
		return true
	end
	
	for key, expected_node in pairs(expected_nodes) do
		if node_to_test == expected_node then
			return false
		end
	end
	
	return true
end

function MaskBasedPlacer.test_node_single_not(node_to_test, expected_node)
	return expected_node == nil
		or node_to_test ~= expected_node
end


function MaskBasedPlacer.test_node_multiple(node_to_test, expected_nodes)
	if expected_nodes == nil then
		return true
	end
	
	for key, expected_node in pairs(expected_nodes) do
		if node_to_test == expected_node then
			return true
		end
	end
	
	return false
end

function MaskBasedPlacer.test_node_single(node_to_test, expected_node)
	return expected_node == nil
		or node_to_test == expected_node
end

function MaskBasedPlacer:register_node(definition)
	local cloned_definition = tableutil.clone(definition)
	
	cloned_definition.initial_rotation = cloned_definition.initial_rotation or rotationutil.ROT_0
	
	cloned_definition.node = nodeutil.get_id(cloned_definition.node)
	
	cloned_definition.node_above = nodeutil.get_id(cloned_definition.node_above)
	cloned_definition.node_below = nodeutil.get_id(cloned_definition.node_below)
	
	if cloned_definition.nodes_above ~= nil then
		for key, value in pairs(cloned_definition.nodes_above) do
			cloned_definition.nodes_above[key] = nodeutil.get_id(value)
		end
	end
	
	if cloned_definition.nodes_below ~= nil then
		for key, value in pairs(cloned_definition.nodes_below) do
			cloned_definition.nodes_below[key] = nodeutil.get_id(value)
		end
	end
	
	cloned_definition.node_not_above = nodeutil.get_id(cloned_definition.node_not_above)
	cloned_definition.node_not_below = nodeutil.get_id(cloned_definition.node_not_below)
	
	if cloned_definition.nodes_not_above ~= nil then
		for key, value in pairs(cloned_definition.nodes_not_above) do
			cloned_definition.nodes_not_above[key] = nodeutil.get_id(value)
		end
	end
	
	if cloned_definition.nodes_not_below ~= nil then
		for key, value in pairs(cloned_definition.nodes_not_below) do
			cloned_definition.nodes_not_below[key] = nodeutil.get_id(value)
		end
	end
	
	cloned_definition.replacement_node = nodeutil.get_id(cloned_definition.replacement_node)
	
	for key, value in pairs(cloned_definition.surroundings) do
		if type(value) == "table" then
			if value["not"] ~= nil then
				if type(value["not"]) == "table" then
					for sub_key, sub_value in pairs(value["not"]) do
						value["not"][sub_key] = nodeutil.get_id(sub_value)
					end
				else
					value["not"] = nodeutil.get_id(value["not"])
				end
			else
				for sub_key, sub_value in pairs(value) do
					value[sub_key] = nodeutil.get_id(sub_value)
				end
			end
		elseif value ~= MaskBasedPlacer.MASK_VALUE_IGNORE then
			cloned_definition.surroundings[key] = nodeutil.get_id(value)
		end
	end
	
	if self.nodes[cloned_definition.node] == nil then
		self.nodes[cloned_definition.node] = List:new()
	end
	
	self.nodes[cloned_definition.node]:add(cloned_definition)
end

function MaskBasedPlacer:run(manipulator, minp, maxp)
	for y = minp.y - 1, maxp.y + 1, 1 do
		for x = minp.x - 1, maxp.x + 1, 1 do
			for z = minp.z - 1, maxp.z + 1, 1 do
				self:run_on_coordinates(manipulator, x, z, y)
			end
		end
	end
end

function MaskBasedPlacer:run_on_coordinates(manipulator, x, z, y)
	local current_node = manipulator:get_node(x, z, y)
	local definition = self.nodes[current_node]
	
	if definition == nil then
		return
	end
	
	local node_above = manipulator:get_node(x, z, y + 1)
	local node_below = manipulator:get_node(x, z, y - 1)
	
	if node_above == minetest.CONTENT_IGNORE
		or node_below == minetest.CONTENT_IGNORE then
		return
	end
	
	local surrounding_nodes = MaskBasedPlacer.get_surroundings(manipulator, x, z, y)
	
	for key, value in pairs(surrounding_nodes) do
		if value == minetest.CONTENT_IGNORE then
			return
		end
	end
	
	definition:foreach(function(definition, index)
		local upside_down = false
		
		if not MaskBasedPlacer.test_nodes(definition, node_above, node_below) then
			if definition.upside_down
				and MaskBasedPlacer.test_nodes(definition, node_below, node_above) then
				
				upside_down = true
			else
				return
			end
		end
		
		local start_index = arrayutil.index(surrounding_nodes, definition.surroundings, MaskBasedPlacer.mask_equals, 2)
		
		if start_index >= 1 then
			local rotation = MaskBasedPlacer.rotate_rotation(
				definition.initial_rotation,
				math.floor(start_index / 2))
			
			if upside_down then
				if rotation == facedirutil.POSITIVE_X then
					rotation = rotationutil.increment(rotation)
				end
				
				rotation = facedirutil.upsidedown(rotation)
			end
			
			manipulator:set_node(x, z, y, definition.replacement_node, rotation)
		end
	end)
end

