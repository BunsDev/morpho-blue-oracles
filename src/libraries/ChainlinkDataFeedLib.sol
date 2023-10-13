// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "../interfaces/AggregatorV3Interface.sol";

import {ErrorsLib} from "./ErrorsLib.sol";

/// @title ChainlinkDataFeedLib
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Library exposing functions to interact with a Chainlink-compliant feed.
library ChainlinkDataFeedLib {
    /// @dev Performs safety checks and returns the latest price of a `feed`.
    /// @dev When `feed` is the address zero, returns 1.
    /// @dev Notes on safety checks:
    /// - A stale period is not checked since the heartbeat of a Chainlink feed is an offchain parameter that can
    /// change any time and checking the price deviation onchain is not possible. It was not recommended by the Chailink
    /// team either.
    /// - The price is not checked to be in the min/max bounds since the check is already performed by Chainlink most of
    /// the time. Adding
    /// a safety margin would be arbitrary as well since the contract is immutable.
    /// - No fallback is used. In case the oracle reverts, Morpho Blue users can still exit their positions but
    /// can't be liquidated.
    function getPrice(AggregatorV3Interface feed) internal view returns (uint256) {
        if (address(feed) == address(0)) return 1;

        (, int256 answer,,,) = feed.latestRoundData();
        require(answer >= 0, ErrorsLib.NEGATIVE_ANSWER);

        return uint256(answer);
    }

    /// @dev Returns the number of decimals of a `feed`.
    /// @dev When `feed` is the address zero, returns 0.
    function getDecimals(AggregatorV3Interface feed) internal view returns (uint256) {
        if (address(feed) == address(0)) return 0;

        return feed.decimals();
    }
}
