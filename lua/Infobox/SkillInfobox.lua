SkillInfobox = SkillInfobox or class(VoidUIInfobox)

function SkillInfobox:_anim_new_border()
	local highlight_texture = "guis/textures/VoidUI_IB/hud_timer_border"
    local scale, panel_w, panel_h = self:get_scale_options()
	local new_border = self._panel:bitmap({
        name = "border",
		texture = highlight_texture,
		texture_rect = {0,0,171,150},
		layer = 2,
		w = panel_w,
		h = panel_h,
        render_template = "VertexColorTexturedRadial"
	})
	return new_border
end

function SkillInfobox:FetchInfo(data)
    self._priority = VoidUI_IB.options.Skill_priority or 6
    self._type = "Skill"

    if data.time then
        self._is_timer = true
    end

    if data.value and not string.find(data.value, "/") then
        self.is_percentage = true
    end

    if data.is_aced then
        self.use_ace_icon = true
    end
end

function SkillInfobox:check_valid()
    if not VoidUI_IB.options.skills or not VoidUI_IB.options["skill_"..self.id] then
        return false
    end
    return true
end

function SkillInfobox:create(data)
    local scale, panel_w, panel_h = self:get_scale_options()
    local font_size = panel_h / 3
    if self.is_percentage then
        self._text_panel = self:new_text(tostring(math.ceil(data.value * 100)).."%")
        self:FixFont(self._text_panel, font_size)
    end
    if self.use_ace_icon then
        self.ace_icon = self:new_icon("guis/textures/pd2/skilltree_2/ace_symbol")
        self.ace_icon:set_alpha(0.6)
        self.ace_icon:set_blend_mode("add")
        self.ace_icon:set_color(Color(1,1,1))
        self.ace_icon:set_size(panel_w * 1.2, panel_h * 1.2)
        self.ace_icon:set_center(self._background:center())
    end
    if self._is_timer then
        self._init_time = data.time
        if data.time > 5 then
            self._text_panel = self:new_text(tostring(math.ceil(data.time)).."s")
        else
            self._text_panel = self:new_text(tostring(math.round_with_precision(data.time, 1)).."s")
        end
        self._text_panel:set_font_size(font_size)
        if VoidUI_IB.options.AnimateSkillBorders then
            self._panel:remove(self._border)
            self._border = self:_anim_new_border()
        end
    end
end

if VoidUI_IB.options.ReverseSkillAnimation then
    function SkillInfobox:_anim_border()
        if not self._border or not self._init_time then return end
        self._border:stop()
        local ratio = self.value / self._init_time
        
        self._border:set_color(Color(1, 1 - ratio, 1, 1))
    end
else
    function SkillInfobox:_anim_border()
        if not self._border or not self._init_time then return end
        self._border:stop()
        local ratio = self.value / self._init_time
        
        self._border:set_color(Color(1, ratio, 1, 1))
    end
end

function SkillInfobox:_set_value(value)
    local scale, panel_w, panel_h = self:get_scale_options()
    local _,_,w,_ = self._text_panel:text_rect()
    local font_size = panel_h / 3

    if self._is_timer then
        if value > 5 then
            self._text_panel:set_text(tostring(math.ceil(value)).."s")
        else
            self._text_panel:set_text(tostring(math.round_with_precision(value, 1)).."s")
        end
        self._text_panel:set_font_size(font_size)
        self.value = value
        if VoidUI_IB.options.AnimateSkillBorders then
            self:_anim_border()
        end
        return
    end

    if self.is_percentage then

        value = math.ceil(value * 100)

        if value == self.value then
            return
        end

        self.value = value

        self._text_panel:set_text(tostring(value).."%")
        self:FixFont(self._text_panel, font_size)

        if alive(self._background) then
            self._background:stop()
            self._background:animate(callback(self, self, "_blink_background"))
        end
    else 
        if value == self.value then
            return
        end

        self.value = value

        if alive(self._text_panel) and self._text_panel.set_text then
            self._text_panel:set_text(tostring(value))
            self:FixFont(self._text_panel, font_size)
            if alive(self._background) then
                self._background:stop()
                self._background:animate(callback(self, self, "_blink_background"))
            end
        end
    end
end