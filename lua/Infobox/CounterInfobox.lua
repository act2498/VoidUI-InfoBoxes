CounterInfobox = CounterInfobox or class(VoidUIInfobox)

function CounterInfobox:FetchInfo(data)
    self._priority = VoidUI_IB.options.Counter_priority or 6
    self._type = "Counter"

    self.value = data.value or 0
end

function CounterInfobox:check_valid()
    if string.find(tostring(self.value), "-") or (tostring(self.value) == "0" or self.value == "0 | x0") and VoidUI_IB.options.remove_empty then
        return false
    elseif not VoidUI_IB.options[self.id.."_infobox"] then
        return false
    end

    return true
end

function CounterInfobox:create(data)
    self._text_panel = self:new_text(self.value)

    self:set_value(self.value)
end

function CounterInfobox:_set_value(value)
    if not value then
        self:Error("No value provided for CounterInfobox "..tostring(self.id).."!")
    end
    local scale, panel_w, panel_h = self:get_scale_options()
    local font_size = panel_h / 2
    value = tostring(value)
    if value == "0 | x0" or value == "0" then
        if VoidUI_IB.options.remove_empty then
            self:remove()
            return
        end
    end
    if value == self.value then
        return
    else
        self.value = value
    end
    if alive(self._text_panel) and self._text_panel.set_text then
        local text = self._text_panel
        text:set_text("x"..value)
        self:FixFont(text, font_size)
    end
    if alive(self._background) then
        self._background:stop()
        self._background:animate(callback(self, self, "_blink_background"))
    end
end