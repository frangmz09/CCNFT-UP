// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {Counters} from "openzeppelin-contracts/contracts/utils/Counters.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

contract CCNFT is ERC721Enumerable, Ownable, ReentrancyGuard {
    // EVENTOS
    event Buy(address indexed buyer, uint256 indexed tokenId, uint256 value);
    event Claim(address indexed claimer, uint256 indexed tokenId);
    event Trade(address indexed buyer, address indexed seller, uint256 indexed tokenId, uint256 value);
    event PutOnSale(uint256 indexed tokenId, uint256 price);

    struct TokenSale {
        bool onSale;
        uint256 price;
    }

    using Counters for Counters.Counter;
    Counters.Counter private tokenIdTracker;

    mapping(uint256 => uint256) public values;
    mapping(uint256 => bool) public validValues;
    mapping(uint256 => TokenSale) public tokensOnSale;

    uint256[] public listTokensOnSale;

    address public fundsCollector;
    address public feesCollector;

    bool public canBuy;
    bool public canClaim;
    bool public canTrade;

    uint256 public totalValue;
    uint256 public maxValueToRaise;

    uint16 public buyFee;
    uint16 public tradeFee;

    uint16 public maxBatchCount;

    uint32 public profitToPay;

    IERC20 public fundsToken;

    constructor() ERC721("CCNFT", "CCNFT") {}

    // PUBLIC FUNCTIONS

    function buy(uint256 value, uint256 amount) external nonReentrant {
        require(canBuy, "Buy is not enabled");
        require(amount > 0 && amount <= maxBatchCount, "Invalid amount");
        require(validValues[value], "Invalid value");
        require(totalValue + (value * amount) <= maxValueToRaise, "Max value exceeded");

        totalValue += value * amount;

        for (uint256 i = 0; i < amount; i++) {
            uint256 currentId = tokenIdTracker.current();
            values[currentId] = value;
            _safeMint(_msgSender(), currentId);
            emit Buy(_msgSender(), currentId, value);
            tokenIdTracker.increment();
        }

        if (!fundsToken.transferFrom(_msgSender(), fundsCollector, value * amount)) {
            revert("Cannot send funds tokens");
        }

        if (buyFee > 0) {
            uint256 feeAmount = (value * amount * buyFee) / 10000;
            if (!fundsToken.transferFrom(_msgSender(), feesCollector, feeAmount)) {
                revert("Cannot send fees tokens");
            }
        }
    }

    function claim(uint256[] calldata listTokenId) external nonReentrant {
        require(canClaim, "Claim is not enabled");
        require(listTokenId.length > 0 && listTokenId.length <= maxBatchCount, "Invalid amount");

        uint256 claimValue = 0;
        TokenSale storage tokenSale;

        for (uint256 i = 0; i < listTokenId.length; i++) {
            uint256 tokenId = listTokenId[i];
            require(_exists(tokenId), "Token does not exist");
            require(ownerOf(tokenId) == _msgSender(), "Only owner can Claim");

            claimValue += values[tokenId];
            values[tokenId] = 0;

            tokenSale = tokensOnSale[tokenId];
            // Si estaba en venta, lo sacamos
            if (tokenSale.onSale) {
                tokenSale.onSale = false;
                tokenSale.price = 0;
                removeFromArray(listTokensOnSale, tokenId);
            }

            _burn(tokenId);
            emit Claim(_msgSender(), tokenId);
        }

        totalValue -= claimValue;

        uint256 totalToPay = claimValue + ((claimValue * profitToPay) / 10000);

        if (!fundsToken.transfer(_msgSender(), totalToPay)) {
            revert("cannot send funds");
        }
    }

    function trade(uint256 tokenId) external nonReentrant {
        require(canTrade, "Trade is not enabled");
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) != _msgSender(), "Buyer is the Seller");

        TokenSale storage tokenSale = tokensOnSale[tokenId];
        require(tokenSale.onSale, "Token not On Sale");

        address seller = ownerOf(tokenId);
        uint256 price = tokenSale.price;
        
        // Transferir precio al vendedor
        if (!fundsToken.transferFrom(_msgSender(), seller, price)) {
            revert("Cannot send funds to seller");
        }

        // Transferir fee si aplica
        if (tradeFee > 0) {
            uint256 feeAmount = (price * tradeFee) / 10000;
            if (!fundsToken.transferFrom(_msgSender(), feesCollector, feeAmount)) {
                revert("Cannot send trade fee");
            }
        }

        emit Trade(_msgSender(), seller, tokenId, price);

        _safeTransfer(seller, _msgSender(), tokenId, "");

        tokenSale.onSale = false;
        tokenSale.price = 0;
        removeFromArray(listTokensOnSale, tokenId);
    }

    function putOnSale(uint256 tokenId, uint256 price) external {
        require(canTrade, "Trade is not enabled");
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == _msgSender(), "Not owner");
        require(price > 0, "Price must be greater than zero");

        TokenSale storage tokenSale = tokensOnSale[tokenId];
        tokenSale.onSale = true;
        tokenSale.price = price;

        addToArray(listTokensOnSale, tokenId);

        emit PutOnSale(tokenId, price);
    }

    // SETTERS

    function setFundsToken(address token) external onlyOwner {
        require(token != address(0), "Invalid address");
        fundsToken = IERC20(token);
    }

    function setFundsCollector(address _address) external onlyOwner {
        require(_address != address(0), "Invalid address");
        fundsCollector = _address;
    }

    function setFeesCollector(address _address) external onlyOwner {
        require(_address != address(0), "Invalid address");
        feesCollector = _address;
    }

    function setProfitToPay(uint32 _profitToPay) external onlyOwner {
        profitToPay = _profitToPay;
    }

    function setCanBuy(bool _canBuy) external onlyOwner {
        canBuy = _canBuy;
    }

    function setCanClaim(bool _canClaim) external onlyOwner {
        canClaim = _canClaim;
    }

    function setCanTrade(bool _canTrade) external onlyOwner {
        canTrade = _canTrade;
    }

    function setMaxValueToRaise(uint256 _maxValueToRaise) external onlyOwner {
        maxValueToRaise = _maxValueToRaise;
    }

    function addValidValues(uint256 value) external onlyOwner {
        validValues[value] = true;
    }

    function setMaxBatchCount(uint16 _maxBatchCount) external onlyOwner {
        maxBatchCount = _maxBatchCount;
    }

    function setBuyFee(uint16 _buyFee) external onlyOwner {
        buyFee = _buyFee;
    }

    function setTradeFee(uint16 _tradeFee) external onlyOwner {
        tradeFee = _tradeFee;
    }

    // ARRAYS & HELPERS

    function addToArray(uint256[] storage list, uint256 value) private {
        uint256 index = find(list, value);
        if (index == list.length) {
            list.push(value);
        }
    }

    function removeFromArray(uint256[] storage list, uint256 value) private {
        uint256 index = find(list, value);
        if (index < list.length) {
            // Movemos el último elemento a la posición a borrar y hacemos pop
            list[index] = list[list.length - 1];
            list.pop();
        }
    }

    function find(uint256[] storage list, uint256 value) private view returns (uint256) {
        for (uint256 i = 0; i < list.length; i++) {
            if (list[i] == value) {
                return i;
            }
        }
        return list.length;
    }

    // NOT SUPPORTED FUNCTIONS (Bloqueamos transferencias directas sin Trade)

    function transferFrom(address from, address to, uint256 tokenId)
        public
        pure
        override(ERC721, IERC721)
    {
        revert("Not Allowed: Use trade()");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId)
        public
        pure
        override(ERC721, IERC721)
    {
        revert("Not Allowed: Use trade()");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        public
        pure
        override(ERC721, IERC721)
    {
        revert("Not Allowed: Use trade()");
    }

    // Compliance required by Solidity overrides
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}