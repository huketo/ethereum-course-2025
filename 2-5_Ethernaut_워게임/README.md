# Ethernaut 보안 워게임 실습

## 📜 들어가며: 스마트 컨트랙트 보안의 중요성

스마트 컨트랙트는 "코드가 곧 법(Code is Law)"이라는 원칙에 따라 한번 배포되면 수정하기가 극히 어렵습니다. 또한, 수많은 사람들의 실제 자산을 다루기 때문에 작은 코드 결함 하나가 막대한 재산 피해로 이어질 수 있습니다. 역사적으로 The DAO 해킹, Parity 지갑 동결 사태 등 수많은 보안 사고가 스마트 컨트랙트의 취약점으로 인해 발생했습니다.

따라서 스마트 컨트랙트 개발자에게 보안은 선택이 아닌 필수 역량입니다. 이번 시간에는 **Ethernaut**이라는 스마트 컨트랙트 해킹 워게임 플랫폼을 통해, 실제 공격 사례에서 발견된 주요 취약점들을 직접 경험하고 방어하는 방법을 학습합니다.

**Ethernaut**는 OpenZeppelin에서 만든 학습 플랫폼으로, 각 레벨마다 특정 취약점을 가진 스마트 컨트랙트가 주어집니다. 우리의 목표는 해당 컨트랙트의 소유권을 탈취하거나, 컨트랙트의 상태를 우리가 원하는 대로 변경하는 것입니다.

> 🎮 **실습 준비**: 브라우저에서 [Ethernaut 공식 홈페이지](https://ethernaut.openzeppelin.com/)에 접속하고, MetaMask 지갑을 Sepolia 테스트넷으로 연결하세요. 각 레벨을 시작하기 위해 소량의 Sepolia ETH가 필요합니다.
> `Language` 메뉴에서 `한국어`를 선택하면 한글로 된 설명을 볼 수 있습니다.

---

## Level 1. Fallback

### **목표**

1.  컨트랙트의 소유권을 탈취합니다.
2.  컨트랙트의 잔액을 0으로 만듭니다.

### **취약점 분석**

주어진 `Fallback` 컨트랙트의 코드를 살펴봅시다.

```solidity
contract Fallback {
  mapping(address => uint) public contributions;
  address public owner;

  constructor() {
    owner = msg.sender;
    contributions[msg.sender] = 1000 * (1 ether);
  }

  modifier onlyOwner {
     require(msg.sender == owner, "caller is not the owner");
     _;
  }

  function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if(contributions[msg.sender] > contributions[owner]) {
      owner = msg.sender;
    }
  }

  function getContribution() public view returns (uint) {
    return contributions[msg.sender];
  }

  function withdraw() public onlyOwner {
    payable(owner).transfer(address(this).balance);
  }

  receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }
}
```

-   **`contribute()` 함수**: 0.001 ETH 미만의 이더를 보내 기여할 수 있습니다. 만약 누적 기여금이 현재 `owner`의 기여금보다 많아지면, `owner`가 `msg.sender`로 변경됩니다. 하지만 초기 `owner`의 기여금은 1000 ETH로 매우 크기 때문에, 이 함수를 통해 `owner`가 되는 것은 거의 불가능합니다.
-   **`receive()` 함수**: 이더리움에서 컨트랙트로 데이터(calldata) 없이 이더만 전송될 때 호출되는 특별한 함수입니다. 이 컨트랙트의 `receive` 함수에는 치명적인 로직이 있습니다.
    -   `require(msg.value > 0 && contributions[msg.sender] > 0)`: 0보다 큰 금액을 보내고, 이전에 한 번이라도 기여한 적이 있다면, `owner = msg.sender;` 즉, **소유권이 즉시 공격자에게 넘어옵니다!**

### **공격 시나리오**

1.  **`contribute()` 호출**: `receive` 함수의 두 번째 조건(`contributions[msg.sender] > 0`)을 만족시키기 위해, 아주 적은 양의 이더(예: 0.0001 ETH)를 담아 `contribute()` 함수를 호출합니다.
2.  **`receive()` 트리거**: 데이터 없이, 0보다 큰 이더(예: 0.0001 ETH)를 컨트랙트 주소로 직접 전송합니다. MetaMask의 '보내기' 기능을 사용하면 됩니다. 이더가 전송되면 `receive()` 함수가 자동으로 호출됩니다.
3.  **소유권 탈취**: `receive()` 함수의 `require` 문을 통과하고, 컨트랙트의 `owner`가 공격자의 주소로 변경됩니다.
4.  **자금 인출**: 이제 `owner`가 되었으므로, `withdraw()` 함수를 호출하여 컨트랙트에 남아있는 모든 이더를 인출합니다.

### **방어 방법**

-   `fallback` 또는 `receive` 함수에는 매우 신중하게 로직을 작성해야 합니다. 특히 상태를 변경하는 로직(예: 소유권 변경)은 절대로 포함해서는 안 됩니다.
-   만약 이더를 받는 기능만 구현하고 싶다면, `receive() external payable {}` 처럼 함수 본문을 비워두는 것이 안전합니다.

---

## Level 3. Coin Flip

### **목표**

동전 뒤집기 게임에서 10번 연속으로 이겨야 합니다.

### **취약점 분석**

```solidity
contract CoinFlip {
  // ...
  function flip(bool _guess) public returns (bool) {
    uint256 blockValue = uint256(block.blockhash(block.number - 1));
    uint256 coinFlip = blockValue / FACTOR;
    bool side = coinFlip == 1 ? true : false;

    if (side == _guess) {
      consecutiveWins++;
      return true;
    } else {
      consecutiveWins = 0;
      return false;
    }
  }
}
```

-   **예측 가능한 난수**: 이 컨트랙트는 동전의 앞/뒤를 결정하기 위해 `block.blockhash(block.number - 1)` 값을 사용합니다. `blockhash`는 이전 블록의 해시값으로, 블록체인 상에 공개되어 있는 데이터입니다. 즉, **결과값이 나오기 전에 누구나 미리 예측할 수 있는 값**이라는 의미입니다.
-   블록체인은 결정론적(deterministic) 시스템이기 때문에, 컨트랙트 내부에서 `block.timestamp`, `block.number`, `block.blockhash` 등과 같은 변수만을 사용하여 안전한 난수를 생성하는 것은 불가능합니다.

### **공격 시나리오**

1.  **공격용 스마트 컨트랙트 작성**: `CoinFlip` 컨트랙트와 동일한 로직으로 동전의 면을 계산하는 함수를 가진 별도의 공격 컨트랙트를 작성합니다.

    ```solidity
    contract AttackCoinFlip {
        function predict(address _coinFlipAddress) public returns (bool) {
            uint256 blockValue = uint256(block.blockhash(block.number - 1));
            uint256 coinFlip = blockValue / CoinFlip(_coinFlipAddress).FACTOR();
            bool side = coinFlip == 1 ? true : false;
            return side;
        }

        function attack(address _coinFlipAddress) public {
            bool prediction = predict(_coinFlipAddress);
            CoinFlip(_coinFlipAddress).flip(prediction);
        }
    }
    ```

2.  **공격 컨트랙트 배포**: 작성한 `AttackCoinFlip` 컨트랙트를 Sepolia 테스트넷에 배포합니다.
3.  **공격 실행**: 배포된 공격 컨트랙트의 `attack()` 함수를 10번 호출합니다. `attack()` 함수는 다음 블록이 채굴되기 전에 `CoinFlip` 컨트랙트와 동일한 방법으로 결과를 예측하고, 그 예측값을 `flip()` 함수에 전달합니다. 이 모든 과정이 하나의 트랜잭션 안에서 일어나므로, `block.number`는 동일하게 유지되어 예측은 100% 성공하게 됩니다.

### **방어 방법**

-   블록체인 상에서 안전한 난수가 필요할 때는 **체인링크(Chainlink) VRF(Verifiable Random Function)** 와 같은 외부 오라클(Oracle) 서비스를 사용해야 합니다. 오라클은 블록체인 외부에서 생성된 검증 가능한 난수를 안전하게 컨트랙트로 전달해 줍니다.

---

## Level 5. Token

### **목표**

아주 적은 양의 토큰으로 시작하여, 컨트랙트가 보유한 모든 토큰을 탈취합니다.

### **취약점 분석**

```solidity
contract Token {
  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) {
    totalSupply = _initialSupply;
    balances[msg.sender] = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }
  // ...
}
```

-   **산술 언더플로우 (Arithmetic Underflow)**: 이 컨트랙트는 Solidity 0.8.0 이전 버전에서 흔히 발견되던 **정수 언더플로우** 취약점을 가지고 있습니다. `transfer` 함수를 봅시다.
    -   `require(balances[msg.sender] - _value >= 0);`: `balances[msg.sender]`는 `uint` (부호 없는 정수) 타입입니다. `uint`는 항상 0 이상이므로, 이 `require` 문은 `balances[msg.sender]`가 `_value`보다 작을 때도 항상 `true`를 반환하게 되어 아무런 방어 역할을 하지 못합니다.
    -   만약 공격자가 보유한 토큰(예: 20개)보다 더 많은 양(예: 21개)을 전송하려고 하면, `balances[msg.sender] -= _value;` 라인에서 언더플로우가 발생합니다. 즉, `20 - 21`의 결과가 `-1`이 되는 대신, `uint` 타입의 최댓값에 가까운 아주 큰 숫자가 되어버립니다.

### **공격 시나리오**

1.  **초기 상태**: 공격자는 20개의 토큰을 가지고 있습니다.
2.  **언더플로우 공격**: 공격자는 `transfer()` 함수를 호출하여, 자신이 가지고 있지 않은 임의의 주소(아무 주소나 상관없음)로 21개의 토큰을 보냅니다.
3.  **잔액 변경**: `balances[msg.sender] -= 21;` 이 실행되면서, 공격자의 잔액은 `20 - 21`의 결과로 언더플로우가 발생하여 `uint`의 최댓값에 가까운 엄청나게 큰 숫자로 변합니다.
4.  **토큰 탈취**: 이제 공격자는 사실상 무한대에 가까운 토큰을 보유하게 되었으므로, `totalSupply` 만큼의 토큰을 자신의 다른 계정으로 전송하여 컨트랙트의 모든 토큰을 탈취할 수 있습니다.

### **방어 방법**

-   **Solidity 0.8.0 이상 버전 사용**: Solidity 0.8.0 버전부터는 컴파일러가 산술 오버플로우/언더플로우를 자동으로 감지하고 방지해 줍니다. 덧셈, 뺄셈 등의 연산에서 오버/언더플로우가 발생하면 트랜잭션이 자동으로 되돌려집니다.
-   **SafeMath 라이브러리 사용 (구버전)**: 0.8.0 미만 버전에서는 OpenZeppelin의 `SafeMath` 라이브러리를 사용하여 모든 산술 연산을 `add()`, `sub()`, `mul()`, `div()` 함수로 대체해야 합니다. 이 라이브러리는 오버/언더플로우 발생 시 `require` 문을 통해 실행을 중단시킵니다.
