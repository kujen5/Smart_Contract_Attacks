// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {InternationalBank} from "../src/InternationalBank.sol";
import {Attacker} from "../src/Attacker.sol";

contract WorkflowTest is Test {
    address user=makeAddr("Kujen");
    InternationalBank public internationalBank;
    Attacker public attacker;

    function setUp() external {
        internationalBank = new InternationalBank();
        attacker = new Attacker(address(internationalBank));
    }
    function testAttackerCanStealAllETH() public {
        vm.deal(user, 10 ether);
        vm.prank(user);
        internationalBank.depositETH{value: 5 ether}();

        assertEq(address(internationalBank).balance, 5 ether);
        attacker.Steal{value: 1 ether}();
        assertEq(address(internationalBank).balance, 0);
        assertEq(address(attacker).balance, 6 ether);
      
    }


}