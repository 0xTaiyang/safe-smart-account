// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MerkleProof {
    // gas: 1997:
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) external pure returns (bool) {
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

    // gas: 2303:
    function verifyCalldataOld(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) external  pure returns (bool) {
            return processProofCalldata(proof, leaf) == root;
    }

    function processProofCalldata(
        bytes32[] calldata proof,
        bytes32 leaf
    ) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    function _hashPair(bytes32 a, bytes32 b)
        private
        pure
        returns(bytes32)
    {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b)
        private
        pure
        returns (bytes32 value)
    {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }

    // Merkle Root: 0xcc50382cfd3c9a617741e9a85efee8752b8feb95a2cbecd6365fb21366ce0c8c
    // Leaf (0): 0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb
    // Proof:
    // [
    //     "0xb5553de315e0edf504d9150af82dafa5c4667fa618ed0a6f19c69b41166c5510",
    //     "0xd253a52d4cb00de2895e85f2529e2976e6aaaa5c18106b68ab66813e14415669",
    //     "0x65d48a9a71389c608324abbe0156c2f0dd4f751d76d5f789779f4b1a25ef4a02",
    //     "0x1a8e90cd79c92557c57fc344b3ceca73f0d2fa2cea641b339fc8b862e093f15e"
    // ]
}