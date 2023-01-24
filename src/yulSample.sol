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

    struct Var10 {
        uint256 subVar1;
        uint256 subVar2;
    }

    constructor() {
        var8[uint(1)] = uint(2);
        var9[0][1] = uint(2);
    }

    function getStructValues() external pure returns (uint256, uint256) {
        // initialize struct
        Var10 memory s;
        s.subVar1 = 32; // 0x80 - 0xa0
        s.subVar2 = 64; // 0xa0 - 0xc0

        assembly {
            return(0x80, 0xc0)
        }
    }

    function createArray(uint range) public returns (uint256[] memory) {
        uint256[] memory arr = new uint256[](range);

        unchecked {
            for (uint i = 0; i < range; i++) {
                arr[i] = i;
            }
        }
        return arr;
    }

    function createDynamicArray(
        uint range
    ) public view returns (uint256[] memory) {
        uint MAX = 22; // First 22 words are linear, then quadratic.. Set only for MAX uint256..

        if (range > MAX) {
            range = MAX;
        }

        assembly {
            // Create an dynamic sized array manually.
            // Don't need to define the data type here as the EVM will prefix it
            let location := mload(0x40) // Get the highest available block of memory

            // mstore(location, 0) // Set size to range

            for {
                let i := 0
            } lt(i, range) {
                i := add(i, 1)
            } {
                // get next available memory location.
                let nextMemoryLocation := add(
                    add(location, 0x20), // add 32 bytes to the location (skip the length of the array)
                    mul(0x20, add(i, 1)) // multiplying the length of the array by 32 bytes. This advances us to the next memory location AFTER our array.
                )
                // stores new value to memory
                mstore(nextMemoryLocation, i)

                mstore(location, add(i, 1)) // Set size to range

                mstore(0x40, mul(0x20, add(i, 2))) // Update the msize offset to be our memory reference plus the amount of bytes we're using
            }
            return(add(location, 0x20), mul(range, 0x20))
        }
    }

    function getDynamicArray(
        uint256[] memory arr
    ) external view returns (uint256[] memory) {
        assembly {
            // where array is stored in memory (0x80)
            let location := arr

            // length of array is stored at arr (4)
            let length := mload(arr)

            // get next available memory location.
            let nextMemoryLocation := add(
                add(location, 0x20), // add 32 bytes to the location (skip the length of the array)
                mul(length, 0x20) // multiplying the length of the array by 32 bytes. This advances us to the next memory location AFTER our array.
            )

            // stores new value to memory
            mstore(nextMemoryLocation, 4)

            // increment length by 1
            length := add(length, 1)

            // store new length value to location (0x80)
            mstore(location, add(length, 1))

            // update free memory pointer - There may be other operations required in the contract.
            mstore(0x40, 0x140)

            // Return the updated array.
            //  we have location which is 1 word (32 bytes)
            // then length (5) x 1 word (0x20)
            // memory used = 0x80 - 0x120
            return(add(location, 0x20), mul(length, 0x20))
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

    function getUint128FromSharedSlot(
        uint _slot
    ) external view returns (uint128, uint128) {
        uint128 firstVar;
        uint128 secondVar;

        bytes32 mask = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
        uint offset = 16; // half of 32 bytes..

        assembly {
            // load the slot from storage.
            let slot := sload(_slot)
            // the and() operation sets secondVar to 0x00
            firstVar := and(slot, mask)

            // we shift secondVar to firstVar's position
            // secondVar's old position becomes 0x00
            secondVar := shr(mul(offset, 8), slot)
        }

        return (firstVar, secondVar);
    }

    function writeFirstValue(uint _slot, uint256 newVal) external {
        uint offset = 16; // half of 32 bytes..
        assembly {
            // load slot
            let slot := sload(_slot)

            // isolate firstvalue by shifting left 128 bits
            let shiftedSecondVal := shl(128, mul(offset, 8))

            // combine new value with isolated firstvalue
            let newValueForSlot := or(shiftedSecondVal, newVal)

            // store new value to slot
            sstore(_slot, newValueForSlot)
        }
    }

    function writeSecondValue(uint _slot, uint256 newVal) external {
        uint offset = 16; // half of 32 bytes..
        assembly {
            // load slot
            let slot := sload(_slot)

            // mask for clearing secondvalue
            let
                mask
            := 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff

            // isolate firstvalue
            let clearedFirstValue := and(slot, mask)

            // format new value into secondvalue position
            let shiftedVal := shl(mul(offset, 8), newVal)

            // combine new value with isolated firstvalue
            let newValueForSlot := or(shiftedVal, clearedFirstValue)

            // store new value to slot
            sstore(_slot, newValueForSlot)
        }
    }

    function getSlot() external pure returns (uint slot, uint offset) {
        assembly {
            slot := var5.slot
            offset := var5.offset
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

            // gets offset of secondvalue
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

                // Break here if it exceeds the defined max iterations.
                if gt(i, MAX) {
                    break
                }
            }
        }

        return result;
    }
}
