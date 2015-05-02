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


--- RampGen is the main class that allows to place ramps in a world.
--
-- The only function that should be called from the client is "run".
rampgen = {
	templates = nil
}


--- Initializes the templates.
function rampgen.init_templates()
	rampgen.templates = List:new()
	
	rampgen.templates:add({
		is_corner = false,
		key = "ramp",
		-- n f n
		-- f   f
		-- n t n
		mask = { nil, false, nil, false, nil, true, nil, false }
	})
	
	rampgen.templates:add({
		is_corner = true,
		key = "inner",
		-- f f f
		-- f   f
		-- n f n
		masks = {
			{ false, false, false, false, false, false, true, false },
			{ false, false, false, false, true, false, false, false }
		}
	})
	
	rampgen.templates:add({
		is_corner = true,
		key = "outer",
		-- f f n
		-- f   t
		-- n t t
		mask = { false, false, nil, true, true, true, nil, false }
	})
end

--- Checks if the given node is "air".
--
-- @param node The node to check.
-- @return true if the node is air.
function rampgen.is_air(node)
	if rampgen.air == nil then
		rampgen.air = minetest.get_content_id("air")
	end
	
	return node == rampgen.air
end

--- Equals function for the mask values.
--
-- @param actual The atual value, generated from the map.
-- @param mask The mask value, from the templates.
-- @return true if the values equal.
function rampgen.mask_value_equals(actual, mask)
	if mask == nil then
		return true
	end

	return actual == mask
end

--- Runs the RampGen and creates ramps in the world.
-- 
-- @param manipulator The MapManipulator to use.
-- @param minp The minimum point.
-- @param maxp The maximum point.
-- @param nodes The lookup table for the ramp creation. The lookup table
--        consists of entries with the ID of the node as key and the three
--        ramps. Example:
--            { 45 = {
--                param_floor = true,
--                param_ceiling = true,
--                ramp = ramp_node,
--                inner = inner_corner_node,
--                outer = outer_corner_node }}
function rampgen.run(manipulator, minp, maxp, nodes)
	if nodes == nil then
		return
	end
	
	if rampgen.templates == nil then
		rampgen.init_templates()
	end
	
	for y = minp.y, maxp.y, 1 do
		for x = minp.x, maxp.x, 1 do
			for z = minp.z, maxp.z, 1 do
				if not rampgen.is_air(manipulator:get_node(x, z, y)) then
					rampgen.run_on_node(manipulator, x, z, y, nodes)
				end	
			end
		end
	end
end

--- Creates a ramp (or not) on the given location.
-- 
-- @param manipulator The MapManipulator to use.
-- @param x The x coordinate.
-- @param z The z coordinate.
-- @param y The y coordinate.
-- @param nodes The lookup table for the ramp creation. The lookup table
--        consists of entries with the ID of the node as key and the three
--        ramps. Example:
--            { 45 = {
--                param_floor = true,
--                param_ceiling = true,
--                ramp = ramp_node,
--                inner = inner_corner_node,
--                outer = outer_corner_node }}
function rampgen.run_on_node(manipulator, x, z, y, nodes)
	local node = manipulator:get_node(x, z, y)
	
	if rampgen.is_air(node) then
		return
	end
	
	local node_info = nodes[node]
	
	if node_info == nil then
		return
	end
	
	local above_air = rampgen.is_air(manipulator:get_node(x, z, y - 1))
	local below_air = rampgen.is_air(manipulator:get_node(x, z, y + 1))
	
	if node_info.param_floor ~= nil and not node_info.param_floor then
		below_air = false;
	end
	
	if node_info.param_ceiling ~= nil and not node_info.param_ceiling then
		above_air = false;
	end
	
	-- Either have air below or above it, but not both and not neither.
	if above_air ~= below_air then
		--  -- ?- +-
		--  -?    +?
		--  -+ ?+ ++
		local node_mask = {
			rampgen.is_air(manipulator:get_node(x - 1, z - 1, y)),
			rampgen.is_air(manipulator:get_node(x, z - 1, y)),
			rampgen.is_air(manipulator:get_node(x + 1, z - 1, y)),
			rampgen.is_air(manipulator:get_node(x + 1, z, y)),
			rampgen.is_air(manipulator:get_node(x + 1, z + 1, y)),
			rampgen.is_air(manipulator:get_node(x, z + 1, y)),
			rampgen.is_air(manipulator:get_node(x - 1, z + 1, y)),
			rampgen.is_air(manipulator:get_node(x - 1, z, y))
		}
		
		rampgen.templates:foreach(function(template, index)
			local node_ramp = node_info[template.key]
			
			if node_ramp == nil then
				return
			end
			
			local start_index = -1
			
			if template.masks ~= nil then
				for index = 1, #template.masks, 1 do	
					local mask_index = arrayutil.index(node_mask, template.masks[index], rampgen.mask_value_equals, 2)
					
					if mask_index >= 0 then
						start_index = mask_index
					end
				end
			else
				start_index = arrayutil.index(node_mask, template.mask, rampgen.mask_value_equals, 2)
			end
			
			if start_index >= 0 then
				local facedir = 0;
				local axis = rotationutil.POS_Y
				local rotation = rotationutil.ROT_0
				
				if below_air then
					if start_index == 1 then
						rotation = rotationutil.ROT_180
					elseif start_index == 3 then
						rotation = rotationutil.ROT_90
					elseif start_index == 5 then
						rotation = rotationutil.ROT_0
					elseif start_index == 7 then
						rotation = rotationutil.ROT_270
					end
				elseif above_air then
					axis = rotationutil.NEG_Y
					
					if template.is_corner then
						if start_index == 1 then
							rotation = rotationutil.ROT_90
						elseif start_index == 3 then
							rotation = rotationutil.ROT_180
						elseif start_index == 5 then
							rotation = rotationutil.ROT_270
						elseif start_index == 7 then
							rotation = rotationutil.ROT_0
						end
					else
						if start_index == 1 then
							rotation = rotationutil.ROT_180
						elseif start_index == 3 then
							rotation = rotationutil.ROT_270
						elseif start_index == 5 then
							rotation = rotationutil.ROT_0
						elseif start_index == 7 then
							rotation = rotationutil.ROT_90
						end
					end
				end
				
				local facedir = rotationutil.facedir(axis, rotation)
				
				manipulator:set_node(x, z, y, node_ramp, facedir)
			end
		end)
	end
end

