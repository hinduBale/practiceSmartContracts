// SPDX-License-Identifier: GPL-3.0

pragma solidity ^ 0.7.0;

contract HotelRoom {
    //  Just to increase the readability of code
    enum Status {
        vacant,
        occupied
    }
    
    Status private _currentStatus;
    
    // This event can be used for listening in the front-end for handing out room-keys to the people 
    // associated with this address
    event nowOccupied(address _occupant, uint _value);
    
    address public tenant;
    address payable public owner;
    uint private _itemFee; //itemFee == Rent for the hotel room
    
    //The one who deploys the contract will be the owner of the contract
    constructor() {
        owner = msg.sender;
        _currentStatus = Status.vacant;
    }
    
    modifier onlyWhileVacant() {
        require(_currentStatus == Status.vacant, "Currently Occupied");
        _;
    }
    
    modifier costs(uint _amount) {
        require(msg.value >= _amount, "More Ether required");
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function setItemFee(uint newFee) external onlyOwner {
        _itemFee = newFee;
    }
    
    // receive is a keyword and ever since Solidity version 0.6.0 it is used
    // in conjunction with fallback() when the calldata is empty.
    receive() external payable onlyWhileVacant costs(_itemFee) {
        _currentStatus = Status.occupied;
        if(msg.value > _itemFee) {
            msg.sender.transfer(msg.value - _itemFee);
        }
        tenant = msg.sender;
        owner.transfer(_itemFee);
        emit nowOccupied(msg.sender, msg.value);
    }
    
    function vacateRoom() external {
        require(msg.sender == owner || msg.sender == tenant, "You do not have authority to vacate room!");
        tenant = 0x0000000000000000000000000000000000000000;
        _currentStatus = Status.vacant;
    }
}
