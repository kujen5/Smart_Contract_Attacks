// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;
import {Test} from "forge-std/Test.sol";

import {WeakRandomness} from "../src/WeakRandomness.sol";
import {Attacker} from "../src/Attacker.sol";
import {console} from "forge-std/console.sol";



contract WorkflowTest is Test{
    WeakRandomness weakRandomness;
    Attacker attacker;

    function setUp() external{
        weakRandomness = new WeakRandomness();
        attacker = new Attacker();  
        vm.deal(address(this), 10 ether);
        payable(address(weakRandomness)).transfer(5 ether);
    }
    function testAttackerCanGuessNumberCorrectlyEachTime() public {
        assertEq(address(weakRandomness).balance, 5 ether);
        assertEq(address(attacker).balance, 0);
        attacker.Steal(weakRandomness);
        assertEq(address(weakRandomness).balance, 4 ether);
        assertEq(address(attacker).balance, 1 ether);

        // Now if we do the same thing 4 more times, we'll steal all the funds:
        vm.roll(2);
        attacker.Steal(weakRandomness);
        vm.roll(3);
        attacker.Steal(weakRandomness);
        vm.roll(4);
        attacker.Steal(weakRandomness);
        vm.roll(5);
        attacker.Steal(weakRandomness);
        assertEq(address(weakRandomness).balance, 0);
        assertEq(address(attacker).balance, 5 ether);
    }
}
