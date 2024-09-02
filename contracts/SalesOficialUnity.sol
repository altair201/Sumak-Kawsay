// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SalesOficialUnity{
    address public owner;
    uint private buyPrice;
    uint private sold;
    uint private totalTokensSold;
    IERC20 private token;
    IERC20 private paymentToken;
    uint private currentPhaseIndex;
    bool public saleEnded;
    uint private phaseStartTime; 
    uint private phaseTarget = 2.1 * 10 ** 6; 
    uint private unsoldTokens;
    uint private totalTokenscontract = 6.3 * 10 ** 6;

    struct Phase {
        uint total;
        uint price;
        uint phase;
    }

    Phase[] private phases;
    mapping(address => uint) private purchasedTokens;

    event TokensPurchased(address indexed buyer, uint amount);
    event TokensClaimed(address indexed claimer, uint amount);
    event USDTClaimed(address indexed claimer, uint amount);



    constructor(address _token, address _paymentToken) {
        owner = msg.sender;
        token = IERC20(_token);
        paymentToken = IERC20(_paymentToken);
        currentPhaseIndex = 0;
        sold = 0;
        saleEnded = false;

        buyPrice = 2.38 * 10 ** 18; // ajustar segun decimales del token USDT
        phaseStartTime = block.timestamp;

        for (uint i = 0; i < 3; i++) {
            phases.push(Phase(phaseTarget, buyPrice, i + 1));
        }
    }


    function buy(uint tokens) public {
        require(!saleEnded, "Sale has ended");
        require(phase(currentPhaseIndex).total-sold >= tokens, "Not enough tokens available in this phase");

        uint usdtToUse = tokens * phase(currentPhaseIndex).price;
        require(paymentToken.allowance(msg.sender, address(this)) >= usdtToUse, "Not enough USDT approved");

        require(paymentToken.transferFrom(msg.sender, address(this), usdtToUse), "USDT transfer failed");

        sold += tokens;
        totalTokensSold += tokens;
        purchasedTokens[msg.sender] += tokens;

        if (phases[currentPhaseIndex].total == sold) {
            currentPhaseIndex++;
            phaseStartTime = block.timestamp;
            if (currentPhaseIndex == phases.length) {
                saleEnded = true;
            }
            else sold = 0;
        }
        emit TokensPurchased(msg.sender, tokens);
    }

    function checkTimePhase() public view returns (uint) {
        uint regressive = 600;
        uint currentTime = block.timestamp;
    
        uint timeElapsed = phaseStartTime + regressive - currentTime; 
    
        return timeElapsed; 
    }

    function switchPhase() public onlyOwner() {
        uint regressive = 600; 
        uint currentTime = block.timestamp;
        uint timeElapsed = currentTime - phaseStartTime;
        uint remainingTokens = phases[currentPhaseIndex].total - sold;

        sold = 0;
        currentPhaseIndex++;

        if (currentPhaseIndex >= phases.length) {
            currentPhaseIndex = 0; // Reiniciar a la fase 1
        }

        // Calcular el total de tokens que se usarán en la nueva fase
        uint newPhaseTotal = phases[currentPhaseIndex].total + remainingTokens;

        // Asegurarse de no exceder el total permitido
        if (newPhaseTotal > totalTokenscontract - totalTokensSold) {
            phases[currentPhaseIndex].total = totalTokenscontract - totalTokensSold;
        } else {
            phases[currentPhaseIndex].total = newPhaseTotal;
        }
    
        phaseStartTime = block.timestamp;
    }

    function claimUSDT() public onlyOwner {
        uint amount = paymentToken.balanceOf(address(this)); 
        require(amount > 0, "No USDT to claim"); 
        require(paymentToken.transfer(owner, amount), "USDT transfer failed"); 
        emit USDTClaimed(owner, amount); 
    }




    function claimTokens() public {
        require(saleEnded, "Sale has not ended yet");
        uint tokensToClaim = purchasedTokens[msg.sender];
        require(tokensToClaim > 0, "No tokens to claim");

        require(token.transfer(msg.sender, tokensToClaim * 10 ** 18), "Token transfer failed"); // ajustar segun decimales del token UNITY
        purchasedTokens[msg.sender] = 0;

        emit TokensClaimed(msg.sender, tokensToClaim);
    }

    function balanceOf(address account) public view returns (uint) {
        return purchasedTokens[account];
    }

    function endSale() public onlyOwner {
        require(!saleEnded, "Sale has already ended");

        uint remainingTokens = totalTokenscontract - totalTokensSold;

        require(remainingTokens > 0, "No remaining tokens to transfer");

        require(token.transfer(owner, remainingTokens * 10 ** 18), "Token transfer failed");

        payable(owner).transfer(address(this).balance);

        saleEnded = true;
    }



    function _unAmount(uint _amountDeci, uint decimals) private pure returns(uint){
        return _amountDeci / (10**decimals);
    }

    function _tokens() public view returns (uint) {
        return _unAmount(token.balanceOf(msg.sender), 18);
    }



    function tokensSold() public view returns (uint) {
        return totalTokensSold;
    }

    function totalTokens() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function currentPhase() public view returns (Phase memory, uint) {
        if (currentPhaseIndex < phases.length) {
            return (phases[currentPhaseIndex], sold);
        }else {
            return (phases[currentPhaseIndex - 1], sold);    
        }
    }

    function phase(uint phaseId) public view returns (Phase memory) {
        return phases[phaseId];
    }

    function _tokenPrice() public view returns (uint) {
        return buyPrice;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }
}