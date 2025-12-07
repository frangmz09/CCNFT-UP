-include .env

# VARIABLES POR DEFECTO 
amount ?= 1
value ?= 100000000000000000000
price ?= 200000000000000000000
id ?= 0

# 1. CONFIGURACIÓN Y MANTENIMIENTO

all: clean install update build

clean:; forge clean
install:; forge install
update:; forge update
build:; forge build
format:; forge fmt

# 2. TESTEO

test:; forge test
test-v:; forge test -vv
snapshot:; forge snapshot

# 3. DESPLIEGUE

deploy-sepolia:
	forge script script/DeployCCNFT.s.sol:DeployCCNFT \
	--rpc-url $(SEPOLIA_RPC_URL) \
	--private-key $(PRIVATE_KEY) \
	--broadcast \
	--verify \
	--etherscan-api-key $(ETHERSCAN_API_KEY) \
	-vvvv

# 4. INTERACCIONES (Write)

# Aprobar (Permite pasar amount)
# Ej: make approve amount=5000000000000000000
approve:
	AMOUNT=$(amount) forge script script/Interactions.s.sol:ApproveCCNFT --rpc-url $(SEPOLIA_RPC_URL) --broadcast -vvvv

# Comprar (Permite pasar amount y value)
# Ej: make buy amount=2
buy:
	AMOUNT=$(amount) VALUE=$(value) forge script script/Interactions.s.sol:BuyNFT --rpc-url $(SEPOLIA_RPC_URL) --broadcast -vvvv

# Vender (Permite pasar id y price)
# Ej: make sell id=1 price=300000000000000000000
sell:
	ID=$(id) PRICE=$(price) forge script script/Interactions.s.sol:PutOnSaleCCNFT --rpc-url $(SEPOLIA_RPC_URL) --broadcast -vvvv

# Reclamar (Permite pasar id)
# Ej: make claim id=1
claim:
	ID=$(id) forge script script/Interactions.s.sol:ClaimCCNFT --rpc-url $(SEPOLIA_RPC_URL) --broadcast -vvvv

# 5. LECTURA RÁPIDA (Read)

check-balance:
	cast call $(BUSD_ADDRESS) "balanceOf(address)" $(shell cast wallet address --private-key $(PRIVATE_KEY)) --rpc-url $(SEPOLIA_RPC_URL)

check-owner:
	cast call $(CCNFT_ADDRESS) "ownerOf(uint256)" $(id) --rpc-url $(SEPOLIA_RPC_URL)