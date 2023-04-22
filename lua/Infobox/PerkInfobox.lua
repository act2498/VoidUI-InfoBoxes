PerkInfobox = PerkInfobox or class(SkillInfobox)

function PerkInfobox:FetchInfo(data)
    self._priority = VoidUI_IB.options.Perk_priority or 6
    self._type = "Perk"

    self.time = data.time
    self.value = data.value

    if self.time then
        self._is_timer = true
    end

    if self.value and not string.find(self.value, "/") then
        self.is_percentage = true
    end
end

function PerkInfobox:check_valid()
    return VoidUI_IB.options.ib_perks and VoidUI_IB.options["skill_"..self.id]
end

function PerkInfobox:create(data)
    local scale, panel_w, panel_h = self:get_scale_options()
    local font_size = panel_h / 3
    local value = self.value
    local time = self.time
    self._init_time = time
    if self.is_percentage then
        self._text_panel = self:new_text(tostring(math.ceil(value * 100)).."%")
        self:FixFont(self._text_panel, font_size)
    end
    if self._is_timer then
        if time > 5 then
            self._text_panel = self:new_text(tostring(math.ceil(time)).."s")
        else
            self._text_panel = self:new_text(tostring(math.round_with_precision(time, 1)).."s")
        end
        self._text_panel:set_font_size(font_size)
        if VoidUI_IB.options.AnimatePerkBorders then
            self._panel:remove(self._border)
            self._border = self:_anim_new_border()
        end
    end
end

if VoidUI_IB.options.ReversePerkAnimation then
    function PerkInfobox:_anim_border()
        if not self._border or not self._init_time then return end
        self._border:stop()
        local ratio = self.value / self._init_time
        
        self._border:set_color(Color(1, 1 - ratio, 1, 1))
    end
else
    function PerkInfobox:_anim_border()
        if not self._border or not self._init_time then return end
        self._border:stop()
        local ratio = self.value / self._init_time
        
        self._border:set_color(Color(1, ratio, 1, 1))
    end
end


function PerkInfobox:_set_value(value)
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
        if VoidUI_IB.options.AnimatePerkBorders then
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