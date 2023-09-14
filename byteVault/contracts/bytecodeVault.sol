//SPDX-License-Identifier: MIT
pragma solidity ^0.5.11;

contract BytecodeVault {
    address public owner;

    constructor() public payable {
        owner = msg.sender;
    }

    modifier onlyBytecode() {
        require(msg.sender != tx.origin, "No high-level contracts allowed!");
        _;
    }

    function withdraw() external onlyBytecode {
        uint256 sequence = 0xdeadbeef;
        bytes memory senderCode;

        address bytecaller = msg.sender;

        assembly {
            //caller合约的代码大小
            let size := extcodesize(bytecaller)
            //内存中加载第3个slot数据
            senderCode := mload(0x40)
            //利用size和senderCode的计算结果，作为第3个slot数据，和上一行命令结合起来，
            //就是更新第3个slot的值
            mstore(0x40, add(senderCode, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            //将caller合约大小写入senderCode指定的slot中
            mstore(senderCode, size)
            //将合约代码复制到senderCode+1个slot的位置
            //跟上一行结合来看，就是在指定slot位先写入合约大小，再保存合约数据
            extcodecopy(bytecaller, add(senderCode, 0x20), 0, size)
        }
        require(senderCode.length % 2 == 1, "Bytecode length must be even!");
        for(uint256 i = 0; i < senderCode.length - 3; i++) {
            //取sequence第1个高位字节
            if(senderCode[i] == byte(uint8(sequence >> 24))
                //sequence第2个高位字节
                && senderCode[i+1] == byte(uint8((sequence >> 16) & 0xFF))
                //sequence第3个高位字节
                && senderCode[i+2] == byte(uint8((sequence >> 8) & 0xFF))
                //取sequence第4个高位字节，即最后1个字节
                && senderCode[i+3] == byte(uint8(sequence & 0xFF))) {
                msg.sender.transfer(address(this).balance);
                return;
            }
        }
        revert("Sequence not found!");
    }

    function isSolved() public view returns(bool){
        return address(this).balance == 0;
    }
}

