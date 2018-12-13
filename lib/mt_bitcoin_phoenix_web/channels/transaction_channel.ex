defmodule MtBitcoinPhoenixWeb.TransactionChannel do
  use MtBitcoinPhoenixWeb, :channel

  def join("transaction:lobby", payload, socket) do
    if authorized?(payload) do
      send(self, :after_join)
      :timer.send_interval(2000, :tx)
      :timer.send_interval(10000, :mining)
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

  def handle_info(:mining, socket) do
    {_, miner_list} = ListUserMiner.getUserMinerList()
    Miner.miner_mining(miner_list)
    push socket, ":mining", %{status: "Mined"}
    {:noreply, socket}
  end

  def handle_info(:tx, socket) do
    {user_list, miner_list} = ListUserMiner.getUserMinerList()
    send = Enum.at(user_list, Enum.random(1..length(user_list)-1))
    rcv = Enum.random(user_list)

    if send == rcv do

    else
      amt = :rand.uniform(50)
      User.transaction(send, miner_list, rcv, amt)

      {_, _, pubFrom} = User.get_user_information(send)
      {_, _, pubTo} = User.get_user_information(rcv)

      push socket, "new:tx", %{from: Base.encode64(pubFrom), to: Base.encode64(pubTo), amt: amt}
    end

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
