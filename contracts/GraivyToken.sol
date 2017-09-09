pragma solidity ^0.4.11;


import './MintableToken.sol';

/**
 * @title Mintable Graivy token
 * @dev ERC20 Token with mintable token creation
 * @dev Issue: * https://github.com/graivy/graivy-token
 * Based on code by OpenZeppelin: https://github.com/OpenZeppelin/zeppelin-solidity
 */

contract GraivyToken is MintableToken {
  string public constant name = "Graivy Tokens";
  string public constant symbol = "GVY";
  uint8 public constant decimals = 18;
  string public version = 'GVY0.3.0';


  function GraivyToken() {
      totalSupply = 0;
      supplyMod = 1;
      tokenWeight = 1000;
      tokenCap = 200000000000000000000000000;
      trackerThreshold = 10000000000000000000000000;
      mintMinimum = 1000000000000000;
      claimMinimum = 1000000000000000;
      claimLockTime = 24 hours;
  }
}
