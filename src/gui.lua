-- Functions related to the investigation lab GUI.

IVG_LAB_GUI = {}

function IVG_LAB_GUI.render(player)
	IVG_LAB_GUI.destroy_if_open_investigation_lab_gui(player)

	local frame = player.gui.screen.add {
		type = "frame",
		name = "ivg_lab:root",
		caption = "Investigation Lab",
		direction = "vertical",
		style = "dialog_frame",
	}

	local top = frame.add {
		type = "flow",
		direction = "horizontal"
	}
	top.style.bottom_padding = 6

	local investigate = top.add {
		type = "flow",
		direction = "vertical"
	}
	investigate.style.minimal_width = 200

	local investigate_label = investigate.add {
		type = "label",
		caption = "Open Investigations",
		style = "frame_title"
	}
	investigate_label.style.bottom_padding = 4

	investigate.add {
		type = "list-box",
		name = "ivg_lab:available_list",
		items = IVG_LAB_GUI.available_investigations(player),
	}

	local requires = top.add {
		type = "flow",
		direction = "vertical",
	}
	requires.style.minimal_width = 200

	local requires_label = requires.add {
		type = "label",
		caption = "Requires",
		style = "frame_title",
	}
	requires_label.style.bottom_padding = 4

	local requires_list = requires.add {
		type = "flow",
	}

	set_player_field(player.index, "requires_list", requires_list)
	IVG_LAB_GUI.render_requirements(player.index)

	frame.add {
		type = "button",
		name = "ivg_lab:start",
		caption = "Investigate",
	}

	frame.force_auto_center()
	player.opened = frame
end

function IVG_LAB_GUI.destroy_if_open_investigation_lab_gui(player)
	if player.gui.screen["ivg_lab:root"] ~= nil then
		player.gui.screen["ivg_lab:root"].destroy()
	end
end

-- Renders the requirements of the selected investigation if necessary.
function IVG_LAB_GUI.render_requirements(player_index)
	local requires_list = get_player_field(player_index, "requires_list", requires_list)

	-- If there's no requirement to render, don't render.
	if (requires_list == nil) or (not requires_list.valid) then
		return
	end

	-- Remove everything that's already in there.
	requires_list.clear()

	-- If the player has yet to choose something to investigate, show
	-- a message, and then we're done.
	if global.selected_investigation == nil then
		requires_list.add {
			type = "label",
			caption = "No investigation selected."
		}
		return
	end

	-- At this point, we know the player has selected an investigation.

	-- For each ingredient in the requirements, show a line that looks like
	-- the requirements of a crafting recipe in tooltips.
	player = game.get_player(player_index)
	for _ix, ingredient in ipairs(global.selected_investigation.ingredients) do
		local requirement = requires_list.add {
			type = "flow",
			direction = "horizontal",
		}

		requirement.add {
			type = "sprite",
			sprite = "item/" .. ingredient[1]
		}

		local player_ingredient_count = player.get_item_count(ingredient[1])
		local display_have_count = tostring(math.min(player_ingredient_count, ingredient[2]))

		requirement.add {
			type = "label",
			caption = display_have_count .. " / " .. ingredient[2]
		}
	end
end

-- Return a list of the localized strings of the technologies that can be investigated.
-- Note(Havvy): This function is totally out of place here.
--              It also does bad things like side effects.
function IVG_LAB_GUI.available_investigations(player)
	local available = {}
	local player_available = {}

	for _ix, investigation in ipairs(global.investigations) do
		if INVESTIGATION.can_player_investigate(player, investigation) then
			table.insert(player_available, investigation)
			table.insert(available, game.technology_prototypes[investigation.technology].localised_name)
		end
	end

	set_player_field(player.index, "ivg_lab:available", player_available)
	return available
end