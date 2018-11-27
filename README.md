# Student info
1. Vu Nhat Minh (or Minh Vu) (9194-1842)
2. Truc D Nguyen (9482-7764)

# Instructions
The main source code is in **lib/**:
* proj4v2.ex: This file defines main routines
* miner.ex: The implementation of a miner node
* user.ex: The implementation of a user/wallet node
* crypto.ex: The implementation of some crypto functions (generating keys; signing, verifying messages)

### Run test cases
```
$ mix test
```

### Compilation
```
$ mix escript.build
```

### Run program
```
$ ./proj4v2 <numUser> <numMiner>
```
- numNode: number of users 
- numMiner: number of miners

### Output 
The result of test case 7 (to be presented in the subsequent sections):
- The ledger
- The final balance of each user

# What is working
- Ledger records transactions
- Mining transactions with proof-of-work
- Users can transact bitcoins
- Get balance of users
- Each node is identified by a pair of public/private key 
- Each transaction is verified based on the signature and its validity (having enough fund to transact)

# Code description
- Initially, each user possesses 100 BTC
- When a user issues a transaction, it first broadcasts the transaction to all miners. Each miner then handles the call, verifies the validity of the transaction and saves the transaction to its buffer for mining. 
- When the function Miner.miner\_mining()\1 is called, all miners start to mine a new block containing all their transaction saved in their corresponding buffers. 
- In the Miner.miner\_mining()\1, a GenServer.cast is called to each miner. Each miner then spawns an internal process to conduct the mining by calling the function GenServer.cast(sub\_pid, {:only\_mining,self(),k}) where “sub\_pid” is the pid of the internal process and “k” is the number of “k” bits in the mining. 
- When the internal process of one miner finishes, it informs its parent (the miner main process) the result (GenServer.call(pid, {:mining\_result,result,k})). This miner then informs the results to all other miners (GenServer.cast(pid, {:inform\_result, result,k})). Upon receiving the result, the received miner will check the result. If it is valid, it clears the transaction buffer and update the ledger. The internal process of the received miner periodically checks if the miner needs the mining result anymore. If not, it will terminate itself.

# Test cases
## Test 1: signing and verifying signature
- Create a pair of public/private key
- Sign a random message using the private key and verify with the public key (should return _true_)

## Test 2: signing and verifying signature (negative)
- Create a pair of public/private key
- Sign a random message using a random signature and verify with the public key (should return _false_)

## Test 3: Proof-of-work
- Get a block from the ledger
- Verify the proof-of-work

## Test 4: One valid transaction
- User 0 sends 3 BTC to user 1
- The balance of user 0 should be 97
- The balance of user 1 should be 103
- The transaction should appear in the ledger

## Test 5: One invalid transaction
- User 0 sends 300 BTC to user 1 (not enough fund)
- The balance of user 0 and 1 should be 100
- The transaction should not appear in the ledger

## Test 6: Multiple independent transactions
- User 0 sends to user 1: 1 BTC
- User 2 sends to user 3: 2 BTC
- User 4 sends to user 5: 3 BTC
- User 6 sends to user 7: 4 BTC
- User 8 sends to user 9: 5 BTC
- All transactions should appear in the ledger
- The balance should be updated accordingly

## Test 7: Multiple dependent transactions
- User 0 sends to user 2: 1 BTC
- User 0 sends to user 1: 2 BTC
- User 0 sends to user 2: 3 BTC
- User 1 sends to user 3: 4 BTC
- User 1 sends to user 3: 5 BTC
- User 1 sends to user 4: 6 BTC
- User 2 sends to user 5: 7 BTC
- All transactions should appear in the ledger
- The balance should be updated accordingly

## Test 8: Multiple dependent transactions with invalid transactions
- User 0 sends to user 2: 50 BTC
- User 0 sends to user 1: 20 BTC
- User 0 sends to user 2: 20 BTC
- User 1 sends to user 3: 100 BTC
- User 1 sends to user 3: 50 BTC (invalid because 1 only has 20 BTC)
- User 1 sends to user 4: 6 BTC
- User 2 sends to user 5: 7 BTC
- All transactions except for the invalid one should appear in the ledger
- The balance should be updated accordingly

## Test 9: stress test
- Run bitcoin with 1000 users/wallets and 100 miners
- 1000 random transactions are created
- The program should be able to run without errors

