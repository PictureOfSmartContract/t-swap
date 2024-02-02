## Medium `TSwapPool::deposit` is missing deadline check causing transactions to complete even after the deadline

### [M-1] TITLE (Root cause + Impact)

**Description:** The `deposit` function accepts a deadline paramter, which according to the documentation is " The deadline for the transaction to be completed by". However, this parameter is never used. As a consequence, operators that add liquidity to the pool might be executed at unexpected times, in market conditions where the deposit rate is unfavorable.

**Impact:** The transaction could be sent when market conditions are unfavorable to depositm even when adding a dealdine parameter.

**Proof of Concept:** The `deadline` parameter is unused.

**Recommended Mitigation:**

```diff
function deposit(
        uint256 wethToDeposit,
        uint256 minimumLiquidityTokensToMint,
        uint256 maximumPoolTokensToDeposit,
        //@audit-high this deadline parameter is not used
        uint64 deadline
    )
        external
+       revertIfDeadlinePassed(deadline)
        revertIfZero(wethToDeposit)
        returns (uint256 liquidityTokensToMint)
    {


```

## Informationals

### [I-1] `PoolFactory::PoolFactory__PoolDoesNotExistTITLE (Root cause + Impact)` is not used and should be removed

```diff
-    error PoolFactory__PoolDoesNotExist(address tokenAddress);
```

### [I-2] Lacking of zero address checks

```diff
constructor(address wethToken) {
+       if(wethToken == adderss(0)) {
+   revert();
+}
        i_wethToken = wethToken;
    }

```
