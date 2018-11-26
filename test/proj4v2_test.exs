defmodule Proj4v2Test do
  use ExUnit.Case
  doctest Proj4v2

  test "signing and verifying signature" do
    IO.puts("Test 1")
    {pub, pri} = Crypto.generate_keys
    msg = :crypto.strong_rand_bytes(10)
    signature = Crypto.sign(msg, pri)
    assert Crypto.verify(msg, signature, pub) == true
  end

  test "signing and verifying signature - negative" do
    IO.puts("Test 2")
    {pub, _} = Crypto.generate_keys
    msg = :crypto.strong_rand_bytes(10)
    signature = :crypto.strong_rand_bytes(10)
    assert Crypto.verify(msg, signature, pub) == false
  end

  test "Proof of Work" do
    IO.puts("Test 3")
    {user_list, miner_list} = Proj4v2.init(10, 5)

    User.transaction(Enum.at(user_list, 0),miner_list,Enum.at(user_list, 2),1)
    User.transaction(Enum.at(user_list, 0),miner_list,Enum.at(user_list, 1),2)
    User.transaction(Enum.at(user_list, 0),miner_list,Enum.at(user_list, 2),3)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000);
    #
    User.transaction(Enum.at(user_list, 1),miner_list,Enum.at(user_list, 3),4)
    # User.transaction(user_list,miner_list)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000);

    {_, ledger, _, _, _, _} = Miner.get_miner_information(List.first(miner_list))
    last_block = List.last(ledger)
    sec_last_block = List.last(List.delete(ledger, last_block))
    pow = Enum.at(last_block, 1)

    block_string = Enum.join(sec_last_block)
    prev_hash = :crypto.hash(:sha, block_string)

    tx = Enum.at(last_block, 0)
    t = [prev_hash] ++ [tx]
    tx_string = Enum.join(t)
    temp = :crypto.hash(:sha256, tx_string <> pow) |> Base.encode16
    k = 3
    assert String.slice(temp,0,k) === String.duplicate("0",k)
  end

  test "one valid transaction: 0->1 3 btc" do
    IO.puts("Test 4")
    {user_list, miner_list} = Proj4v2.init(10, 5)
    User.transaction(Enum.at(user_list, 0),miner_list,Enum.at(user_list, 1),3)
    Miner.miner_mining(miner_list)
    :timer.sleep(1000);

    balance = Miner.getBalance(List.first(miner_list))
    {_, _, public_key0} = User.get_user_information(Enum.at(user_list, 0))
    assert balance[Base.encode64(public_key0)] == 97
    {_, _, public_key1} = User.get_user_information(Enum.at(user_list, 1))
    assert balance[Base.encode64(public_key1)] == 103

    {_, ledger, _, _, _, _} = Miner.get_miner_information(List.first(miner_list))
    last_block = List.last(ledger)
    tx = Base.encode64(public_key0) <> Base.encode64(public_key1) <> Integer.to_string(3)
    assert tx in last_block
  end

  test "one invalid transaction: 0->1 300 btc" do
    IO.puts("Test 5")
    {user_list, miner_list} = Proj4v2.init(10, 5)
    User.transaction(Enum.at(user_list, 0),miner_list,Enum.at(user_list, 1),300)
    Miner.miner_mining(miner_list)
    :timer.sleep(1000);

    balance = Miner.getBalance(List.first(miner_list))
    {_, _, public_key0} = User.get_user_information(Enum.at(user_list, 0))
    assert balance[Base.encode64(public_key0)] == 100
    {_, _, public_key1} = User.get_user_information(Enum.at(user_list, 1))
    assert balance[Base.encode64(public_key1)] == 100
  end

  test "multiple independent transactions" do
    IO.puts("Test 6")
    {user_list, miner_list} = Proj4v2.init(10, 5)

    User.transaction(Enum.at(user_list, 0),miner_list,Enum.at(user_list, 1),1)
    User.transaction(Enum.at(user_list, 2),miner_list,Enum.at(user_list, 3),2)
    User.transaction(Enum.at(user_list, 4),miner_list,Enum.at(user_list, 5),3)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000);
    #
    User.transaction(Enum.at(user_list, 6),miner_list,Enum.at(user_list, 7),4)
    # User.transaction(user_list,miner_list)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000);

    User.transaction(Enum.at(user_list, 8),miner_list,Enum.at(user_list, 9),5)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000);

    balance = Miner.getBalance(List.first(miner_list))
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 0))
    assert balance[Base.encode64(public_key)] == 99
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 1))
    assert balance[Base.encode64(public_key)] == 101
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 2))
    assert balance[Base.encode64(public_key)] == 98
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 3))
    assert balance[Base.encode64(public_key)] == 102
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 4))
    assert balance[Base.encode64(public_key)] == 97
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 5))
    assert balance[Base.encode64(public_key)] == 103
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 6))
    assert balance[Base.encode64(public_key)] == 96
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 7))
    assert balance[Base.encode64(public_key)] == 104
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 8))
    assert balance[Base.encode64(public_key)] == 95
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 9))
    assert balance[Base.encode64(public_key)] == 105
  end


  test "multiple dependent transactions" do
    IO.puts("Test 7")
    {user_list, miner_list} = Proj4v2.init(10, 5)

    User.transaction(Enum.at(user_list, 0),miner_list,Enum.at(user_list, 2),1)
    User.transaction(Enum.at(user_list, 0),miner_list,Enum.at(user_list, 1),2)
    User.transaction(Enum.at(user_list, 0),miner_list,Enum.at(user_list, 2),3)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000);
    #
    User.transaction(Enum.at(user_list, 1),miner_list,Enum.at(user_list, 3),4)
    # User.transaction(user_list,miner_list)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000);

    User.transaction(Enum.at(user_list, 1),miner_list,Enum.at(user_list, 3),5)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000);

    User.transaction(Enum.at(user_list, 1),miner_list,Enum.at(user_list, 4),6)
    User.transaction(Enum.at(user_list, 2),miner_list,Enum.at(user_list, 5),7)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000);

    balance = Miner.getBalance(List.first(miner_list))
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 0))
    assert balance[Base.encode64(public_key)] == 94
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 1))
    assert balance[Base.encode64(public_key)] == 87
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 2))
    assert balance[Base.encode64(public_key)] == 97
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 3))
    assert balance[Base.encode64(public_key)] == 109
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 4))
    assert balance[Base.encode64(public_key)] == 106
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 5))
    assert balance[Base.encode64(public_key)] == 107
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 6))
    assert balance[Base.encode64(public_key)] == 100
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 7))
    assert balance[Base.encode64(public_key)] == 100
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 8))
    assert balance[Base.encode64(public_key)] == 100
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 9))
    assert balance[Base.encode64(public_key)] == 100
  end

  test "multiple dependent transactions with invalid transactions" do
    IO.puts("Test 8")
    {user_list, miner_list} = Proj4v2.init(10, 5)

    User.transaction(Enum.at(user_list, 0),miner_list,Enum.at(user_list, 2),50)
    User.transaction(Enum.at(user_list, 0),miner_list,Enum.at(user_list, 1),20)
    User.transaction(Enum.at(user_list, 0),miner_list,Enum.at(user_list, 2),20)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000);
    #
    User.transaction(Enum.at(user_list, 1),miner_list,Enum.at(user_list, 3),100)
    # User.transaction(user_list,miner_list)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000);

    User.transaction(Enum.at(user_list, 1),miner_list,Enum.at(user_list, 3),50)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000);

    User.transaction(Enum.at(user_list, 1),miner_list,Enum.at(user_list, 4),6)
    User.transaction(Enum.at(user_list, 2),miner_list,Enum.at(user_list, 5),7)

    Miner.miner_mining(miner_list)
    :timer.sleep(1000);

    balance = Miner.getBalance(List.first(miner_list))
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 0))
    assert balance[Base.encode64(public_key)] == 10
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 1))
    assert balance[Base.encode64(public_key)] == 14
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 2))
    assert balance[Base.encode64(public_key)] == 163
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 3))
    assert balance[Base.encode64(public_key)] == 200
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 4))
    assert balance[Base.encode64(public_key)] == 106
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 5))
    assert balance[Base.encode64(public_key)] == 107
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 6))
    assert balance[Base.encode64(public_key)] == 100
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 7))
    assert balance[Base.encode64(public_key)] == 100
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 8))
    assert balance[Base.encode64(public_key)] == 100
    {_, _, public_key} = User.get_user_information(Enum.at(user_list, 9))
    assert balance[Base.encode64(public_key)] == 100
  end

  @tag timeout: 240000
  test "stress" do
    IO.puts("Test 9")
    {user_list, miner_list} = Proj4v2.init(1000, 100)

    for i <- 1..1000  do
      send = Enum.random(user_list)
      rcv = Enum.random(user_list)
      User.transaction(send,miner_list,rcv,:rand.uniform(50))
#      random_number = :rand.uniform(100)
      if rem(i, 100) == 0 do
        IO.puts("Mining ...")
        Miner.miner_mining(miner_list)
        :timer.sleep(1000)
      end
    end

    Miner.miner_mining(miner_list)
    :timer.sleep(1000)
  end
end
