// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ErkCoin} from "../src/tokens/ErkCoin.sol";
import {Weth} from "../src/tokens/Weth.sol";
import {MockV3Aggregator} from "../test/MockV3Aggregator.sol";
import {UniswapV3Factory} from "@uniswap/v3-core/contracts/UniswapV3Factory.sol";
import {SwapRouter} from "@uniswap/v3-periphery/contracts/SwapRouter.sol";
import {ArbitrageBot} from "../src/ArbitrageBot.sol";

contract DeployEngine is Script {
    error Error__PoolAddressFailure();
    
    uint8 constant DECIMALS = 8;
    int256 constant ERK_USD_INITIAL_PRICE = 6000e8;
    int256 constant WETH_USD_INITIAL_PRICE = 3000e8;

    uint24 constant FEE = 3000; // .3%

    address[] priceFeeds;
    SwapRouter[] routers;

    function run() external returns (ArbitrageBot) {
        // deployer key?
        vm.startBroadcast();

        // tokens
        ErkCoin erk = new ErkCoin();
        Weth weth = new Weth();

        // mock oracles
        MockV3Aggregator erkPriceFeed = new MockV3Aggregator(DECIMALS, ERK_USD_INITIAL_PRICE);
        MockV3Aggregator wethPriceFeed;

        priceFeeds.push(address(erkPriceFeed));

        if (block.chainid == 11155111) {
            priceFeeds.push(0x694AA1769357215DE4FAC081bf1f309aDC325306); // sepolia address
        } else { // anvil chain
            wethPriceFeed = new MockV3Aggregator(DECIMALS, WETH_USD_INITIAL_PRICE);
            priceFeeds.push(address(wethPriceFeed));
        }
        

        // factoryA, routerA, poolA
        UniswapV3Factory factoryA = new UniswapV3Factory();
        factoryA.setOwner(address(this));
        address poolAddressA = factoryA.createPool(address(erk), address(weth), FEE);
        SwapRouter routerA = new SwapRouter(address(factoryA), address(wethPriceFeed));
        if (poolAddressA == address(0)) {
            revert Error__PoolAddressFailure();
        }

        // factoryB, routerB, poolB
        UniswapV3Factory factoryB = new UniswapV3Factory();
        factoryB.setOwner(address(this));
        address poolAddressB = factoryB.createPool(address(erk), address(weth), FEE);
        SwapRouter routerB = new SwapRouter(address(factoryB), address(wethPriceFeed));
        if (poolAddressB == address(0)) {
            revert Error__PoolAddressFailure();
        }

        routers.push(routerA);
        routers.push(routerB);

        // arbitrage bot
        ArbitrageBot bot = new ArbitrageBot(erk, weth, priceFeeds, routers);

        vm.stopBroadcast();

        return bot;
    }
}
