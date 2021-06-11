# Practice Smart Contracts
A repository that'll contain the rough smart contracts that I code to brush my Solidity skills.

## List of Resources

* [send vs call vs transfer methods](https://fravoll.github.io/solidity-patterns/secure_ether_transfer.html)

## AddressBook Smart Contract
It is a simple address book. It allows one to save a list of address to the block chain with an alias name. Remember to never save sensitive or private data to the blockchain as it can be read. 

## HotelRoom Smart Contract
The sample solidity hotel contract below allows one to rent a hotel room. It allows someone to make a payment for a room if the room is vacant. Once payment is made to the contract the funds are sent to the owner. This could be expanded to unlock the door or dispense a key code after payment is made. 
Features:
* Introduced a tenant address, so that vacating a room becomes possible
* Only the owner or current tenat can vacate the room
* The hotel room rent can be adjusted and is not a static value
* Only the owner can change the rent
* If excess funds are transferred to the contract, the surplus is returned to the `msg.sender`

## TimeLock Smart Contract
This contract demonstrates how to use the passing of time in a Solidity smart contract. Think of this contract like a weekly allowance or escrow that needs to pay out weekly.
The noticable point in this contract is the usage of the `call` function as opposed to `send()` or `transfer()`. Here are a few points detailing the use-cases for `send`, `transfer` and `call` function.

Also, note that, **call in combination with re-entrancy guard is the recommended method to use after December 2019**.

* `send` and `transfer`, cannot control the amount of gas being forwarded to the contract. Therefore it will always transfer the in-built *2300 gwei gas stipend* to handle the incoming amount.
* Therefore, if the `fallback` function of the receiving address does computations or tasks that push the gas required above *2300 gwei*, then the transaction fails.
* In order for transaction to go through surely, we can also use `<addr>.call({value: _value, gas: _gas})("yourData")`. If you did not specify the `gas` param, then all the remaining gas is transferred to the receiving address.
* `call` and `send` return a boolean to show whether the transaction got through or not. `transfer` simply propogates the error, if any. Along with boolean, `call` also returns a field of type `byte32` representing txn data.
* `fallback` functions requiring more gas than the stipend could freeze a contract, which is using the transfer method.
* Therefore, the burden of taking money should ideally be put on the user by providing a withdraw function rather than taking on onself the burden of sending money.
* The `call` method is susceptible to the *re-entry attack*. However, call in combination with re-entrancy guard is the recommended method to use after December 2019.
* In contracts, where you are sending payment using `call` or anyhow interacting with external contracts, Use the **Checks-Effects-Interactions Pattern**.

## Handy Solidity quirks I came across:

* When declaring function that returns something, you have the following two choices:


`return` variable is directly declared inside the function:
```solidity
  function addTwoNumbers(uint a, uint b) public returns (uint) {
    uint result = a + b;
    return result;
  }
```
Against something like:
```solidity
  function addTwoNumbers(uint a, uint b) public returns (uint result) {
    result = a + b;
  }
```
* Code to determine whether another address is a contract or not (not entirely safe)
* The assembly language that all Ethereum contracts compile down to contains an opcode for this precise operation: EXTCODESIZE. This opcode returns the size of the code on an address. If the size is larger than zero, the address is a contract. But you need to write assembly code within the contract to access this opcode since the Solidity compiler does not support it directly at the moment. 
* `EXTCODESIZE` returns 0 if it is called from the constructor of a contract, because it is basically not yet deployed. So if you are using this in a security sensitive setting, you would have to consider if this is a problem.
```solidity
function isContract(address _addr) private returns (bool isContract) {
  uint size;
  assembly {
    size := extcodesize(_addr)
  }
  return (size > 0)
}
```

