// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";

contract Token is ERC777 {
    constructor(string memory name_, string memory symbol_, address[] memory defaultOperators_, uint256 initialSupply_)
        ERC777(name_, symbol_, defaultOperators_)
    {
        _mint(msg.sender, initialSupply_, "", "");
    }
}
