// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/yulSample.sol";

contract YulSampleTest is Test {
    YulSample public yulSample;

    function setUp() public {
        yulSample = new YulSample();
    }

    function testaddOneAnTwo() public {
        assertEq(yulSample.addOneAnTwo(), 3);
    }

    function testHowManyEvens(
        uint startNum,
        uint endNum
    ) external returns (uint) {
        assertEq(yulSample.howManyEvens(0, 20), 10);
    }

    function testHowManyEvensMAX(

    ) external returns (uint) {
        assertEq(yulSample.howManyEvens(0, 200000), 50);
    }

    function testGetValInHex() external {
        bytes32 slot = yulSample.getValInHex(uint(0));
        assertEq(uint(slot), 256);
    }
}
