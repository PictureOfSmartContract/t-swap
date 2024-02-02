// SPDX-License-Identifier: GNU General Public License v3.0
pragma solidity 0.8.20;

import { Test } from "../../lib/forge-std/src/Test.sol";
import { StdInvariant } from "../../lib/forge-std/src/StdInvariant.sol";
import { ERC20Mock } from "../mocks/ERC20Mock.sol";
import { PoolFactory } from "../../src/PoolFactory.sol";
import { TSwapPool } from "../../src/TSwapPool.sol";
import { Handler } from "./Handler.t.sol";

contract Invariant is StdInvariant, Test {
    ERC20Mock poolToken;
    ERC20Mock weth;
    PoolFactory factory;
    TSwapPool pool;
    Handler handler;

    int256 STARTING_X = 100e18; //Starting ERC20/poolToken
    int256 STARTING_Y = 50e18; //Starting WETH/poolToken

    function setUp() public {
        weth = new ERC20Mock();
        poolToken = new ERC20Mock();
        factory = new PoolFactory(address(weth));
        pool = TSwapPool(factory.createPool(address(poolToken)));
        handler = new Handler(pool);

        //create those initial balance of x & y
        poolToken.mint(address(this), uint256(STARTING_X));
        weth.mint(address(this), uint256(STARTING_Y));

        poolToken.approve(address(pool), type(uint256).max);
        weth.approve(address(pool), type(uint256).max);

        pool.deposit(uint256(STARTING_Y), uint256(STARTING_Y), uint256(STARTING_X), uint64(block.timestamp));

        bytes4[] memory selectors = new bytes4[](2);

        selectors[0] = Handler.deposit.selector;
        selectors[1] = Handler.swapPoolTokenForWethBasedOnOutputWeth.selector;

        targetSelector(FuzzSelector({ addr: address(handler), selectors: selectors }));
        targetContract(address(handler));
    }

    function statefulFuzz_constantProductFormulaStaysTheSameX() public {
        assertEq(handler.actualDeltaX(), handler.expectedDeltaX());
    }

    function statefulFuzz_constantProductFormulaStaysTheSameY() public {
        assertEq(handler.actualDeltaY(), handler.expectedDeltaY());
    }
}
