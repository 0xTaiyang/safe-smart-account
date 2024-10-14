// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.8.0 <0.9.0;

contract Enum {
    enum Operation {
        Call,
        DelegateCall
    }
}

contract ModuleTest {

    address immutable safe;
    bytes32 public merkleRoot;
    mapping(address => bool) private externalExecutors;

    constructor(address _safeAddress, bytes32 _merkleRoot) {
        safe = _safeAddress;
        merkleRoot = _merkleRoot;
    }

    function onlySafe() private view {
        if (!(address(safe) == msg.sender)) {
            revert();
        }
    }

    function onlyExecutor() private view {
        (bool success, ) = safe.staticcall(
            abi.encodeWithSelector(0x2f54bf6e, msg.sender)
        );
        if (!(externalExecutors[msg.sender] || success)) {
            revert();
        }
    }

    function updateExecutors(address[] calldata executors, bool enabled) external  {
        onlySafe();     
        uint256 len = executors.length;
        for (uint256 i = 0; i < len; i++) {
            externalExecutors[executors[i]] = enabled;
        }
    }

    function updateMerkleRoot(bytes32 _merkleRoot) external {
        onlySafe();
        merkleRoot = _merkleRoot;
    }

    function execTransaction(
        address to, 
        bytes memory data,
        bytes32[] calldata proof
    ) external payable {
        onlyExecutor();
        bytes32 leaf = keccak256(abi.encodePacked(to, data));
        verifyMerkleTree(proof, leaf);
        (bool success, ) = safe.call{value: 0}(
            abi.encodeWithSelector(0xddc0ecc7, to, 0, data, Enum.Operation.Call)
        );
        if (!success) {
            revert();
        }
    }

    // verify merkle tree
    function verifyMerkleTree(
        bytes32[] calldata proof,
        bytes32 leaf
    ) private view {
        bytes32 computedHash = leaf;
        uint256 length = proof.length;
        for (uint256 i = 0; i < length; ) {
            bytes32 a = computedHash;
            bytes32 b = proof[i];
            assembly {
                // Check if a is less than b
                switch lt(a, b)
                case 1 {
                    // Store a and b in memory
                    mstore(0x00, a)
                    mstore(0x20, b)
                }
                default {
                    // Store b and a in memory
                    mstore(0x00, b)
                    mstore(0x20, a)
                }
                // Compute the keccak256 hash of the memory region
                computedHash := keccak256(0x00, 0x40)
            }
            unchecked { ++i; }
        }
        if (computedHash != merkleRoot) {
            revert();
        }
    }
}
