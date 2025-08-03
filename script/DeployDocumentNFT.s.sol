// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/DocumentNFT.sol";

contract DeployDocumentNFT is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address walletAddress = vm.envAddress("WALLET_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy DocumentNFT
        DocumentNFT documentNFT = new DocumentNFT();
        
        vm.stopBroadcast();

        console.log("DocumentNFT deployed at:", address(documentNFT));
        console.log("Admin address:", walletAddress);
        
        return address(documentNFT);
    }

    function runWithDependencies(
        address signatureManagerAddress,
        address institutionDAOAddress
    ) external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address walletAddress = vm.envAddress("WALLET_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy DocumentNFT
        DocumentNFT documentNFT = new DocumentNFT();
        
        // Initialize with dependencies
        documentNFT.initialize(
            "TrustifyDocuments",
            "TRUSTDOC",
            walletAddress,
            signatureManagerAddress,
            institutionDAOAddress
        );
        
        vm.stopBroadcast();

        console.log("DocumentNFT deployed at:", address(documentNFT));
        console.log("SignatureManager address:", signatureManagerAddress);
        console.log("InstitutionDAO address:", institutionDAOAddress);
        console.log("Admin address:", walletAddress);
        
        return address(documentNFT);
    }
}
