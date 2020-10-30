-- Copyright (c) Jérémie N'gadi
--
-- All rights reserved.
--
-- Even if 'All rights reserved' is very clear :
--
--   You shall not use any piece of this software in a commercial product / service
--   You shall not resell this software
--   You shall not provide any facility to install this particular software in a commercial product / service
--   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/ESX-Org/es_extended
--   This copyright should appear in every part of the project code


-- icon
-- iconType 'material' 
-- color 
-- 

M('ui.hud')
module.Ready = false;
module.Frame = nil
module.Status, module.isPaused = {}, false

module.Config  = run('data/config.lua', {vector3 = vector3})['Config']

module.CreateStatus = function(name, default, color, visible, tickCallback)

	local self = {}

	self.val          = default
	self.name         = name
	self.default      = default
	self.color        = color
	self.visible      = visible
	self.tickCallback = tickCallback

	self._set = function(k, v)
		self[k] = v
	end

	self._get = function(k)
		return self[k]
	end

	self.onTick = function()
		self.tickCallback(self)
	end

	self.set = function(val)
		self.val = val
	end

	self.add = function(val)
		if self.val + val > module.Config.StatusMax then
			self.val = module.Config.StatusMax
		else
			self.val = self.val + val
		end
	end

	self.remove = function(val)
		if self.val - val < 0 then
			self.val = 0
		else
			self.val = self.val - val
		end
	end

	self.getPercent = function()
		return (self.val / module.Config.StatusMax) * 100
	end

	return self

end

module.GetStatusData = function(minimal)
	local status = {}

	for i=1, #module.Status, 1 do
		if minimal then
			table.insert(status, {
				name    = module.Status[i].name,
				val     = module.Status[i].val,
				percent = (module.Status[i].val / Config.StatusMax) * 100
			})
		else
			table.insert(status, {
				name    = module.Status[i].name,
				val     = module.Status[i].val,
				color   = module.Status[i].color,
				visible = module.Status[i].visible(module.Status[i]),
				max     = module.Status[i].max,
				percent = (module.Status[i].val / module.Config.StatusMax) * 100
			})
		end
	end

	return status
end

Status = {
  health = {
    color = 'red',
    value = 0.50,
  }
}

module.Frame = Frame('status', 'nui://' .. __RESOURCE__ .. '/modules/__core__/status/data/html/index.html', true)

module.Frame:on('load', function()
  module.Ready = true
end)



