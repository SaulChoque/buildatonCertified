// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/DocumentSignatureManager.sol";

contract DeployDocumentSignatureManager is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address walletAddress = vm.envAddress("WALLET_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy DocumentSignatureManager
        DocumentSignatureManager signatureManager = new DocumentSignatureManager();
        
        vm.stopBroadcast();

        console.log("DocumentSignatureManager deployed at:", address(signatureManager));
        console.log("Admin address:", walletAddress);
        
        return address(signatureManager);
    }

    function runWithInstitutionDAO(address institutionDAOAddress) external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address walletAddress = vm.envAddress("WALLET_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy DocumentSignatureManager
        DocumentSignatureManager signatureManager = new DocumentSignatureManager();
        
        // Initialize with institution DAO
        signatureManager.initialize(
            institutionDAOAddress,
            walletAddress,
            "DocumentSignatureManager",
            "1.0"
        );
        
        vm.stopBroadcast();

        console.log("DocumentSignatureManager deployed at:", address(signatureManager));
        console.log("InstitutionDAO address:", institutionDAOAddress);
        console.log("Admin address:", walletAddress);
        
        return address(signatureManager);
    }
}
