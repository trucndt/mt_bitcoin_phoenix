defmodule User do
  def start_node() do
    {:ok, pid} = GenServer.start_link(__MODULE__, :ok, [])
    pid
  end

  def init(:ok) do
    # {User number, private key, public key}
    {:ok, {0, nil, nil}}
  end

  # Create user list
  def create_user_list(num_user) do
    Enum.map(1..num_user, fn user_id ->
      pid = User.start_node()
      User.setting_user_init(pid, user_id)
      pid
    end)
  end

  def setting_user_init(pid, user_id) do
    GenServer.call(pid, {:setting_user_init, user_id})
  end

  def handle_call({:setting_user_init, user_id}, _from, _state) do
    {public_key, private_key} = Crypto.generate_keys()
    {:reply, :ok, {user_id, private_key, public_key}}
  end

  def handle_call({:get_user_information}, _from, state) do
    {:reply, state, state}
  end

  # Transaction
  #  def transaction(user_list,miner_list,to,amt) do
  #    sender = Enum.random(user_list)
  #    {_id, private_key, public_key} = User.get_user_information(sender)
  #    # This is the message
  #    message = Base.encode64(public_key) <> to <> Integer.to_string(amt)
  #    signature = Crypto.sign(message, private_key)
  #    User.broadcast(message, signature, public_key, miner_list)
  #    :ok
  #  end

  def transaction(sender, miner_list, toId, amt) do
    {_id, private_key, public_key} = User.get_user_information(sender)
    {_, _, pubTo} = User.get_user_information(toId)
    # This is the message
    message = Base.encode64(public_key) <> Base.encode64(pubTo) <> Integer.to_string(amt)
    signature = Crypto.sign(message, private_key)
    User.broadcast(message, signature, public_key, miner_list)
    :ok
  end

  def transactionToKey(sender, miner_list, pubTo, amt) do
    {_id, private_key, public_key} = User.get_user_information(sender)
    # This is the message
    message = Base.encode64(public_key) <> Base.decode64(pubTo) <> Integer.to_string(amt)
    signature = Crypto.sign(message, private_key)
    User.broadcast(message, signature, public_key, miner_list)
    :ok
  end

  # Broadcast to miner
  def broadcast(message, signature, public_key, miner_list) do
    Enum.each(miner_list, fn pid ->
      GenServer.call(pid, {:transaction, message, signature, public_key})
    end)
  end

  # Get user information
  def get_user_information(pid) do
    GenServer.call(pid, {:get_user_information})
  end

  def get_list_information(user_list) do
    Enum.map(user_list, fn pid -> User.get_user_information(pid) end)
  end
end
