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
    bytes32 public root;
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

    function updateExecutors(address[] calldata executors, bool enabled) external onlySafe {
        uint256 len = executors.length;
        for (uint256 i = 0; i < len; ) {
            externalExecutors[executors[i]] = enabled;
            unchecked { i++; }
        }
    }

    function updateMerkleRoot(bytes32 _root) external onlySafe {
        root = _root;
    }

    // implementation
    function execTransaction(
        address to, 
        bytes memory data,
        bytes32[] calldata proof
    ) public onlyExecutor {
        bytes32 leaf = keccak256(abi.encodePacked(to, data));
        require(verifyMerkleTree(proof, leaf), "Merkle tree verification failed");
        require(safe.execTransactionFromModule(
            to,
            0,
            data,
            Enum.Operation.Call
        ), "Module transaction failed");
    }

    // verify merkle tree
    function verifyMerkleTree(
        bytes32[] calldata proof,
        bytes32 leaf
    ) public view returns (bool) {
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
        return computedHash == root;
    }
}
