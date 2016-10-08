data:extend{
  {
    type = "technology",
    name = "assembling-machine-dynamic",
    icon = "__base__/graphics/technology/automation.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "assembling-machine-dynamic"
      }
    },
    prerequisites = { "circuit-network", "automation-2"},
    unit =
    {
      count = 50,
      ingredients = {{"science-pack-1", 1}, {"science-pack-2", 1}},
      time = 30
    },
    order = "a-b-c"
  },
}
