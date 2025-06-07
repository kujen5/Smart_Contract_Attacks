// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract DoS {
    event DoS__NewPlayersJoinedCompetition();

    address[] public s_players;
    uint256 public constant ENTRANCE_FEE = 0.01 ether;

    function enterCompetition() public payable {
        require(msg.value >= ENTRANCE_FEE * s_players.length, "Must send enough money to be able to enroll.");

        for (uint256 i = 0; i < s_players.length; i++) {
            require(s_players[i] != msg.sender, "Forbidden. Player is already registered.");
        }
        s_players.push(msg.sender);
        emit DoS__NewPlayersJoinedCompetition();
    }
}
