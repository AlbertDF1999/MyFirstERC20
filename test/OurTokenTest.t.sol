//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 constant STARTING_BALANCE = 100 ether;

    function setUp() external {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        console.log(address(ourToken).balance);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }

    function testAllowancesWork() public {
        uint256 initialAllowance = 1000;

        //Bob approves alice to spend tokens on her behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    // function testInitialSupply() public {
    //     assertEq(ourToken.totalSupply(), ourToken.balanceOf(deployer));
    // }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    // =========================
    // Transfer Tests
    // =========================

    function testTransfer() public {
        uint256 amount = 10 ether;

        vm.prank(bob);
        bool success = ourToken.transfer(alice, amount);

        assertTrue(success);
        assertEq(ourToken.balanceOf(alice), amount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - amount);
    }

    function testTransferFromDeployer() public {
        uint256 deployerBalance = ourToken.balanceOf(msg.sender);
        uint256 amount = 50 ether;

        vm.prank(msg.sender);
        ourToken.transfer(alice, amount);

        assertEq(ourToken.balanceOf(alice), amount);
        assertEq(ourToken.balanceOf(msg.sender), deployerBalance - amount);
    }

    function testTransferFailsWithInsufficientBalance() public {
        uint256 amount = STARTING_BALANCE + 1;

        vm.prank(bob);
        vm.expectRevert();
        ourToken.transfer(alice, amount);
    }

    function testTransferToZeroAddress() public {
        vm.prank(bob);
        vm.expectRevert();
        ourToken.transfer(address(0), 10 ether);
    }

    function testTransferEmitsEvent() public {
        uint256 amount = 10 ether;

        vm.prank(bob);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(bob, alice, amount);
        ourToken.transfer(alice, amount);
    }

    // =========================
    // Allowance Tests
    // =========================

    function testApprove() public {
        uint256 amount = 50 ether;

        vm.prank(bob);
        bool success = ourToken.approve(alice, amount);

        assertTrue(success);
        assertEq(ourToken.allowance(bob, alice), amount);
    }

    function testApproveEmitsEvent() public {
        uint256 amount = 50 ether;

        vm.prank(bob);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Approval(bob, alice, amount);
        ourToken.approve(alice, amount);
    }

    function testTransferFrom() public {
        uint256 amount = 50 ether;

        // Bob approves Alice to spend tokens
        vm.prank(bob);
        ourToken.approve(alice, amount);

        // Alice transfers from Bob to herself
        vm.prank(alice);
        bool success = ourToken.transferFrom(bob, alice, amount);

        assertTrue(success);
        assertEq(ourToken.balanceOf(alice), amount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - amount);
        assertEq(ourToken.allowance(bob, alice), 0);
    }

    function testTransferFromToThirdParty() public {
        uint256 amount = 30 ether;
        address charlie = makeAddr("charlie");

        vm.prank(bob);
        ourToken.approve(alice, amount);

        vm.prank(alice);
        ourToken.transferFrom(bob, charlie, amount);

        assertEq(ourToken.balanceOf(charlie), amount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - amount);
    }

    function testTransferFromFailsWithoutApproval() public {
        vm.prank(alice);
        vm.expectRevert();
        ourToken.transferFrom(bob, alice, 10 ether);
    }

    function testTransferFromFailsWithInsufficientAllowance() public {
        uint256 approvalAmount = 30 ether;
        uint256 transferAmount = 50 ether;

        vm.prank(bob);
        ourToken.approve(alice, approvalAmount);

        vm.prank(alice);
        vm.expectRevert();
        ourToken.transferFrom(bob, alice, transferAmount);
    }

    function testTransferFromEmitsEvent() public {
        uint256 amount = 40 ether;

        vm.prank(bob);
        ourToken.approve(alice, amount);

        vm.prank(alice);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(bob, alice, amount);
        ourToken.transferFrom(bob, alice, amount);
    }

    // function testIncreaseAllowance() public {
    //     uint256 initialAllowance = 50 ether;
    //     uint256 increaseAmount = 25 ether;

    //     vm.startPrank(bob);
    //     ourToken.approve(alice, initialAllowance);
    //     ourToken.increaseAllowance(alice, increaseAmount);
    //     vm.stopPrank();

    //     assertEq(
    //         ourToken.allowance(bob, alice),
    //         initialAllowance + increaseAmount
    //     );
    // }

    // function testDecreaseAllowance() public {
    //     uint256 initialAllowance = 50 ether;
    //     uint256 decreaseAmount = 20 ether;

    //     vm.startPrank(bob);
    //     ourToken.approve(alice, initialAllowance);
    //     ourToken.decreaseAllowance(alice, decreaseAmount);
    //     vm.stopPrank();

    //     assertEq(
    //         ourToken.allowance(bob, alice),
    //         initialAllowance - decreaseAmount
    //     );
    // }

    // function testDecreaseAllowanceFailsWhenDecreaseBelowZero() public {
    //     uint256 allowance = 30 ether;

    //     vm.startPrank(bob);
    //     ourToken.approve(alice, allowance);
    //     vm.expectRevert();
    //     ourToken.decreaseAllowance(alice, allowance + 1);
    //     vm.stopPrank();
    // }

    // =========================
    // Balance Tests
    // =========================

    function testBalanceOf() public {
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
        assertEq(ourToken.balanceOf(alice), 0);
    }

    function testTotalSupplyRemainsConstant() public {
        uint256 initialSupply = ourToken.totalSupply();

        vm.prank(bob);
        ourToken.transfer(alice, 50 ether);

        assertEq(ourToken.totalSupply(), initialSupply);
    }

    // =========================
    // Metadata Tests
    // =========================

    function testName() public {
        assertEq(ourToken.name(), "OurToken");
    }

    function testSymbol() public {
        assertEq(ourToken.symbol(), "OT");
    }

    function testDecimals() public {
        assertEq(ourToken.decimals(), 18);
    }

    // =========================
    // Edge Case Tests
    // =========================

    function testTransferZeroAmount() public {
        vm.prank(bob);
        bool success = ourToken.transfer(alice, 0);
        assertTrue(success);
    }

    function testTransferFromZeroAmount() public {
        vm.prank(bob);
        ourToken.approve(alice, 100 ether);

        vm.prank(alice);
        bool success = ourToken.transferFrom(bob, alice, 0);
        assertTrue(success);
    }

    function testApproveZeroAmount() public {
        vm.prank(bob);
        bool success = ourToken.approve(alice, 0);
        assertTrue(success);
        assertEq(ourToken.allowance(bob, alice), 0);
    }

    function testMultipleApprovals() public {
        vm.startPrank(bob);
        ourToken.approve(alice, 100 ether);
        assertEq(ourToken.allowance(bob, alice), 100 ether);

        ourToken.approve(alice, 50 ether);
        assertEq(ourToken.allowance(bob, alice), 50 ether);
        vm.stopPrank();
    }

    function testTransferToSelf() public {
        uint256 initialBalance = ourToken.balanceOf(bob);

        vm.prank(bob);
        ourToken.transfer(bob, 10 ether);

        assertEq(ourToken.balanceOf(bob), initialBalance);
    }

    // =========================
    // Fuzz Tests
    // =========================

    // function testFuzzTransfer(address to, uint256 amount) public {
    //     vm.assume(to != address(0));
    //     amount = bound(amount, 0, STARTING_BALANCE);

    //     vm.prank(bob);
    //     ourToken.transfer(to, amount);

    //     if (to == bob) {
    //         assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    //     } else {
    //         assertEq(ourToken.balanceOf(to), amount);
    //         assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - amount);
    //     }
    // }

    // function testFuzzApprove(address spender, uint256 amount) public {
    //     vm.assume(spender != address(0));

    //     vm.prank(bob);
    //     ourToken.approve(spender, amount);

    //     assertEq(ourToken.allowance(bob, spender), amount);
    // }

    // function testFuzzTransferFrom(address to, uint256 amount) public {
    //     vm.assume(to != address(0));
    //     amount = bound(amount, 0, STARTING_BALANCE);

    //     vm.prank(bob);
    //     ourToken.approve(alice, amount);

    //     vm.prank(alice);
    //     ourToken.transferFrom(bob, to, amount);

    //     assertEq(ourToken.balanceOf(to), amount);
    // }
}
