Hooks:PostHook( HUDAssaultCorner, "init", "something_funnyxd", function(self, data)
	if not self._custom_hud_panel then
		return
	end
	_G.VoidUITimerAddon = true

	--managers.hud:add_updator("update_hudinfo_mc", callback(self, self, "_update"))

	local icons_panel = self._custom_hud_panel:child("icons_panel")
	icons_panel:set_w(600 * self._scale)
end)

Hooks:PostHook(HUDAssaultCorner, "setup_icons_panel", "vuib_make_it_bigger", function(self)
	self._custom_icons = {
		{},
		{},
		{},
		{},
		{},
		{}
	}
	self._icons_panel:set_w(600 * self._scale)
	self._icons_panel:set_right(self._custom_hud_panel:w())
	if not VoidUIInfobox then return end
	if VoidUI_IB.options.debug_print_level_id then
		local message = "Current Level ID is: "..tostring(Global.game_settings.level_id)
		log("[VoidUI Infoboxes] "..message)
		managers.chat:_receive_message(1, "[VoidUI Infoboxes]", message, Color("fc0394"))
	end

	if VoidUI_IB.options.kills_infobox then
		local kills_panel = CounterInfobox:new({
			id = "kills", value = 0, type = "Counter"
		})
		if VoidUI_IB.options.special_kills and not VoidUI_IB.options.special_kills_infobox then
			kills_panel:set_value("0 | x0")
		end
	end
	if VoidUI_IB.options.special_kills and VoidUI_IB.options.special_kills_infobox then
		local special_kills_panel = CounterInfobox:new({
			id = "special_kills"
		})
	end
	if VoidUI_IB.options.enemies_infobox then
		local enemies_panel = CounterInfobox:new({
			id = "enemies"
		})
	end
	if VoidUI_IB.options.special_enemies_infobox then
		local special_enemies_panel = CounterInfobox:new({
			id = "special_enemies"
		})
	end
	if VoidUI_IB.options.civs_infobox then
		local civs_panel = CounterInfobox:new({
			id = "civs"
		})
	end
	if VoidUI_IB.options.lootbags_infobox then
		local lootbags_panel = CounterInfobox:new({
			id = "lootbags", value = VoidUI_IB.options.SeparateBagged and "0 | x0" or 0
		})
	end
	if VoidUI_IB.options.gagepacks_infobox then
		local gagepacks_panel = CounterInfobox:new({
			id = "gagepacks"
		})
	end
	if VoidUI_IB.options.Camera_infobox and not CounterInfobox:child("Camera") then
		local camera_panel = CounterInfobox:new({
			id = "Camera"
		})
	end


	if VoidUI_IB.options.timers then
		for _,unit in ipairs(World:find_units_quick("all", 1)) do
			if tostring(unit:name()) == "Idstring(@IDf2defbb65d875bc0@)"  then
				local data = {id = unit:unit_data().unit_id, name = "Cutter", time = 30}
				managers.mission:add_runned_unit_sequence_trigger(unit:unit_data().unit_id, "interact", callback(self, self, "add_custom_timer", data))
			end
		end
	end
end)

function HUDAssaultCorner:add_custom_timer(data)
	if not VoidUI_IB.options.timers or not VoidUIInfobox then return end
	if VoidUIInfobox:child("cu_"..data.id) then return end --EXISTS!
	TimerInfobox:new({
		id = "cu_"..data.id,
		name = data.name and data.name or data.id,
		time = data.time,
		achievement_id = data.achievement_id and data.achievement_id or nil
	})
	managers.hud:add_updator("update_custom_timer_"..data.id, callback(self, self, "update_custom_timer", data))
	if not self._timer then self._timer = {} end
	self._timer[data.id] = data.time
end

function HUDAssaultCorner:update_custom_timer(data, t, dt)
	if not self._timer[data.id] or not VoidUIInfobox:child("cu_"..data.id) then return end
	self._timer[data.id] = self._timer[data.id] - dt

	VoidUIInfobox:child("cu_"..data.id):set_value(self._timer[data.id])

	if self._timer[data.id] <= 0 and not data.manual_remove then
		managers.hud:remove_updator("update_custom_timer_"..data.id)
		VoidUIInfobox:child("cu_"..data.id):remove()
		self._timer[data.id] = nil
	end
end

function HUDAssaultCorner:remove_custom_timer(id)
	if id and VoidUIInfobox:child("cu_"..id) then
		managers.hud:remove_updator("update_custom_timer_"..id)
		VoidUIInfobox:child("cu_"..id):remove()
		self._timer[id] = nil
	end
end

function HUDAssaultCorner:set_custom_jammed(data)
	if data.jammed and data.id and VoidUIInfobox:child("cu_"..data.id) then
		managers.hud:remove_updator("update_custom_timer_"..data.id)
		VoidUIInfobox:child("cu_"..data.id):set_jammed(data.jammed)
	elseif not data.jammed and data.id and VoidUIInfobox:child("cu_"..data.id) then
		managers.hud:add_updator("update_custom_timer_"..data.id, callback(self, self, "update_custom_timer", data))
		VoidUIInfobox:child("cu_"..data.id):set_jammed(data.jammed)
	end
end

function HUDAssaultCorner:add_custom_time(data)
	if not self._timer then self._timer = {} end
	if data.id and data.time and self._timer[data.id] then
		if data.operation and data.operation == "add" then
			if VoidUIInfobox:child("cu_"..data.id)._init_time < data.time then
				VoidUIInfobox:child("cu_"..data.id)._init_time = data.time
			end
			self._timer[data.id] = self._timer[data.id] + data.time
		elseif data.operation and data.operation == "reset" or data.operation == "set_time" then
			VoidUIInfobox:child("cu_"..data.id)._init_time = data.time
			self._timer[data.id] = data.time
		end
	end
end

function HUDAssaultCorner:update_box(id, value, type)
	local InfoboxClass = type == "Collectable" and CollectableInfobox or CounterInfobox
	if not InfoboxClass:child(id) then
		InfoboxClass:new({
			id = id,
			value = value
		})
	else
		if value and value ~= InfoboxClass:child(id).value then
			InfoboxClass:child(id):set_value(value)
		end
	end
end

Hooks:PostHook(HUDAssaultCorner, 'whisper_mode_changed', 'align_boxes_on_whisperstate_change', function(self, data)
	local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
	--Since these panels are animated, we need some delay to wait for them to achieve alpha 0 or 1
	DelayedCalls:Add("delay_sorting", 0.6, function()
		self:sort_boxes()
	end)
	if not is_whisper_mode and VoidUIInfobox and VoidUIInfobox:child("cu_arrest_cooldown") then
		VoidUIInfobox:child("cu_arrest_cooldown"):remove()
	end
end)

Hooks:PostHook(HUDAssaultCorner, 'show_casing', 'align_boxes_please2', function(self, is_offseted, hostage_panel, big_logo)
	self:sort_boxes()
end)
Hooks:PostHook(HUDAssaultCorner, '_set_hostage_offseted', 'align_timers_on_state_change', function(self, is_offseted, big_logo, ...)
	self:sort_boxes()
end)
Hooks:PostHook(HUDAssaultCorner, '_offset_hostage', 'align_boxes_maybe', function(self, is_offseted, big_logo, ...)
	self:sort_boxes()
end)

Hooks:PostHook(HUDAssaultCorner, '_hide_hostages', 'sort_boxes_again', function(self, ...)
	self:sort_boxes()
end)

Hooks:PostHook(HUDAssaultCorner, '_show_hostages', 'sort_boxes_2', function(self, ...)
	self:sort_boxes()
end)

function HUDAssaultCorner:sort_boxes()
	if not self._custom_icons then return end
	--count visible VoidUI boxes;
	local visible_panels = 0
	local y_offset = 0 --Global row
	if not VoidUI_IB.options.row_one_for_vanilla then
		if self._icons then
			for i, k in ipairs(self._icons) do
				if k.panel and k.panel:visible() and k.panel:alpha() == 1 then
					visible_panels = visible_panels + 1
					k.position = visible_panels
				end
			end
		end
	else
		y_offset = 1
	end
	local icons_panel = self._custom_hud_panel:child("icons_panel")
    
	
    for priority, panels in pairs(self._custom_icons) do
        local row_size = VoidUI_IB.options[priority.."_row_size"] or 7
		if y_offset == 0 and priority > 1 and VoidUI_IB.options.row_one_only_one_priority then
			y_offset = 1
		end
		local row = 1 --Row in priority segment
		local use_visible_panels = false
        for i,panel in ipairs(self._custom_icons[priority]) do
			--Sorts priority segment
			local idx
			if y_offset == 0 or use_visible_panels then
				idx = (i + visible_panels) - ((row - 1) * row_size)
				use_visible_panels = true
			else
				idx = i - ((row - 1) * row_size)
			end
			if alive(panel) then
				local x = icons_panel:w() - panel:w() * idx - (y_offset * 3)
				local y = (panel:h() + 3) * (y_offset)
				local panel_y = panel:y()
				local panel_x = panel:x()
				panel:stop()
				panel:animate(function(o)
					over(0.4, function(p)
						if alive(panel) then
							panel:set_y(math.lerp(panel_y, y, p))
							panel:set_x(math.lerp(panel_x, x, p))
						end
					end)
				end)
			end
			if idx == row_size or i == #self._custom_icons[priority] then
				row = row + 1
                y_offset = y_offset + 1
            end
        end
    end
end