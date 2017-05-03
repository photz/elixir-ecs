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

    ElixirEcs.loop([])

    Supervisor.start_link [], strategy: :one_for_one

  end

  def loop(entities) do
    Logger.info "got #{length(entities)} entities"

    receive do
      {:new_client, new_client_sock} ->
        Logger.info "got a new client"

        Socket.Web.accept! new_client_sock

        {:ok, client_pid} = Websock.Client.start_link(self(),
          new_client_sock)

        entity = Entity.new
        

        entities = [1 | entities]
    end

    loop(entities)
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
