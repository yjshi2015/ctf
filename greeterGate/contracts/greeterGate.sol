// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract Gate {
    bool public locked = true;

    uint256 public timestamp = block.timestamp;
    uint8 private number1 = 10;
    uint16 private number2 = 255;
    bytes32[3] private data;

    constructor(bytes32 _data1, bytes32 _data2, bytes32 _data3) {
        data[0] = _data1;
        data[1] = _data2;
        data[2] = _data3;
    }

    modifier onlyThis() {
        require(msg.sender == address(this), "Only the contract can call this");
        _;
    }

    event UnlockData(bytes data);

    function resolve(bytes memory _data) public {
        console.log("Gate---->resolve---->1");
        //这个限制的作用是防止外部EOA账户直接调用该函数（Remix、ethers中的账户或钱包调用都会失败）
        //因此必须由合约调用！！！
        require(
            msg.sender != tx.origin,
            "msg.sender == tx.origin is not allowed"
        );
        console.log("Gate---->resolve---->2");
        emit UnlockData(_data);
        (bool success, ) = address(this).call(_data);
        console.log("Gate---->resolve---->3");
        require(success, "wtf, call failed!!!");
    }

    function unlock(bytes memory _data) public onlyThis {
        console.log("Gate---->unlock---->1");
        require(bytes16(_data) == bytes16(data[2]));
        console.log("Gate---->unlock---->2");
        locked = false;
    }

    function isSolved() public view returns (bool) {
        return !locked;
    }
}
