// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract YulSample {
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
                if eq(mod(i, 2), 0)  {
                    ans := add(ans, 1)
                }

                if gt(i, MAX){
                    break
                }
            }
        }

        return ans;
    }
}
