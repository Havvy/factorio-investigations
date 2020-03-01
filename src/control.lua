-- Investigations data. Defines VANILLA
require("investigations")

-- Utility functions.
require("helpers")

-- Functions related to the investigation lab gui.
require("gui")

script.on_init(function ()
	global.investigations = VANILLA

	-- These should be force-specific.
	global.has_given_lab = false
	global.selected_investigation = nil

	global.players = {}
	-- available_investigations: List<TechnologyNameString> = Technology blocked by investigation
end)

script.on_load(function (event)
	commands.add_command("reload_investigations", "", function()
		global.investigations = VANILLA
	end)
end)


-- Give the first player in the game an investigation lab.
-- They only get one, so they better not lose it!
script.on_event(defines.events.on_player_created, function (event)
	if global.has_given_lab == true then return end

    local player = game.players[event.player_index].insert{name = "investigation-lab", count = 1}
    global.has_given_lab = true
end)

script.on_event(defines.events.on_gui_opened, function (event)
	-- Check for investigation-lab being opened. Return otherwise,
	-- since we only care about that entity.
	if event.entity == nil then return end
	if event.entity.name ~= "investigation-lab" then return end

	local player = game.get_player(event.player_index)

	-- Close the shown GUI. It's useless.
	player.opened = nil

	-- Open the investigation lab GUI.
	IVG_LAB_GUI.render(player)
end)

-- Handle a player selecting a technology to possibly investigate.
script.on_event(defines.events.on_gui_selection_state_changed, function(event)
	if event.element.name == "ivg_lab:available_list" then
		INVESTIGATION.select_investigation {
			player_index = event.player_index,
			investigation_index = event.element.selected_index
		}
	end
end)

script.on_event(defines.events.on_gui_click, function(event)
	if event.element.name == "ivg_lab:start" then
		-- Handle the player starting an investigation.
		local player = game.get_player(event.player_index)
		
		if global.selected_investigation ~= nil then
			INVESTIGATION.investigate(player, global.selected_investigation)
		end
	end
end)

-- Make ESC work for the investigation lab GUI.
script.on_event(defines.events.on_gui_closed, function (event)
	if event.element ~= nil and event.element.name == "ivg_lab:root" then
		IVG_LAB_GUI.destroy_if_open_investigation_lab_gui(game.get_player(event.player_index))
	end
end)