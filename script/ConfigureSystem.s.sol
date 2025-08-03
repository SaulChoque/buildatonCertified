// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/InstitutionDAO.sol";
import "../src/DocumentSignatureManager.sol";
import "../src/DocumentNFT.sol";
import "../src/DocumentWorkflow.sol";
import "../src/DocumentFactory.sol";

contract ConfigureSystem is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address walletAddress = vm.envAddress("WALLET_ADDRESS");

        // You need to provide these addresses after deployment
        address institutionDAOAddress = vm.envAddress("INSTITUTION_DAO_ADDRESS");
        address signatureManagerAddress = vm.envAddress("SIGNATURE_MANAGER_ADDRESS");
        address documentNFTAddress = vm.envAddress("DOCUMENT_NFT_ADDRESS");
        address documentWorkflowAddress = vm.envAddress("DOCUMENT_WORKFLOW_ADDRESS");
        address documentFactoryAddress = vm.envAddress("DOCUMENT_FACTORY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        InstitutionDAO institutionDAO = InstitutionDAO(institutionDAOAddress);
        DocumentSignatureManager signatureManager = DocumentSignatureManager(signatureManagerAddress);
        DocumentNFT documentNFT = DocumentNFT(documentNFTAddress);
        DocumentWorkflow documentWorkflow = DocumentWorkflow(documentWorkflowAddress);
        DocumentFactory documentFactory = DocumentFactory(documentFactoryAddress);

        console.log("==== Configuring System Roles ====");

        // Grant roles in InstitutionDAO
        bytes32 adminRole = institutionDAO.ADMIN_ROLE();
        bytes32 roleCreatorRole = institutionDAO.ROLE_CREATOR_ROLE();
        
        if (!institutionDAO.hasRole(adminRole, walletAddress)) {
            institutionDAO.grantRole(adminRole, walletAddress);
            console.log("Admin role granted to deployer in InstitutionDAO");
        }
        
        if (!institutionDAO.hasRole(roleCreatorRole, walletAddress)) {
            institutionDAO.grantRole(roleCreatorRole, walletAddress);
            console.log("Role creator role granted to deployer in InstitutionDAO");
        }

        // Grant roles in DocumentNFT
        bytes32 minterRole = documentNFT.MINTER_ROLE();
        bytes32 updaterRole = documentNFT.UPDATER_ROLE();
        
        if (!documentNFT.hasRole(minterRole, documentWorkflowAddress)) {
            documentNFT.grantRole(minterRole, documentWorkflowAddress);
            console.log("Minter role granted to DocumentWorkflow in DocumentNFT");
        }
        
        if (!documentNFT.hasRole(updaterRole, documentWorkflowAddress)) {
            documentNFT.grantRole(updaterRole, documentWorkflowAddress);
            console.log("Updater role granted to DocumentWorkflow in DocumentNFT");
        }

        // Grant roles in DocumentWorkflow
        bytes32 workflowAdminRole = documentWorkflow.WORKFLOW_ADMIN_ROLE();
        bytes32 creatorRole = documentWorkflow.CREATOR_ROLE();
        
        if (!documentWorkflow.hasRole(workflowAdminRole, walletAddress)) {
            documentWorkflow.grantRole(workflowAdminRole, walletAddress);
            console.log("Workflow admin role granted to deployer in DocumentWorkflow");
        }
        
        if (!documentWorkflow.hasRole(creatorRole, walletAddress)) {
            documentWorkflow.grantRole(creatorRole, walletAddress);
            console.log("  Creator role granted to deployer in DocumentWorkflow");
        }

        // Grant roles in DocumentFactory
        bytes32 factoryAdminRole = documentFactory.FACTORY_ADMIN_ROLE();
        
        if (!documentFactory.hasRole(factoryAdminRole, walletAddress)) {
            documentFactory.grantRole(factoryAdminRole, walletAddress);
            console.log("  Factory admin role granted to deployer in DocumentFactory");
        }

        // Grant workflow role in SignatureManager
        bytes32 workflowRole = signatureManager.WORKFLOW_ROLE();
        if (!signatureManager.hasRole(workflowRole, documentWorkflowAddress)) {
            signatureManager.grantWorkflowRole(documentWorkflowAddress);
            console.log("  Workflow role granted to DocumentWorkflow in SignatureManager");
        }

        vm.stopBroadcast();

        console.log("\n==== System Configuration Complete ====");
    }

    // Function to create a sample department and roles
    function setupSampleData() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address walletAddress = vm.envAddress("WALLET_ADDRESS");
        address institutionDAOAddress = vm.envAddress("INSTITUTION_DAO_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        InstitutionDAO institutionDAO = InstitutionDAO(institutionDAOAddress);

        console.log("==== Setting up Sample Data ====");

        // Create sample department
        institutionDAO.createDepartment("Administration", walletAddress);
        console.log("  Administration department created");

        // Create sample roles
        institutionDAO.createRole("DOCUMENT_REVIEWER", "Can review and approve documents");
        institutionDAO.createRole("DOCUMENT_CREATOR", "Can create new documents");
        institutionDAO.createRole("DEPARTMENT_HEAD", "Head of department with special permissions");
        
        console.log("  Sample roles created");

        // Add deployer as member with empty roles array (roles will be granted separately)
        bytes32[] memory emptyRoles = new bytes32[](0);
        institutionDAO.addMember(walletAddress, "System Administrator", "Administration", emptyRoles);
        console.log("  Deployer added as member");

        vm.stopBroadcast();

        console.log("\n==== Sample Data Setup Complete ====");
    }
}
