// // SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import { BlockHashStorage } from "../src/BlockHashStorage.sol";
import { TestBlocks } from "./TestBlocks.sol";

// exposes the internal block hash storage functions for testing
contract BlockHashProxy is BlockHashStorage {
    constructor(
        uint256 initialCheckpointHeight,
        bytes32 initialBlockHash,
        bytes32 initialRetargetBlockHash,
        uint8 minimumConfirmationDelta
    ) BlockHashStorage(initialCheckpointHeight, initialBlockHash, initialRetargetBlockHash, minimumConfirmationDelta) { }

    function AddBlock(
        uint256 safeBlockHeight,
        uint256 proposedBlockHeight,
        uint256 confirmationBlockHeight,
        bytes32[] memory blockHashes,
        uint256 proposedBlockIndex
    ) public {
        addBlock(safeBlockHeight, proposedBlockHeight, confirmationBlockHeight, blockHashes, proposedBlockIndex);
    }
}

contract BlockHashStorageTest is Test, TestBlocks {
    bytes4 constant INVALID_SAFE_BLOCK = bytes4(keccak256("InvalidSafeBlock()"));
    bytes4 constant BLOCK_DOES_NOT_EXIST = bytes4(keccak256("BlockDoesNotExist()"));
    bytes4 constant INVALID_CONFIRMATION_BLOCK = bytes4(keccak256("InvalidConfirmationBlock()"));
    bytes4 constant INVALID_PROPOSED_BLOCK_OVERWRITE = bytes4(keccak256("InvalidProposedBlockOverwrite()"));

    BlockHashProxy blockHashProxy;

    function setUp() public {
        blockHashProxy = new BlockHashProxy(blockHeights[0], blockHashes[0], retargetBlockHash, 5);
    }

    function fetchBlockSubset(uint256 start, uint256 end) public view returns (bytes32[] memory) {
        bytes32[] memory subset = new bytes32[](end - start);
        for (uint256 i = start; i < end; i++) {
            subset[i - start] = blockHashes[i];
        }
        return subset;
    }

    function testSimpleAddBlocks() public { 
      bytes32[] memory blocks = fetchBlockSubset(0, 5);
      blockHashProxy.AddBlock(blockHeights[0], blockHeights[1], blockHeights[6], blocks, 1);
    }
}