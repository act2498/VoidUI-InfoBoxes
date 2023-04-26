function VoidUIMenu:open_infobox_menu()
	self:Close(true)
	VoidUI_IB.Menu = VoidUI_IB.Menu or VoidUI_IB_Menu:new()
	VoidUI_IB.Menu:Open()
end

if not VoidUIMenu.mouse_wheel_down then
	function VoidUIMenu:mouse_wheel_down()
		if self._one_scroll_down_delay then
			self._one_scroll_down_delay = nil
			return
		end
		self:MenuDown()
	end
end

if not VoidUIMenu.mouse_wheel_up then
	function VoidUIMenu:mouse_wheel_up()
		if self._one_scroll_up_delay then
			self._one_scroll_up_delay = nil
			return
		end
		self:MenuUp()
	end
end

if not VoidUIMenu.move_all then
	function VoidUIMenu:move_all(value)
		for i, panel in ipairs(self._open_menu.panel:children()) do
			if panel.y then
				local starting_point = panel:y()
				local des = panel:y() + value
				panel:stop()
				panel:animate(function()
					local dur = 0.2
					local t = 0
					while dur > t do
						coroutine.yield()
						t = t + TimerManager:main():delta_time()
						panel:set_y(math.lerp(starting_point, des, t / dur))
					end
				end)
			end
		end
	end
end

Hooks:PostHook(VoidUIMenu, 'HighlightItem', 'ib_check_pos_hi', function(self, item)
	if item == self._back_button then return end
	if item.panel and item.panel:bottom() > (self._panel:bottom() - 40) then
		self:move_all(-1 * (item.panel:bottom() - (self._panel:bottom() - 40) + item.panel:h()))
	elseif item.panel and item.panel:top() < self._panel:top() then
		if item.panel == self._open_menu.items[1].panel then
			self:move_all(self._panel:top() - item.panel:top() + self._open_menu.panel:child("title"):h())
		else
			self:move_all(self._panel:top() - item.panel:top())
		end
	end
end)

Hooks:PostHook(VoidUIMenu, 'Open', 'ib_add_scroll_triggers', function(self)
if managers.menu:is_pc_controller() then
	Input:mouse():add_trigger(Input:mouse():button_index(Idstring("mouse wheel up")), callback(self, self, 'mouse_wheel_up'))
	Input:mouse():add_trigger(Input:mouse():button_index(Idstring("mouse wheel down")), callback(self, self, 'mouse_wheel_down'))
end
end)

Hooks:PostHook(VoidUIMenu, 'MenuUp', 'ib_scroll_delay_up', function(self)
self._one_scroll_up_delay = true
end)

Hooks:PostHook(VoidUIMenu, 'MenuDown', 'ib_scroll_delay_down', function(self)
self._one_scroll_down_delay = true
end)

VoidUI_IB_Menu = VoidUI_IB_Menu or class(VoidUIMenu)

VoidUI_IB_Menu.default_menu = "infobox" --The default menu to open
VoidUI_IB_Menu.MainClass = VoidUI_IB and VoidUI_IB or {} --The main class

function VoidUI_IB_Menu:refresh_align_hud(item)
	local id = string.sub(item.id,string.len(item.id))
	hud = managers.hud and managers.hud._hud_infobox[tonumber(id)]
	if hud then
		hud:sort_boxes()
		if hud._debug_icons then
			hud:sort_boes(hud._debug_icons)
		end
	else
		log("HUD not found; " .. tostring(id))
	end
end

function VoidUI_IB_Menu:set_hud_space_position(item)
	local id = string.sub(item.id, 1, 1)
	hud = managers.hud and managers.hud._hud_infobox[tonumber(id)]
	if string.sub(item.id,string.len(item.id)) == "x" then
		if hud then
			local x = (item.value / 100) * (hud._hud_panel:w() - hud._icons_panel:w())
			hud._icons_panel:set_x(x)
			if hud.debug_panel then
				hud.debug_panel:set_x(x)
			end
		end
	elseif string.sub(item.id,string.len(item.id)) == "y" then
		if hud then
			local y = (item.value / 100) * (hud._hud_panel:h() - hud._icons_panel:h())
			hud._icons_panel:set_y(y)
			if hud.debug_panel then
				hud.debug_panel:set_y(y)
			end
		end
	end
end

function VoidUI_IB_Menu:Cancel()
	if self._open_choice_dialog then
		self:CloseMultipleChoicePanel()
	elseif self._open_color_dialog then
		self:CloseColorMenu(false)
	elseif self._open_menu.id == self.default_menu then
		self:Close(true)
		VoidUI.Menu = VoidUI.Menu or VoidUIMenu:new()
		VoidUI.Menu:Open()
	elseif self._open_menu.parent_menu then
		self:OpenMenu(self._open_menu.parent_menu, true)
	else
		self:Close()
	end
end
	
	--callbacks

	function VoidUI_IB_Menu:open_support_page()
		os.execute("cmd /c start https://ko-fi.com/miamicenter")
	end

	function VoidUI_IB_Menu:refresh_infoboxes(item)
		if VoidUIInfobox then
			VoidUIInfobox:refresh_all()
		end

		--Check if options are valid;

		--Check if row size is 0 for given priority when changing infobox priority
		if string.find(item.id, "_priority") and not item.value == 1 then
			local _type = string.gsub(item.id, "_priority", "")
			local _priority = item.value
			local _hud = VoidUI_IB.options["hud_".._type]
			if _hud > 2 then
				if VoidUI_IB.options[(_hud - 2).."_".._priority.."_row_size"] == 0 then
					--Print Error - Given priority has row size = 0 -> Infobox won't spawn!
				end
			end
		end

		--Check if row size is 0 for given priority when changing HUD

		if string.find(item.id, "hud_") then
			local _type = string.gsub(item.id, "hud_", "")
			local _priority = VoidUI_IB.options[_type.."_priority"]
			local _hud = item.value
			if _hud > 2 then
				if VoidUI_IB.options[(_hud - 2).."_".._priority.."_priority"] == 0 then
					--Print Error - Given priority has row size = 0 -> Infobox won't spawn!
				end
			end
		end
	end