import Logger

defmodule ElixirEcs do
  use Application

  @moduledoc """
  Documentation for ElixirEcs.
  """

  @doc """
  Test
  """
  def start(_type, _args) do
    
    port = get_port(3000)

    Logger.info "running on port #{port}"
    
    case Websock.Server.start_link(self(), port) do
      {server_pid, :ok} ->
        Logger.debug "Server running with PID #{port}"

      _ ->
        Logger.debug "unable to run server"
    end

    ElixirEcs.loop(0, %{})

    Supervisor.start_link [], strategy: :one_for_one

  end

  def loop(entity_count, entities, clients \\ [], prev_time \\ nil) do
    #Logger.info "got #{length(Map.keys(entities))} entities"

    {entity_count, entities, clients} =
      receive do
      {:new_client, new_client_sock} ->
        Logger.info "got a new client"

        Socket.Web.accept! new_client_sock

        entity_id = entity_count

        {:ok, client_pid} = Websock.Client.start_link(
          self(), new_client_sock, entity_id)

        entity = Component.create_player_entity(entity_id)

        {
          entity_count + 1,
          Map.put(entities, entity_id, entity),
          [client_pid | clients]
        }

    after 1_000 ->
        {entity_count, entities, clients}
    end

    prev_time = if is_integer(prev_time),
      do: prev_time,
      else: System.system_time(:microsecond)

    time = System.system_time(:microsecond)
             
    time_elapsed = time - prev_time

    entities = entities
    |> Systems.Networked.run(time_elapsed)
    |> Systems.IntentToAction.run(time_elapsed)
    |> Systems.Movement.run(time_elapsed)

    broadcast_state(clients, entities)

    loop(entity_count, entities, clients, time)
  end

  def broadcast_state([client|clients], entities) do
    send client, {:state_update, entities}
    broadcast_state(clients, entities)
  end
  def broadcast_state([], entities) do
  end

  defp get_port(default_port) do
    env_var_name = "PORT"

    try do
      case System.get_env(env_var_name) do
        nil ->
          Logger.debug "environment variable #{env_var_name} not set, default to port #{default_port}"
          default_port
        value ->
          {p, _} = value |> Integer.parse
          p
      end
    rescue
      MatchError ->
        Logger.warn "incorrect port, using #{default_port} instead"
        default_port
    end
  end

end
