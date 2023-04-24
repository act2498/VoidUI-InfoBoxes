if RequiredScript == "lib/managers/hud/hudobjectives" then
    if VoidUI.options.enable_objectives then
        Hooks:PostHook(HUDObjectives, "init", "vuib_objectives_make_skills_panel", function(self, hud)
            local objectives_panel = self._hud_panel:child("objectives_panel")
            if not self._scale then self._scale = VoidUI.options.hud_objectives_scale and VoidUI.options.hud_objectives_scale or VoidUI.options.hud_assault_scale end
            if not self._scale then log("Failed fetching the HUD Scale option! Setting to 1...") self._scale = 1 end
            self._icons_panel = self._hud_panel:panel({
                name = "icons_panel",
                w = 360 * self._scale,
                h = 240 * self._scale,
            })
            self._icons_panel:set_top(40 * self._scale)
            self._icons_panel:set_left(objectives_panel:left())
            self._custom_icons = {{},{},{},{},{},{}}
        end)

        Hooks:PostHook(HUDObjectives, "create_objective", "vuib_move_skills_panel_1", function(self, id, data)
            local objectives_panel = self._hud_panel:child("objectives_panel")
            local panel_y = self._icons_panel:y()
            local destination = 40 * self._scale + ((32 * self._scale) * #self._objectives)
            
            self._icons_panel:stop()
            self._icons_panel:animate(function(o)
                over(0.4, function(p)
                    if alive(self._icons_panel) then
                        self._icons_panel:set_y(math.lerp(panel_y, destination, p))
                    end
                end)
            end)
        end)

        Hooks:PostHook(HUDObjectives, "activate_objective", "vuib_move_skills_panel_2", function(self, id, data)
            local objectives_panel = self._hud_panel:child("objectives_panel")
            local last_objective_panel = self._objectives[1]
            --self._skills_panel:set_top(last_objective_panel:bottom() + 5)
        end)

        function HUDObjectives:sort_boxes()
            --count visible VoidUI boxes;
            local visible_panels = 0
            local y_offset = 0 --Global row
            local icons_panel = self._icons_panel
            
            for priority, panels in pairs(self._custom_icons) do
                local row_size = VoidUI_IB.options["skills_"..priority.."_row_size"] or 7
                if y_offset == 0 and priority > 1 and VoidUI_IB.options.row_one_only_one_priority then
                    y_offset = 1
                end
                local row = 1 --Row in priority segment
                for i,panel in ipairs(self._custom_icons[priority]) do
                    --Sorts priority segment
                    local idx = i - ((row - 1) * row_size)
                    if alive(panel) then
                        local x = panel:w() * (idx - 1)
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
    end

    function HUDObjectives:getInfoboxClass(type)
        if type == "Perk" then
            return PerkInfobox
        else
            return SkillInfobox
        end
    end
    
    function HUDObjectives:remove_buff(id)
        if not VoidUIInfobox then return end
        if not VoidUIInfobox:child(id) then return end

        managers.hud:remove_updator("buff_"..id)
        VoidUIInfobox:child(id):remove()
        self._timer[id] = nil
    end
     
    function HUDObjectives:add_buff(data)
        local InfoboxClass = self:getInfoboxClass(data.type)
        if not InfoboxClass then
            log("[VoidUI Infoboxes]: Attempt add buff: "..data.id.." but no InfoboxClass found!")
            return
        end
        if not VoidUI_IB.options["skill_"..data.id] then return end

        if VoidUI_IB.options.debug_buffs and data.id ~= "ArmorRecovery" and data.id ~= "AutoShrug" then
            managers.chat:_receive_message(1, "[VoidUI Infoboxes]", "Attempt add buff: "..data.id, Color(1, 0.5, 0.5, 1))
        end
        if data.time and data.value and not InfoboxClass:child(data.id) then
            InfoboxClass:new({
                id = data.id,
                value = data.value and data.value or nil,
                is_aced = data.is_aced and data.is_aced or nil
            })
        end
        if VoidUIInfobox:child(data.id) then
            if data.value then
                VoidUIInfobox:child(data.id):set_value(data.value)
            end
        else
            InfoboxClass:new({
                id = data.id,
                time = data.time and data.time or nil,
                value = data.value and data.value or nil,
                is_aced = data.is_aced and data.is_aced or nil
            })
        end
        if not self._timer then self._timer = {} end
        if data.time and not self._timer[data.id] then
            self._timer[data.id] = data.time
            managers.hud:add_updator("buff_"..data.id, callback(self, self, "update_buff_timer", data))
        elseif data.time and self._timer[data.id] then
            self._timer[data.id] = data.time
            self:change_buff_timer(data)
        end
    end
    
    function HUDObjectives:update_buff_timer(data, t, dt)
        --local InfoboxClass = self:getInfoboxClass(data.type)
        if not self._timer[data.id] or not VoidUIInfobox:child(data.id) then return end
        self._timer[data.id] = self._timer[data.id] - dt
        if not data.value then
            VoidUIInfobox:child(data.id):set_value(self._timer[data.id])
        end
        if self._timer[data.id] <= 0 and data.on_callback then
            data.on_callback()
            if not data.dont_remove_clbk then
                data.on_callback = nil
            end
            return
        end
        if self._timer[data.id] <= 0 and not data.manual_remove then
            managers.hud:remove_updator("buff_"..data.id)
            VoidUIInfobox:child(data.id):remove()
            self._timer[data.id] = nil
        end
    end
    
    function HUDObjectives:change_buff_timer(data)
        if not self._timer then self._timer = {} end
        local infobox = VoidUIInfobox:child(data.id)
        if not infobox then return end
        if data.id and data.time and self._timer[data.id] then
            if data.operation then
                if data.operation == "add" then
                    self._timer[data.id] = self._timer[data.id] + data.time
                    if infobox._init_time < data.time then
                        infobox._init_time = self._timer[data.id]
                    end
                elseif data.operation == "reset" or data.operation == "set_time" then
                    self._timer[data.id] = data.time
                    infobox._init_time = data.time
                end
            end
        end
    end
end