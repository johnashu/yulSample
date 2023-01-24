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
        assertEq(yulSample.getValFromDynamicArray(0, 6), value);
    }

    function testGetMappedValue() public {
        assertEq(yulSample.getMappedValue(1, 7), 2);
    }

    function testGetNestedMappedValue() public {
        assertEq(yulSample.getNestedMappedValue(0, 1, 8), 2);
    }

    function testGetUint128FromSharedSlot() public {
        (uint128 var1, uint128 var2) = yulSample.getUint128FromSharedSlot(3);
        assertEq(var1, uint128(1));
        assertEq(var2, uint128(2));
    }

    function testWriteFirstValue() public {
        assertEq(yulSample.var4(), 1);
        yulSample.writeFirstValue(3, 2123);
        assertEq(yulSample.var4(), 2123);
    }

    function testWriteSecondValue() public {
        assertEq(yulSample.var5(), 2);
        yulSample.writeSecondValue(3, 10);
        assertEq(yulSample.var5(), 10);
    }

    function testGetStructValues() public {
        (uint256 var1, uint256 var2) = yulSample.getStructValues();
        assertEq(var1, uint256(32));
        assertEq(var2, uint256(64));
    }



    function testGetDynamicArray() public {
        assertEq(
            yulSample.createArray(5),
            yulSample.getDynamicArray((yulSample.createDynamicArray(5)))
            
        );
    }

    function testGetSlot() public {
        (uint slot, uint offset) = yulSample.getSlot();
        emit log_uint(slot);
        emit log_uint(offset);
    }
}
