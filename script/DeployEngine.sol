// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ErkCoin} from "../src/tokens/ErkCoin.sol";
import {Weth} from "../src/tokens/Weth.sol";
import {MockV3Aggregator} from "../test/MockV3Aggregator.sol";
import {UniswapV3Factory} from "@uniswap/v3-core/contracts/UniswapV3Factory.sol";
import {SwapRouter} from "@uniswap/v3-periphery/contracts/SwapRouter.sol";

contract DeployEngine is Script {
    uint8 constant DECIMALS = 8;
    int256 constant ERK_INITIAL_PRICE = 3000;
    int256 constant WETH_INITIAL_PRICE = 1000;
    
    function run() public returns (ErkCoin, Weth) {
        vm.startBroadcast();
        // tokens
        ErkCoin erk = new ErkCoin();
        Weth weth = new Weth();

        // mock oracles
        MockV3Aggregator erkPriceFeed = new MockV3Aggregator(DECIMALS, ERK_INITIAL_PRICE);
        MockV3Aggregator wethPriceFeed = new MockV3Aggregator(DECIMALS, WETH_INITIAL_PRICE);

        // factory and router
        UniswapV3Factory factory = new UniswapV3Factory(); // fee: 0.3% 
        SwapRouter router = new SwapRouter(address(factory), address(wethPriceFeed));
        
        vm.stopBroadcast();

        return (erk, weth);
    }
}