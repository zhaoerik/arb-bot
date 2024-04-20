// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ArbitrageBot} from "../src/ArbitrageBot.sol";
import {DeployEngine} from "../script/DeployEngine.sol";
import {Test} from "forge-std/Test.sol";

contract ArbitrageBotTest is Test {
    DeployEngine deployer;
    ArbitrageBot bot;

    function setUp() public {
        deployer = new DeployEngine();
        bot = deployer.run();
    }

    function testGetErkCoinPrice() public view {
        int256 got = bot.getErkCoinPrice();
        int256 want = 6000e8;

        assertEq(got, want);
    }

    function testUsdToEther(int256 _amount) public returns (int256) {

    }
}
