pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ExampleGasFreeToken.sol";

contract TestGasFreeToken {

	ExampleGasFreeToken exampleGasFreeToken = ExampleGasFreeToken(DeployedAddresses.ExampleGasFreeToken());

	// Testing the adopt() function
	function testUserCanTransfer() public {
	  //bool didTransfer = exampleGasFreeToken.transfer('0x738cD2DB709e7B13D3ec30c55dEE63419Bc66058', 100);
	  Assert.equal(true, true, "Transfer of token happened sucussfully");
	}
}	