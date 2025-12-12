// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IExerciceSolution {
    // --- Gestion Générale ---
    function submitExercise(address solution) external;
    
    // --- ERC721 Standard & Enumerable ---
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    // --- Animal Info (Ex 2 & 5) ---
    function getAnimalCharacteristics(uint256 animalNumber) external view returns (string memory _name, bool _wings, uint256 _legs, uint256 _sex);
    
    // --- Création & Mort (Ex 4 & 5) ---
    function declareAnimal(uint256 sex, uint256 legs, bool wings, string memory name) external returns (uint256);
    function declareDeadAnimal(uint256 animalNumber) external;
    
    // --- Breeder (Ex 3) ---
    function registrationPrice() external view returns (uint256);
    function registerMeAsBreeder() external payable;
    function isBreeder(address account) external view returns (bool);

    // --- Vente / Marketplace (Ex 6) ---
    function isAnimalForSale(uint256 animalNumber) external view returns (bool);
    function animalPrice(uint256 animalNumber) external view returns (uint256);
    function buyAnimal(uint256 animalNumber) external payable;
    function offerForSale(uint256 animalNumber, uint256 price) external;

    // --- Reproduction / Breeding (Ex 7 - Evaluateur 2) ---
    function declareAnimalWithParents(uint256 sex, uint256 legs, bool wings, string memory name, uint256 parent1, uint256 parent2) external returns (uint256);
    function getParents(uint256 animalNumber) external view returns (uint256, uint256);
    function canReproduce(uint256 animalNumber) external view returns (bool);
    function reproductionPrice(uint256 animalNumber) external view returns (uint256);
    function offerForReproduction(uint256 animalNumber, uint256 price) external;
    function authorizedBreederToReproduce(uint256 animalNumber) external view returns (address);
    function payForReproduction(uint256 animalNumber) external payable;
}