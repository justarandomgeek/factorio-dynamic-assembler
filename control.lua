local crc32 = require('crc32')

local function get_signal_value(control,signal)
	local val=0

	local network = control.get_circuit_network(defines.wire_type.red)
	if network then
	  val = val + network.get_signal(signal)
	end

	network = control.get_circuit_network(defines.wire_type.green)
	if network then
	  val = val + network.get_signal(signal)
	end

  return val
end

local function onTick()
  if global.dynamic_assemblers ~= nil then
    if not global.dynamic_assemblers[global.tickIndex] then
      global.tickIndex = nil
    end

    global.tickIndex,data = next(global.dynamic_assemblers,global.tickIndex)

    if data then
      if data.assembler.valid and data.control.valid then

        -- if signal-S is set, assign that recipe
        local set = get_signal_value(data.control,{name="signal-S",type="virtual"})
        if set == -1 then
          data.assembler.recipe=nil
        elseif set ~= 0 then
          local recipe = global.recipemap[set]
          if recipe then
            data.assembler.recipe = recipe
          end
        end

        -- Output the current recipe on signal-R
        local rid = 0
        if data.assembler.recipe and data.assembler.recipe.valid then
          --game.players[1].print("recipe: "..data.assembler.recipe.name)
          rid = global.recipemap[data.assembler.recipe.name] or 0
          --game.players[1].print("rid: " .. rid)
        end
        data.control.parameters={enabled=true,parameters={
          {index=1,count=rid,signal={name="signal-R",type="virtual"}}
        }}
      elseif data.assembler.valid and data.combinator.valid then
        data.control = data.combinator.get_or_create_control_behavior()
        global.dynamic_assemblers[index] = data
      else
        -- delete whatever's left
        if data.assembler and data.assembler.valid then
          data.assembler.destroy()
        end
        if data.combinator and data.combinator.valid then
          data.combinator.destroy()
        end
        table.remove(global.dynamic_assemblers, global.tickIndex )
      end
    end
  end
end

local function onBuilt(event)
  local entity = event.created_entity
  if entity.name == "assembling-machine-dynamic" then
    local combinatorpos = {entity.position.x+2,entity.position.y}

    local combinator = entity.surface.find_entity("constant-combinator",combinatorpos)

    if not combinator then
      local ghost = entity.surface.find_entity("entity-ghost", combinatorpos)
      if ghost.valid and ghost.ghost_name == "constant-combinator" then
        _,combinator = ghost.revive()
      end
    end

    if not combinator then
      combinator = entity.surface.create_entity{
        name="constant-combinator",
        position = combinatorpos,
        force = entity.force
      }
    end


    combinator.operable=false
    combinator.minable=false
    combinator.destructible=false

    local control = combinator.get_or_create_control_behavior()

    local entData = {control = control, assembler=entity, combinator=combinator}
    global.dynamic_assemblers = global.dynamic_assemblers or {}
    table.insert(global.dynamic_assemblers,entData)
  end
end

local function recipe_id(recipe)
  local id = crc32.Hash(recipe)
  if id > 2147483647 then
    id = id - 4294967295
  end
  return id

end

local function reindex_recipes()
  local recipemap={}

  for recipe,_ in pairs(game.forces['player'].recipes) do
    local id = recipe_id(recipe)
    recipemap[recipe] = id
    recipemap[id] = recipe
  end

  game.write_file('recipemap.txt',serpent.block(recipemap,{comment=false}))
  global.recipemap = recipemap
end


script.on_event(defines.events.on_tick, onTick)
script.on_event(defines.events.on_built_entity, onBuilt)
script.on_event(defines.events.on_robot_built_entity, onBuilt)

script.on_init(function()
  -- Index recipes for new install
  reindex_recipes()
end
)

script.on_configuration_changed(function(data)
  -- when any mods change, reindex recipes to ensure that
  reindex_recipes()
end
)

remote.add_interface("dynamic_assembler",
	{
		reindex_recipes = reindex_recipes
	}
)
