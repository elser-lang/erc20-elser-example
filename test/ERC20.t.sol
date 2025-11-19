// SPDX-License-Identifier: GPL 2.0
pragma solidity ^0.8.13;

import {IElserERC20} from "../src/interfaces/IElserERC20.sol";
import {Test} from "forge-std/Test.sol";

contract ElserERC20Test is Test {
    IElserERC20 public token;

    address distributor = vm.addr(0x228);
    uint256 public MINT_AMT = 10_000_000e18;

    address alice = vm.addr(0xAAAAAAAA);

    function setUp() public {
	bytes memory bytecode = vm.parseBytes(vm.readFile("./elser-artifacts/erc20.bytecode"));

        address _token;
	
        vm.startPrank(distributor);
        assembly {
            _token := create(0, add(bytecode, 32), mload(bytecode))
        }
        vm.stopPrank();

	if (_token == address(0)) revert("CREATE() failed.");
        token = IElserERC20(_token);
    }

    function test_distributor() external {
        address d = token.distributor();
        assertEq(d, distributor);
    }

    function test_mintDistributor() external {
        _mint();
        assertEq(token.balanceOf(distributor), MINT_AMT);
    }

    function test_approveAndTransferFrom() external {
        _mint();

        vm.prank(distributor);
        token.approve(alice, MINT_AMT / 2);

        assertEq(token.allowance(distributor, alice), MINT_AMT / 2);

        // Spend allowance
        vm.startPrank(alice);
        token.transferFrom(distributor, alice, MINT_AMT / 2);

        assertEq(token.balanceOf(distributor), MINT_AMT / 2);
        assertEq(token.balanceOf(alice), MINT_AMT / 2);
        assertEq(token.allowance(distributor, alice), 0);
    }

    function test_transfer() external {
        _mint();

        vm.startPrank(distributor);

        token.transfer(alice, MINT_AMT / 4);
        token.transfer(address(0), MINT_AMT / 4);
        token.transfer(address(this), MINT_AMT / 4);
        token.transfer(address(token), MINT_AMT / 4);

        vm.stopPrank();

        assertEq(token.balanceOf(alice), MINT_AMT / 4);
        assertEq(token.balanceOf(address(0)), MINT_AMT / 4);
        assertEq(token.balanceOf(address(this)), MINT_AMT / 4);
        assertEq(token.balanceOf(address(token)), MINT_AMT / 4);
    }

    function _mint() internal {
        vm.prank(distributor);
        token.mintDistributor(MINT_AMT);
    }
}
