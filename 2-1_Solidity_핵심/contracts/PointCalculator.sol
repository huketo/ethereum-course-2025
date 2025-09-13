// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library PointCalculator {
    uint256 private constant NUMERATOR = 125;
    uint256 private constant DENOMINATOR = 100;

    function getPoints(uint256 ethAmount) internal pure returns (uint256) {
        // 정밀도 손실 방지를 위해 곱셈을 먼저 수행합니다.
        return (ethAmount * NUMERATOR) / DENOMINATOR;
    }
}
