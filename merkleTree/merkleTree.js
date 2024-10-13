const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');


const leaves = ['a', 'b', 'c', 'd','e','f','g','h','i','j'].map(x => keccak256(x));
const leafIndex = 1;  
const leaf = leaves[leafIndex];

const bufferToHex = (buffer) => '0x' + buffer.toString('hex');
const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

const root = tree.getRoot();
console.log('Merkle Root:', bufferToHex(root));


console.log(`Leaf (${leafIndex}):`, bufferToHex(leaf));

const proof = tree.getProof(leaf);

const proofFormatted = proof.map(p => bufferToHex(p.data));
console.log(`Proof:\n${JSON.stringify(proofFormatted, null, 4)}`);

const isValid = tree.verify(proof, leaf, root);
console.log('Is valid proof:', isValid);