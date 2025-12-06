// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {BUSD} from "../src/BUSD.sol";
import {CCNFT} from "../src/CCNFT.sol";

contract CCNFTTest is Test {
    address deployer;
    address c1; // Cliente 1
    address c2; // Cliente 2
    address funds; // Recolector de fondos
    address fees; // Recolector de fees
    
    BUSD busd;
    CCNFT ccnft;

    function setUp() public {
        // Configuramos direcciones falsas para probar
        deployer = address(this); 
        c1 = address(0x1);
        c2 = address(0x2);
        funds = address(0x3);
        fees = address(0x4);

        // Desplegamos los contratos
        busd = new BUSD();
        ccnft = new CCNFT();

        // Transferimos tokens BUSD al c1 y c2 para que tengan saldo en pruebas futuras
        busd.transfer(c1, 1000 * 10**18);
        busd.transfer(c2, 1000 * 10**18);
    }

    function testSetFundsCollector() public {
        ccnft.setFundsCollector(funds);
        assertEq(ccnft.fundsCollector(), funds);
    }

    function testSetFeesCollector() public {
        ccnft.setFeesCollector(fees);
        assertEq(ccnft.feesCollector(), fees);
    }

    function testSetProfitToPay() public {
        uint32 profit = 500; // 5%
        ccnft.setProfitToPay(profit);
        assertEq(ccnft.profitToPay(), profit);
    }

    function testSetCanBuy() public {
        // Test set to true
        ccnft.setCanBuy(true);
        assertTrue(ccnft.canBuy());

        // Test set to false
        ccnft.setCanBuy(false);
        assertFalse(ccnft.canBuy());
    }

    function testSetCanTrade() public {
        ccnft.setCanTrade(true);
        assertTrue(ccnft.canTrade());

        ccnft.setCanTrade(false);
        assertFalse(ccnft.canTrade());
    }

    function testSetCanClaim() public {
        ccnft.setCanClaim(true);
        assertTrue(ccnft.canClaim());

        ccnft.setCanClaim(false);
        assertFalse(ccnft.canClaim());
    }

    function testSetMaxValueToRaise() public {
        uint256 maxVal = 100000 * 10**18;
        ccnft.setMaxValueToRaise(maxVal);
        assertEq(ccnft.maxValueToRaise(), maxVal);
    }

    function testAddValidValues() public {
        uint256 val1 = 100 * 10**18;
        uint256 val2 = 200 * 10**18;
        
        ccnft.addValidValues(val1);
        ccnft.addValidValues(val2);

        assertTrue(ccnft.validValues(val1));
        assertTrue(ccnft.validValues(val2));
        assertFalse(ccnft.validValues(500)); // Uno que no agregamos
    }

    function testSetMaxBatchCount() public {
        uint16 batch = 10;
        ccnft.setMaxBatchCount(batch);
        assertEq(ccnft.maxBatchCount(), batch);
    }

    function testSetBuyFee() public {
        uint16 fee = 200; // 2%
        ccnft.setBuyFee(fee);
        assertEq(ccnft.buyFee(), fee);
    }

    function testSetTradeFee() public {
        uint16 fee = 100; // 1%
        ccnft.setTradeFee(fee);
        assertEq(ccnft.tradeFee(), fee);
    }

    function testCannotTradeWhenCanTradeIsFalse() public {
        // Aseguramos que canTrade sea false
        ccnft.setCanTrade(false);
        
        // Esperamos que la llamada falle con el mensaje exacto del require
        vm.expectRevert("Trade is not enabled");
        ccnft.trade(1); 
    }

    function testCannotTradeWhenTokenDoesNotExist() public {
        ccnft.setCanTrade(true);
        
        // El token 999 no existe
        vm.expectRevert("Token does not exist");
        ccnft.trade(999);
    }
}