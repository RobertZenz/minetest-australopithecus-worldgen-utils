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


--- Provides various utility functions for generation worlds.
worldgenutil = {}


--- Iterates over all two dimensions, from the given minimum point to the
-- given maximum point.
--
-- @param minp The minimum point.
-- @param maxp The maximum point.
-- @param action The action to execute on every point.
-- @param action_x Optional. The action to execute on every x step.
function worldgenutil.iterate2d(minp, maxp, action, action_x)
	for x = minp.x, maxp.x, 1 do
		if action_x ~= nil then
			action_x(x)
		end
		
		for z = minp.z, maxp.z, 1 do
			action(x, z)
		end
	end
end

--- Iterates over all three dimensions, from the given minimum point to the
-- given maximum point.
--
-- @param minp The minimum point.
-- @param maxp The maximum point.
-- @param action The action to execute on every point.
-- @param action_x Optional. The action to execute on every x step.
-- @param action_z Optional. The action to execute on every z step.
function worldgenutil.iterate3d(minp, maxp, action, action_x, action_z)
	for x = minp.x, maxp.x, 1 do
		if action_x ~= nil then
			action_x(x)
		end
		
		for z = minp.z, maxp.z, 1 do
			if action_z ~= nil then
				action_z(x, z)
			end
			
			for y = minp.y, maxp.y, 1 do
				action(x, z, y)
			end
		end
	end
end

