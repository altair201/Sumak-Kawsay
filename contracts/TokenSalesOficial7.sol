// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSalesOficial7 {
    address public owner;
    uint private buyPrice;
    uint private sold;
    uint private totalTokensSold;
    uint private toSold;
    address private noOne = address(0);
    IERC20 private token;
    IERC20 private paymentToken;
    uint private currentPhaseIndex;
    bool public saleEnded;
    uint private phaseStartTime; 
    uint private phaseTarget = 2.1 * 10 ** 6; 
    uint private unsoldTokens; 
    bool private phaseEnded;

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

        buyPrice = 2.38 * 10 ** 18;
        phaseStartTime = block.timestamp;

        for (uint i = 0; i < 3; i++) {
            uint discountPercentage = (i == 0) ? 20 : (i == 1) ? 10 : 0;
            uint discountedPrice = (buyPrice * (100 - discountPercentage)) / 100;
            phases.push(Phase(phaseTarget, discountedPrice, i + 1));
        }
    }


    function buy(uint tokens) public {
        require(!saleEnded, "Sale has ended");
        require(phase(currentPhaseIndex).total >= tokens, "Not enough tokens available in this phase");

        uint usdtToUse = tokens * phase(currentPhaseIndex).price;
        require(paymentToken.allowance(msg.sender, address(this)) >= usdtToUse, "Not enough USDT approved");

        require(paymentToken.transferFrom(msg.sender, address(this), usdtToUse), "USDT transfer failed");

        require(token.transfer(msg.sender, tokens), "Token transfer failed");

        sold += tokens;
        totalTokensSold += tokens;
        purchasedTokens[msg.sender] += tokens;

        if (phases[currentPhaseIndex].total == 0) {
            currentPhaseIndex++;
            sold = 0;
            if (currentPhaseIndex == phases.length) {
                saleEnded = true;
            }
        }
        emit TokensPurchased(msg.sender, tokens);
    }

    function advanceToNextPhase() public {
        Phase storage currentPhaseA = phases[currentPhaseIndex];
    
        if (block.timestamp >= phaseStartTime + 1 hours) {
            
                if (currentPhaseIndex < phases.length - 1) {

                    currentPhaseIndex++;
                    currentPhaseA = phases[currentPhaseIndex];
                    phaseStartTime = block.timestamp;
                    phaseTarget = currentPhaseA.total;
                    sold = 0;
                } else {
                    saleEnded = true;
                    return;
                }
            
        }
    }


    function checkAndUpdatePhase() public view returns (uint) {
        uint regressive = 3600;
        uint currentTime = block.timestamp;
    
        uint timeElapsed = phaseStartTime + regressive - currentTime; 
    
        return timeElapsed; 
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

        require(token.transfer(msg.sender, tokensToClaim));
        purchasedTokens[msg.sender] = 0;

        emit TokensClaimed(msg.sender, tokensToClaim);
    }

    function balanceOf(address account) public view returns (uint) {
        return purchasedTokens[account];
    }

    function endSale() public onlyOwner {
        require(!saleEnded, "Sale has already ended");

        require(token.transfer(owner, phases[currentPhaseIndex].total));

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
        return _unAmount(token.totalSupply(), 18);
    }

    function currentPhase() public view returns (uint, uint, uint, uint) {
        Phase memory current = phases[currentPhaseIndex];
        uint totalTokensPhase = sold;
        return (current.phase, current.total, current.price, totalTokensPhase);
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