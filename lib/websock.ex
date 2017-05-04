defmodule Websock do
  defmodule Server do
    def start_link(pid, port) do
      Task.start_link(fn -> loop(pid, Socket.Web.listen!(port)) end)
    end

    def loop(pid, server) do
      client = Socket.Web.accept!(server)
      send pid, {:new_client, client}
      loop(pid, server)
    end
  end

  defmodule ClientListener do
    def start_link(pid, client) do
      Task.start_link(fn -> loop(pid, client) end)
    end

    def loop(pid, client) do
      msg = Socket.Web.recv!(client)
      send pid, {:msg_from_client, msg}
      loop(pid, client)
    end
  end

  defmodule ClientMessage do
    defstruct [:type]
  end

  defmodule Client do
    def start_link(pid, client, entity_id) do
      Task.start_link(fn -> init(pid, client, entity_id) end)
    end

    def init(pid, client, entity_id) do
      ClientListener.start_link(self(), client)
      loop(pid, client, entity_id)
    end

    def loop(pid, client, entity_id) do
      receive do
        {:msg_from_client, {:text, msg}} ->
          IO.puts "message from client: #{msg}"
          client_msg = Poison.decode!(msg, as: %ClientMessage{})

          case client_msg.type do
            "forward" ->
              send pid, {:command, :forward, entity_id, self()}

            "backward" ->
              send pid, {:command, :backward, entity_id, self()}

            "left" ->
              send pid, {:command, :left, entity_id, self()}

            "right" ->
              send pid, {:command, :right, entity_id, self()}

            "stop_frontal" ->
              send pid, {:command, :stop_frontal, entity_id, self()}

            "stop_lateral" ->
              send pid, {:command, :stop_lateral, entity_id, self()}
          end

        {:status_info, response} ->
          {:ok, status_as_json} = Poison.encode(response)
          Socket.Web.send! client, {:text, status_as_json}

      end

      loop(pid, client, entity_id)
    end
  end
end
