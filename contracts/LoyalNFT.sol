// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LoyalNFT is ERC1155 {
    using SafeMath for uint256;

    uint256 public creatorShare = 5; // Percentage of payment to be given to the original creator
    mapping(uint256 => address) public originalCreators; // Mapping of token IDs to original creators

    constructor() ERC1155("Artsy") {}

    function mint(
        address _to,
        uint256 _id,
        uint256 _amount,
        address _originalCreator,
        bytes memory _data
    ) public {
        require(_to != address(0), "Invalid address");
        require(_originalCreator != address(0), "Invalid original creator");

        _mint(_to, _id, _amount, _data);
        originalCreators[_id] = _originalCreator;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) public override {
        require(_from != address(0), "Invalid sender");
        require(_to != address(0), "Invalid recipient");
        require(_exists(_id), "Token does not exist");
        require(balanceOf(_from, _id) >= _amount, "Insufficient balance");

        address originalCreator = originalCreators[_id];
        uint256 salePrice = msg.value;
        uint256 creatorFee = salePrice.mul(creatorShare).div(100); // Calculate the 5% fee to be given to the original creator
        uint256 sellerPayment = salePrice.sub(creatorFee); // Calculate the payment to be given to the seller

        if (originalCreator != address(0)) {
            payable(originalCreator).transfer(creatorFee); // Transfer the fee to the original creator
        }

        payable(_from).transfer(sellerPayment); // Transfer the payment to the seller
        safeTransferFrom(_from, _to, _id, _amount, _data);
    }
}
