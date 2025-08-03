// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/DocumentFactory.sol";

contract DeployDocumentFactory is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address walletAddress = vm.envAddress("WALLET_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy DocumentFactory
        DocumentFactory documentFactory = new DocumentFactory();
        
        // Initialize factory
        documentFactory.initialize();
        
        vm.stopBroadcast();

        console.log("DocumentFactory deployed at:", address(documentFactory));
        console.log("Admin address:", walletAddress);
        
        return address(documentFactory);
    }
}
