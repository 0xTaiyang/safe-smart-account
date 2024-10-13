// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

interface ISafe {
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) external returns (bool success);

    function isOwner(address owner) external view returns (bool);
}

contract Enum {
    enum Operation {
        Call,
        DelegateCall
    }
}

contract ModuleTest {

    ISafe safe;
    mapping(address => bool) public externalExecutors;


    constructor(address _safeAddress) {
        safe = ISafe(_safeAddress);
    }

    modifier onlySafe() {
        require(address(safe) == msg.sender, "only safe");
        _;
    }

    modifier onlyExecutor() {
        require(externalExecutors[msg.sender] || safe.isOwner(msg.sender), "only executor");
        _;
    }

    function modifyExecutor(address executor, bool enabled) public onlySafe {
        externalExecutors[executor] = enabled;
    }

    // implementation
    function testExecTransactionFromModule(address to, bytes memory data) public onlyExecutor {
        require(safe.execTransactionFromModule(
            to,
            0,
            data,
            Enum.Operation.Call
        ), "Module transaction failed");
    }
}
