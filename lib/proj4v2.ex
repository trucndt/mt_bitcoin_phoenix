defmodule Proj4v2 do
  def main(args) do
    [numUser, numMiner] = args

    numUser = String.to_integer(numUser)
    numMiner = String.to_integer(numMiner)

    {user_list, miner_list} = init(numUser, numMiner)

    User.transaction(Enum.at(user_list, 0), miner_list, Enum.at(user_list, 2), 1)
    User.transaction(Enum.at(user_list, 0), miner_list, Enum.at(user_list, 1), 2)
    User.transaction(Enum.at(user_list, 0), miner_list, Enum.at(user_list, 2), 3)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000)
    #

    User.transaction(Enum.at(user_list, 1), miner_list, Enum.at(user_list, 3), 4)
    # User.transaction(user_list,miner_list)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000)

    User.transaction(Enum.at(user_list, 1), miner_list, Enum.at(user_list, 3), 5)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000)

    User.transaction(Enum.at(user_list, 1), miner_list, Enum.at(user_list, 4), 6)
    User.transaction(Enum.at(user_list, 2), miner_list, Enum.at(user_list, 5), 7)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000)

    {_, ledger, _, _, _, _} = Miner.get_miner_information(List.first(miner_list))
    IO.inspect(ledger)
    balance = Miner.getBalance(List.first(miner_list))
    IO.inspect(balance)
  end

  def init(numUser, numMiner) do
    user_list = User.create_user_list(numUser)
    miner_list = Miner.create_miner_list(numMiner)
    Miner.update_other_miner(miner_list)

    initState =
      Enum.reduce(user_list, %{}, fn pid, acc ->
        {_, _, pubKey} = User.get_user_information(pid)
        Map.put(acc, Base.encode64(pubKey), 100)
      end)

    Miner.initialState(miner_list, initState)
    {user_list, miner_list}
  end
end
