--Init my stuff;
HUDInfobox = HUDInfobox or class()

function HUDInfobox:init(hud, id)
    self.id = id
    self._hud_panel = hud.panel
    self._custom_icons = {{},{},{},{},{},{}}
    local scale = managers.hud._hud_assault_corner and managers.hud._hud_assault_corner._scale or VoidUI.options.hud_assault_scale
    local panel_w, panel_h = 44 * scale, 38 * scale
    local max_row_size = 1
    local temp_row_size
    local rows = 0
    for priority = 1, 6 do
        temp_row_size = VoidUI_IB.options[id.."_"..priority.."_row_size"] or 7
        if temp_row_size > max_row_size then
            max_row_size = temp_row_size
        end
        if temp_row_size ~= 0 then
            rows = rows + 1
        end
    end
    local icons_panel_w, icons_panel_h = panel_w * max_row_size, panel_h * rows + ((rows - 1) * 3)
    self._icons_panel = self._hud_panel:panel({
        name = "icons_panel",
        w = icons_panel_w,
        h = icons_panel_h,
        layer = 3,
        x = (VoidUI_IB.options[id.."_hud_space_x"] / 100) * (self._hud_panel:w() - icons_panel_w),
        y = (VoidUI_IB.options[id.."_hud_space_y"] / 100) * (self._hud_panel:h() - icons_panel_h)
    })
    if VoidUI_IB.options[id.."_show_debug_position"] then
        self._debug_icons = {{},{},{},{},{},{}}
        self.debug_panel = self._hud_panel:bitmap({
            name = "debug_rect",
            color = Color.red:with_alpha(0.5),
            layer = 0,
            w = self._icons_panel:w(),
            h = self._icons_panel:h()
        })
        self.debug_panel:set_center(self._icons_panel:center())
        self:show_debug_infobox_panels()
    end
end

function HUDInfobox:spawn_debug_ib()
    local scale = managers.hud._hud_assault_corner and managers.hud._hud_assault_corner._scale or VoidUI.options.hud_assault_scale
    local panel_w, panel_h = 44 * scale, 38 * scale
    local debug_ib = self._icons_panel:panel({
        layer = 0,
        w = panel_w,
        h = panel_h
    })
    local area = debug_ib:bitmap({
        color = Color.green:with_alpha(0.5),
        layer = 0,
        w = panel_w,
        h = panel_h
    })
    local debug_text = debug_ib:text({
        name = "debug_text",
        text = "ID: "..tostring(self.id),
        font = tweak_data.menu.pd2_small_font,
        font_size = panel_h / 3,
        color = Color.white,
        layer = 0,
        align = "center",
        vertical = "center"
    })
    debug_text:set_center(debug_ib:center())

    return debug_ib
end
function HUDInfobox:show_debug_infobox_panels()
    local y_offset = 1
    for priority = 1, 6 do
        local row_size = VoidUI_IB.options[self.id.."_"..priority.."_row_size"] or 7
        if row_size ~= 0 then
            for idx = 1, row_size do
                local ib = self:spawn_debug_ib()
                table.insert(self._debug_icons[priority], ib)
                ib:child("debug_text"):set_text("Priority: "..tostring(priority).."\nIndex: "..tostring(idx).."\nRow: "..tostring(y_offset))
            end
            y_offset = y_offset + 1
        end
    end
    self:sort_boxes(self._debug_icons)
end
function HUDInfobox:sort_boxes(table_to_sort)
    if not table_to_sort then
        table_to_sort = self._custom_icons
    end
    local icons_panel = self._icons_panel
    local y_offset = 0 --Global row
    local align_option = VoidUI_IB.options[self.id.."_hud_align"]
    local align_x = align_option == 1 and "left" or align_option == 3 and "left" or "right"
    local align_y = align_option == 1 and "top" or align_option == 2 and "top" or "bottom"
    for priority, panels in ipairs(table_to_sort) do
        local row_size = VoidUI_IB.options[self.id.."_"..priority.."_row_size"] or 7
        if row_size ~= 0 and #panels == 0 and VoidUI_IB.options[self.id.."_dont_change_y"] then
            y_offset = y_offset + 1
        end
        local row = 1 --Row in priority segment
        for i,panel in ipairs(table_to_sort[priority]) do
            --Sorts priority segment
            local idx = i - ((row - 1) * row_size)
            if alive(panel) then
                local panel_x = panel:x()
                local panel_y = panel:y()
                local x, y = 0, 0
                if align_x == "left" then
                    x = panel:w() * (idx - 1)
                elseif align_x == "right" then
                    x = icons_panel:w() - panel:w() * idx
                end
                if align_y == "top" then
                    y = (panel:h() + 3) * (y_offset)
                elseif align_y == "bottom" then
                    y = icons_panel:h() - (panel:h() * (y_offset + 1) + 3 * y_offset)
                end
                
                panel:stop()
                panel:animate(function(o)
                    over(0.4, function(p)
                        if alive(panel) then
                            panel:set_y(math.lerp(panel_y, y, p))
                            panel:set_x(math.lerp(panel_x, x, p))
                        end
                    end)
                end)
                panel:set_y(y)
                panel:set_x(x)
            end
            if idx == row_size or i == #table_to_sort[priority] then
                row = row + 1
                y_offset = y_offset + 1
            end
        end
    end
end

Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "setup_InfoboxHUD", function(self)
    hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
    self._hud_infobox = {}
    for i=1, 4 do
        table.insert(self._hud_infobox, HUDInfobox:new(hud, i))
    end
end)