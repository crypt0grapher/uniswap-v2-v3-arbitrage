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

    function test_Swap() public {
        arb.executeArbitrageIfWethIsTokenA(
            //Uniswap ETH/USDT LP (UNI-V2)
            0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852,
            //UniswapV3 ETH/USDT LP (UNI-V3)
            0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8,
            1 ether,
            0
        );
    }

//    function testFuzz_SetNumber(uint256 x) public {
//        counter.setNumber(x);
//        assertEq(counter.number(), x);
//    }
}
