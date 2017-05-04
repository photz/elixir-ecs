defmodule Component do
  @moduledoc """
  A module for working with components in an Entity Component System
  """

  def create_player_entity(entity_id) do
    import Entity, only: [add_component: 2]
    Entity.new(entity_id)
    |> add_component(Component.Displacement.new(0, 0, 0))
    |> add_component(Component.Velocity.new(0, 0, 0))
    |> add_component(Component.Controllable.new)
  end

  defmodule Displacement do
    def new(x, y, z) do
      %{:name => :displacement, :x => x, :y => y, :z => z}
    end
  end

  defmodule Velocity do
    def new(x, y, z) do
      %{:name => :velocity, :x => x, :y => y, :z => z}
    end
    def move_forward(velocity) do
      %{ velocity | :x => 1 }
    end
    def stop_moving_forward(velocity) do
      %{ velocity | :x => 0 }
    end
  end

  defmodule Controllable do
    def new do
      %{
        name: :controllable,
        frontal_movement: nil,
        lateral_movement: nil
      }
    end
    def moving_forward?(component) do
      component.forward_movement == :forward
    end
    def moving_backward?(component) do
      component.backward_movement == :backward
    end
    def move_forward(component) do
      Map.put(component, :frontal_movement, :forward)
    end
    def move_backward(component) do
      Map.put(component, :frontal_movement, :backward)
    end
    def move_left(component) do
      Map.put(component, :lateral_movement, :left)
    end
    def moving_left?(component) do
      component.lateral_movement == :left
    end
    def moving_right?(component) do
      component.lateral_movement == :right
    end
    def move_right(component) do
      Map.put(component, :lateral_movement, :right)
    end
    def stop_moving_frontally(component) do
      Map.put(component, :frontal_movement, nil)
    end
    def stop_moving_laterally(component) do
      Map.put(component, :lateral_movement, nil)
    end
  end
end
