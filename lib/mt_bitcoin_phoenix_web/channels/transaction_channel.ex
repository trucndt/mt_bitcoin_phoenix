defmodule MtBitcoinPhoenixWeb.TransactionChannel do
  use MtBitcoinPhoenixWeb, :channel

  def join("transaction:lobby", payload, socket) do
    if authorized?(payload) do
      send(self, :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    {user_list, _} = ListUserMiner.getUserMinerList()
    {_, _, myPub} = User.get_user_information(Enum.at(user_list, 0))
    push socket, ":join", %{myPub: Base.encode64(myPub)}
    {:noreply, socket}
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
    IO.puts("something #{payload["receiver"]}, #{payload["btc"]}")
    toId = String.to_integer(payload["receiver"])
    btc = String.to_integer(payload["btc"])

    {user_list, miner_list} = ListUserMiner.getUserMinerList()
    User.transaction(Enum.at(user_list, 0), miner_list, Enum.at(user_list, toId), btc)

    {_, _, pubFrom} = User.get_user_information(Enum.at(user_list, 0))

    push socket, "new:tx", %{from: Base.encode64(pubFrom), to: payload["receiver"], amt: payload["btc"]}

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
