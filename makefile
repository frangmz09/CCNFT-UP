-include .env

# Comandos básicos
all: clean remove install update build

# Limpiar cache y artefactos
clean:; forge clean

# Compilar contratos
build:; forge build

# Ejecutar tests
test:; forge test

# DESPLIEGUE EN SEPOLIA
# Este comando ejecuta el script, transmite la transacción, y verifica el contrato en Etherscan
deploy-sepolia:
	forge script script/DeployCCNFT.s.sol:DeployCCNFT \
	--rpc-url $(SEPOLIA_RPC_URL) \
	--private-key $(PRIVATE_KEY) \
	--broadcast \
	--verify \
	--etherscan-api-key $(ETHERSCAN_API_KEY) \
	-vvvv