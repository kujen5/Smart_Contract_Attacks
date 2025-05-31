// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract InternationalBank {
    mapping(address => uint256) public userToETHDepositedBalance;

    function depositETH() public payable {
        userToETHDepositedBalance[msg.sender] += msg.value;
    }

    function withdrawETH() public {
        uint256 userBalance = userToETHDepositedBalance[msg.sender];
        require(userBalance > 0, "You do not have enough balance to withdraw. Please deposit first.");
        (bool success,) = msg.sender.call{value: userBalance}("");
        require(success, "Transfer failed.");

        userToETHDepositedBalance[msg.sender] = 0;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
