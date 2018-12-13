defmodule ListUserMiner do
  @moduledoc false
  use GenServer

  def start_link(arg) do
    user_list = User.create_user_list(200)
    miner_list = Miner.create_miner_list(50)
    Miner.update_other_miner(miner_list)

    initState =
      Enum.reduce(user_list, %{}, fn pid, acc ->
        {_, _, pubKey} = User.get_user_information(pid)
        Map.put(acc, Base.encode64(pubKey), 100)
      end)

    Miner.initialState(miner_list, initState)

    # user, miner, transaction, block, time
    GenServer.start_link(__MODULE__, {user_list, miner_list, 0, 0, :os.system_time(:millisecond)}, name: :list)
  end

  def getUserMinerList() do
    GenServer.call(:list, :getUserMiner)
  end

  def handle_call(:getUserMiner, _from, state) do
    {user_list, miner_list, _, _, _} = state
    {:reply, {user_list, miner_list}, state}
  end

  def handle_call(:updateTx, _from, state) do
    {user_list, miner_list, noTx, noBlock, time} = state
    {:reply, :ok, {user_list, miner_list, noTx + 1, noBlock, time}}
  end

  def handle_call(:updateBlock, _from, state) do
    {user_list, miner_list, noTx, noBlock, time} = state
    {:reply, :ok, {user_list, miner_list, noTx, noBlock + 1, time}}
  end

  def handle_call(:getInfo, _from, state) do
    {_, _, noTx, noBlock, time} = state
    {:reply, {noTx, noBlock, time}, state}
  end



  def updateTx() do
    GenServer.call(:list, :updateTx)
  end

  def updateBlock() do
    GenServer.call(:list, :updateBlock)
  end

  def getInfo() do
    GenServer.call(:list, :getInfo)
  end
end
