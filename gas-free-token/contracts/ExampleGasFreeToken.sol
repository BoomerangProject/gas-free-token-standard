pragma solidity ^0.4.24;

import "./GasFreeTokenImpl.sol";
import "./Ownable.sol";

contract ExampleGasFreeToken is GasFreeTokenImpl, Ownable {

   string public constant name = "Boomerang";
   string public constant symbol = "BOOMERANG";
   uint8 public constant decimals = 18;
   string public constant version = "1.0";

   uint256 public constant tokenUnit = 10 ** 18;
   uint256 public constant oneBillion = 10 ** 9;
   uint256 public constant maxTokens = 10 * oneBillion * tokenUnit;

   constructor() public  {
      totalSupply_ = maxTokens;
      balances[msg.sender] = maxTokens;
   }
}
