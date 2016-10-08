local p = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"])
p.name = "assembling-machine-dynamic"
p.minable.result = "assembling-machine-dynamic"

data:extend{p}
