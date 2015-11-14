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


--- Utility functions for the creation and registration of ramps.
ramputil = {}


--- Creates the nodebox for an inner corner.
--
-- @param detail The level of detail, basically how many steps the ramp will
--               have.
-- @return The nodebox for an inner corner.
function ramputil.create_inner_corner_nodebox(detail)
	local part = 1 / detail
	local nodebox = {}
	
	for step = 0, detail - 1, 1 do
		local corner = -0.5 + part * step
		
		table.insert(nodebox, {
			corner, part * step - 0.5, -0.5,
			0.5, part * step + part - 0.5, 0.5,
		})
		
		table.insert(nodebox, {
			-0.5, part * step - 0.5, corner,
			corner, part * step + part - 0.5, 0.5,
		})
	end
	
	return nodebox
end

--- Creates the nodebox for a flat inner corner.
--
-- @param detail The level of detail, basically how many steps the ramp will
--               have.
-- @return The nodebox for a flat inner corner.
function ramputil.create_inner_corner_flat_nodebox(detail)
	local part = 1 / detail
	local nodebox = {}
	
	for step = 0, detail - 1, 1 do
		for sec_step = 0, detail - 1, 1 do
			table.insert(nodebox, {
				-0.5 + part * math.max(sec_step - step, 0), 0.5 - step * part - part, 0.5 - part * sec_step,
				0.5, 0.5 - step * part, 0.5 - part * sec_step - part
			})
		end
	end
	
	return nodebox
end

--- Creates the nodebox for an inner steep corner.
--
-- @param detail The level of detail, basically how many steps the ramp will
--               have.
-- @return The nodebox for an inner steep corner.
function ramputil.create_inner_steep_corner_nodebox(detail)
	local part = 1 / detail
	local steep_part = 0.4 / detail
	local nodebox = {}
	
	for step = 0, detail - 1, 1 do
		local corner = -0.15 + steep_part * step
		
		table.insert(nodebox, {
			corner, part * step - 0.5, -0.5,
			0.5, part * step + part - 0.5, 0.5,
		})
		
		table.insert(nodebox, {
			-0.5, part * step - 0.5, corner,
			corner, part * step + part - 0.5, 0.5,
		})
	end
	
	return nodebox
end

--- Creates the lookup table for the given nodes which is used by rampgen.
--
-- @param node_name The name of the node,
-- @param ramp_name The name of the ramp.
-- @param inner_corner_name The name of the inner corner part.
-- @param outer_corner_name The name of the outer corner part.
-- @return The lookup table for these nodes.
function ramputil.create_lookup_table(node_name, ramp_name, inner_corner_name, outer_corner_name)
	local node_id = minetest.get_content_id(node_name)
	local ramp_id = minetest.get_content_id(ramp_name)
	local inner_corner_id = minetest.get_content_id(inner_corner_name)
	local outer_corner_id = minetest.get_content_id(outer_corner_name)
	
	local ramp_lookup = {}
	ramp_lookup[node_id] = {
		node = node_id,
		param_floor = true,
		param_ceiling = true,
		ramp = ramp_id,
		inner = inner_corner_id,
		outer = outer_corner_id
	}
	ramp_lookup[ramp_id] = ramp_lookup[node_id]
	ramp_lookup[inner_corner_id] = ramp_lookup[node_id]
	ramp_lookup[outer_corner_id] = ramp_lookup[node_id]
	
	return ramp_lookup
end

--- Creates the nodebox for a flat outer corner.
--
-- @param detail The level of detail, basically how many steps the ramp will
--               have.
-- @return The nodebox for a flat outer corner.
function ramputil.create_outer_corner_flat_nodebox(detail)
	local part = 1 / detail
	local nodebox = {}
	
	for step = 0, detail - 1, 1 do
		for sec_step = 0, detail - step - 1, 1 do
			table.insert(nodebox, {
				part * sec_step + part * step - 0.5, -0.5 + step * part, 0.5 - part * sec_step,
				0.5, -0.5 + step * part + part, 0.5 - part * sec_step - part
			})
		end
	end
	
	return nodebox
end

--- Creates the nodebox for an outer corner.
--
-- @param detail The level of detail, basically how many steps the ramp will
--               have.
-- @return The nodebox for an outer corner.
function ramputil.create_outer_corner_nodebox(detail)
	local part = 1 / detail
	local nodebox = {}
	
	for step = 0, detail - 1, 1 do
		table.insert(nodebox, {
			-0.5 + part * step, part * step - 0.5, part * step - 0.5,
			0.5, part * step + part - 0.5, 0.5,
		})
	end
	
	return nodebox
end

--- Creates the nodebox for an outer steep corner.
--
-- @param detail The level of detail, basically how many steps the ramp will
--               have.
-- @return The nodebox for an outer steep corner.
function ramputil.create_outer_steep_corner_nodebox(detail)
	local part = 1 / detail
	local steep_part = 0.4 / detail
	local nodebox = {}
	
	for step = 0, detail - 1, 1 do
		table.insert(nodebox, {
			-0.15 + steep_part * step, part * step - 0.5, steep_part * step - 0.15,
			0.5, part * step + part - 0.5, 0.5,
		})
	end
	
	return nodebox
end

--- Creates ramps (ramp, inner and outer corner) for the given node.
--
-- @param node The node description (table), or the node name.
-- @param use_mesh If the created nodes should use a mesh instead of nodeboxes.
-- @param nodebox_detail The detail level of the nodeboxes. Even if a mesh is
--                       used, the nodebox is still created for the collision
--                       box.
-- @return The node descriptions for the ramp, inner and outer corner.
function ramputil.create_ramp_from_node(node, use_mesh, nodebox_detail)
	local ramp = tableutil.clone(node)
	-- Remove the metatable, otherwise we'll run into trouble.
	setmetatable(ramp, nil)
	
	ramp.description = node.description .. " (Ramp)"
	ramp.name = node.name .. "_ramp"
	ramp.paramtype = "light"
	ramp.paramtype2 = "facedir"
	
	ramp.drawtype = "nodebox"
	ramp["drawtype"] = "nodebox"
	ramp.node_box = {
		fixed = ramputil.create_ramp_nodebox(nodebox_detail),
		type = "fixed"
	}
	ramp.after_dig_node = after
	if use_mesh then
		ramp.drawtype = "mesh"
		ramp.mesh = "ramp.obj"
	end
	
	local inner_corner = tableutil.clone(ramp)
	inner_corner.description = node.description .. " (Inner Corner)"
	inner_corner.mesh = "inner_corner_ramp.obj"
	inner_corner.name = node.name .. "_inner_corner_ramp"
	inner_corner.node_box.fixed = ramputil.create_inner_corner_nodebox(nodebox_detail)
	
	local outer_corner = tableutil.clone(ramp)
	outer_corner.description = node.description .. " (Outer Corner)"
	outer_corner.mesh = "outer_corner_ramp.obj"
	outer_corner.name = node.name .. "_outer_corner_ramp"
	outer_corner.node_box.fixed = ramputil.create_outer_corner_nodebox(nodebox_detail)
	
	return ramp, inner_corner, outer_corner
end

--- Creates the nodebox for a ramp.
--
-- @param detail The level of detail, basically how many steps the ramp will
--               have.
-- @return The nodebox for a ramp.
function ramputil.create_ramp_nodebox(detail)
	local part = 1 / detail
	local nodebox = {}
	
	for step = 0, detail - 1, 1 do
		table.insert(nodebox, {
			-0.5, part * step - 0.5, part * step - 0.5,
			0.5, part * step + part - 0.5, 0.5,
		})
	end
	
	return nodebox
end

--- Creates the nodebox for a steep ramp.
--
-- @param detail The level of detail, basically how many steps the ramp will
--               have.
-- @return The nodebox for a steep ramp.
function ramputil.create_steep_ramp_nodebox(detail)
	local part = 1 / detail
	local steep_part = 0.4 / detail
	local nodebox = {}
	
	for step = 0, detail - 1, 1 do
		table.insert(nodebox, {
			-0.5, part * step - 0.5, steep_part * step - 0.15,
			0.5, part * step + part - 0.5, 0.5,
		})
	end
	
	return nodebox
end


--- Creates and registers ramps (ramp, inner and outer corner) for the given
-- node.
--
-- @param node The node description (table), or the node name.
-- @param base_name The base name for the new nodes.
-- @param use_mesh If the created nodes should use a mesh instead of nodeboxes.
-- @param nodebox_detail The detail level of the nodeboxes. Even if a mesh is
--                       used, the nodebox is still created for the collision
--                       box.
-- @return The lookup entry used by rampmaker. That's a table that holds
--         the three nodes.
function ramputil.register_ramps_for_node(node, base_name, use_mesh, nodebox_detail)
	if type(node) == "string" then
		node = minetest.registered_nodes[node]
	end
	
	local ramp, inner_corner, outer_corner = ramputil.create_ramp_from_node(node, use_mesh, nodebox_detail)

	minetest.register_node(base_name .. "_ramp", ramp)
	minetest.register_node(base_name .. "_inner_corner_ramp", inner_corner)
	minetest.register_node(base_name .. "_outer_corner_ramp", outer_corner)
	
	return ramputil.create_lookup_table(
		node.name,
		base_name .. "_ramp",
		base_name .. "_inner_corner_ramp",
		base_name .. "_outer_corner_ramp"
	)
end

