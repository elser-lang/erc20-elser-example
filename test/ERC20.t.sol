// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Test, console} from "forge-std/Test.sol";

interface IElserERC20 is IERC20 {
    function distributor() external view returns (address);

    function mintDistributor(uint256 amt) external;
}

contract ElserERC20Test is Test {
    IElserERC20 public token;

    address distributor = vm.addr(0x228);
    uint256 public MINT_AMT = 10_000_000e18;

    address alice = vm.addr(0xbeaf);

    function setUp() public {
        bytes memory bytecode = bytes(
            hex"6012600355336004556102b96100175f396102b95ff3fe5f3560e01c8063a9059cbb146100f8578063095ea7b3146100e357806323b872dd146100cb57806370720792146100be57806318160ddd146100af57806370a082311461009d578063dd62ed3e14610088578063313ce567146100795763bfe109281461006a575f80fd5b610072610285565b5f5260205ff35b61008161027f565b5f5260205ff35b610096602435600435610271565b5f5260205ff35b6100a860043561024b565b5f5260205ff35b6100b7610238565b5f5260205ff35b6100c9600435610200565b005b6100dc60443560243560043561017e565b5f5260205ff35b6100f1602435600435610162565b5f5260205ff35b61010660243560043561010d565b5f5260205ff35b906101173361023d565b54916101228161023d565b54928281106101535761014e938380920361013c3361023d565b55016101478261023d565b553361029d565b600190565b61015b61028b565b5f5260205ffd5b9061017991816101728233610258565b55336102ab565b600190565b919061018a3384610258565b54926101958161023d565b5461019f8361023d565b548486106101f1578482106101e257848092816101dd98036101c13387610258565b55036101cc8461023d565b55016101d78361023d565b5561029d565b600190565b6101ea61028b565b5f5260205ffd5b6101f9610291565b5f5260205ffd5b600454803303610229576102138161023d565b5490610223835f5493019161023d565b55015f55565b610231610297565b5f5260205ffd5b5f5490565b5f52600160205260405f2090565b6102549061023d565b5490565b5f52600260205260405f20906040526060526040802090565b9061027b91610258565b5490565b60035490565b60045490565b61029a90565b6101bc90565b6103e790565b5f5260205260405260605fa0565b5f5260205260405260605fa056"
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
