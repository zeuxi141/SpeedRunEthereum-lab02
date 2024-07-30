pragma solidity 0.8.4; // Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
	YourToken public yourToken;
	uint256 public constant tokensPerEth = 100;

	event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
	event SellTokens(
		address seller,
		uint256 amountOfTokens,
		uint256 amountOfETH
	);
	event Withdraw(address owner, uint256 amountOfETH);

	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

	// Buy tokens with ETH
	function buyTokens() public payable {
		uint256 amountOfTokens = msg.value * tokensPerEth;
		require(
			yourToken.balanceOf(address(this)) >= amountOfTokens,
			"Vendor: Not enough tokens available"
		);
		yourToken.transfer(msg.sender, amountOfTokens);
		emit BuyTokens(msg.sender, msg.value, amountOfTokens);
	}

	// Withdraw ETH from contract (only owner can call this)
	function withdraw() public onlyOwner {
		uint256 balance = address(this).balance;
		payable(owner()).transfer(balance);
		emit Withdraw(owner(), balance);
	}

	// Sell tokens to get ETH back
	function sellTokens(uint256 _amount) public {
		uint256 amountOfETH = _amount / tokensPerEth;
		require(
			address(this).balance >= amountOfETH,
			"Vendor: Not enough ETH in contract"
		);
		yourToken.transferFrom(msg.sender, address(this), _amount);
		payable(msg.sender).transfer(amountOfETH);
		emit SellTokens(msg.sender, _amount, amountOfETH);
	}
}
