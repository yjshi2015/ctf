// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract VaultLogic {
    address payable public owner;
    bytes32 private password;

    constructor(bytes32 _password) {
        owner = payable(msg.sender);
        password = _password;
    }

    function changeOwner(bytes32 _password, address payable newOwner) public {
        if (password == _password) {
            owner = newOwner;
        }
    }

    function withdraw() external {
        console.log("VaultLogic---->withdraw---->1");
        if (owner == msg.sender) {
            console.log("VaultLogic---->withdraw---->2");
            owner.transfer(address(this).balance);
            console.log("VaultLogic---->withdraw---->3");
        }
        console.log("VaultLogic---->withdraw---->4");
    }
}

contract Vault {
    address public owner;
    VaultLogic logic;

    constructor(address _logicAddress) payable {
        logic = VaultLogic(_logicAddress);
        owner = msg.sender;
    }

    fallback() external {
        console.log("Vault---->fallback---->1");
        (bool result, ) = address(logic).delegatecall(msg.data);
        console.log("Vault---->fallback---->2");
        if (result) {
            this;
        }
    }

    receive() external payable {
        uint256 val = msg.value;
        console.log("Vault---->receive---->val: ", val);
    }
}

contract SetUp {
    address public logic;

    address payable public vault;

    constructor(bytes32 _password) payable {
        VaultLogic logicCon = new VaultLogic(_password);
        logic = address(logicCon);
        Vault vaultCon = new Vault(logic);
        vault = payable(address(vaultCon));
        vault.call{value: 1 ether}("");
    }

    receive() external payable {
        console.log("SetUp---->receive---->", msg.value);
    }

    function isSolved() public view returns (bool) {
        return vault.balance == 0;
    }
}