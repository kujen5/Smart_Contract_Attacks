// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {DoS} from "../src/DoS.sol";

contract DoSTest is Test {
    DoS dos;
    uint256 constant public NUMBER_OF_PLAYERS = 100;
    uint256 public constant ENTRANCE_FEE = 0.01 ether;


    function setUp() public {
        dos = new DoS();
    }

    function testDenialOfService() public {
        vm.txGasPrice(1);
        
        

        address[] memory playersTest = new address[](NUMBER_OF_PLAYERS);
        for (uint256 i = 0; i < NUMBER_OF_PLAYERS; i++) {
            playersTest[i] = address(uint160(i));
        }
        uint256 gasAtStart=gasleft();
        dos.enterCompetition{value: ENTRANCE_FEE * NUMBER_OF_PLAYERS}(playersTest);
        uint256 gasAtEnd=gasleft();
        uint256 gasUsed=( gasAtStart - gasAtEnd) * tx.gasprice;
        console.log("Used gas amount: ",gasUsed);

        
        for (uint256 i = 0; i < NUMBER_OF_PLAYERS; i++) {
            playersTest[i] = address(uint160(i+NUMBER_OF_PLAYERS));
        }
        gasAtStart=gasleft();
        dos.enterCompetition{value: ENTRANCE_FEE * NUMBER_OF_PLAYERS}(playersTest);
        gasAtEnd=gasleft();
        uint256 gasUsed2=( gasAtStart - gasAtEnd) * tx.gasprice;
        console.log("Used gas amount: ",gasUsed2);

    }
}
