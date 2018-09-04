var ethUtil = require('ethereumjs-util');
var ethAbi = require('ethereumjs-abi');


const actorAddress = '0x2533429651311875c997df71d92496b5c4349224';
const actorPrivateKey = '0x5c125515cfdb6147b2c9deee00be03f1a0c2343e37a6b971cfab834ec6768252'
const recieverAddress = '0x2983c7b744ead099c925d86eb7b6efb6f200e854';
const numTokens = 100;
const transferType = 0;
const TRANSFER = 0;
const NONCE = 0;

const transferArgumentMessage = ethAbi.soliditySHA3(
	[ 'address', 'address', 'uint256' ],
	[ actorAddress, recieverAddress, numTokens ]);

console.log('transferArgumentMessage: ' + ethUtil.bufferToHex(transferArgumentMessage));
const transferArgumentMessageHash = ethUtil.hashPersonalMessage(transferArgumentMessage);
console.log('transferArgumentMessageHash: ' + ethUtil.bufferToHex(transferArgumentMessageHash));

const nonceMessage = ethAbi.soliditySHA3(
	[ 'bytes32', 'uint256', 'uint256' ],
	[ transferArgumentMessageHash, TRANSFER, NONCE]);

console.log('nonceMessage: ' + ethUtil.bufferToHex(nonceMessage));
const nonceMessageHash = ethUtil.hashPersonalMessage(transferArgumentMessage);
console.log('nonceMessageHash: ' + ethUtil.bufferToHex(nonceMessageHash));

const privateKey = ethUtil.toBuffer(actorPrivateKey)
const signature = ethUtil.ecsign(nonceMessageHash, privateKey);

console.log(signature.v)
console.log(ethUtil.bufferToHex(signature.r))
console.log(ethUtil.bufferToHex(signature.s))