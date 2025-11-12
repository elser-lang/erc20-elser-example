// SPDX-License-Identifier: GPL 2.0
pragma solidity ^0.8.13;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IElserERC20 is IERC20 {
    function distributor() external view returns (address);

    function mintDistributor(uint256 amt) external;
}

