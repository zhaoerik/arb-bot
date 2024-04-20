// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ErkCoin} from "./tokens/ErkCoin.sol";
import {Weth} from "./tokens/Weth.sol";
import {MockV3Aggregator} from "../test/MockV3Aggregator.sol";
import {SwapRouter} from "@uniswap/v3-periphery/contracts/SwapRouter.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract ArbitrageBot {
    event ExecutedArbitrageA(uint256 indexed time, uint256 profit);
    
    ErkCoin public erk;
    Weth public weth;
    MockV3Aggregator public erkPriceFeed;
    MockV3Aggregator public wethPriceFeed;
    SwapRouter public routerA;
    SwapRouter public routerB;

    uint8 constant public PRICE_DISCREPENCY_THRESHOLD = 5; // 5%
    uint16 constant private FEE = 3000; // 0.3%
    uint256 constant public DEADLINE = 3 minutes; // deadline

    constructor(
        ErkCoin _erk,
        Weth _weth,
        address[] memory _priceFeeds,
        SwapRouter[] memory _routers
    ) {
        erk = _erk;
        weth = _weth;
        erkPriceFeed = MockV3Aggregator(_priceFeeds[0]);
        wethPriceFeed = MockV3Aggregator(_priceFeeds[1]);
        routerA = _routers[0];
        routerB = _routers[1];
    }

    function arbitrageInA() external { // buy in A (cheaper), sell in B (for profit)
        // approve amount to routerA
        uint256 amountIn = address(this).balance;
        weth.approve(address(routerA), amountIn);

        // swap WETH for ERK using routerA
        // (uint256 amountIn, )
        (uint256 amountOutErk) = routerA.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: address(weth),
                tokenOut: address(erk),
                amountIn: amountIn,
                amountOutMinimum: 1,
                fee: FEE,
                recipient: address(this),
                deadline: block.timestamp + DEADLINE,
                sqrtPriceLimitX96: 0
            })
        );

        // swap ERK for WETH using routerB
        uint256 amountOutWeth = routerB.exactOutputSingle(
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: address(erk),
                tokenOut: address(weth),
                amountOut: amountIn,
                amountInMaximum: amountOutErk,
                fee: FEE,
                recipient: address(this),
                deadline: block.timestamp + DEADLINE,
                sqrtPriceLimitX96: 0
            })
        );
        emit ExecutedArbitrageA(block.timestamp, amountOutWeth - amountIn);
    }

    function arbitrageInB() external {
        
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
