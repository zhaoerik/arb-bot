// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ErkCoin} from "./tokens/ErkCoin.sol";
import {Weth} from "./tokens/Weth.sol";
import {MockV3Aggregator} from "../test/MockV3Aggregator.sol";
import {SwapRouter} from "@uniswap/v3-periphery/contracts/SwapRouter.sol";

contract ArbitrageBot {
    ErkCoin erk;
    Weth weth;
    MockV3Aggregator erkPriceFeed;
    MockV3Aggregator wethPriceFeed;
    SwapRouter routerA;
    SwapRouter routerB;

    uint8 constant public PRICE_DISCREPENCY_THRESHOLD = 5; // 5%

    constructor(
        ErkCoin _erkcoin,
        Weth _weth,
        address _erkPriceFeed,
        address _wethPriceFeed,
        SwapRouter _routerA,
        SwapRouter _routerB
    ) {
        erk = _erkcoin;
        weth = _weth;
        erkPriceFeed = MockV3Aggregator(_erkPriceFeed);
        wethPriceFeed = MockV3Aggregator(_wethPriceFeed);
        routerA = _routerA;
        routerB = _routerB;
    }

    function arbitrageInA() external {
        
    }


    function getErkCoinPrice() public view returns (int256) {
        (, int256 price,,,) = erkPriceFeed.latestRoundData();
        return price;
    }

    function getWethPrice() public view returns (int256) {
        (, int256 price,,,) = wethPriceFeed.latestRoundData();
        return price;
    }
}
