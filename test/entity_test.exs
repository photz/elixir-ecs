defmodule EntityTest do
  use ExUnit.Case
  doctest Entity

  test "creating a new entity" do
    entity = Entity.new
    assert Enum.empty?(Map.keys(entity.components))
  end

  test "adding a component to an entity" do
    import Component
    component = Component.Displacement.new(10, 4, 2)
    entity = Entity.new |> Entity.add_component(component)
    assert Entity.has_component?(entity, :displacement)
  end

  test "removing a component" do
    import Component
    component = Component.Displacement.new(40, 3, 12)
    entity = Entity.new
    |> Entity.add_component(component)
    |> Entity.remove_component(component)
    refute Entity.has_component?(entity, :displacement)
  end

  test "updating a component" do
    import Component
    component = Component.Displacement.new(2, 2, 0)
    entity = Entity.new |> Entity.add_component(component)
    component = Component.Displacement.new(3, 3, 1)
    entity = Entity.update_component(entity, component)
    assert Entity.get_component(entity, :displacement).x == 3
  end
end
