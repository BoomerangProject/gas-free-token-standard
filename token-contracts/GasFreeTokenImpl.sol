pragma solidity ^0.4.24;

import "./SafeMath.sol";
import "./GasFreeToken.sol";

/**
 * @title GasFree Token implementation
 */
contract GasFreeTokenImpl is GasFreeToken {
  using SafeMath for uint256;
  
  enum methodType {TRANSFER, TRANSFER_FROM, APPROVE}

  mapping (address => uint256) balances;
  mapping(address => uint256) public nonceValue;
  mapping (address => mapping (address => uint256)) internal allowed;



  uint256 totalSupply_;
  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  /**
  * @dev Transfer token from one address to another as a third party
  * @param _actorAddress address The address which tokens are being sent from
  * @param _to The address to transfer to
  * @param _value uint256 The amount to be transferred.
  * @param _v | _r | _s A hashed nonce that is coupled to function arguments to 
  * prevent frontrunning attacks and allow third parties to subsidize gas costs
  */
  function transfer(address _actorAddress, address _to, uint256 _value, uint8 _v, bytes32 _r, bytes32 _s) public returns (bool) {
    verifyTransfer(_actorAddress, _to, _value, _v, _r, _s);

    require(_to != address(0));
    require(_value <= balances[_actorAddress]);

    balances[_actorAddress] = balances[_actorAddress].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(_actorAddress, _to, _value, msg.sender);
    return true;
  }
  
  /**
  * @dev Verify the transfer of a token from one address to another by a third party
  * @param _actorAddress address The address which tokens are being sent from
  * @param _to The address to transfer to
  * @param _value uint256 the amount of tokens to be transferred
  * @param _v _r _s A hashed nonce that is coupled to function arguments to 
  * prevent frontrunning attacks and allow third parties to subsidize gas costs
  */
  function verifyTransfer(address _actorAddress, address _to, uint256 _value, uint8 _v, bytes32 _r, bytes32 _s) private {
    bytes32 argumentsHash = keccak256(abi.encodePacked(_actorAddress, _to, _value));
    bytes32 nonceHash = keccak256(abi.encodePacked(argumentsHash, methodType.TRANSFER, nonceValue[_actorAddress]));
    bytes memory prefix = '\x19Ethereum Signed Message:\n32';
    bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, nonceHash));
    address recoveredAddress = ecrecover(prefixedHash, _v, _r, _s);
    require(recoveredAddress == _actorAddress);

    nonceValue[_actorAddress] += 1;
  }

  /**
  * @dev Transfer tokens from one address to another
  * @param _from address The address which you want to send tokens from
  * @param _to address The address which you want to transfer to
  * @param _value uint256 the amount of tokens to be transferred
  */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }
  
  /**
  * @dev Transfer token from one address to another as a third party
  * @param _actorAddress address The address which is enacting the transfer
  * @param _from address The address which you want to send tokens from
  * @param _to address The address which you want to transfer to
  * @param _value uint256 the amount of tokens to be transferred
  * @param _v | _r | _s A hashed nonce that is coupled to function arguments to 
  * prevent frontrunning attacks and allow third parties to subsidize gas costs
  */
  function transferFrom(address _actorAddress, address _from, address _to, uint256 _value, uint8 _v, bytes32 _r, bytes32 _s) public returns (bool) {
  
    verifyTransferFrom(_actorAddress, _from, _to, _value, _v, _r, _s);

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][_actorAddress]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][_actorAddress] = allowed[_from][_actorAddress].sub(_value);
    emit Transfer(_from, _to, _value, msg.sender);
    return true;
  }
  
  /**
  * @dev Verify the transfer of a token from one address to another by a third party
  * @param _actorAddress address The address which is enacting the transfer
  * @param _from address The address which you want to send tokens from
  * @param _to address The address which you want to transfer to
  * @param _value The amount to be transferred
  * @param _v _r _s A hashed nonce that is coupled to function arguments to 
  * prevent frontrunning attacks and allow third parties to subsidize gas costs
  */
  function verifyTransferFrom(address _actorAddress, address _from, address _to, uint256 _value, uint8 _v, bytes32 _r, bytes32 _s) private {
    bytes32 argumentsHash = keccak256(abi.encodePacked(_actorAddress, _from, _to, _value));
    bytes32 nonceHash = keccak256(abi.encodePacked(argumentsHash, methodType.TRANSFER_FROM, nonceValue[_actorAddress]));
    bytes memory prefix = '\x19Ethereum Signed Message:\n32';
    bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, nonceHash));
    address recoveredAddress = ecrecover(prefixedHash, _v, _r, _s);
    require(recoveredAddress == _actorAddress);

    nonceValue[_actorAddress] += 1;
  }

  /**
  * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
  * Beware that changing an allowance with this method brings the risk that someone may use both the old
  * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
  * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
  * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
  * @param _spender The address which will spend the funds.
  * @param _value The amount of tokens to be spent.
  */
  function approve(address _spender, uint256 _value) public returns (bool) {

    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
  
  /**
  * @dev Approve the passed address to spend the specified amount of tokens on behalf of actor address.
  * @param _actorAddress address The address which is enacting the approval
  * @param _spender The address which will spend the funds.
  * @param _value The amount of tokens to be spent.
  * @param _v _r _s A hashed nonce that is coupled to function arguments to 
  * prevent frontrunning attacks and allow third parties to subsidize gas costs
  */
  function approve(address _actorAddress, address _spender, uint256 _value, uint8 _v, bytes32 _r, bytes32 _s) public returns (bool) {
    
    verifyApprove(_actorAddress, _spender, _value, _v, _r, _s);
    
    require((_value == 0) || (allowed[_actorAddress][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    emit Approval(_actorAddress, _spender, _value, msg.sender);
    return true;
  }
  
    /**
  * @dev Verify that a third party has the needed hash to call approve by proxy 
  * @param _actorAddress address The address which is enacting the approval
  * @param _spender The address which will spend the funds.
  * @param _value The amount of tokens to be spent.
  * @param _v _r _s A hashed nonce that is coupled to function arguments to 
  * prevent frontrunning attacks and allow third parties to subsidize gas costs
  */
  function verifyApprove(address _actorAddress, address _spender, uint256 _value, uint8 _v, bytes32 _r, bytes32 _s) private {
    bytes32 argumentsHash = keccak256(abi.encodePacked(_actorAddress, _spender, _value));
    bytes32 nonceHash = keccak256(abi.encodePacked(argumentsHash, methodType.APPROVE, nonceValue[_actorAddress]));
    bytes memory prefix = '\x19Ethereum Signed Message:\n32';
    bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, nonceHash));
    address recoveredAddress = ecrecover(prefixedHash, _v, _r, _s);
    require(recoveredAddress == _actorAddress);

    nonceValue[_actorAddress] += 1;
  }

  /**
  * @dev Function to check the amount of tokens that an owner allowed to a spender.
  * @param _owner address The address which owns the funds.
  * @param _spender address The address which will spend the funds.
  * @return A uint256 specifying the amount of tokens still available for the spender.
  */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
}