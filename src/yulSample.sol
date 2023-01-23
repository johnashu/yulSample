// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract YulSample {
    // slot 0
    // 0x0000000000000000000000000000000000000000000000000000000000000100
    uint256 var1 = 256;

    // slot 1
    // 0x0000000000000000000000009acc1d6aa9b846083e8a497a661853aae07f0f00
    address var2 = 0x9ACc1d6Aa9b846083E8a497A661853aaE07F0F00;

    // slot 2
    // 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    bytes32 var3 =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    // slot 3
    // 0x0000000000000000000000000000000200000000000000000000000000000001
    // 0x000000000000000000000000000002 and 0x000000000000000000000000000001
    uint128 var4 = 1;
    uint128 var5 = 2;

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

    function addOneAnTwo() external pure returns (uint256) {
        // We can access variables from solidity inside our Yul code
        uint256 ans;

        assembly {
            // assigns variables in Yul
            let one := 1
            let two := 2
            // adds the two variables together
            ans := add(one, two)
        }
        return ans;
    }

    function howManyEvens(
        uint256 startNum,
        uint256 endNum
    ) external pure returns (uint256) {
        // the value we will return
        uint256 ans;
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
                    ans := add(ans, 1)
                }

                if gt(i, MAX) {
                    break
                }
            }
        }

        return ans;
    }
}
