--[[
struct Investigation {
	--- Name of the technology to require investigation
	technology: String,

	--- The items required to be investigated. The string is the item name,
	--- and the int is the item count.
	ingredients: Array<{String, Int}>,

	--- How long an investigation lasts in seconds. Defaults to 60 seconds.
	time: Int | nil,
}
]]--

-- Module for investigation specific functions.
INVESTIGATION = {}

-- ONLY AVAILABLE DURING THE DATA STAGE!
function INVESTIGATION.add_investigation_tech(investigation)
	local investigated_tech_name = investigation.technology

	local investigated_tech = data.raw.technology[investigation.technology]
	local ingredients = investigation.ingredients

	local investigation_tech = table.deepcopy(investigated_tech)

	if investigation_tech == nil then
		log("Error: Invalid technology: " .. investigation.technology)

		for name, _proto in pairs(data.raw.technology) do
			log(name)
		end
	end

	-- Give unique tech name.
	investigation_tech.name = "investigate-" .. investigation.technology

	-- Give localisation
	local investigated_tech_localisation = investigated_tech.localised_name or {"technology-name." .. investigated_tech.name}
	investigation_tech.localised_name = {"technology-name.investigate", investigated_tech_localisation}
	investigation_tech.localised_description = {"technology-description.investigate"}

	-- Make unresearchable; show player they need to research first.
	table.insert(investigation_tech.unit.ingredients, {"investigation-required", 1})

	-- Make sure the technology has no actual effects so that when it is researched,
	-- by the investigation, don't actually give the effect.
	investigation_tech.effects = nil

	-- Let the game know about this new tech.
	data:extend({investigation_tech})

	-- Set the prereq of the tech to be investigated to the investigation tech.
	investigated_tech.prerequisites = {investigation_tech.name}
end

function INVESTIGATION.can_player_investigate(player, investigation)
	local technologies = player.force.technologies
	local investigation_technology = technologies["investigate-" .. investigation.technology]

	-- No: Investigation already complete.
	if investigation_technology.researched then
		return false
	end

	-- No: Prereqs not researched
	for _name, technology in pairs(investigation_technology.prerequisites) do
		if not technology.researched then
			return false
		end
	end

	-- Yes!
	return true
end

function INVESTIGATION.select_investigation(input)
	local player_index = input.player_index
	local investigation_index = input.investigation_index

	global.selected_investigation = get_player_field(player_index, "ivg_lab:available")[investigation_index]
	IVG_LAB_GUI.render_requirements(player_index)
end

function INVESTIGATION.try_start_investigation(player, investigation)
	-- See if the player has everything to do the investigation.
	for _ix, ingredient in ipairs(investigation.ingredients) do
		local player_ingredient_count = player.get_item_count(ingredient[1])
		if player_ingredient_count < ingredient[2] then
			return false
		end
	end

	-- Now that we know the player has it, take it from them.
	for _ix, ingredient in ipairs(investigation.ingredients) do
		player.remove_item { name = ingredient[1], count = ingredient[2] }
	end

	return true
end

function INVESTIGATION.investigate(player, investigation)
	if not INVESTIGATION.try_start_investigation(player, investigation) then
		return
	end

	player.force.technologies["investigate-" .. investigation.technology].researched = true
end

VANILLA = {
	-- Sciences here are ordered by tech level (military > logistics)
	-- and then by order on https://davemcw.com/factorio/tech-tree/

	-- RED SCIENCE (copper + iron gears)
	-- For most of these technologies, they are bootstrap ones that we don't
	-- want to add a restriction on, or can bank on the red science cost.

	{
		technology = "military",

		-- More than what you start with.
		ingredients = { {"firearm-magazine", 20}, },
	},

	{
		technology = "logistics",
		ingredients = { {"transport-belt", 10}, },
	},

	{
		technology = "steel-axe",
		ingredients = { {"steel-plate", 10}, },
	},

	{
		technology = "fast-inserter",
		ingredients = { {"inserter", 50}, },
	},

	-- GREEN SCIENCE
	-- Inserters, circuits (by proxy), and belts. Only the circuits are interesting.

	{
		technology = "advanced-material-processing",
		ingredients = { {"steel-plate", 10}, }
	},

	{
		technology = "engine",
		ingredients = { {"steel-plate", 50}, },
	},

	{
		technology = "automation",
		ingredients = { {"assembling-machine-2", 50}, },
	},

	{
		technology = "solar-energy",
		ingredients = { {"steel-plate", 10}, },
	},

	{
		technology = "electric-energy-distribution-1",
		ingredients = { {"steel-plate", 10}, },
	},

	{
		technology = "military-2",
		ingredients = { {"firearm-magazine", 100}, {"steel-plate", 10}, },
	},

	-- Automobilism uses engines, but you only need a small number of cars,
	-- so I feel like this is a tech like "toolbelt"

	-- Fluid Handling would take engines, but the tanks and barrels are
	-- more important than pumps.

	{
		technology = "gates",
		ingredients = { {"stone-wall", 50}, },
	},

	{
		technology = "railway",
		ingredients = { {"engine-unit", 10}, },
	},

	{
		technology = "oil-processing",
		ingredients = { {"empty-barrel", 50}, },
	},

	{
		technology = "automated-rail-transportation",
		ingredients = { {"rail", 200}, {"locomotive", 1}, },
	},

	{
		technology = "fluid-wagon",
		ingredients = { {"storage-tank", 9}, {"cargo-wagon", 3}, },
	},

	{
		technology = "plastics",
		ingredients = { {"petroleum-gas-barrel", 10}, },
	},

	{
		technology = "sulfur-processing",
		ingredients = { {"petroleum-gas-barrel", 10}, },
	},

	{
		technology = "advanced-electronics",
		-- The electronic circuits are here for lore purposes.
		ingredients = { {"plastic-bar", 10}, {"electronic-circuit", 50}, }
	},

	{
		technology = "battery",
		ingredients = { {"sulfuric-acid-barrel", 10}, },
	},

	{
		technology = "explosives",
		ingredients = { {"sulfur", 10}, },
	},

	{
		technology = "flammables",
		ingredients = { {"crude-oil-barrel", 10}, },
	},

	{
		technology = "stack-inserter",
		ingredients = { {"advanced-circuit", 10}, {"fast-inserter", 50}, },
	},

	{
		technology = "modules",
		ingredients = { {"advanced-circuit", 50}, },
	},

	{
		technology = "electric-energy-accumulators",
		ingredients = { {"battery", 20}, },
	},

	{
		technology = "cliff-explosives",
		ingredients = { {"explosives", 50}, },
	},

	{
		technology = "solar-panel-equipment",
		ingredients = { {"solar-panel", 10}, {"advanced-circuit", 10}, {"modular-armor", 1}, },
	},

	{
		technology = "battery-equipment",
		ingredients = { {"battery", 10}, },
	},

	-- MILITARY SCIENCE
	-- Walls, grenades, and piercing rounds
	-- Almost all techs are already using products that are expected to be in
	-- the factory from prior investigations. Not much to add here. Probably
	-- for the best.

	{
		technology = "land-mine",
		ingredients = { {"explosives", 10}, },
	},

	{
		technology = "rocketry",
		ingredients = { {"explosives", 10}, },
	},

	-- CHEMICAL SCIENCE
	-- Engines, advanced circuits, and sulfur.

	{
		technology = "uranium-processing",
		ingredients = { {"concrete", 200}, },
	},

	-- {
	-- 	technology = "advanced-electronics",
	-- 	ingredients = { {"sulfuric-acid-barrel", 10}, },
	-- },

	{
		technology = "laser",
		ingredients = { {"battery", 100}, },
	}
}