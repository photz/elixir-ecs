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

      cond do

        is_nil(velocity) or is_nil(displacement) ->
          entities_map


        true ->

          displacement = %{ displacement |
                            :x => displacement.x + velocity.x,
                            :y => displacement.y + velocity.y,
                            :z => displacement.z + velocity.z }
                            
          entity = entity |> Entity.update_component(displacement)

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

          x = 
            case controllable.frontal_movement do
              :forward -> speed
              :backward -> -speed
              nil -> 0
            end

          y =
            case controllable.lateral_movement do
              :left -> speed
              :right -> -speed
              nil -> 0
            end

          velocity = %{ velocity | :x => x, :y => y }

          entity = entity |> Entity.update_component(velocity)

          %{ entities_map | entity_id => entity }
      end

    end
  end

  defmodule Networked do

    def run(entities) do
      receive do

        {:command, command, entity_id, _} ->

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
