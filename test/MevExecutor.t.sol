// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {UniswapV3V2Arbitrage} from "../src/UniswapV3V2Arbitrage.sol";

contract MevExecutorTest is Test {
    UniswapV3V2Arbitrage public arb;

    function setUp() public {
        arb = new UniswapV3V2Arbitrage();
    }
//
//
//    function testFuzz(uint256 x) public {
//        // We first send 1 Eth to the Sender contract.
//        (bool success,) = address(sender).call{value: 1 ether}("");
//        assertTrue(success);
//
//        // We try to drain the contract.
//        sender.guess(x);
//
//        assertEq(address(sender).balance, 1 ether);
//    }

    // in 0xd3d2E2692501A5c9Ca623199D38826e513033a17 weth is tokenB
    uint size = 1 ether;

    function test_Swap() public {
        arb.executeArbitrageIfWethIsTokenB(
        //Uniswap UNI/ETH LP (UNI-V2)
            0xd3d2E2692501A5c9Ca623199D38826e513033a17,
            //UniswapV3 UNI/ETH LP (UNI-V3)
            0x1d42064Fc4Beb5F8aAF85F4617AE8b3b5B8Bd801,
            size,
            0
        );
    }

//    function testFuzz_SetNumber(uint256 x) public {
//        counter.setNumber(x);
//        assertEq(counter.number(), x);
//    }

    receive() external payable {}
}
