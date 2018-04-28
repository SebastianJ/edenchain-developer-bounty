# edenchain-developer-bounty
EdenChain Developer Bounty Program Answers

![EdenChain Logo](https://edenchain.io/img/logo01.png)

## Question 1: "How would you store 1 million phone numbers?"

How long is a piece of string?

How to store 1 million phone numbers is totally dependent on the use case for those phone numbers, and you haven't specified the use case.

If it's just a matter of storing the phone numbers and retrieving them fast, key-value stores like [Redis](https://redis.io), [LevelDB](https://github.com/google/leveldb) or [Memcached](https://memcached.org) (with appropiate configuration) could be used and store all of the phone numbers in memory for super fast retrieval.

If it's a matter of storing the numbers and using them in conjunction with other pieces of data, NoSQL solutions like [MongoDB](https://www.mongodb.com) / [Cassandra](http://cassandra.apache.org) or more traditional SQL-based databases like [PostgreSQL](https://www.postgresql.org) or [MySQL](https://www.mysql.com) / [MariaDB](https://mariadb.org) could be used.

Again, it totally depends on the use case for the phone numbers.

* Will strictly only phone numbers be saved? Or will they be saved together with other attributes that should also be queryable together with the phone numbers?
* How should the numbers be retrieved? Simple lookups based on an actual phone number or more advanced lookups using the phone number in conjunction with other attributes or even other separate pieces of data (i.e. other collections for NoSQL or other tables for SQL)?

Please see the section "Implementations" for further discussion of this question.

## Question 2: "How can you check that your friend, Bob, has your phone number stored correctly while keeping your message safe from prying eyes?"

This question is a bit unclear to be honest.

I'm interpreting this question the following way and making these assumptions:

1. Bob has the same copy of the data source as we have
2. Both data sources contain encrypted hashes of phone numbers
3. The hashing function for both data sources are the same and future data in both sources will be generated using the exact same hashing function
4. We can check if Bob has our phone number by sending him the hashed version of our phone number
5. Bob will use our hash and compare it to the stored phone numbers in the data source
6. If there's a matching hash in the data source then Bob has our phone number securely and cryptographically stored.

TL;DR: We give Bob our encrypted/hashed phone number and Bob checks his data source if the hash exists there. If it does, he's got our phone number securely stored and we didn't have to send the phone number in clear text for prying eyes to see.

Please see the section "Implementations" for further discussion of this question.

## Question 3: "How would you organize your huge collection of shirts in your closet for easy retrieval?"

Not sure why we're suddenly talking about shirts instead of phone numbers, but ah well.

If we're talking a non-blockchain context then obviously you store the data for the shirts (or phone numbers) in a key-value store, NoSQL database or SQL database and apply the appropriate indexes - yet again depending on the specs of the project you're building.

In a blockchain context one way to effectively store the data is using binary tree/b-tree collections of the data items/transactions/etc. each block holds.

Please see the section "Implementations" for further discussion of this question.

## Implementations

Since EdenChain is a blockchain project and I'm guessing that your questions originally were framed in the context of blockchains, I'm assuming you're more interested in how the phone numbers/shirts could be stored and retrieved on a blockchain rather than in key-value stores, NoSQL databases, SQL databases etc.

Obviously one or several key-value stores, NoSQL databases or SQL databases are often used for the actual persistance of a blockchain on disk or in memory, but let's keep that out of the discussion for now.

To reiterate, the questions posed for this challenge are:

1. How would you store 1 million phone numbers?
2. How can you check that your friend, Bob, has your phone number stored correctly while keeping your message safe from prying eyes?
3. How would you organize your huge collection of shirts in your closet for easy retrieval?

### Binary search trees / B-trees

In terms of question 1 and question 3, [Binary search trees](https://en.wikipedia.org/wiki/Binary_search_tree) / [B-trees](https://en.wikipedia.org/wiki/B-tree) could be viable options for effectively tackling the problems posed by questions 1 and 3.

According to Wikipedia, "Binary search trees (BST), sometimes called ordered or sorted binary trees, are a particular type of container: data structures that store "items" (such as numbers, names etc.) in memory. They allow fast lookup, addition and removal of items, and can be used to implement either dynamic sets of items, or lookup tables that allow finding an item by its key (e.g., finding the phone number of a person by name)."

And regarding B-trees:

"In computer science, a B-tree is a self-balancing tree data structure that keeps data sorted and allows searches, sequential access, insertions, and deletions in logarithmic time. The B-tree is a generalization of a binary search tree in that a node can have more than two children. Unlike self-balancing binary search trees, the B-tree is optimized for systems that read and write large blocks of data. B-trees are a good example of a data structure for external memory. It is commonly used in databases and filesystems."

In this repo there's a fairly simplistic Binary Search Tree/BST implemented at lib/edenchain/developer/bounty/binary_tree/node.rb. It can be demoed by running bin/binary_tree.

In terms of blockchains, BST/B-trees should probably only be used as a data storage format for data or transactions stored in each block since the structure doesn't keep track of the actual deterministic order between various data points, e.g. blocks.

If the entire blockchain's blocks were stored this way there would be no way to determine the correct block order and subsequently the blockchain would be subject to [Byzantine faults](https://en.wikipedia.org/wiki/Byzantine_fault_tolerance).

If node A produces a new block the same time as node B produces a new block then node C won't be able to tell which of these new blocks should be considered as the new block since there's no chain or tree determining the correct and valid order of the previous blocks.

For a solution to this problem, please see the section "Merkle Trees".

**See [bin/binary_tree](https://github.com/SebastianJ/edenchain-developer-bounty/blob/master/bin/binary_tree) for a demo of a simple BST implementation**

### Hashing

In terms of question 2, what we need to do is to effectively hash our phone number and only use that hash when communicating with third parties.

This can easily be done by just using one-way hashing functions like [SHA-1](https://en.wikipedia.org/wiki/SHA-1)/[SHA-256](https://en.wikipedia.org/wiki/SHA-2)/[SHA-512](https://en.wikipedia.org/wiki/SHA-2) or by performing two-way encryption/decryption by using a private and a public key using for example [HMAC](https://en.wikipedia.org/wiki/HMAC).

For simplicity the solutions proposed here will only use one-way encryption and SHA256 as its algorithm.

### Merkle Trees

In the section "Binary search trees / B-trees" we briely discussed that BST:s/B-trees aren't optimal data structures for storing the blocks in a blockchain since there's no way to verify the order of the blocks, and as such, Byzantine faults would occur quite quickly after multiple nodes are running our blockchain.

A better and more suitable implementation that is Byzantine fault tolerant is the usage of [Merkle Trees](https://en.wikipedia.org/wiki/Merkle_tree). Both Bitcoin and Ethereum are using versions of Merkle Trees to manage their respective blockchains.

By using Merkle Trees every block in a blockchain will hold a reference to the previous block in the form of the previous block's hash. The previous block's hash will also be encoded in the new block's hash and as such, the structure of the entire chain of blocks can be verified by computing the hashes in the correct block order.

If node A produces a new block at roughly the same time as node B produces a new block then node C can:

1. Verify the entire chain from the top to the bottom and conclude if the chain it has received is correct or not
2. Discern which one of the new blocks produced by node A and B that should be considered as valid, and which block should be considered to be orphaned. This is done by first checking the integrity of the chain and secondly checking the timestamp of the new blocks. The block that's verified to be valid as well as having the oldest timestamp of the two new blocks will be considered as the new and valid block to further the blockchain.

Combining all of the above leads us to...

### A super simple blockchain implementation

![Quick rundown of the simple blockchain implementation](https://github.com/SebastianJ/edenchain-developer-bounty/blob/master/files/screencast.gif)

In this repo there's a super simple blockchain implementation that combines the concepts of Binary Search Trees, Hashing and Merkle Trees to store 1,000,000 hashed phone numbers (well, it can be anything actually, but just to stick to the bounty questions) and easily retrieve them, while simultaneously mitigating Byzantine faults and creating a verifiable blockchain.

The simple blockchain implementation features:

* Automatic generation of 1,000,000 phone numbers to use as seed data for the blockchain
* A rudimentary Merkle Tree implementation that creates each new block's hashing key based on the previous blocks hash (and as such, makes it possible to verify the validity of the entire chain)
* Optional simplistic Proof of Work (PoW) algorithm that increases the difficulty for the hashing function every x blocks (currently set to every 250 blocks - can obviously be changed).
* Simplistic block size limits by simply limiting the amount of data items a specific block can hold. The block size can also be changed by setting a different parameter when initializing the blockchain.
* Binary Tree/BTree implementation for storing and rapidly accessing each block's data items.
* A simple addressing system in the format of BLOCKHEIGHTxDATAHASH that can be used to easily retrieve a specific data item (i.e. a phone number, shirt etc.). This makes it easier to just select a desired block and lookup data in that block instead of iterating over all available blocks in order to find the desired data item.

The main code base for this blockchain is stored in [lib/edenchain/developer/bounty/blockchain/chain.rb](https://github.com/SebastianJ/edenchain-developer-bounty/blob/master/lib/edenchain/developer/bounty/blockchain/chain.rb) and [lib/edenchain/developer/bounty/blockchain/block.rb](https://github.com/SebastianJ/edenchain-developer-bounty/blob/master/lib/edenchain/developer/bounty/blockchain/block.rb) and is easily demoed by running [bin/blockchain](https://github.com/SebastianJ/edenchain-developer-bounty/blob/master/bin/blockchain).

Just be aware that running [bin/blockchain](https://github.com/SebastianJ/edenchain-developer-bounty/blob/master/bin/blockchain) with the Proof of Work algorithm enabled will lead to slower execution compared to running without PoW enabled.

![Bogdanoff hands out 140,000 EDN tokens to me (obviously)](https://github.com/SebastianJ/edenchain-developer-bounty/blob/master/files/bogdanoff-edn.jpg)

## Setup

In order to run the examples in this repo you need to install [Ruby](https://www.ruby-lang.org/en/), preferably version 2.5.1.

After checking out/forking the repo, run `bin/setup` to install dependencies.

Then, run `bin/blockchain` to run the blockchain demo.

You can also run `bin/console` to run an interactive prompt that will allow you to experiment with different parts of the codebase.
