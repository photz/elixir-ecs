defmodule Component do
  @moduledoc """
  A module for working with components in an Entity Component System
  """

  def create_player_entity(entity_id) do
    import Entity, only: [add_component: 2]
    Entity.new(entity_id)
    |> add_component(Component.Displacement.new)
    |> add_component(Component.Velocity.new)
    |> add_component(Component.Controllable.new)
    |> add_component(Component.Orientation.new)
  end

  defmodule Orientation do
    def new do
      %{:name => :orientation, :angle => 0}
    end
    def set_angle(component, angle) do
      %{ component | :angle => angle }
    end
  end

  defmodule Displacement do
    def new do
      displacement = Graphmath.Vec3.create()
      %{:name => :displacement, :displacement => displacement}
    end
    def set(displacement, vec) do
      %{ displacement | :displacement => vec }
    end
  end

  defmodule Velocity do
    def new do
      velocity = Graphmath.Vec3.create()
      %{:name => :velocity, :velocity => velocity}
    end
    def move_forward(velocity) do
      {x, y, z} = velocity.velocity
      %{ velocity | :velocity => {x, y, 1} }
    end
    def stop_moving_forward(velocity) do
      {x, y, z} = velocity
      %{ velocity | :velocity => {x, y, 0} }
    end
    def set(velocity, vec) do
      %{ velocity | :velocity => vec }
    end
  end

  defmodule Controllable do
    def new do
      %{
        name: :controllable,
        frontal_movement: nil,
        lateral_movement: nil,
        angle: 0.0
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
    def set_angle(component, angle) do
      Map.put(component, :angle, angle)
    end
  end
end
