// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {PointCalculator} from "./PointCalculator.sol";

error NotOwner();

contract PointEmitter {
    using PointCalculator for uint256;

    uint256 public constant MINIMUM_CONTRIBUTION = 0.01 ether;
    address public immutable i_owner;
    mapping(address => uint256) public userPoints;

    constructor() {
        i_owner = msg.sender;
    }

    function contribute() public payable {
        require(
            msg.value >= MINIMUM_CONTRIBUTION,
            "Must send at least 0.01 ETH"
        );

        uint256 pointsReceived = msg.value.getPoints();
        userPoints[msg.sender] += pointsReceived;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    function withdraw() public view onlyOwner {
        // 1. 인출할 금액 (컨트랙트의 전체 잔액)
        uint256 amount = address(this).balance;

        // 2. 소유자에게 ETH 전송 (call 메소드 사용)
        // 전송 실패 시 트랜잭션을 되돌리기 위해 require 구문으로 감쌉니다.
        (bool success, ) = i_owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    // 이 컨트랙트에 ETH가 직접 보내지면 contribute 함수를 호출합니다.
    receive() external payable {
        contribute();
    }
}
