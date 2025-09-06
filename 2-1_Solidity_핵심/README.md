# Solidity 프로그래밍 핵심

태그: Blockchain, Solidity, Smart Contract
프로젝트: 블록체인 강의

## 📜 들어가며: Solidity란?

**Solidity**는 이더리움과 같은 EVM(Ethereum Virtual Machine) 기반 블록체인에서 스마트 컨트랙트를 작성하기 위해 만들어진 가장 대표적인 프로그래밍 언어입니다. C++, Python, JavaScript 등 여러 언어의 영향을 받아 정적 타입(statically-typed) 언어로 설계되었습니다.

Solidity로 작성된 코드는 컴파일 과정을 거쳐 EVM이 이해할 수 있는 **바이트코드(Bytecode)** 로 변환된 후, 블록체인에 배포됩니다. 이번 시간에는 스마트 컨트랙트의 뼈대를 이루는 Solidity의 핵심 문법과 개념들을 알아보겠습니다.

---

## 1. 핵심 문법

모든 Solidity 파일은 다음과 같은 기본 구조를 가집니다.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyContract {
    // 여기에 코드를 작성합니다.
}
```

### **`pragma` (프라그마)**

-   **`pragma solidity ^0.8.20;`**: 이 코드가 어떤 버전의 Solidity 컴파일러를 사용해야 하는지를 명시합니다. `^` 기호는 "0.8.20 버전 이상, 하지만 0.9.0 미만"을 의미합니다. 이는 컴파일러 버전이 달라 발생할 수 있는 예기치 않은 동작이나 보안 취약점을 방지하는 중요한 역할을 합니다.
-   **`// SPDX-License-Identifier: MIT`**: 소스 코드의 라이선스를 명시하는 주석입니다. 컴파일러가 경고 메시지를 표시하지 않도록 파일을 작성할 때 가장 먼저 추가하는 것이 좋습니다. `MIT`는 가장 널리 사용되는 오픈소스 라이선스 중 하나입니다.

### **`contract` (컨트랙트)**

-   **`contract MyContract { ... }`**: Solidity 코드의 기본 단위로, 다른 객체 지향 언어의 '클래스(Class)'와 유사합니다. 컨트랙트 내부에는 상태 변수, 함수, 구조체, 이벤트 등 관련된 데이터와 로직이 함께 포함됩니다.

### **데이터 타입 (Data Types)**

Solidity는 변수의 타입을 명확하게 지정해야 하는 정적 타입 언어입니다. 자주 사용되는 주요 데이터 타입은 다음과 같습니다.

-   **`bool`**: `true` 또는 `false` 값을 가집니다.
-   **`uint` / `int`**: 부호 없는 정수(Unsigned Integer)와 부호 있는 정수(Integer)입니다. `uint8`, `uint16`, `uint256` 와 같이 8비트 단위로 크기를 명시할 수 있습니다. (`uint`는 `uint256`의 별칭입니다.)
-   **`address`**: 이더리움 주소(20바이트, 40자 16진수)를 저장하는 특별한 타입입니다. `balance` (잔액 조회), `transfer` (이더 전송) 등의 멤버 함수를 가집니다.
-   **`bytes`**: 동적인 크기의 바이트 배열입니다. `bytes1`, `bytes32` 등 고정된 크기를 가질 수도 있습니다.
-   **`string`**: 동적인 크기의 UTF-8 인코딩 문자열입니다.
-   **`mapping`**: 해시 테이블과 유사한 키-값 쌍 데이터 구조입니다. `mapping(keyType => valueType)` 형태로 선언합니다. (예: `mapping(address => uint) public balances;`)
-   **`struct`**: 여러 변수를 묶어 새로운 사용자 정의 타입을 만들 때 사용합니다.

### **함수 (Functions)**

컨트랙트의 동작을 정의하는 코드 블록입니다.

```solidity
function myFunction(uint _myNumber) public pure returns (uint) {
    return _myNumber * 2;
}
```

-   **가시성 지정자 (Visibility Specifiers)**: 함수를 어디서 호출할 수 있는지 범위를 지정합니다.
    -   **`public`**: 컨트랙트 내부, 상속받은 컨트랙트, 외부 사용자 등 누구나 호출할 수 있습니다.
    -   **`private`**: 해당 컨트랙트 내부에서만 호출할 수 있습니다. 상속받은 컨트랙트에서도 호출이 불가능합니다.
    -   **`internal`**: `private`과 유사하지만, 상속받은 컨트랙트에서는 호출할 수 있습니다.
    -   **`external`**: 외부에서만 호출할 수 있습니다. (컨트랙트 내부에서 호출하려면 `this.functionName()` 구문을 사용해야 합니다.) 가스 효율이 좋아 외부 호출용 API 함수에 주로 사용됩니다.

-   **상태 변경 지정자 (State Mutability Specifiers)**: 함수가 블록체인의 상태를 어떻게 다루는지를 명시합니다.
    -   **`view`**: 블록체인의 상태를 읽기만 하고, 변경하지 않는 함수입니다. (예: 특정 계정의 잔액 조회) 호출 시 가스를 소모하지 않습니다.
    -   **`pure`**: 블록체인의 상태를 읽지도, 변경하지도 않는 함수입니다. 오직 함수의 입력값에만 의존하여 결과를 반환합니다. (예: 두 숫자를 더하는 함수) 호출 시 가스를 소모하지 않습니다.
    -   (지정하지 않으면): 블록체인의 상태를 변경할 수 있는 함수입니다. 호출 시 가스를 소모하며, 트랜잭션으로 실행됩니다.

### **`modifier` (수식자)**

-   함수의 실행 조건이나 사전/사후 처리 로직을 정의하는 코드 조각입니다. 주로 접근 제어(예: "관리자만 이 함수를 실행할 수 있다")에 사용되어 코드의 중복을 줄여줍니다.

    ```solidity
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
    ```

    -   `onlyOwner` 수식자는 함수를 실행하는 주체(`msg.sender`)가 컨트랙트의 `owner`인지 확인합니다.
    -   `require()` 문은 조건이 `false`일 경우 실행을 중단하고 트랜잭션을 되돌립니다.
    -   `_;` 부분에 수식자가 적용된 함수의 본문 코드가 삽입되어 실행됩니다.

### **`event` (이벤트)**

-   컨트랙트에서 특정 동작이 발생했음을 외부(DApp 프론트엔드 등)에 알리는 역할을 합니다. 로그(Log) 데이터는 블록체인에 직접 저장되지만, 컨트랙트의 상태(Storage)를 사용하는 것보다 훨씬 저렴합니다.

    ```solidity
    event Transfer(address indexed from, address indexed to, uint amount);

    function transfer(address _to, uint _amount) public {
        // ... (잔액 변경 로직)
        emit Transfer(msg.sender, _to, _amount);
    }
    ```

    -   DApp은 이 `Transfer` 이벤트를 구독(subscribe)하고 있다가, 새로운 전송이 발생하면 사용자에게 알림을 보내거나 화면을 업데이트할 수 있습니다.
    -   `indexed` 키워드는 해당 파라미터를 필터링 가능한 검색 조건으로 만들어 줍니다.

---

## 2. 상태 변수와 메모리: `storage`, `memory`, `calldata`

Solidity에서 변수가 어디에 저장되는지를 이해하는 것은 가스비 최적화와 데이터 처리에 매우 중요합니다.

-   **`storage` (스토리지)**
    -   **위치**: 블록체인에 영구적으로 저장됩니다.
    -   **특징**: 컨트랙트의 상태 변수(함수 바깥에 선언된 변수)는 기본적으로 `storage`에 저장됩니다. 데이터를 블록체인에 기록하고 유지해야 하므로 **가스비가 가장 비쌉니다.**
    -   **사용**: 컨트랙트가 계속해서 기억해야 할 중요한 데이터(예: 사용자 잔액, 소유권 정보)에 사용됩니다.

-   **`memory` (메모리)**
    -   **위치**: 함수가 실행되는 동안에만 임시로 데이터를 저장합니다.
    -   **특징**: 함수 실행이 끝나면 해당 데이터는 사라집니다. `storage`보다 훨씬 저렴하지만, 여전히 가스를 소모합니다.
    -   **사용**: 함수 내에서만 사용되는 임시 변수, 다른 함수에 인자를 전달하는 경우 등에 사용됩니다. `string`, `bytes`, 배열, 구조체 등 복잡한 타입의 함수 파라미터나 지역 변수에 반드시 지정해야 합니다.

-   **`calldata`**
    -   **위치**: 트랜잭션이나 외부 함수 호출에 포함된 데이터가 저장되는 특수한 읽기 전용 공간입니다.
    -   **특징**: `memory`와 유사하게 임시적이지만, **수정이 불가능(immutable)** 하다는 점이 다릅니다. 외부 함수의 인자에 사용될 때 가장 효율적이며, **가스비가 가장 저렴합니다.**
    -   **사용**: 외부에서 함수를 호출할 때 전달되는 데이터를 그대로 읽기만 할 경우에 사용합니다. (예: `function doSomething(string calldata _name) external { ... }`)

**간단한 비유:**

-   `storage`: 하드 디스크 (영구 저장, 비쌈)
-   `memory`: RAM (임시 저장, 빠름, 중간 비용)
-   `calldata`: CD-ROM (읽기 전용, 매우 저렴)

---

## 3. 간단한 예제 컨트랙트 작성 및 컴파일

다음은 지금까지 배운 개념들을 종합한 간단한 `Counter` 컨트랙트입니다.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Hardhat/Foundry 개발 환경에서는 console.log를 사용할 수 있습니다.
import "hardhat/console.sol";

contract Counter {
    // 상태 변수 (storage에 저장됨)
    uint public count;

    // 이벤트 선언
    event CountIncreased(uint newCount);
    event CountDecreased(uint newCount);

    // 생성자: 컨트랙트가 처음 배포될 때 한 번만 실행됩니다.
    constructor(uint _initialCount) {
        count = _initialCount;
        console.log("Counter contract deployed with initial count:", _initialCount);
    }

    // count를 1 증가시키는 함수 (상태 변경)
    function increment() public {
        count += 1;
        console.log("Count is now:", count);
        emit CountIncreased(count);
    }

    // count를 1 감소시키는 함수 (상태 변경)
    function decrement() public {
        // uint는 0보다 작아질 수 없으므로, 언더플로우 방지
        require(count > 0, "Count cannot be less than zero");
        count -= 1;
        console.log("Count is now:", count);
        emit CountDecreased(count);
    }

    // 현재 count 값을 반환하는 함수 (상태 읽기)
    function getCount() public view returns (uint) {
        return count;
    }
}
```

### **컴파일**

Hardhat 프로젝트의 `contracts` 폴더에 위 코드를 `Counter.sol` 파일로 저장합니다. 그 후 터미널에서 다음 명령어를 실행하여 컨트랙트를 컴파일합니다.

```bash
npx hardhat compile
```

컴파일이 성공하면 `artifacts` 디렉토리에 `Counter.json` 파일이 생성됩니다. 이 파일에는 컨트랙트의 **ABI(Application Binary Interface)** 와 **바이트코드(Bytecode)** 가 포함되어 있어, DApp이 컨트랙트와 상호작용하거나 블록체인에 배포하는 데 사용됩니다.
