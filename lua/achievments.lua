local tracked_elements = {
    bex = {102602},
    pbr2 = {103479},
    pines = {{type="masks", achiev_id="xmas_2014"}}
}
if RequiredScript == "lib/managers/mission/elementawardachievment" and VoidUI_IB.options.Achievement then
    Hooks:PostHook(ElementAwardAchievment, "on_toggle", "VUIB_Track_Achievements1", function(self, value)
        if not tracked_elements[Global.game_settings.level_id] then
            Hooks:RemovePostHook("VUIB_Track_Achievements1")
            return
        end
        if table.contains(tracked_elements[Global.game_settings.level_id], self._id) then
            if not VoidUI_IB.options.show_unlocked then
                local ach_info = managers.achievment:get_info(self._values.achievment)
                if ach_info.awarded then
                    return
                end
            end
            if AchievementInfobox:child("achiv_" .. tostring(self._values.achievment)) then
                AchievementInfobox:child("achiv_" .. tostring(self._values.achievment)):set_valid(value)
            else
                AchievementInfobox:new({
                    id = "achiv_"..tostring(self._values.achievment),
                    name_id = "Achievement",
                    achievement_id = self._values.achievment,
                    valid = value
                })
            end
        end
    end)

    Hooks:PostHook(ElementAwardAchievment, "init", "VoidUI_start_tracking_achievement", function(self)
        if not tracked_elements[Global.game_settings.level_id] then
            Hooks:RemovePostHook("VoidUI_start_tracking_achievement")
            return
        end

        if table.contains(tracked_elements[Global.game_settings.level_id], self._id) then
            if not VoidUI_IB.options.show_unlocked then
                local ach_info = managers.achievment:get_info(self._values.achievment)
                if ach_info.awarded then
                    return
                end
            end
        
            if not AchievementInfobox:child("achiv_".. tostring(self._values.achievment)) then
                AchievementInfobox:new({
                    id = "achiv_"..tostring(self._values.achievment),
                    name_id = "Achievement",
                    achievement_id = self._values.achievment,
                    valid = self._values.enabled
                })
            end
        end
        for _, val in pairs(tracked_elements[Global.game_settings.level_id]) do
            if type(val) == "table" then
                if val.type == "masks" then
                    local achiev_data = tweak_data.achievement.four_mask_achievements[val.achiev_id]
                    local all_masks_valid = true
                    if achiev_data.masks then
                        local available_masks = deep_clone(achiev_data.masks)
                        local valid_mask_count = 0
                        for _, peer in pairs(managers.network:session():all_peers()) do
                            local current_mask = peer:mask_id()
                            if table.contains(available_masks, current_mask) then
                                table.delete(available_masks, current_mask)
                                valid_mask_count = valid_mask_count + 1
                            else
                                all_masks_valid = false
                            end
                        end
                        for _, char in pairs(managers.criminals._characters) do
                            if char.data.ai then
                                local current_mask = char.data.mask_id
                                if table.contains(available_masks, current_mask) then
                                    table.delete(available_masks, current_mask)
                                    valid_mask_count = valid_mask_count + 1
                                else
                                    all_masks_valid = false
                                end
                            end
                        end
                    end
                    if AchievementInfobox:child("achiv_" .. tostring(achiev_data.award)) then
                        AchievementInfobox:child("achiv_" .. tostring(achiev_data.award)):set_valid(all_masks_valid)
                    else
                        AchievementInfobox:new({
                            id = "achiv_"..tostring(achiev_data.award),
                            name_id = "Achievement",
                            achievement_id = achiev_data.award,
                            valid = all_masks_valid
                        })
                    end
                end
            end
        end
    end)

    Hooks:PostHook(ElementAwardAchievment, "on_executed", "VUIB_Track_Achievements2", function(self, instigator)
        if not tracked_elements[Global.game_settings.level_id] then
            Hooks:RemovePostHook("VUIB_Track_Achievements2")
            return
        end
        if table.contains(tracked_elements[Global.game_settings.level_id], self._id) then
            if AchievementInfobox:child("achiv_" .. tostring(self._values.achievment)) then
                AchievementInfobox:child("achiv_" .. tostring(self._values.achievment)):award()
            end
        end
    end)
end