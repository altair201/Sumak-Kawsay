// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AMDtoken is ERC20 {
    constructor() ERC20("AMDtoken", "AMD") {
        _mint(msg.sender, 2000000000 * 10 ** 18);
    }
}