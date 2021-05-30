# Practice Smart Contracts
A repository that'll contain the rough smart contracts that I code to brush my Solidity skills.

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
