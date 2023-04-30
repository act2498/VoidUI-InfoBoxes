
core:module("CoreMissionManager")
core:import("CoreTable")

local level = Global.level_data and Global.level_data.level_id or ""

if level == "framing_frame_3" then
    Hooks:PreHook(MissionManager, "_add_script", "InfoBoxes_BagCountFix", function(self, data)
        for _, element in pairs(data.elements) do
			if element.id == 100538 then
				table.remove(element.values.elements, table.index_of(element.values.elements, 100743))
				table.insert(element.values.elements, 100744) --Fix links
			elseif element.id == 100501 then
				element.values.enabled = false
			elseif element.id == 100545 then
				table.remove(element.values.elements, table.index_of(element.values.elements, 100744))
				table.insert(element.values.elements, 100743) --Fix linking LOL
			elseif element.id == 100546 then
				element.values.sequence_list = {}
			elseif element.id == 100533 then
				element.values.sequence_list = {}
			elseif element.id == 100539 then
				element.values.sequence_list = {}
				--Voila
			end
        end
    end)
elseif level == "mia_2" then
	Hooks:PreHook(MissionManager, "_add_script", "VUIBA_HLM2_TimerFix", function(self, data)
        for _, element in pairs(data.elements) do
			if element.id == 101282 then
				table.insert(element.values.elements, 101043)
				table.insert(element.values.elements, 100053)
			end
        end
	end)
end