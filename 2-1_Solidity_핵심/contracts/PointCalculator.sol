// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library PointCalculator {
    uint256 private constant NUMERATOR = 125;
    uint256 private constant DENOMINATOR = 100;

    function getPoints(uint256 ethAmount) internal pure returns (uint256) {
        return (ethAmount * NUMERATOR) / DENOMINATOR;
    }
}
