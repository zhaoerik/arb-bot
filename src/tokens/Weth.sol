// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Weth is ERC20 {
    constructor() ERC20("Wrapped Ether", "WETH") {
        _mint(msg.sender, 500 * 10 ** decimals());
    }
}