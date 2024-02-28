// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDToken is ERC20 {
    constructor() ERC20("USDToken", "USDT") {
        _mint(msg.sender, 2000000000 * 10 ** 18);
    }
}