if not VoidUI_IB.options.gagepacks_infobox then return end
Hooks:PostHook(GageAssignmentManager, 'present_progress', 'vuib_update_gage_packs', function(self,assignment, peer_name)
    if not managers.hud or not managers.hud._hud_assault_corner then return end
    managers.hud._hud_assault_corner:update_box("gagepacks", self:count_active_units() - 1)
end)

Hooks:PostHook(GageAssignmentManager, 'on_unit_interact', 'vuib_update_gage_packs2', function(self, unit, assignment)
    managers.hud._hud_assault_corner:update_box("gagepacks", self:count_active_units() - 1)
end)
Hooks:PostHook(GageAssignmentManager, 'get_current_experience_multiplier', 'vuib_update_gage_packs', function(self,assignment, peer_name)
    if not managers.hud or not managers.hud._hud_assault_corner then return end
    managers.hud._hud_assault_corner:update_box("gagepacks", self:count_active_units())
end)

Hooks:PostHook(GageAssignmentManager, 'on_unit_spawned', 'vuib_update_gage_packs4', function(self,assignment, peer_name)
    managers.hud._hud_assault_corner:update_box("gagepacks", self:count_active_units())
end)