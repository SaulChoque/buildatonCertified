// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/InstitutionDAO.sol";
import "../src/DocumentSignatureManager.sol";
import "../src/DocumentNFT.sol";
import "../src/DocumentWorkflow.sol";
import "../src/DocumentFactory.sol";

contract DeployFullSystem is Script {
    struct DeployedContracts {
        address institutionDAO;
        address signatureManager;
        address documentNFT;
        address documentWorkflow;
        address documentFactory;
    }

    function run() external returns (DeployedContracts memory) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address walletAddress = vm.envAddress("WALLET_ADDRESS");

        console.log("==== Deploying Trustify Document System ====");
        console.log("Deployer address:", walletAddress);
        console.log("Network RPC:", vm.envString("ANVIL_RPC_URL"));
        
        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy InstitutionDAO first (no dependencies)
        console.log("\n1. Deploying InstitutionDAO...");
        InstitutionDAO institutionDAO = new InstitutionDAO();
        institutionDAO.initialize(walletAddress);
        console.log("InstitutionDAO deployed at:", address(institutionDAO));

        // 2. Deploy DocumentSignatureManager (depends on InstitutionDAO)
        console.log("\n2. Deploying DocumentSignatureManager...");
        DocumentSignatureManager signatureManager = new DocumentSignatureManager();
        signatureManager.initialize(
            address(institutionDAO),
            walletAddress,
            "TrustifySignatureManager",
            "1.0"
        );
        console.log("DocumentSignatureManager deployed at:", address(signatureManager));

        // 3. Deploy DocumentNFT (depends on InstitutionDAO and SignatureManager)
        console.log("\n3. Deploying DocumentNFT...");
        DocumentNFT documentNFT = new DocumentNFT();
        documentNFT.initialize(
            "TrustifyDocuments",
            "TRUSTDOC",
            walletAddress,
            address(signatureManager),
            address(institutionDAO)
        );
        console.log("DocumentNFT deployed at:", address(documentNFT));

        // 4. Deploy DocumentWorkflow (depends on all previous contracts)
        console.log("\n4. Deploying DocumentWorkflow...");
        DocumentWorkflow documentWorkflow = new DocumentWorkflow();
        documentWorkflow.initialize(
            walletAddress,
            address(documentNFT),
            address(signatureManager),
            address(institutionDAO)
        );
        console.log("     DocumentWorkflow deployed at:", address(documentWorkflow));

        // 5. Deploy DocumentFactory (can deploy institution systems)
        console.log("\n5. Deploying DocumentFactory...");
        DocumentFactory documentFactory = new DocumentFactory();
        documentFactory.initialize();
        console.log("     DocumentFactory deployed at:", address(documentFactory));

        // 6. Grant necessary roles for workflow integration
        console.log("\n6. Configuring roles...");
        signatureManager.grantWorkflowRole(address(documentWorkflow));
        console.log("     Workflow role granted to DocumentWorkflow");

        vm.stopBroadcast();

        console.log("\n==== Deployment Summary ====");
        console.log("InstitutionDAO:          ", address(institutionDAO));
        console.log("DocumentSignatureManager:", address(signatureManager));
        console.log("DocumentNFT:             ", address(documentNFT));
        console.log("DocumentWorkflow:        ", address(documentWorkflow));
        console.log("DocumentFactory:         ", address(documentFactory));
        console.log("\n==== Deployment Complete! ====");

        return DeployedContracts({
            institutionDAO: address(institutionDAO),
            signatureManager: address(signatureManager),
            documentNFT: address(documentNFT),
            documentWorkflow: address(documentWorkflow),
            documentFactory: address(documentFactory)
        });
    }

    // Function to deploy just the core system without factory
    function deployCoreSystem() external returns (DeployedContracts memory) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address walletAddress = vm.envAddress("WALLET_ADDRESS");

        console.log("==== Deploying Core Document System ====");
        
        vm.startBroadcast(deployerPrivateKey);

        InstitutionDAO institutionDAO = new InstitutionDAO();
        institutionDAO.initialize(walletAddress);

        DocumentSignatureManager signatureManager = new DocumentSignatureManager();
        signatureManager.initialize(
            address(institutionDAO),
            walletAddress,
            "TrustifySignatureManager",
            "1.0"
        );

        DocumentNFT documentNFT = new DocumentNFT();
        documentNFT.initialize(
            "TrustifyDocuments",
            "TRUSTDOC",
            walletAddress,
            address(signatureManager),
            address(institutionDAO)
        );

        DocumentWorkflow documentWorkflow = new DocumentWorkflow();
        documentWorkflow.initialize(
            walletAddress,
            address(documentNFT),
            address(signatureManager),
            address(institutionDAO)
        );

        signatureManager.grantWorkflowRole(address(documentWorkflow));

        vm.stopBroadcast();

        console.log("Core system deployed successfully!");

        return DeployedContracts({
            institutionDAO: address(institutionDAO),
            signatureManager: address(signatureManager),
            documentNFT: address(documentNFT),
            documentWorkflow: address(documentWorkflow),
            documentFactory: address(0)
        });
    }
}
