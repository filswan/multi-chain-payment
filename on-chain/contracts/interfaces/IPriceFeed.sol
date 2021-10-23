// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.4;

interface IPriceFeed {
    /// @notice Returns the amount of swapped token 
    /// @param token1
    /// @param token2
    /// @param amount1
    /// @param amount2
    /// @return The amount of swapped token
    function getSwapAmount(
        address token1,
        address token2,
        uint256 amount1,
        uint256 amount2
    ) external view returns (uint256);
}
