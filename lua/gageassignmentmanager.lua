if not VoidUI_IB.options.gagepacks_infobox then return end
Hooks:PostHook(GageAssignmentManager, 'present_progress', 'VUIBA_GageAssignmentManager_present_progress', function(self,assignment, peer_name)
    if not managers.hud or not managers.hud._hud_assault_corner then return end
    managers.hud._hud_assault_corner:update_box("gagepacks", self:count_active_units() - 1)
end)

Hooks:PostHook(GageAssignmentManager, 'on_unit_interact', 'VUIBA_GageAssignmentManager_on_unit_interact', function(self, unit, assignment)
    managers.hud._hud_assault_corner:update_box("gagepacks", self:count_active_units() - 1)
end)
Hooks:PostHook(GageAssignmentManager, 'get_current_experience_multiplier', 'VUIBA_GageAssignmentManager_get_current_experience_multiplier', function(self,assignment, peer_name)
    if not managers.hud or not managers.hud._hud_assault_corner then return end
    managers.hud._hud_assault_corner:update_box("gagepacks", self:count_active_units())
end)

Hooks:PostHook(GageAssignmentManager, 'on_unit_spawned', 'VUIBA_GageAssignmentManager_on_unit_spawned', function(self,assignment, peer_name)
    managers.hud._hud_assault_corner:update_box("gagepacks", self:count_active_units())
end)