pragma solidity ^0.4.11;

import './DistributableToken.sol';


/**
 * @title Modified mintable token
 * @dev Simple ERC20 Token, with modified mintable token creation
 * @dev Issue: * https://github.com/graivy/gravy-token
 * Based on code by OpenZeppelin: https://github.com/OpenZeppelin/zeppelin-solidity
 */

contract MintableToken is DistributableToken {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event ResetTracker();

  bool public mintingFinished = false;
  uint256 public tokenWeight;
  uint256 public tokenCap;
  uint256 public supplyMod;
  uint256 public mintMinimum;
  uint256 public mintTracker;
  uint256 public trackerThreshold;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param amount calculated from msg.value and token modifiers
   * @return True if the operation was successful including amount minted
   */
  function mint(address _to) canMint payable returns (bool, uint256 amount) {
    require(msg.value >= mintMinimum);
    amount = msg.value.mul(tokenWeight).div(supplyMod);
    mintTracker += amount;
    totalSupply = totalSupply.add(amount);
    balances[_to] = balances[_to].add(amount);
    if (totalSupply >= tokenCap) finishMinting();
    if (mintTracker >= trackerThreshold) resetTracker();
    Mint(_to, amount);
    return (true, amount);
  }

  /**
   * @dev Internal function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() internal returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

  /**
   * @dev Internal function to reset tracker for tracking mint supply adjustment
   * @return True if the operation was successful.
   */
  function resetTracker() internal returns (bool) {
    mintTracker = 0;
    supplyMod = supplyMod.mul(2);
    ResetTracker();
    return true;
  }
}
