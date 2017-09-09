pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';


/**
 * @title Distributable token contract
 * @dev Enables minter contract ether distribution with lock time
 * @dev Issue: * https://github.com/graivy-token
 */

contract DistributableToken is StandardToken {
  event Claim(address indexed owner, uint256 amount, uint256 etherAmount);
  event Unlock (address owner, uint256 storedTokens);


  struct Account {
    uint256 storedTokens;
    uint releaseTime;
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
   * @dev Function to claim ether share
   * @param amount The amount of GVY user wishes to claim ether with
   * @param etherAmount is calculated from msg.value and token modifiers
   * @return True if the operation was successful including amount minted 
   */
  function claim(uint256 amount) canClaim returns (bool, uint256 etherAmount, uint releaseTime) {
    require(balanceOf(msg.sender) >= amount);
    etherAmount = this.balance.div(totalSupply).mul(amount);
    require(etherAmount >= claimMinimum);
    require(etherAmount < this.balance);
    balances[msg.sender] = balances[msg.sender].sub(amount);
    balances[this] = balances[this].add(amount);
    releaseTime = block.timestamp.add(claimLockTime);
    accounts[msg.sender].storedTokens = amount;
    accounts[msg.sender].releaseTime = releaseTime;
    msg.sender.transfer(etherAmount);
    Claim(msg.sender, amount, etherAmount);
    return (true, etherAmount, releaseTime);
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
