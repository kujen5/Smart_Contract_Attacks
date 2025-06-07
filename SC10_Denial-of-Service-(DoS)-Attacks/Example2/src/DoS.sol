// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

contract DoS {
    event DoS__NewPlayersJoinedCompetition();

    address[] public s_players;
    uint256 public constant ENTRANCE_FEE = 0.01 ether;

    function enterCompetition(address[] memory p_newPlayersArray) public payable {
        require(msg.value == ENTRANCE_FEE * p_newPlayersArray.length, "Must send enough money to be able to enroll.");

        for (uint256 i = 0; i < p_newPlayersArray.length; i++) {
            s_players.push(p_newPlayersArray[i]);
        }

        for (uint256 i = 0; i < s_players.length - 1; i++) {
            for (uint256 j = i + 1; j < s_players.length; j++) {
                require(s_players[i] != s_players[j], "Forbidden. Player is already registered.");
            }
        }
        emit DoS__NewPlayersJoinedCompetition();
    }
}