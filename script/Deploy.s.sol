// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IdeaETH} from "../src/IdeaETH.sol";
import {ImmutableCreate2Deployer} from "./ImmutableCreate2Deployer.sol";

contract Deploy is ImmutableCreate2Deployer {

    function run() public {
        register(
            "IdeaETH",
            bytes32(0x0000000000000000000000000000000000000000f397fd2e3ff52e0001f3d6d0),
            type(IdeaETH).creationCode
        );
        deploy();
    }
}
