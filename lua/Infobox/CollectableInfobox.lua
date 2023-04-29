CollectableInfobox = CollectableInfobox or class(CounterInfobox)

function CollectableInfobox:FetchInfo(data)
    self._priority = VoidUI_IB.options.Collectable_priority or 6
    self._type = "Collectable"

    self._value = data.value and data.value or 0
end

function CollectableInfobox:check_valid()
    return VoidUI_IB.options.collectables and VoidUI_IB.options["collectable_"..self.id]
end

function CollectableInfobox:_set_value(value)
    local scale, panel_w, panel_h = self:get_scale_options()
    value = tostring(value)
    if value == "0 | x0" or value == "0" then
        self:remove()
        return
    end
    if self.value and value == self.value then
        return
    end
    if alive(self._text_panel) and self._text_panel.set_text then
        local text = self._text_panel
        text:set_text("x"..value)
        local font_size = panel_h / 2
        self:FixFont(text, font_size)
    end
    if alive(self._background) then
        self._background:stop()
        self._background:animate(callback(self, self, "_blink_background"))
    end
end