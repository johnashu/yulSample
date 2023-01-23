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

    function testHowManyEvens() external {
        assertEq(yulSample.howManyEvens(0, 20), 10);
    }

    function testHowManyEvensMAX() external {
        assertEq(yulSample.howManyEvens(0, 200000), 50);
    }

    function testGetValInHex() external {
        bytes32 slot = yulSample.getValInHex(uint(0));
        assertEq(uint(slot), 256);
    }

    function testReadAndWriteStorage() external {
        (uint256 x, uint256 y, uint256 z) = yulSample.readAndWriteToStorage();
        assertEq(x, uint(3));
        assertEq(y, uint(16));
        assertEq(z, uint(1));
    }

    function testDynamicArray(uint value) external {
        assertEq(yulSample.getValInHex(6), bytes32(0x00));
        yulSample.addToDynamicArray(value, 0, 6);   

        emit log_bytes32(yulSample.getValInHex(6));    

        // assertEq(yulSample.getValInHex(6), bytes32(0x01));
        assertEq(yulSample.getValFromDynamicArray(0, 6), value);
    }

    function testGetSlot() public {
         uint slot = yulSample.getSlot();
         emit log_uint(slot);
    }

}



