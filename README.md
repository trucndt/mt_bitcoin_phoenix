# Student info
1. Vu Nhat Minh (or Minh Vu) (9194-1842)
2. Truc D Nguyen (9482-7764)

# Submission
There are two folders:
1. mt\_bitcoin\_phoenix/protocol/: this project implements the Bitcoin protocol
2. mt\_bitcoin\_phoenix/: this project implements a web interface for Bitcoin protocol in project **protocol/** on the Phoenix framework

Youtube video: https://youtu.be/Ri2rtOckkus



# Instructions
### Test cases for the protocol
Test the Bitcoin protocol in the folder **protocol/**:
```
$ cd mt\_bitcoin\_phoenix/protocol
$ mix test
```

10 test cases are described in the last section of this document.

### Web interface
We assume the machine has already installed Postgresql

To run the web interface:
```
$ cd mt_bitcoin_phoenix
$ mix phx.server
```
(You might need to run mix ecto.create to create the database)
Access this web interface via http://localhost:4000






# What is working
## Web interface
- There are 200 users generating random transactions with 50 miners
- Initially, each user is assigned 100 btc
- In the home page, web client can send bitcoins via the web interface, transactions log among all users are also displayed
- In the balance tab, users can check their balance (client's account is bolded)
- In the statistic tab, system metrics are displayed
- Data are updated in real time using web sockets

## Bitcoin protocol
- Ledger records transactions
- Mining transactions with proof-of-work
- Users can transact bitcoins
- Get balance of users
- Each node is identified by a pair of public/private key 
- Each transaction is verified based on the signature and its validity (having enough fund to transact)




# Test cases
(Note: initially, each user is assigned 100 btc)

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

## Test 9: consecutive invalid transactions
- User 0 sends to user 1: 75 btc 
- User 0 sends to user 2: 65 btc (invalid because of balance limit)
- A block is mined only accepting the first transaction 
- User 0 sends to user 2: 15 btc
- User 0 sends to user 1: 25 btc (invalid because of balance limit)
- A block is mined only accepting the third transaction 
- All transactions except for the invalid one should appear in the ledger
- The balance should be updated accordingly

## Test 10: stress test
- Run bitcoin with 1000 users/wallets and 100 miners
- 1000 random transactions are created
- The program should be able to run without errors

