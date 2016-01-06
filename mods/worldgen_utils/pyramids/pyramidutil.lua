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


--- Utility functions for the creation and registration of pyramids.
pyramidutil = {}

function pyramidutil.create_connected_corner_nodebox(detail)
	local part = 1 / detail
	local nodebox = {}
	
	for step = 0, detail - 1, 1 do
		local size = part * step
		local half = (size + part) / 2
		
		table.insert(nodebox, {
			-half, 0.5 - size, -half,
			half, 0.5 - size - part, 0.5
		})
		table.insert(nodebox, {
			half, 0.5 - size, -half,
			0.5, 0.5 - size - part, half
		})
	end
	
	return nodebox
end

function pyramidutil.create_connected_cross_nodebox(detail)
	local part = 1 / detail
	local nodebox = {}
	
	for step = 0, detail - 1, 1 do
		local size = part * step
		local half = (size + part) / 2
		
		table.insert(nodebox, {
			-half, 0.5 - size, -0.5,
			half, 0.5 - size - part, 0.5
		})
		table.insert(nodebox, {
			half, 0.5 - size, -half,
			0.5, 0.5 - size - part, half
		})
		table.insert(nodebox, {
			-0.5, 0.5 - size, -half,
			-half, 0.5 - size - part, half
		})
	end
	
	return nodebox
end

function pyramidutil.create_connected_end_nodebox(detail)
	local part = 1 / detail
	local nodebox = {}
	
	for step = 0, detail - 1, 1 do
		local size = part * step
		local half = (size + part) / 2
		
		table.insert(nodebox, {
			-half, 0.5 - size, -half,
			half, 0.5 - size - part, 0.5
		})
	end
	
	return nodebox
end

function pyramidutil.create_connected_straight_nodebox(detail)
	local part = 1 / detail
	local nodebox = {}
	
	for step = 0, detail - 1, 1 do
		local size = part * step
		local half = (size + part) / 2
		
		table.insert(nodebox, {
			-half, 0.5 - size, -0.5,
			half, 0.5 - size - part, 0.5
		})
	end
	
	return nodebox
end

function pyramidutil.create_connected_t_nodebox(detail)
	local part = 1 / detail
	local nodebox = {}
	
	for step = 0, detail - 1, 1 do
		local size = part * step
		local half = (size + part) / 2
		
		table.insert(nodebox, {
			-half, 0.5 - size, -0.5,
			half, 0.5 - size - part, 0.5
		})
		table.insert(nodebox, {
			half, 0.5 - size, -half,
			0.5, 0.5 - size - part, half
		})
	end
	
	return nodebox
end

function pyramidutil.create_nodebox(detail)
	local part = 1 / detail
	local nodebox = {}
	
	for step = 0, detail - 1, 1 do
		local size = part * step
		local half = (size + part) / 2
		
		table.insert(nodebox, {
			-half, 0.5 - size, -half,
			half, 0.5 - size - part, half
		})
	end
	
	return nodebox
end

