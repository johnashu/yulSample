// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract YulSample {
    // slot 0
    // 0x0000000000000000000000000000000000000000000000000000000000000100
    uint256 public var1 = 256;

    // slot 1
    // 0x0000000000000000000000009acc1d6aa9b846083e8a497a661853aae07f0f00
    address public var2 = 0x9ACc1d6Aa9b846083E8a497A661853aaE07F0F00;

    // slot 2
    // 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    bytes32 public var3 =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    // slot 3
    // 0x0000000000000000000000000000000200000000000000000000000000000001
    // 0x000000000000000000000000000002 and 0x000000000000000000000000000001
    uint128 public var4 = 1;
    uint128 public var5 = 2;

    // slot 4 & 5
    // 0x0000000000000000000000000000000100000000000000000000000000000000
    // 0x0000000000000000000000000000000300000000000000000000000000000002
    uint128[4] public var6 = [0, 1, 2, 3];

    // slot 6
    // getValInHex(6) = 0x00 - unknown length as it is a dynamic array
    // the keccak256 hash of the current storage slot (slot 6) is
    // used as the start index of the array.
    uint256[] public var7;

    // slot 7
    mapping(uint256 => uint256) var8;

    // slot 8
    mapping(uint256 => mapping(uint256 => uint256)) var9;

    constructor() {
        var8[uint(1)] = uint(2);
        var9[0][1] = uint(2);
    }

    function getSlot() external view returns (uint slot) {
        assembly {
            slot := var7.slot
        }
    }

    function addToDynamicArray(
        uint256 value,
        uint targetIndex,
        uint256 slot
    ) external {
        // get hash of slot for start index
        bytes32 startIndex = keccak256(abi.encode(slot));
        assembly {
            // get the length of the array
            let len := sload(startIndex)
            // check if targetIndex is less than or equal to len
            let le := or(lt(targetIndex, len), eq(targetIndex, len))
            if le {
                let ptr := add(startIndex, targetIndex)
                sstore(ptr, value)
            }
        }
    }

    // input is the storage slot that we want to read
    function getValInHex(uint256 y) external view returns (bytes32) {
        // since Yul works with hex we want to return in bytes
        bytes32 x;

        assembly {
            // assign value of slot y to x
            x := sload(y)
        }

        return x;
    }

    function readAndWriteToStorage()
        external
        returns (uint256, uint256, uint256)
    {
        uint256 x;
        uint256 y;
        uint256 z;

        assembly {
            // gets slot of var5
            let slot := var5.slot

            // gets offset of var5
            let offset := var5.offset

            // assigns x and y from solidity to slot and offset
            x := slot
            y := offset
            // stores value 1 in slot 0
            sstore(0, 1)

            // assigns z to the value from slot 0
            z := sload(0)
        }
        return (x, y, z);
    }

    function getValFromDynamicArray(
        uint256 targetIndex,
        uint256 slot
    ) external view returns (uint256) {
        // get hash of slot for start index
        bytes32 startIndex = keccak256(abi.encode(slot));

        uint256 result;

        assembly {
            // adds start index and target index to get storage location. Then loads corresponding storage slot
            result := sload(add(startIndex, targetIndex))
        }

        return result;
    }

    function getMappedValue(
        uint256 key,
        uint256 slot
    ) external view returns (uint256) {
        // the code looks very similar to getting an element from a dynamic array. The main difference is that we hash the key and slot together.

        // hashs the key and uint256 value of slot
        bytes32 location = keccak256(abi.encode(key, slot));

        uint256 result;

        // loads storage slot of location and returns result
        assembly {
            result := sload(location)
        }

        return result;
    }

    function getNestedMappedValue(
        uint256 key1,
        uint256 key2,
        uint256 slot
    ) external view returns (uint256) {

        // hashs the key and uint256 value of slot
        bytes32 location = keccak256(
            abi.encode(key2, keccak256(abi.encode(key1, slot)))
        );

        uint256 result;

        // loads storage slot of location and returns result
        assembly {
            result := sload(location)
        }

        return result;
    }

    function addOneAnTwo() external pure returns (uint256) {
        // We can access variables from solidity inside our Yul code
        uint256 result;

        assembly {
            // assigns variables in Yul
            let one := 1
            let two := 2
            // adds the two variables together
            result := add(one, two)
        }
        return result;
    }

    function howManyEvens(
        uint256 startNum,
        uint256 endNum
    ) external pure returns (uint256) {
        // the value we will return
        uint256 result;
        uint MAX = 100;

        assembly {
            // syntax for for loop
            for {
                let i := startNum
            } lt(i, add(endNum, 1)) {
                i := add(i, 1)
            } {
                // if i == 0 skip this iteration
                if iszero(i) {
                    continue
                }

                // checks if i % 2 == 0
                // we could of used iszero `iszero(mod(i, 2))`, but I wanted to show you eq()
                if eq(mod(i, 2), 0) {
                    result := add(result, 1)
                }

                if gt(i, MAX) {
                    break
                }
            }
        }

        return result;
    }
}
