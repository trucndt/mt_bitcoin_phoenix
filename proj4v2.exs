defmodule Proj4v2 do

end

num_users = Enum.at(System.argv,0) |> String.to_integer()
num_miners = Enum.at(System.argv,1) |> String.to_integer()

user_list = User.create_user_list(num_users)
miner_list = Miner.create_miner_list(num_miners)
Miner.update_other_miner(miner_list)

initState = Enum.reduce(user_list, %{}, fn pid, acc ->
  {_,_,pubKey} = User.get_user_information(pid)
  Map.put(acc, Base.encode64(pubKey), 100)
end)

Miner.initialState(miner_list,initState)


#server_info = Miner.get_miner_information(miner_server)
#IO.inspect(server_info)

User.transaction(user_list,miner_list,"BK/NwPDPn06s1jFN1R2VpjWhTvQi7D4x/p2OhghxAExQe37/kA5VfrDG2euzKs4tc/dLGECUZWzLv1NPThO2/FY=",1)
User.transaction(user_list,miner_list,"BK/NwPDPn06s1jFN1R2VpjWhTvQi7D4x/p2OhghxAExQe37/kA5VfrDG2euzKs4tc/dLGECUZWzLv1NPThO2/FY=",2)
User.transaction(user_list,miner_list,"BK/NwPDPn06s1jFN1R2VpjWhTvQi7D4x/p2OhghxAExQe37/kA5VfrDG2euzKs4tc/dLGECUZWzLv1NPThO2/FY=",3)

Miner.miner_mining(miner_list)
:timer.sleep(1000);
#
User.transaction(user_list,miner_list,"BK/NwPDPn06s1jFN1R2VpjWhTvQi7D4x/p2OhghxAExQe37/kA5VfrDG2euzKs4tc/dLGECUZWzLv1NPThO2/FY=",4)
# User.transaction(user_list,miner_list)

Miner.miner_mining(miner_list)
:timer.sleep(1000);

User.transaction(user_list,miner_list,"BK/NwPDPn06s1jFN1R2VpjWhTvQi7D4x/p2OhghxAExQe37/kA5VfrDG2euzKs4tc/dLGECUZWzLv1NPThO2/FY=",5)

Miner.miner_mining(miner_list)
:timer.sleep(1000);

User.transaction(user_list,miner_list,"BK/NwPDPn06s1jFN1R2VpjWhTvQi7D4x/p2OhghxAExQe37/kA5VfrDG2euzKs4tc/dLGECUZWzLv1NPThO2/FY=",6)

Miner.miner_mining(miner_list)
:timer.sleep(1000);
User.transaction(user_list,miner_list,"BK/NwPDPn06s1jFN1R2VpjWhTvQi7D4x/p2OhghxAExQe37/kA5VfrDG2euzKs4tc/dLGECUZWzLv1NPThO2/FY=",7)
#
# User.transaction(user_list,miner_list)
# User.transaction(user_list,miner_list)
# User.transaction(user_list,miner_list)
#
# Miner.miner_mining(miner_list,miner_server)
# :timer.sleep(1000);

IO.puts("*****************")

info = Miner.get_list_information(miner_list)
IO.inspect(info)

IO.puts("*****************")

{_, ledger, _, _, _, _} = Miner.get_miner_information(List.first(miner_list))
IO.inspect(ledger)

last_block = List.last(ledger)
IO.inspect(last_block)
sec_last_block = List.last(List.delete(ledger, last_block))
IO.inspect(sec_last_block)

prev_hash = Miner.prev_hash([sec_last_block])


test_string = Enum.join([prev_hash] ++ last_block)

temp = :crypto.hash(:sha256, test_string )|> Base.encode16
IO.inspect(temp)
