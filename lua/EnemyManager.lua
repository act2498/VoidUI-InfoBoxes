local special_unit_ids = {
    "shield",
	"spooc",
	"shadow_spooc",
	"tank",
	"tank_hw",
	"tank_green",
	"tank_black",
	"tank_skull",
	"taser",
	"medic",
	"sniper",
	"phalanx_minion",
	"phalanx_vip",
	"swat_turret",
	"biker_boss",
	"chavez_boss",
	"mobster_boss",
	"hector_boss",
	"hector_boss_no_armor",
	"drug_lord_boss",
	"drug_lord_boss_stealth"
}
any_special_enemy_box_active = false
for i,name in pairs(special_unit_ids) do
    if VoidUI_IB.options["enemy_"..name.."_infobox"] then
        any_special_enemy_box_active = true
    end
end

if VoidUI_IB.options.enemies_infobox or VoidUI_IB.options.special_enemies_infobox or any_special_enemy_box_active then
    local special_counter = {}
    local function check_special_name(name)
        if string.find(name, "tank") then
            name = "tank"
        elseif string.find(name, "spooc") then
            name = "spooc"
        end
        return name
    end

    function EnemyManager:VUIB_update_units_count(stats_name)
        local hud = managers.hud._hud_assault_corner
        if not hud then return end --HUD not loaded yet
        if not VoidUI_IB.options.special_enemies_infobox then
            hud:update_box("enemies", self._enemy_data.nr_units)
        else
            hud:update_box("special_enemies", self._enemy_data.nr_special_units)
            hud:update_box("enemies", self._enemy_data.nr_units - self._enemy_data.nr_special_units)
        end

        local enemy_name = check_special_name(stats_name)
        if VoidUI_IB.options["enemy_"..enemy_name.."_infobox"] then
            if not special_counter[enemy_name] then
                special_counter[enemy_name] = 0
            end

            special_counter[enemy_name] = special_counter[enemy_name] + 1
            hud:update_box("enemy_"..enemy_name, special_counter[enemy_name])
        end
    end

    Hooks:PostHook(EnemyManager, "_init_enemy_data", "VUIB_init_enemy_counters", function(self)
        self._enemy_data.nr_special_units = 0
    end)

    Hooks:PostHook(EnemyManager, 'on_enemy_registered', 'add_enemy', function(self, enemy)
        local stats_name = enemy:base()._stats_name or enemy:base()._tweak_table
        if table.contains(special_unit_ids, stats_name) then
            self._enemy_data.nr_special_units = self._enemy_data.nr_special_units + 1
        end
        self:VUIB_update_units_count(stats_name)
    end)

    Hooks:PostHook(EnemyManager, 'on_enemy_unregistered', 'remove_enemy', function(self, unit)
        local stats_name = unit:base()._stats_name or unit:base()._tweak_table
        if table.contains(special_unit_ids, stats_name) then
            self._enemy_data.nr_special_units = self._enemy_data.nr_special_units - 1
        end
        self:VUIB_update_units_count(stats_name)
    end)
end
if VoidUI_IB.options.civs_infobox then
    Hooks:PostHook(EnemyManager, 'on_civilian_died', 'vuib_remove_civilian', function(self, dead_unit, damage_info)
        managers.hud._hud_assault_corner:update_box("civs", table.size(self._civilian_data.unit_data))
    end)

    Hooks:PostHook(EnemyManager, 'on_civilian_destroyed', 'vuib_remove_civilian2', function(self, dead_unit, damage_info)
        managers.hud._hud_assault_corner:update_box("civs", table.size(self._civilian_data.unit_data))
    end)

    Hooks:PostHook(EnemyManager, 'register_civilian', 'vuib_add_civilian', function(self,unit)
        if managers.hud._hud_assault_corner then
            managers.hud._hud_assault_corner:update_box("civs", table.size(self._civilian_data.unit_data))
        end
    end)
end