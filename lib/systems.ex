defmodule Systems do
  @moduledoc """
  Provices systems for an Entity Component System
  """
  defmodule Movement do
    def run(entities_map) do
      Enum.reduce(entities_map, entities_map, &update/2)
    end
    def update({entity_id, entity}, entities_map) do

      velocity = entity |> Entity.get_component(:velocity)
      displacement = entity |> Entity.get_component(:displacement)
      orientation = entity |> Entity.get_component(:orientation)

      cond do

        is_nil(velocity) or is_nil(displacement) or is_nil(orientation) ->
          entities_map

        true ->

          displacement_vec = displacement.displacement

          velocity_vec = velocity.velocity

          angle = orientation.angle

          {x, y, z} = velocity_vec
          velocity_vec = {x, y, z, 1}

          rot = Graphmath.Mat44.make_rotate_y(angle)

          go_vec = Graphmath.Mat44.apply(rot, velocity_vec)

          {xd, yd, zd, _} = go_vec

          {x, y, z} = displacement_vec

          displacement_vec = {x + xd, y + yd, z + zd}

          displacement = displacement |> Component.Displacement.set(displacement_vec)

          entity = entity
          |> Entity.update_component(displacement)

          %{ entities_map | entity_id => entity }
      end
    end
  end


  defmodule IntentToAction do
    def run(entities_map) do
      Enum.reduce(
        entities_map, entities_map, &Systems.IntentToAction.update/2)
    end

    def update({entity_id, entity}, entities_map) do
      
      speed = 1

      case entity |> Entity.has_component?(:controllable) do
        
        false -> entities_map

        true ->
          controllable = entity |> Entity.get_component(:controllable)
          velocity = entity |> Entity.get_component(:velocity)

          z = 
            case controllable.frontal_movement do
              :forward -> speed
              :backward -> -speed
              nil -> 0
            end

          x =
            case controllable.lateral_movement do
              :left -> speed
              :right -> -speed
              nil -> 0
            end

          velocity = Component.Velocity.set(velocity, {x, 0, z})

          entity = entity |> Entity.update_component(velocity)

          orientation = entity |> Entity.get_component(:orientation)

          orientation = orientation |> Component.Orientation.set_angle(controllable.angle)

          entity = entity |> Entity.update_component(orientation)

          %{ entities_map | entity_id => entity }
      end

    end
  end

  defmodule Networked do

    def run(entities) do
      receive do

        {:command, command, data, entity_id, _} ->

          entity = Map.fetch!(entities, entity_id)

          compo = entity |> Entity.get_component(:controllable)

          component =
            case command do
              :forward ->
                Component.Controllable.move_forward(compo)

              :backward ->
                Component.Controllable.move_backward(compo)

              :left ->
                Component.Controllable.move_left(compo)

              :right ->
                Component.Controllable.move_right(compo)

              :stop_frontal ->
                compo |> Component.Controllable.stop_moving_frontally

              :stop_lateral ->
                compo |> Component.Controllable.stop_moving_laterally

              :turn ->
                angle = data
                compo |> Component.Controllable.set_angle(angle)
            end

          entity = entity |> Entity.update_component(component)

          entities = Map.put(entities, entity_id, entity)

          # record which entities have been updated!
      after
        0 -> entities
      end
    end
  end
end
