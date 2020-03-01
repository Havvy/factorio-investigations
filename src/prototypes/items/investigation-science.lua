-- This is a psuedo-item that exists for the purpose of showing
-- an icon on the research screen for the psuedo-investigation
-- technologies.
--
-- Because technology research items must be tools in the current
-- version of Factorio, this item is also a tool.
local investigation_required = {
    type = "tool",
    name = "investigation-required",
    icon = "__base__/graphics/icons/automation-science-pack.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "science-pack",
    order = "a[investigation-science-pack]",
    stack_size = 500,
    durability = 1,
}

data:extend({ investigation_required })