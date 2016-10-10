local entity = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"])
entity.name = "assembling-machine-dynamic"
entity.minable.result = "assembling-machine-dynamic"
data:extend{entity}

local entity = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"])
entity.name = "assembling-machine-dynamic-2"
entity.minable.result = "assembling-machine-dynamic-2"
data:extend{entity}

local entity = table.deepcopy(data.raw["assembling-machine"]["chemical-plant"])
entity.name = "chemical-plant-dynamic"
entity.minable.result = "chemical-plant-dynamic"
data:extend{entity}
