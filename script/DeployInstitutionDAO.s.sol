// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/InstitutionDAO.sol";

contract DeployInstitutionDAO is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address walletAddress = vm.envAddress("WALLET_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy InstitutionDAO
        InstitutionDAO institutionDAO = new InstitutionDAO();
        
        // Initialize with admin address
        institutionDAO.initialize(walletAddress);
        
        vm.stopBroadcast();

        console.log("InstitutionDAO deployed at:", address(institutionDAO));
        console.log("Admin address:", walletAddress);
        
        return address(institutionDAO);
    }
}
