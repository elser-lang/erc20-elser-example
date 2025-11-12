// SPDX-License-Identifier: GPL 2.0
pragma solidity ^0.8.13;

import {IElserERC20} from "../src/interfaces/IElserERC20.sol";
import {Test, console} from "forge-std/Test.sol";

contract ElserERC20Test is Test {
    IElserERC20 public token;

    address distributor = vm.addr(0x228);
    uint256 public MINT_AMT = 10_000_000e18;

    address alice = vm.addr(0xAAAAAAAA);

    function setUp() public {
        bytes memory bytecode = bytes(
            hex"6012600355336004556102a1806100155f395ff3fe5f3560e01c8063a9059cbb146100f8578063095ea7b3146100ea57806323b872dd146100d257806370720792146100c557806318160ddd146100bc57806370a08231146100a8578063dd62ed3e1461007e578063313ce567146100745763bfe109281461006a575f80fd5b6004545f5260205ff35b6003545f5260205ff35b6100a06024356004355f52600260205260405f20906040526060526040802090565b545f5260205ff35b6100a06004355f52600160205260405f2090565b5f545f5260205ff35b6100d060043561024e565b005b6100e3604435602435600435610199565b5f5260205ff35b6100e3602435600435610175565b6100e360243560043590610114335f52600160205260405f2090565b5491610128815f52600160205260405f2090565b549282811061016b57610166938380920361014b335f52600160205260405f2090565b550161015f825f52600160205260405f2090565b5533610293565b600190565b61029a5f5260205ffd5b90610166918161015f82335f52600260205260405f20906040526060526040802090565b91906101b933845f52600260205260405f20906040526060526040802090565b54926101cd815f52600160205260405f2090565b546101e0835f52600160205260405f2090565b548486106102445784821061016b5784809281610166980361021633875f52600260205260405f20906040526060526040802090565b550361022a845f52600160205260405f2090565b550161023e835f52600160205260405f2090565b55610293565b6101bc5f5260205ffd5b6004548033036102895761026a815f52600160205260405f2090565b5490610283835f549301915f52600160205260405f2090565b55015f55565b6103e75f5260205ffd5b5f5260205260405260605fa056"
        );

        address _token;
        vm.startPrank(distributor);
        assembly {
            _token := create(0, add(bytecode, 32), mload(bytecode))
        }
        vm.stopPrank();

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
