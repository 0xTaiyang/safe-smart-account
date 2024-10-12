// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

interface ISafe {
    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction.
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) external returns (bool success);

    /**
     * @notice Returns if `owner` is an owner of the Safe.
     * @return Boolean if owner is an owner of the Safe.
     */
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

    modifier onlyOwner() {
        require(safe.isOwner(msg.sender), "only owner");
        _;
    }

    modifier onlyExecutor() {
        require(externalExecutors[msg.sender] || safe.isOwner(msg.sender), "only executor");
        _;
    }

    function modifyExecutor(address executor, bool enabled) public onlyOwner {
        externalExecutors[executor] = enabled;
    }

    // implementation logic
    function testExecTransactionFromModule(address to, bytes memory data) public onlyExecutor {
        require(safe.execTransactionFromModule(
            to,
            0,
            data,
            Enum.Operation.Call
        ), "Module transaction failed");
    }
}
