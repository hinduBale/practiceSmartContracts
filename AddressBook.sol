// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.7.0 < 0.8.0;

contract AddressBook {
    //maps an address to an address array
    mapping(address => address[]) private _addresses;
    
    //maps an address to the aliases of the related addresses
    // when you are mapping a key to another mapping, the key gets mapped to the value of the second mapping
    mapping(address => mapping(address => string)) private _aliases;
    
    // array types (reference types) require the memory keyword
    function getAddressArray(address adr) public view returns(address[] memory) {
        return _addresses[adr];
    }
    
    //function to add addresses to your AddressBook
    function addAddress(address adr, string alias) public {
        _addresses[msg.sender].push(adr);
        _addresses[msg.sender][adr] = alias; //This is how you assign values to mapping of a mapping wale case mein
    }
    
    function removeAddress(address adr) public {
        uint length = _addresses[msg.sender].length;
        for(uint i = 0; i < length; i++) {
            if(adr == _addresses[msg.sender][i]) {
                // The 1 < condition is making sure that the address book of msg.sender had more than 1 contact, else there is no point of deleting and shifitng stuff
                if(1 < _addresses[msg.sender].length && i < length - 1) {
                    // Migrate the last address from the address book to the index from where the address was removed
                    _addresses[msg.sender][i] = _addresses[msg.sender][length-1];
                }
                delete _addresses[msg.sender][length-1];
                _addresses[msg.sender].length--;
                delete aliases[msg.sender][adr];
                break;
            }
        }
    }
    
    function getAlias(address addrOwner, address addr) public view returns(string memory) {
        return _aliases[addrOwner][addr];
    }
    
}
