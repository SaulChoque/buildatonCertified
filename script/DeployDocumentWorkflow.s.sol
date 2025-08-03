// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/DocumentWorkflow.sol";

contract DeployDocumentWorkflow is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address walletAddress = vm.envAddress("WALLET_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy DocumentWorkflow
        DocumentWorkflow documentWorkflow = new DocumentWorkflow();
        
        vm.stopBroadcast();

        console.log("DocumentWorkflow deployed at:", address(documentWorkflow));
        console.log("Admin address:", walletAddress);
        
        return address(documentWorkflow);
    }

    function runWithDependencies(
        address documentNFTAddress,
        address signatureManagerAddress,
        address institutionDAOAddress
    ) external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address walletAddress = vm.envAddress("WALLET_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy DocumentWorkflow
        DocumentWorkflow documentWorkflow = new DocumentWorkflow();
        
        // Initialize with dependencies
        documentWorkflow.initialize(
            walletAddress,
            documentNFTAddress,
            signatureManagerAddress,
            institutionDAOAddress
        );
        
        vm.stopBroadcast();

        console.log("DocumentWorkflow deployed at:", address(documentWorkflow));
        console.log("DocumentNFT address:", documentNFTAddress);
        console.log("SignatureManager address:", signatureManagerAddress);
        console.log("InstitutionDAO address:", institutionDAOAddress);
        console.log("Admin address:", walletAddress);
        
        return address(documentWorkflow);
    }
}
