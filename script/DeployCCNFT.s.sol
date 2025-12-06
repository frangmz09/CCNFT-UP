// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {BUSD} from "../src/BUSD.sol";
import {CCNFT} from "../src/CCNFT.sol";

contract DeployCCNFT is Script {
    function run() external {
        // Leemos la clave privada del archivo .env
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Empezamos la transmisión de transacciones (todo lo que siga se ejecuta on-chain)
        vm.startBroadcast(deployerPrivateKey);

        // 1. Desplegar BUSD (Moneda de pago)
        BUSD busd = new BUSD();

        // 2. Desplegar CCNFT (Contrato principal)
        CCNFT ccnft = new CCNFT();

        // 3. Configuración Inicial Básica (Opcional, pero recomendado para ahorrar pasos manuales)
        // Seteamos el token de pago
        ccnft.setFundsToken(address(busd));
        
        // Seteamos valores válidos de ejemplo (ej: 100 y 200 tokens)
        ccnft.addValidValues(100 * 10**18);
        ccnft.addValidValues(200 * 10**18);

        // Habilitamos la compra
        ccnft.setCanBuy(true);
        ccnft.setMaxBatchCount(20);
        ccnft.setMaxValueToRaise(1000000 * 10**18);

        // Seteamos direcciones (usamos la misma del deployer temporalmente o pon las reales)
        address myAddress = vm.addr(deployerPrivateKey);
        ccnft.setFundsCollector(myAddress);
        ccnft.setFeesCollector(myAddress);

        vm.stopBroadcast();
    }
}