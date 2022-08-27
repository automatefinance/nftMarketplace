pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";

//Inheritting the ReentrancyGuard contract from Open Zepplin to make the nonReentrant security modifer available...
//The nonReentrant() prevents a contract from calling itself, directly, or indirectly
//Using the Counters.Counter() to asign ERC721 ids for _itemsSold, and _itemIds or the ID of a market item
contract NFTMarket is ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

    //MarketItem struct allows us to store records of items that will be 
    //available in the marketplace 
  struct MarketItem {
    uint itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
  }

    //creates key-value pair between MarketItems and ID and saving it to idToMarketItem
  mapping(uint256 => MarketItem) private idToMarketItem;

  //creating event for creation of market items so it will be 
  //logged and stored on the blockchain by the address
  event MarketItemCreated (
    uint indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price
  );
    //function getMarketItem()that accepts the marketItemId variable and returns the key-value pair from our mapping()
  function getMarketItem(uint256 marketItemId) public view returns (MarketItem memory) {
    return idToMarketItem[marketItemId];
  }

    //transfers an NFT to contract address of the market and puts item for sale 
  function createMarketItem(
    address nftContract,
    uint256 tokenId,
    uint256 price
  ) public payable nonReentrant {
    require(price > 0, "Price must be at least 1 wei");

    _itemIds.increment();
    uint256 itemId = _itemIds.current();
  
    idToMarketItem[itemId] =  MarketItem(
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(address(0)),
      price
    );

    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

    emit MarketItemCreated(
      itemId,
      nftContract,
      tokenId,
      msg.sender,
      address(0),
      price
    );
  }
    
    //function that takes address, itemId, and ETH and transfers between addresses
    //if the requirements are met
  function createMarketSale(
    address nftContract,
    uint256 itemId
    ) public payable nonReentrant {
    uint price = idToMarketItem[itemId].price;
    uint tokenId = idToMarketItem[itemId].tokenId;
    require(msg.value == price, "Please submit the asking price in order to complete the purchase");

    idToMarketItem[itemId].seller.transfer(msg.value);
    IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
    idToMarketItem[itemId].owner = payable(msg.sender);
    _itemsSold.increment();
  }

    //this function will return or display the MarketItems that are still for sale
  function fetchMarketItem(uint itemId) public view returns (MarketItem memory) {
    MarketItem memory item = idToMarketItem[itemId];
    return item;
  }

  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint itemCount = _itemIds.current();
    uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
    uint currentIndex = 0;

    MarketItem[] memory items = new MarketItem[](unsoldItemCount);
    for (uint i = 0; i < itemCount; i++) {
      if (idToMarketItem[i + 1].owner == address(0)) {
        uint currentId = idToMarketItem[i + 1].itemId;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
   
    return items;
  }

    //returns or displays the NFTS owned by a specific address
    //using the msg.sender syntax, which represents the last address to call the function
  function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        uint currentId = idToMarketItem[i + 1].itemId;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
   
    return items;
  }
}