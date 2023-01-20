// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// Soul bound tokens -  can only be minted once , to take part in DAO activity

contract DAOMemberNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    string baseURI;

    uint256 public price = 0.01 ether;

    event Attest(address indexed to, uint256 indexed tokenId);
    event Revoke(address indexed to, uint256 indexed tokenId);

    constructor(string memory _base) ERC721("Knowledge DAO Member", "KnDAO") {
        baseURI = _base;
    }

    // to change the URI at any point of time , the URI is same for all the tokens as we DAO NFT is same for all
    function changeURI(string memory newURI) public onlyOwner {
        baseURI = newURI;
    }

    /// for every token ID we have the same metadata as the DAO NFT is same for everybody
    ///  we can create dynmaic on Chain NFT data too which is dynamic for users input
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return baseURI;
    }

    /// to mint the token ID for the DAO user to join the DAO
    // only 1 NFT can be minted per User
    function safeMint() public payable {
        require(msg.value >= price, "Invalid Amount sent");
        require(balanceOf(msg.sender) == 0, "You are already a DAO Member");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        require(
            to == address(0) || from == address(0),
            "The NFT is non transferrable"
        );
        super._beforeTokenTransfer(from, to, tokenId, 1);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        if (from == address(0)) {
            emit Attest(to, tokenId);
        } else if (to == address(0)) {
            emit Revoke(to, tokenId);
        }
    }

    /// can be called by the owner of token to exit the DAO
    /// Burns the token ID from the users Account
    function burn(uint256 tokenId) external {
        require(
            ownerOf(tokenId) == msg.sender,
            "Only owner of the token can burn it"
        );
        _burn(tokenId);
    }

    /// function to remove someone from the DAO  , called only by the owner
    /// will burn the token ID from the users account
    function revoke(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
