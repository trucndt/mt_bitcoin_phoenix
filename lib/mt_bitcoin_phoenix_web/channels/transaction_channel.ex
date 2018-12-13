defmodule MtBitcoinPhoenixWeb.TransactionChannel do
  use MtBitcoinPhoenixWeb, :channel

  def join("transaction:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (transaction:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    IO.puts("something")

    {user_list, miner_list} = ListUserMiner.getUserMinerList()
    IO.inspect(user_list)
    IO.inspect(miner_list)

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
