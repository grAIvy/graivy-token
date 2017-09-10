pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';


/**
 * @title Distributable token contract
 * @dev Enables minter contract ether distribution with lock time
 * @dev Issue: * https://github.com/graivy..
 */

contract DistributableToken is StandardToken {
  event Lock(address indexed owner, uint256 amount);
  event Unlock (address owner, uint256 storedTokens);
  event Claim (address owner, uint256 amount);


  struct Account {
    uint256 storedTokens;
    uint releaseTime;
    bool paid;
  }

  mapping(address => Account) accounts;

  uint public claimLockTime;
  uint256 public claimMinimum;

  modifier canClaim() {
    require(accounts[msg.sender].storedTokens == 0);
    require(balances[msg.sender] > 0);
    _;
  }

  /**
   * @dev Function to lock GVY to claim ETH
   * @param amount The amount of GVY user wishes to claim ether with
   * @return True if the operation was successful including amount minted
   */
  function lock(uint256 amount) canClaim returns (bool, uint releaseTime) {
    require(balanceOf(msg.sender) >= amount);
    balances[msg.sender] = balances[msg.sender].sub(amount);
    balances[this] = balances[this].add(amount);
    releaseTime = block.timestamp.add(claimLockTime);
    accounts[msg.sender].storedTokens = amount;
    accounts[msg.sender].releaseTime = releaseTime;
    accounts[msg.sender].paid = false;
    Lock(msg.sender, amount);
    return (true, releaseTime);
  }

  /**
   * @dev Function to claim ETH.
   * @return True if the operation was successful.
   */
  function claim() returns (bool) {
    Account storage c = accounts[msg.sender];
    require(c.paid == false);
    uint256 stored = c.storedTokens * 10 ** (4);
    uint256 weight = ((stored / totalSupply) + 5) / 10;
    uint256 fixedWeight = weight.mul(this.balance);
    uint256 amount = fixedWeight.div(1000);
    msg.sender.transfer(amount);
    c.paid = true;
    Claim(msg.sender, amount);
    return true;
  }

  /**
   * @dev Function to unlock tokens.
   * @return True if the operation was successful.
   */
  function unlock() returns (bool) {
    Account storage c = accounts[msg.sender];
    require(c.releaseTime <= block.timestamp);
    require(c.storedTokens > 0);
    uint256 storedTokens = c.storedTokens;
    c.storedTokens = 0;
    balances[this] = balances[this].sub(storedTokens);
    balances[msg.sender] = balances[msg.sender].add(storedTokens);
    Unlock(msg.sender, storedTokens);
    return true;
  }

  function checkLocked() constant returns (uint256 storedTokens) {
    return accounts[msg.sender].storedTokens;
  }

  function getReleaseTime() constant returns (uint releaseTime) {
    return accounts[msg.sender].releaseTime;
  }
}
