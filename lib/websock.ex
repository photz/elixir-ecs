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

  defmodule Client do
    def start_link(pid, client) do
      Task.start_link(fn -> init(pid, client) end)
    end

    def init(pid, client) do
      ClientListener.start_link(self(), client)
      loop(pid, client)
    end

    def loop(pid, client) do
      IO.puts "listening..."
      receive do
        {:msg_from_client, {:text, msg}} ->
          IO.puts "message from client: #{msg}"
          Socket.Web.send! client, {:text, ~s|{"bla":"boom"}|}
          

        {:status_info, response} ->
          {:ok, status_as_json} = Poison.encode(response)
          Socket.Web.send! client, {:text, status_as_json}

      end
      loop(pid, client)
    end
  end
end
