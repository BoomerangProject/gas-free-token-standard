pragma solidity ^0.4.24;

import './ERC20Token.sol';

/**
 * @title GasFree Token interface
 */
contract GasFreeToken is ERC20Token {
    function transfer(address _actorAddress, address _to, uint256 _value, uint8 _v, bytes32 _r, bytes32 _s) public returns (bool success);
    function transferFrom(address _actorAddress, address _from, address _to, uint256 _value, uint8 _v, bytes32 _r, bytes32 _s) public returns (bool success);
    function approve(address _actorAddress, address _spender, uint256 _value, uint8 _v, bytes32 _r, bytes32 _s) public returns (bool success);
    event Transfer(address indexed _from, address indexed _to, uint256 _value, address indexed _subsidizer);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value, address indexed _subsidizer);
}

