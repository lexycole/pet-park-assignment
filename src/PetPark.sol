// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {
    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }
    enum Gender {
        None,
        Male,
        Female
    }

    struct Borrower {
        uint age;
        Gender gender;
        bool hasBorrowed;
        AnimalType borrowedAnimal;
    }

    address public owner;
    mapping(AnimalType => uint) public animalCounts;
    mapping(address => Borrower) public borrowers;

    event Added(AnimalType indexed animalType, uint count);
    event Borrowed(AnimalType indexed animalType);
    event Returned(AnimalType indexed animalType);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can perform this operation"
        );
        _;
    }

    modifier canBorrow(
        AnimalType _animalType,
        uint _age,
        Gender _gender
    ) {
        require(_animalType != AnimalType.None, "Invalid animal type");
        require(_age > 0, "Invalid Age");
        require(
            animalCounts[_animalType] > 0,
            "This animal type is currently unavailable"
        );

        if (_gender == Gender.Male) {
            require(
                _animalType == AnimalType.Dog || _animalType == AnimalType.Fish,
                "Men can borrow only Dog and Fish"
            );
        } else if (_gender == Gender.Female && _age < 40) {
            require(
                _animalType != AnimalType.Cat,
                "Women under 40 are not allowed to borrow a Cat"
            );
        }

        if (borrowers[msg.sender].hasBorrowed) {
            require(
                borrowers[msg.sender].gender == _gender &&
                    borrowers[msg.sender].age == _age,
                "Cannot borrow with different Age or Gender"
            );
        }

        _;
    }

    function add(AnimalType _animalType, uint _count) public onlyOwner {
        animalCounts[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(
        uint _age,
        Gender _gender,
        AnimalType _animalType
    ) public canBorrow(_animalType, _age, _gender) {
        animalCounts[_animalType]--;
        borrowers[msg.sender] = Borrower(_age, _gender, true, _animalType);
        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        require(borrowers[msg.sender].hasBorrowed, "No borrowed pets");
        animalCounts[borrowers[msg.sender].borrowedAnimal]++;
        emit Returned(borrowers[msg.sender].borrowedAnimal);

        delete borrowers[msg.sender];
    }
}
