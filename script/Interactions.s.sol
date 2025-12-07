// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {BUSD} from "../src/BUSD.sol";
import {CCNFT} from "../src/CCNFT.sol";

// 1. Aprobar BUSD
contract ApproveCCNFT is Script {
    function run() external {
        address busdAddress = vm.envAddress("BUSD_ADDRESS");
        address ccnftAddress = vm.envAddress("CCNFT_ADDRESS");
        
        // Leemos "AMOUNT" de la terminal, o usamos 10 millones por defecto
        uint256 amount = vm.envOr("AMOUNT", uint256(10000000 * 10 ** 18));
        
        approveConfidently(busdAddress, ccnftAddress, amount);
    }

    function approveConfidently(address busd, address ccnft, uint256 amount) public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        BUSD(busd).approve(ccnft, amount);
        vm.stopBroadcast();
        
        console.log("Aprobado CCNFT para gastar %s BUSD", amount);
    }
}

// 2. Comprar NFT
contract BuyNFT is Script {
    function run() external {
        address ccnftAddress = vm.envAddress("CCNFT_ADDRESS");
        
        // Leemos valores dinámicos o usamos defaults
        uint256 value = vm.envOr("VALUE", uint256(100 * 10 ** 18));
        uint256 amount = vm.envOr("AMOUNT", uint256(1));

        buyNft(ccnftAddress, value, amount);
    }

    function buyNft(address ccnft, uint256 value, uint256 amount) public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        CCNFT(ccnft).buy(value, amount);
        vm.stopBroadcast();

        console.log("Comprados %s NFT(s) por valor de %s cada uno", amount, value);
    }
}

// 3. Poner en Venta
contract PutOnSaleCCNFT is Script {
    function run() external {
        address ccnftAddress = vm.envAddress("CCNFT_ADDRESS");

        uint256 tokenId = vm.envOr("ID", uint256(0));
        uint256 price = vm.envOr("PRICE", uint256(200 * 10 ** 18));

        putOnSale(ccnftAddress, tokenId, price);
    }

    function putOnSale(address ccnft, uint256 tokenId, uint256 price) public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        CCNFT(ccnft).putOnSale(tokenId, price);
        vm.stopBroadcast();

        console.log("NFT ID %s puesto en venta a precio %s", tokenId, price);
    }
}

// 4. Reclamar (Claim)
contract ClaimCCNFT is Script {
    function run() external {
        address ccnftAddress = vm.envAddress("CCNFT_ADDRESS");
        
        uint256 tokenId = vm.envOr("ID", uint256(0));

        claimNft(ccnftAddress, tokenId);
    }

    function claimNft(address ccnft, uint256 tokenId) public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        uint256[] memory tokensToClaim = new uint256[](1);
        tokensToClaim[0] = tokenId; 

        vm.startBroadcast(deployerPrivateKey);
        CCNFT(ccnft).claim(tokensToClaim);
        vm.stopBroadcast();

        console.log("NFT ID %s Reclamado y Quemado exitosamente", tokenId);
    }
}