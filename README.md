# 🌾 CryptoCampo NFT - Tokenización de Activos Agrícolas

Este proyecto es una DApp (Aplicación Descentralizada) diseñada para la tokenización de bienes agrícolas (Real World Assets - RWA). Permite representar toneladas de granos (Soja, Maíz, Trigo) mediante NFTs, facilitando su comercio, inversión y liquidación en la Blockchain de Ethereum (Sepolia Testnet).

El sistema utiliza un token **ERC20 (BUSD)** como moneda de pago y liquidez para todas las transacciones dentro del ecosistema.

## Funcionalidades Principales

El contrato inteligente `CCNFT` implementa la siguiente lógica de negocio:

* **Compra (Buy):** Los usuarios pueden comprar NFTs pagando con BUSD. El contrato valida límites de compra y precios preestablecidos.
* **Mercado Secundario (Trade):** Los poseedores de NFTs pueden ponerlos a la venta (`putOnSale`) y otros usuarios pueden comprarlos directamente en el contrato (`trade`), pagando una comisión (Fee) al protocolo.
* **Reclamo/Liquidación (Claim):** El usuario puede "quemar" su NFT para recibir el valor subyacente del activo más un beneficio (`profitToPay`) en BUSD, retirando el activo de circulación.
* **Gestión de Tarifas:** Sistema de *Fees* configurables para la compra y el intercambio, dirigidos a una *wallet* colectora.
* **Seguridad:** Implementación de `ReentrancyGuard` y patrón `Ownable` para gestión administrativa.

## Stack Tecnológico

* **Lenguaje:** Solidity `^0.8.19`
* **Framework:** Foundry (Forge, Cast, Anvil)
* **Estándares:** OpenZeppelin (ERC721Enumerable, ERC20, Ownable)
* **Red de Despliegue:** Sepolia Testnet
* **Automatización:** GNU Make

## Estructura del Proyecto

* `src/`: Contratos inteligentes (`CCNFT.sol`, `BUSD.sol`).
* `test/`: Tests unitarios exhaustivos escritos en Solidity.
* `script/`: Scripts de despliegue automatizado y verificación.
* `Makefile`: Atajos para comandos de compilación y despliegue.

## Prerrequisitos

* [Foundry](https://book.getfoundry.sh/getting-started/installation) instalado.
* Una billetera configurada con claves privadas (para despliegue).
* Archivo `.env` configurado (ver ejemplo abajo).

## Instalación y Configuración

1.  **Clonar el repositorio:**
    ```bash
    git clone [https://github.com/TU_USUARIO/ProyectoFinalCCNFT.git](https://github.com/TU_USUARIO/ProyectoFinalCCNFT.git)
    cd ProyectoFinalCCNFT
    ```

2.  **Instalar dependencias:**
    ```bash
    forge install
    ```

3.  **Configurar variables de entorno:**
    Crea un archivo `.env` en la raíz:
    ```ini
    PRIVATE_KEY=0x... (Tu clave privada)
    SEPOLIA_RPC_URL=https://... (Tu URL RPC)
    ETHERSCAN_API_KEY=... (Tu API Key)
    ```

4.  **Compilar:**
    ```bash
    make build
    ```

5.  **Correr Tests:**
    ```bash
    make test
    ```

## Despliegue en Sepolia

El proyecto cuenta con un script automatizado que despliega los contratos `BUSD` y `CCNFT`, configura los permisos iniciales, establece los precios y verifica el código en Etherscan.

```bash
make deploy-sepolia