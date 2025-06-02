// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;
///@dev This contract aims at helping user pick a random number, if your random number is correct you win!
import {console} from "forge-std/console.sol";

contract WeakRandomness{


    constructor() payable{}
    receive() external payable{}
    function guessRandomNumber(uint256 p_guessedNumber) public{
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(msg.sender,block.timestamp,block.prevrandao,blockhash(block.number - 1))));
        console.log("random number:",randomNumber);
        if (p_guessedNumber == randomNumber){
            console.log("entered");
            (bool success,)=msg.sender.call{value: 1 ether}("");
            require(success,"Failed to sent prize");
        }

    }
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}