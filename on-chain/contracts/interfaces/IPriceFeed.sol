// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.4;

interface IPriceFeed {
    /// @notice Returns the amount of swapped token 
    /// 
    /// @return The amount of swapped token
    function getSwapAmount(
        address dexPair,
        uint8 tokenIndex,
        uint256 amount
    ) external view returns (uint256);
}
