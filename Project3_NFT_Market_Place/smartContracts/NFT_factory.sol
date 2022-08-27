// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";

//ERC721 non-fungible token creation
//ERC721URIStorage is a flexible but more expensive way of storing metadata
//Counter is a struct data type in the Counters OpenZeppelin library...
//Libraries can help save gas fees!
//when we say 'use Counters for Counters.Counter;', it means we attach every function from library 'Counters' to 'Counters.Counter'
//The Counters.Counter function provides counters that can be incremented, decremented,...
// or reset. This can be used to track the number of elements in a mapping, issuing ERC721 ids,...
//or counting request ids. In Our case we are isuuing ERC721 ids for each NFT to then be stored in the contractAddress
// The ERC721URIStorage contract is an implementation of ERC721 that...
//includes the metadata standard extensions ( IERC721Metadata ) as well as a mechanism for per token metadata
contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter; 
    Counters.Counter private _tokenIds;
    address contractAddress;

    //The contstructor takes an argument for the `mrketplace` address, 
    //saving the value and making it available in the smart contract.
    constructor(address mrktplace) ERC721("Eat The Blocks NFTs", "ETBNFT") {
        contractAddress = mrktplace;
    }
    //the developToken function can allow the Market contract approval to transfer
    //the token away from the owner to the seller
    function developToken(string memory tokenURI) public returns (uint) {
        _tokenIds.increment();
        uint256 itemId = _tokenIds.current();

        //mint argument of sender of the message (current call) and itemId
        //emitting the transfer of tokens
        _mint(msg.sender, itemId);

        //set Token URI in the new NFT, which updates the mappin
        _setTokenURI(itemId, tokenURI);

        //sets the approval to trandfer token of the sender on their behalf.
        setApprovalForAll(contractAddress, true);
        return itemId;
    }
}