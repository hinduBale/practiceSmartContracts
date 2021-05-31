// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

// I was asked to import this ERC721 interface because cryptokitty is an ERC 721 compliant NFT
interface ERC721 /* is ERC165 */ {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}


contract Auction {
    
    //I am using the cryptoKitty interface here, so as to prove that the contract owner is also the owner of the cryptoKitty
    address cryptoKittyContractAddress = "Ox...";
    CryptoKittyInterface cryptoKittyContract = CryptoKittyInterface(cryptoKittyContractAddress);
    
    uint private _currentWinningBid; //defaults to 0;
    uint private _currentWinningAddress //defaults to address(0);
    address [] public bidders;
    address public owner;
    uint public kittyDna;
    uint deployWinnerFunTime;
    uint triggerWinnerFunTime;
    
    
    //Key-value pair that stores address with their bids
    mapping(address => uint) public bids_mappings;
    
    constructor(uint cryptoKittyDna) {
        //Transfer kitty to the contract
        cryptoKittyContract.transferFrom(msg.sender, this, cryptoKittyDna); //This mitigates the trust issue, that the contract and kittyOwner would not sell off his cryptoKitty when the auction is still on-going
        
        owner = msg.sender;
        kittyDna = cryptoKittyDna;
        
        // Initializing the time variables that will be automatically trigger the declareWinner function after 5 days of deployment
        deployWinnerFunTime = now;
        triggerWinnerFunTime = now + 5 days;
    }
    
    modifier onlyOwner () {
        require(msg.sender == owner);
        _;
    }
    
    //Function to check who is the owner of the kitty being auctioned
    function checkOwnershipOfKitty() public view returns (address) {
        return cryptoKittyContract.ownerOf(kittyDna);
    }
    
    // The function that the bidders will call to place their bids
    function bidForKitty(uint amount) external payable{
        //Makes sure the bidder has the amount pledged 
        require(msg.value >= amount); //This will ensure that the winner of the auction can actually honor his bid 
        
        //This maps bidders to their bids
        bids_mappings[msg.sender] = amount;
        
        //We maintain an array of bidders too
        bidders.push(msg.sender);
    }
    
    //  Not a necessary function, but kept here just for the feelzzzzz
    function giveUpOwnershipOfContract() private onlyOwner {
        owner = _currentWinningAddress;
    }
   
   //After the declareWinner() function has been called, the money of all the bidders that lost, must be returned
    function handBackBidMoney(address winningAddress) onlyOwner {
        uint numberOfBidders = bidders.length;
        for(uint i = 0; i < numberOfBidders; i++) {
            if(bidders[i] != winningAddress) {
                bidders[i].send(bids_mappings[bidders[i]]);
            }
        }
    }
    
    //Function to transfer the kitty ownership to the bid winner
    function transferKittyOwnerhip(address winningAddress) private onlyOwner {
        //function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
        cryptoKittyContract.transferFrom(this, winningAddress, kittyDna);
    }
    
    //Function is triggered by the contract owner to announce the winner
    //Supposing the contract owner was malicious or just couldn't execute this function, it would automatically be executed after 5 days of contract deployment
    function declareWinner() public returns(address, uint) {
        require((msg.sender == owner && msg.sender == checkOwnershipOfKitty()) || now >= triggerWinnerFunTime);
        uint numberOfBidders = bidders.length;
        for(uint i = 0; i < numberOfBidders; i++) {
            if(bids_mappings[bidders[i]] > currentWinningBid) {
                _currentWinningBid = bids_mappings[bidders[i]];
                _currentWinningAddress = bidders[i];
            }
        }
        
        //This would return the winning address and winning bid.
        giveUpOwnershipOfContract(onlyOwner);
        
        //Give back the bid money to people who did not win the auction
        handBackBidMoney(_currentWinningAddress);
        
        //Kitty Ownership is transferred to the winner
        transferKittyOwnerhip(_currentWinningAddress);
        
        //Winning address and winnnig bid is returned
        return (_currentWinningAddress, _currentWinningBid);
    }
    
    
}

/*
Step1: I visit the website where auction is being held

Step2: I see the maximum bid price

Step3: I call the bidForKitty function with some amount that I want to bid

Step4: I wait for the auction to finish. Like, other people placing their bids.

Step5: ~~When~~ If the contract owner calls the declareWinner function:
 a) If I lost the auction, I get my money back, 
 b) If I won the auction, I don't get my money back and I get ownership of the kitty. 

 Issue1: Contract does not prove that the contract owner is also the owner of the kitty at the time of the auction and before the winner is declared.

 ~~Fact1: A cryptokitty can have only one owner.~~
 Fact1: A cryptoKitty can have only one owner at a given time.

 
 ~~Contract deploy-er, the owner of the kitty and the owner of the contract must be the same address.~~
 Contract deploy-er, the owner of the kitty and the owner of the contract must be the same address at the same time.
 Contract owner should be first eligible for holding the auction.
 
 Or better yet, to make sure that the contract and kitty owner cannot sell their cryptokitty once the aution start,
 make the owner transfer their cryptokitty to the contract itself. This is the practice of escrow.

*/
