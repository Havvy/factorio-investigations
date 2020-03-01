local investigation_lab = table.deepcopy(data.raw.lab["lab"])

investigation_lab.name = "investigation-lab"
investigation_lab.flags = {"placeable-player", "player-creation", "no-automated-item-removal", "no-automated-item-insertion"}
investigation_lab.max_health = 10000
investigation_lab.minable = {mining_time = 0.2, result = "investigation-lab"}
investigation_lab.inputs = {}

local investigation_lab_item = table.deepcopy(data.raw.item["lab"])
investigation_lab_item.name = "investigation-lab"
investigation_lab_item.place_result = "investigation-lab"

data:extend({investigation_lab, investigation_lab_item})