// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {IdeaETH} from "../src/IdeaETH.sol";

contract IdeaETHTest is Test {
    IdeaETH public ideaETH;

    uint256 SUMMER = 1695513599;
    uint256 NOT_SUMMER = 1727136000;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        ideaETH = new IdeaETH();
    }

    receive() payable external {}

    function test_deposit() public {
        vm.deal(address(this), 2 ether);
        vm.warp(SUMMER);
        ideaETH.deposit{value: 1 ether}();
        assertEq(address(ideaETH).balance, 1 ether);
        vm.warp(NOT_SUMMER);
        ideaETH.deposit{value: 1 ether}();
        assertEq(address(ideaETH).balance, 2 ether);
    }

    function test_withdraw() public {
        vm.deal(address(this), 1 ether);
        vm.warp(SUMMER);
        ideaETH.deposit{value: 1 ether}();
        assertEq(address(ideaETH).balance, 1 ether);

        ideaETH.withdraw(1 ether);
        assertEq(address(ideaETH).balance, 0 ether);

        vm.warp(NOT_SUMMER);
        vm.expectRevert();
        ideaETH.withdraw(1 ether);
    }

    function test_receive() public {
        vm.deal(address(this), 2 ether);
        vm.warp(SUMMER);
        (bool s,) = address(ideaETH).call{value: 1 ether}("");
        require(s, "call failed");
        assertEq(address(ideaETH).balance, 1 ether);
        vm.warp(NOT_SUMMER);
        (s, ) = address(ideaETH).call{value: 1 ether}("");
        require(s, "call failed");
        assertEq(address(ideaETH).balance, 2 ether);
    }

    function test_approve() public {
        vm.deal(address(this), 1 ether);
        vm.warp(SUMMER);
        ideaETH.deposit{value: 1 ether}();
        assertEq(address(ideaETH).balance, 1 ether);
        ideaETH.approve(alice, 1);

        vm.warp(NOT_SUMMER);
        vm.expectRevert();
        ideaETH.approve(alice, 1);
    }

    function test_transfer() public {
        vm.deal(address(this), 1 ether);
        vm.warp(SUMMER);
        ideaETH.deposit{value: 1 ether}();
        assertEq(address(ideaETH).balance, 1 ether);
        ideaETH.transfer(alice, 1);

        vm.warp(NOT_SUMMER);
        vm.expectRevert();
        ideaETH.transfer(alice, 1);
    }

    function test_transferFrom() public {
        vm.deal(address(this), 1 ether);
        vm.warp(SUMMER);
        ideaETH.deposit{value: 1 ether}();
        assertEq(address(ideaETH).balance, 1 ether);
        ideaETH.approve(alice, 2);

        vm.prank(alice);
        ideaETH.transferFrom(address(this), bob, 1);

        vm.warp(NOT_SUMMER);
        vm.expectRevert();
        vm.prank(alice);
        ideaETH.transferFrom(address(this), bob, 1);
    }

    function test_summer() public {
        vm.warp(SUMMER);
        assertEq(ideaETH.summer(), true);

        vm.warp(NOT_SUMMER);
        assertEq(ideaETH.summer(), false);

        assertEq(ideaETH.summer(1695513599), true, "2023-09-23 23:59:59 UTC");
        assertEq(ideaETH.summer(1695513600), false, "2023-09-24 00:00:00 UTC");

        assertEq(ideaETH.summer(1696118400), false, "2023-10-01 00:00:00 UTC");
        assertEq(ideaETH.summer(1698796800), false, "2023-11-01 00:00:00 UTC");
        assertEq(ideaETH.summer(1701388800), false, "2023-12-01 00:00:00 UTC");
        assertEq(ideaETH.summer(1704067200), false, "2024-01-01 00:00:00 UTC");
        assertEq(ideaETH.summer(1706745600), false, "2024-02-01 00:00:00 UTC");
        assertEq(ideaETH.summer(1711929600), false, "2024-03-01 00:00:00 UTC");
        assertEq(ideaETH.summer(1714521600), false, "2024-04-01 00:00:00 UTC");
        assertEq(ideaETH.summer(1717200000), false, "2024-05-01 00:00:00 UTC");

        assertEq(ideaETH.summer(1718928000), true, "2024-06-21 00:00:00 UTC");

        assertEq(ideaETH.summer(1719792000), true, "2023-07-01 00:00:00 UTC");
        assertEq(ideaETH.summer(1722470400), true, "2024-08-01 00:00:00 UTC");
        assertEq(ideaETH.summer(1725148800), true, "2024-09-01 00:00:00 UTC");

        assertEq(ideaETH.summer(1727135999), true, "2024-09-23 23:59:59 UTC");
        assertEq(ideaETH.summer(1727136000), false, "2024-09-24 00:00:00 UTC");

        assertEq(ideaETH.summer(1971302400), false, "2032-06-20 23:59:59 UTC");
        assertEq(ideaETH.summer(1971388800), true, "2032-06-21 00:00:00 UTC");
        assertEq(ideaETH.summer(1979596799), true, "2032-09-23 23:59:59 UTC");
        assertEq(ideaETH.summer(1979596800), false, "2032-09-24 00:00:00 UTC");
    }

}
