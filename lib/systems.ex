defmodule Systems do
  @moduledoc """
  Provices systems for an Entity Component System
  """

  defmodule Movement do
    def run([]) do
      []
    end
    def run([entity|entities]) do
      import Entity

      if Entity.has_component?(entity, :displacement) and Entity.has_component?(entity, :velocity) do

        displacement = entity |> Entity.get_component(:displacement)
        velocity = entity |> Entity.get_component(:velocity)

        displacement = %{ displacement |
                          :x => displacement.x + velocity.x,
                          :y => displacement.y + velocity.y,
                          :z => displacement.z + velocity.z }

        entity = entity |> Entity.update_component(displacement)


        [entity | run(entities)]

      else
        [entity | run(entities)]
      end
      
    end
  end
end
