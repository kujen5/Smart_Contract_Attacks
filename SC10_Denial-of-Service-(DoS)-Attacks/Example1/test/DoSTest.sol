// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DoS} from "../src/DoS.sol";

contract DoSTest is Test {
    DoS dos;

    function setUp() public {
        dos = new DoS();
    }

    function testDenialOfService() public {
        vm.txGasPrice(1);
        address[] memory playersTest = new address[](110);
        for (uint256 i = 0; i < playersTest.length - 1; i++) {
            playersTest[i] = address(uint160(i));
        }

        for (uint256 i = 0; i < playersTest.length - 1; i++) {
            address user;
            user = makeAddr(vm.toString(i));
            vm.deal(user, 1 ether);
            vm.prank(user);
            dos.enterCompetition{value: 1 ether}();
        }
    }
}
