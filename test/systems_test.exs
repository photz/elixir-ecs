defmodule SystemTest do
  use ExUnit.Case
  doctest Systems

  test "applying a system to entities" do
    import Component
    import Entity

    displacement = Component.Displacement.new(0, 0, 0)
    velocity = Component.Velocity.new(1, 0, 0)

    entity = [displacement, velocity] |> Entity.new

    [entity | _] = Systems.Movement.run([entity])

    displacement_comp = Entity.get_component(entity, :displacement)

    assert displacement_comp.x == 1
  end
end
