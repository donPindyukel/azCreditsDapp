pragma solidity ^0.4.13;

import './StandartToken.sol';
import './Ownable.sol';

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {

  mapping(address => bool) gotBalance;

  bool public mintingFinished = false;

  event Mint(address indexed sender, uint256 amount);
  
  uint32 public constant TOKENS = 100;

  event MintFinished();

  modifier canMint() {
    require(!gotBalance[msg.sender] && !mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @return A boolean that indicates if the operation was successful.
   */
  function mint() canMint returns (bool) {
    totalSupply = totalSupply.add(TOKENS);
    balances[msg.sender] = balances[msg.sender].add(TOKENS);
    gotBalance[msg.sender] = true;
    Mint(msg.sender, TOKENS);
    return true;
  }

   /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

}
