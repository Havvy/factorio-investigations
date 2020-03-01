function get_player_field(player_index, field)
	if global.players[player_index] == nil then
		global.players[player_index] = {}
	end

	return global.players[player_index][field]
end

function get_player_field_or_default(player_index, field, value)
	if global.players[player_index] == nil then
		global.players[player_index] = {}
	end

	if global.players[player_index][field] == nil then
		global.players[player_index][field] = value
	end

	return global.players[player_index][field]
end

function set_player_field(player_index, field, value)
	if global.players[player_index] == nil then
		global.players[player_index] = {}
	end

	global.players[player_index][field] = value
end