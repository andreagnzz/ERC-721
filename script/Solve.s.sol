// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MyCryptoZoo} from "../src/MyCryptoZoo.sol";
import {IExerciceSolution} from "../src/IExerciceSolution.sol";

contract Solve is Script {
    // Adresses fournies dans le sujet
    address constant EVALUATOR_1 = 0xa39ac9c5eF0582f5D0b21770e34c4c54d6e46Fa6;
    address constant EVALUATOR_2 = 0xB6C6cf310456Bd0dEE01162A9150EC7ccA146936;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 1. Déploiement
        MyCryptoZoo zoo = new MyCryptoZoo();
        console.log("Zoo deploye a:", address(zoo));

        // 2. Mint du token #1 pour l'Evaluateur 1 (Requis Ex 1)
        zoo.mintTo(EVALUATOR_1); 

        // 3. Soumission Evaluateur 1
        IExerciceSolution(EVALUATOR_1).submitExercise(address(zoo));
        
        // 4. Soumission Evaluateur 2
        // Note: submitExercise s'appelle pareil, on caste juste l'adresse
        IExerciceSolution(EVALUATOR_2).submitExercise(address(zoo));

        vm.stopBroadcast();
    }
}