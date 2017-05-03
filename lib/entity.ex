defmodule Entity do
  @moduledoc """
  A module for working with entities in an Entity Component System
  """


  @enforce_keys [:id]
  defstruct [:id, components: %{}]



  defp components_to_map(components) do
    components_to_map(components, %{})
  end
  defp components_to_map([], m) do
    m
  end
  defp components_to_map([component|components], m) do
    m = Map.put_new(m, component.name, component)
    components_to_map(components, m)
  end

  @doc """
  Creates a new entity without any components
  """
  def new(components \\ []) do
    components_map = components_to_map(components)

    %Entity{id: 123, components: components_map}
  end

  @doc """
  Adds a new component to an entity
  """
  def add_component(entity, component) do
    components = Map.put(entity.components, component.name, component)
    %Entity{id: entity.id, components: components}
  end

  @doc """
  Removes a component from an entity
  """
  def remove_component(entity, component) do
    components = Map.delete(entity.components, component.name)
    %Entity{id: entity.id, components: components}
  end

  @doc """
  Returns a boolean indicating whether an entity has the given component
  """
  def has_component?(entity, component_name) do
    Map.has_key?(entity.components, component_name)
  end

  def get_component(entity, component_name) do
    Map.get(entity.components, component_name)
  end

  def update_component(entity, component) do
    components = entity.components
    components = %{ components | component.name => component }
    %Entity{id: entity.id, components: components}
  end
end
