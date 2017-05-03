defmodule Component do
  @moduledoc """
  A module for working with components in an Entity Component System
  """

  defmodule Displacement do
    def new(x, y, z) do
      %{:name => :displacement, :x => x, :y => y, :z => z}
    end
  end

  defmodule Velocity do
    def new(x, y, z) do
      %{:name => :velocity, :x => x, :y => y, :z => z}
    end
  end
end
