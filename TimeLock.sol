// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract TimeLock {
    
    using SafeMath for uint;
    
    mapping(address => uint) public balances;
    mapping(address => uint) public lockTime;
    
    function deposit() external payable {
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        lockTime[msg.sender] = (lockTime[msg.sender].add(1 weeks)).add(now);
    }
    
    function increaseLockTime(uint secondsToIncrease) public  {
        lockTime[msg.sender] = lockTime[msg.sender].add(secondsToIncrease);
    }
    
    // Re-entry guard wasn't required as this function follows the check-effects-interactions pattern
    function withdraw() public() {
        require(balances[msg.sender] > 0, "insufficient balance");
        require(now > lockTime[msg.sender]);
        
        uint transferableAmount = balances[msg.sender];
        balances[msg.sender] = 0;
        
        (bool sent, ) = msg.sender.call({value: transferableAmount})("");
        require(sent, "Failed to send ether");
    }
}
