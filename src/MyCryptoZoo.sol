// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract MyCryptoZoo is ERC721, ERC721Enumerable, Ownable {
    uint256 private _nextTokenId;

    struct Animal {
        string name;
        bool wings;
        uint256 legs;
        uint256 sex;
        // Vente
        bool isForSale;
        uint256 price;
        // Reproduction (Eval 2)
        uint256 parent1;
        uint256 parent2;
        bool isForReproduction;
        uint256 reproductionPrice;
    }

    mapping(uint256 => Animal) public animals;
    mapping(address => bool) public breeders;
    
    // Mapping pour savoir qui a payé pour copuler avec quel animal
    // animalId => adresse autorisée
    mapping(uint256 => address) public _authorizedBreederToReproduce;

    uint256 public constant REGISTRATION_PRICE = 0.001 ether;

    constructor() ERC721("CryptoZoo", "ZOO") Ownable(msg.sender) {}

    // ---------------------------------------------------------
    // HELPERS & GETTERS
    // ---------------------------------------------------------
    function mintTo(address to) public returns (uint256) {
        _nextTokenId++;
        uint256 newItemId = _nextTokenId;
        _mint(to, newItemId);
        return newItemId;
    }

    modifier onlyBreeder() {
        require(breeders[msg.sender], "Not a breeder");
        _;
    }

    function getAnimalCharacteristics(uint256 animalNumber) external view returns (string memory, bool, uint256, uint256) {
        Animal memory a = animals[animalNumber];
        return (a.name, a.wings, a.legs, a.sex);
    }

    function getParents(uint256 animalNumber) external view returns (uint256, uint256) {
        return (animals[animalNumber].parent1, animals[animalNumber].parent2);
    }

    // ---------------------------------------------------------
    // EX 3: BREEDER REGISTRATION
    // ---------------------------------------------------------
    function registrationPrice() external pure returns (uint256) {
        return REGISTRATION_PRICE;
    }

    function registerMeAsBreeder() external payable {
        require(msg.value >= REGISTRATION_PRICE, "Not enough ETH");
        breeders[msg.sender] = true;
    }

    function isBreeder(address account) external view returns (bool) {
        return breeders[account];
    }

    // ---------------------------------------------------------
    // EX 4: DECLARE ANIMAL (MINT)
    // ---------------------------------------------------------
    function declareAnimal(uint256 sex, uint256 legs, bool wings, string memory name) external onlyBreeder returns (uint256) {
        uint256 newItemId = mintTo(msg.sender);
        animals[newItemId] = Animal(name, wings, legs, sex, false, 0, 0, 0, false, 0);
        return newItemId;
    }

    // ---------------------------------------------------------
    // EX 7: BREEDING WITH PARENTS (EVALUATEUR 2)
    // ---------------------------------------------------------
    function declareAnimalWithParents(uint256 sex, uint256 legs, bool wings, string memory name, uint256 parent1, uint256 parent2) external onlyBreeder returns (uint256) {
        // Logique Ex 7c : Vérifier les droits de reproduction
        // Si le parent 2 ne m'appartient pas, je dois avoir l'autorisation
        if (parent2 != 0 && ownerOf(parent2) != msg.sender) {
            require(_authorizedBreederToReproduce[parent2] == msg.sender, "Not authorized to breed with parent2");
            // On consomme l'autorisation (usage unique)
            delete _authorizedBreederToReproduce[parent2];
        }
        
        // Pareil pour parent 1 si nécessaire (sécurité supplémentaire)
        if (parent1 != 0 && ownerOf(parent1) != msg.sender) {
            require(_authorizedBreederToReproduce[parent1] == msg.sender, "Not authorized to breed with parent1");
            delete _authorizedBreederToReproduce[parent1];
        }

        uint256 newItemId = mintTo(msg.sender);
        animals[newItemId] = Animal(name, wings, legs, sex, false, 0, parent1, parent2, false, 0);
        return newItemId;
    }

    function canReproduce(uint256 animalNumber) external view returns (bool) {
        return animals[animalNumber].isForReproduction;
    }

    function reproductionPrice(uint256 animalNumber) external view returns (uint256) {
        return animals[animalNumber].reproductionPrice;
    }

    function authorizedBreederToReproduce(uint256 animalNumber) external view returns (address) {
        return _authorizedBreederToReproduce[animalNumber];
    }

    function offerForReproduction(uint256 animalNumber, uint256 price) external {
        require(ownerOf(animalNumber) == msg.sender, "Not owner");
        animals[animalNumber].isForReproduction = true;
        animals[animalNumber].reproductionPrice = price;
    }

    function payForReproduction(uint256 animalNumber) external payable {
        require(animals[animalNumber].isForReproduction, "Not for reproduction");
        require(msg.value >= animals[animalNumber].reproductionPrice, "Price too low");

        address owner = ownerOf(animalNumber);
        // Transfert de l'argent au proprio
        payable(owner).transfer(msg.value);

        // On autorise l'acheteur à utiliser cet animal
        _authorizedBreederToReproduce[animalNumber] = msg.sender;
    }

    // ---------------------------------------------------------
    // EX 5: DEATH (BURN)
    // ---------------------------------------------------------
    function declareDeadAnimal(uint256 animalNumber) external {
        require(ownerOf(animalNumber) == msg.sender, "Not owner");
        delete animals[animalNumber]; 
        _burn(animalNumber);
    }

    // ---------------------------------------------------------
    // EX 6: MARKETPLACE (VENTE)
    // ---------------------------------------------------------
    function offerForSale(uint256 animalNumber, uint256 price) external {
        require(ownerOf(animalNumber) == msg.sender, "Not owner");
        animals[animalNumber].isForSale = true;
        animals[animalNumber].price = price;
    }

    function isAnimalForSale(uint256 animalNumber) external view returns (bool) {
        return animals[animalNumber].isForSale;
    }
    
    function animalPrice(uint256 animalNumber) external view returns (uint256) {
        return animals[animalNumber].price;
    }

    function buyAnimal(uint256 animalNumber) external payable {
        Animal storage a = animals[animalNumber];
        require(a.isForSale, "Not for sale");
        require(msg.value >= a.price, "Price too low");
        
        address seller = ownerOf(animalNumber);
        require(seller != msg.sender, "Already owner");

        a.isForSale = false;
        a.price = 0;
        // On reset aussi les status de reproduction à la vente pour éviter les bugs
        a.isForReproduction = false; 
        a.reproductionPrice = 0;

        _transfer(seller, msg.sender, animalNumber);
        payable(seller).transfer(msg.value);
    }

    // ---------------------------------------------------------
    // OVERRIDES ERC721Enumerable
    // ---------------------------------------------------------
    function _update(address to, uint256 tokenId, address auth) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    function addBreeder(address user) external onlyOwner {
        breeders[user] = true;
    }
}