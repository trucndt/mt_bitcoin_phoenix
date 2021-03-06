defmodule Miner do
  def start_node() do
    {:ok, pid} = GenServer.start_link(__MODULE__, :ok, [])
    pid
  end

  def init(:ok) do
    # {Miner number, ledger, new transaction, other miners, sub miner, curState, tempState}
    {:ok, {0, nil, nil, nil, nil, %{},%{}}}
  end

  # Miners
  def create_miner_list(num_miner) do
    Enum.map(1..num_miner, fn miner_id ->
      pid = Miner.start_node()
      Miner.setting_miner_init(pid, miner_id)
      pid
    end)
  end

  def setting_miner_init(pid, miner_id) do
    GenServer.call(pid, {:setting_miner_init, miner_id})
  end

  def update_other_miner(miner_list) do
    Enum.each(miner_list, fn pid ->
      GenServer.call(pid, {:update_other_miner, miner_list})
    end)
  end

  def initialState(miner_list, initState) do
    Enum.each(miner_list, fn pid ->
      GenServer.call(pid, {:init_state, initState})
    end)
  end

  defp parseTx(tx) do
    from = String.slice(tx, 0, 88)
    to = String.slice(tx, 88, 88)
    amt = String.slice(tx, 176, String.length(tx) - 176) |> String.to_integer()
    {from, to, amt}
  end

  # Miner Mining
  def miner_mining(miner_list) do
    Enum.each(miner_list, fn pid ->
      GenServer.call(pid, {:miner_mining})
    end)
  end

  # Handle transaction
  def handle_call({:transaction, message, signature, public_key}, _from, state) do
    {id, ledger, tx, miner_list, sub_miner, curState, tempState} = state
    # This the condition on the message
    {from, _, _amt} = parseTx(message)

    if Crypto.verify(message, signature, public_key) do

      tempState_m =
        Enum.reduce([message], tempState, fn i, acc ->
          {from_m, to_m, amt_m} = parseTx(i)
          temp = Map.put(acc, from_m, acc[from_m] - amt_m)
          Map.put(temp, to_m, temp[to_m] + amt_m)
        end)

      if tempState_m[from] >= 0 do
        new_tx = tx ++ [message]
        {:reply, :ok, {id, ledger, new_tx, miner_list, sub_miner, curState, tempState_m}}
      else
        {:reply, :ok, {id, ledger, tx, miner_list, sub_miner, curState, tempState}}
      end
    else
      {:reply, :ok, {id, ledger, tx, miner_list, sub_miner, curState, tempState}}
    end
  end

  def handle_call({:setting_miner_init, miner_id}, _from, _state) do
    {:reply, :ok, {miner_id, [], [], [], nil, %{}, %{} }}
  end

  def handle_call({:update_other_miner, miner_list}, _from, state) do
    {id, ledger, tx, _list, sub_miner, curState, tempState} = state
    {:reply, :ok, {id, ledger, tx, miner_list, sub_miner, curState, tempState}}
  end

  def handle_call({:init_state, initState}, _from, state) do
    {id, ledger, tx, miner_list, sub_miner, _, _} = state
    {:reply, :ok, {id, ledger, tx, miner_list, sub_miner, initState, initState}}
  end

  def handle_call({:get_miner_information}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:getBalance}, _from, state) do
    {_, _, _, _, _, curState,_} = state
    {:reply, curState, state}
  end

  def handle_call({:miner_mining}, _from, state) do
    {id, ledger, tx, miner_list, _, curState, tempState} = state
    sub_pid = Miner.start_node()
    GenServer.cast(sub_pid, {:only_mining, self(), 3})
    {:reply, :ok, {id, ledger, tx, miner_list, sub_pid, curState, tempState}}
  end

  def handle_call({:mining_result, result, k}, _from, state) do
    {id, ledger, tx, miner_list, _sub_pid, curState, _tempState} = state
    block = tx ++ [result]
    ledger = ledger ++ [block]

    # Update state
    curState =
      Enum.reduce(tx, curState, fn i, acc ->
        {from, to, amt} = parseTx(i)
        temp = Map.put(acc, from, acc[from] - amt)
        Map.put(temp, to, temp[to] + amt)
      end)
    tempState = curState

    if tx == [] do
      {:reply, :ok, state}
    else
      Enum.each(List.delete(miner_list, self()), fn pid ->
        GenServer.cast(pid, {:inform_result, result, k})
      end)

      {:reply, :ok, {id, ledger, [], miner_list, [], curState, tempState}}
    end
  end

  def handle_cast({:inform_result, result, k}, state) do
    {id, ledger, tx, miner_list, _, curState, _tempState} = state
    # {tx,proof_of_work} = result
    if tx == [] do
      {:noreply, state}
    else
      prev_hash = Miner.prev_hash(ledger)
      tx_string = Enum.join([prev_hash] ++ tx)

      temp = :crypto.hash(:sha256, tx_string <> result) |> Base.encode16()
      # IO.inspect(temp)
      new_state =
        if(String.slice(temp, 0, k) === String.duplicate("0", k)) do
          block = tx ++ [result]
          ledger = ledger ++ [block]

          # Update state
          curState =
            Enum.reduce(tx, curState, fn i, acc ->
              {from, to, amt} = parseTx(i)
              temp = Map.put(acc, from, acc[from] - amt)
              Map.put(temp, to, temp[to] + amt)
            end)
          tempState = curState

          {id, ledger, [], miner_list, [], curState, tempState}
        else
          state
        end

      {:noreply, new_state}
    end
  end

  def handle_cast({:only_mining, pid, k}, state) do
    result = Miner.mining(k, pid)

    if result == :no_need_to_compute do
      {:noreply, state}
    else
      GenServer.call(pid, {:mining_result, result, k})
      {:noreply, state}
    end
  end

  def mining(k, pid) do
    {_, ledger, tx, _miner_list, _sub_pid, _,_} = Miner.get_miner_information(pid)

    if tx == [] do
      # {:no_need_to_compute, :nil}
      :no_need_to_compute
    else
      prev_hash = Miner.prev_hash(ledger)
      tx_string = Enum.join([prev_hash] ++ tx)
      trial = Miner.randomizer()
      temp = :crypto.hash(:sha256, tx_string <> trial) |> Base.encode16()

      if(String.slice(temp, 0, k) === String.duplicate("0", k)) do
        # {_,result} = Base.decode16(trial)
        # IO.inspect(result)
        # IO.inspect(trial)
        #        IO.puts("The result came from machine #{id}")
        # {[prev_hash] ++ tx,result}
        # result
        trial
      else
        Miner.mining(k, pid)
      end
    end
  end

  def randomizer() do
    :crypto.strong_rand_bytes(10) |> Base.encode16()
  end

  def prev_hash(ledger) do
    if ledger == [] do
      :crypto.hash(:sha, "whatever")
    else
      last_block = List.last(ledger)
      block_string = Enum.join(last_block)
      :crypto.hash(:sha, block_string)
    end
  end

  # Get miner information
  def get_miner_information(pid) do
    GenServer.call(pid, {:get_miner_information})
  end

  def get_list_information(miner_list) do
    Enum.map(miner_list, fn pid -> Miner.get_miner_information(pid) end)
  end

  def getBalance(pid) do
    GenServer.call(pid, {:getBalance})
  end
end
