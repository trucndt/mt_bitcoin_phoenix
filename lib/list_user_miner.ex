defmodule ListUserMiner do
  @moduledoc false
  use GenServer

  def start_link(arg) do
    user_list = User.create_user_list(10)
    miner_list = Miner.create_miner_list(3)
    Miner.update_other_miner(miner_list)

    initState =
      Enum.reduce(user_list, %{}, fn pid, acc ->
        {_, _, pubKey} = User.get_user_information(pid)
        Map.put(acc, Base.encode64(pubKey), 100)
      end)

    Miner.initialState(miner_list, initState)

    GenServer.start_link(__MODULE__, {user_list, miner_list}, name: :list)
  end

  def getUserMinerList() do
    GenServer.call(:list, :getUserMiner)
  end

  def handle_call(:getUserMiner, _from, state) do
    {user_list, miner_list} = state
    {:reply, {user_list, miner_list}, state}
  end
end
