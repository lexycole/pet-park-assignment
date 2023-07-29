// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PetPark.sol";

contract PetParkTest is Test, PetPark {
    PetPark petPark;

    address testOwnerAccount;

    address testPrimaryAccount;
    address testSecondaryAccount;

    function setUp() public {
        petPark = new PetPark();

        testOwnerAccount = msg.sender;
        testPrimaryAccount = address(0xABCD);
        testSecondaryAccount = address(0xABDC);
    }

    function testOwnerCanAddAnimal() public {
        petPark.add(AnimalType.Fish, 5);
    }
    // Test that any non-owner account cannot add animals using the add function
    function testCannotAddAnimalWhenNonOwner() public {
        vm.prank(testPrimaryAccount);
        vm.expectRevert("Only the contract owner can perform this operation");
        petPark.add(AnimalType.Fish, 5);
    }

    function testCannotAddInvalidAnimal() public {
        vm.expectRevert("Invalid animal");
        petPark.add(AnimalType.None, 5);
    }

    function testExpectEmitAddEvent() public {
        vm.expectEmit(false, false, false, true);

        emit Added(AnimalType.Fish, 5);
        petPark.add(AnimalType.Fish, 5);
    }
    // Test that the borrow function fails when called with an age equal to 0
    function testCannotBorrowWhenAgeZero() public {
        petPark.add(AnimalType.Fish, 5);
        vm.expectRevert("Invalid Age");
        petPark.borrow(0, Gender.Male, AnimalType.Fish);
    }

    function testCannotBorrowUnavailableAnimal() public {
        vm.expectRevert("Selected animal not available");

        petPark.borrow(24, Gender.Male, AnimalType.Fish);
    }

    function testCannotBorrowInvalidAnimal() public {
        vm.expectRevert("Invalid animal type");

        petPark.borrow(24, Gender.Male, AnimalType.None);
    }

    function testCannotBorrowCatForMen() public {
        petPark.add(AnimalType.Cat, 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, Gender.Male, AnimalType.Cat);
    }

    function testCannotBorrowRabbitForMen() public {
        petPark.add(AnimalType.Rabbit, 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, Gender.Male, AnimalType.Rabbit);
    }

    function testCannotBorrowParrotForMen() public {
        petPark.add(AnimalType.Parrot, 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, Gender.Male, AnimalType.Parrot);
    }

    function testCannotBorrowForWomenUnder40() public {
        petPark.add(AnimalType.Cat, 5);

        vm.expectRevert("Invalid animal for women under 40");
        petPark.borrow(24, Gender.Female, AnimalType.Cat);
    }

    function testCannotBorrowTwiceAtSameTime() public {
        petPark.add(AnimalType.Fish, 5);
        petPark.add(AnimalType.Cat, 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

        vm.expectRevert("Already adopted a pet");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

        vm.expectRevert("Already adopted a pet");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Cat);
    }

    function testCannotBorrowWhenAddressDetailsAreDifferent() public {
        petPark.add(AnimalType.Fish, 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

        vm.expectRevert("Invalid Age");
        vm.prank(testPrimaryAccount);
        petPark.borrow(23, Gender.Male, AnimalType.Fish);

        vm.expectRevert("Invalid Gender");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Female, AnimalType.Fish);
    }

    function testExpectEmitOnBorrow() public {
        petPark.add(AnimalType.Fish, 5);
        vm.expectEmit(false, false, false, true);

        emit Borrowed(AnimalType.Fish);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);
    }
    // Test that the count of animal decreases correctly when the borrow function is called
    function testBorrowCountDecrement() public {
        petPark.add(AnimalType.Fish, 5);
        uint initialCount = petPark.animalCounts(AnimalType.Fish);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);
        uint afterBorrowCount = petPark.animalCounts(AnimalType.Fish);
        assertEq(afterBorrowCount, initialCount - 1);
    }

    function testCannotGiveBack() public {
        vm.expectRevert("No borrowed pets");
        petPark.giveBackAnimal();
    }

    function testPetCountIncrement() public {
        petPark.add(AnimalType.Fish, 5);

        petPark.borrow(24, Gender.Male, AnimalType.Fish);
        uint reducedPetCount = petPark.animalCounts(AnimalType.Fish);

        petPark.giveBackAnimal();
        uint currentPetCount = petPark.animalCounts(AnimalType.Fish);

        assertEq(reducedPetCount, currentPetCount - 1);
    }
}
