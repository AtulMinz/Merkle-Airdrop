//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdrop;
    mapping(address claimer => bool claim) private s_claimed;

    error MerkleAirdrop___InvalidMerkleProof();
    error MerkleAirdrop___HasAlreadyClaimed();

    event Claim(address, uint256);

    constructor(bytes32 merkleRoot, IERC20 airdrop) {
        i_merkleRoot = merkleRoot;
        i_airdrop = airdrop;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        if (s_claimed[account]) {
            revert MerkleAirdrop___HasAlreadyClaimed();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop___InvalidMerkleProof();
        }
        emit Claim(account, amount);
        i_airdrop.safeTransfer(account, amount);
        s_claimed[account] = true;
    }
}
