pragma solidity ^0.4.24;

import "./SafeMath.sol";
import "./GasFreeToken.sol";

/**
 * @title GasFree Token implementation
 */
contract GasFreeTokenImpl is GasFreeToken {
  using SafeMath for uint256;
  
  enum methodType {TRANSFER, TRANSFER_FROM, APPROVE}
  bytes constant public ethSignedMessagePrefix = '\x19Ethereum Signed Message:\n32';

  mapping (address => uint256) balances;
  mapping(address => mapping(uint => bool)) public usedSigIds;
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
   * 
   * 
   */
  function verifySignature(bytes32 _data, address _signer, bytes _sig, uint256 _sigId) private {
    require(!usedSigIds[_signer][_sigId]);
    
    // Calculate V, R, and S from signature
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly { // solium-disable-line security/no-inline-assembly
        r := mload(add(_sig, 32))
        s := mload(add(_sig, 64))                                                                                                                               
        v := byte(0, mload(add(_sig, 96)))
    }
    if (v < 27){
        v += 27;
    }
    
    require(_signer == ecrecover(keccak256(ethSignedMessagePrefix, _data), v, r, s));
    usedSigIds[_signer][_sigId] = true;
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
  * @param _sigId A hashed nonce that is coupled to function arguments to 
  * prevent frontrunning attacks and allow third parties to subsidize gas costs
  */
  function transfer(address _actorAddress, address _to, uint256 _value, bytes _sig, uint256 _sigId) public returns (bool) {
    bytes32 functionData = keccak256(address(this), _actorAddress, _to, _value, _sigId, methodType.TRANSFER);
    verifySignature(functionData, _actorAddress, _sig, _sigId);

    require(_to != address(0));
    require(_value <= balances[_actorAddress]);

    balances[_actorAddress] = balances[_actorAddress].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(_actorAddress, _to, _value, msg.sender);
    return true;
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
  */
  function transferFrom(address _actorAddress, address _from, address _to, uint256 _value, bytes _sig, uint256 _sigId) public returns (bool) {
    bytes32 functionData = keccak256(address(this), _actorAddress, _from, _to, _value, _sigId, methodType.TRANSFER_FROM);
    verifySignature(functionData, _actorAddress, _sig, _sigId);

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
  */
  function approve(address _actorAddress, address _spender, uint256 _value, bytes _sig, uint256 _sigId) public returns (bool) {
    
    bytes32 functionData = keccak256(address(this), _actorAddress, _spender, _value, _sigId, methodType.APPROVE);
    verifySignature(functionData, _actorAddress, _sig, _sigId);
    
    require((_value == 0) || (allowed[_actorAddress][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    emit Approval(_actorAddress, _spender, _value, msg.sender);
    return true;
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