# ERC 표준 토큰 컨트랙트 개발 (ERC-20)

태그: Blockchain, Solidity, ERC20, OpenZeppelin
프로젝트: 블록체인 강의

## 📜 들어가며: 토큰 표준은 왜 필요할까?

이더리움 블록체인 위에서는 누구나 자신만의 디지털 자산, 즉 **토큰(Token)** 을 발행할 수 있습니다. 초창기에는 개발자들이 각자 다른 방식으로 토큰을 만들었습니다. A 토큰은 `transfer()` 함수로 송금하는데, B 토큰은 `send()` 함수를 사용하는 식이었죠. 이렇게 되면 거래소나 지갑 서비스가 모든 토큰을 지원하기 위해 각각의 구현 방식에 맞춰 코드를 따로 개발해야 하는 큰 비효율이 발생합니다.

이러한 문제를 해결하기 위해 등장한 것이 바로 **ERC(Ethereum Request for Comment)** 라는 이더리움 개선 제안 표준입니다. 그중에서도 **ERC-20**은 대체 가능한 토큰(Fungible Token)이 따라야 할 **공통 인터페이스(규격)** 를 정의한 가장 대표적인 표준입니다.

**대체 가능하다(Fungible)** 는 것은, "어떤 토큰 1개가 다른 토큰 1개와 동일한 가치와 기능을 가져 서로 교환할 수 있다"는 의미입니다. 우리가 사용하는 1만 원짜리 지폐가 다른 1만 원짜리 지폐와 완전히 동일한 가치를 갖는 것과 같습니다.

모든 ERC-20 토큰이 동일한 함수 이름과 동작 방식을 갖게 되면서, 지갑, 거래소, DApp 등 이더리움 생태계의 모든 서비스들이 아주 쉽게 새로운 토큰을 통합하고 지원할 수 있게 되었습니다.

---

## 1. ERC-20 표준의 이해

ERC-20 표준은 모든 토큰 컨트랙트가 반드시 구현해야 하는 **6개의 필수 함수**와 **2개의 필수 이벤트**를 정의하고 있습니다.

### **필수 함수 (Methods)**

-   **`name()`**: 토큰의 이름 (예: "My Token")
-   **`symbol()`**: 토큰의 심볼 (예: "MTK")
-   **`decimals()`**: 토큰의 소수점 자릿수. `18`이 일반적으로 사용됩니다. (예: 1 토큰 = 1,000,000,000,000,000,000 단위)
-   **`totalSupply()`**: 토큰의 총 발행량을 반환합니다.
-   **`balanceOf(address _owner)`**: 특정 주소가 보유한 토큰의 잔액을 반환합니다.
-   **`transfer(address _to, uint256 _value)`**: 호출자의 계정에서 `_to` 주소로 `_value` 만큼의 토큰을 전송합니다.
-   **`transferFrom(address _from, address _to, uint256 _value)`**: `_from` 주소에서 `_to` 주소로 `_value` 만큼의 토큰을 전송합니다. 이 함수는 `approve()` 함수와 함께 사용되어, 다른 사람이나 컨트랙트가 나를 대신하여 토큰을 옮길 수 있도록 허용하는 데 쓰입니다.
-   **`approve(address _spender, uint256 _value)`**: `_spender` 주소(보통 스마트 컨트랙트)가 호출자의 계정에서 `_value` 만큼의 토큰을 인출할 수 있도록 위임(허용)합니다.
-   **`allowance(address _owner, address _spender)`**: `_spender`가 `_owner`의 계정에서 인출할 수 있도록 허용된 토큰의 잔여량을 반환합니다.

### **필수 이벤트 (Events)**

-   **`Transfer(address indexed _from, address indexed _to, uint256 _value)`**: 토큰이 전송될 때(발행, 소각 포함) 반드시 발생시켜야 하는 이벤트입니다.
-   **`Approval(address indexed _owner, address indexed _spender, uint256 _value)`**: `approve()` 함수가 성공적으로 호출되었을 때 발생시켜야 하는 이벤트입니다.

---

## 2. OpenZeppelin 활용: 안전하고 표준화된 ERC-20 컨트랙트 작성법

ERC-20 표준을 처음부터 끝까지 직접 구현하는 것은 매우 복잡하고, 사소한 실수로 인해 심각한 보안 취약점이 발생할 수 있습니다. 다행히 우리에게는 **OpenZeppelin**이라는 훌륭한 도구가 있습니다.

**OpenZeppelin**은 커뮤니티로부터 철저하게 검증된 안전한 스마트 컨트랙트 라이브러리입니다. 개발자들은 OpenZeppelin이 제공하는 표준 ERC-20 구현체를 **상속(inheritance)** 받기만 하면, 아주 간단하고 안전하게 자신만의 토큰을 만들 수 있습니다.

### **OpenZeppelin 설치**

Hardhat 프로젝트에서 다음 명령어를 사용하여 OpenZeppelin 컨트랙트 라이브러리를 설치합니다.

```bash
npm install @openzeppelin/contracts
```

### **ERC-20 컨트랙트 작성**

`contracts` 폴더에 `MyToken.sol` 파일을 생성하고 다음 코드를 작성합니다.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// OpenZeppelin의 ERC20 표준 구현체를 가져옵니다.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// ERC20 컨트랙트를 상속받아 MyToken 컨트랙트를 정의합니다.
contract MyToken is ERC20 {
    // ERC20 생성자에 토큰의 이름과 심볼을 전달합니다.
    constructor(uint256 initialSupply) ERC20("My Token", "MTK") {
        // _mint 함수를 호출하여 컨트랙트를 배포하는 사람(msg.sender)에게
        // initialSupply 만큼의 토큰을 발행하고 지급합니다.
        _mint(msg.sender, initialSupply);
    }
}
```

이 코드가 전부입니다! 단 몇 줄만으로 우리는 완벽한 ERC-20 표준을 따르는 토큰 컨트랙트를 완성했습니다.

-   `import "@openzeppelin/contracts/token/ERC20/ERC20.sol";`: OpenZeppelin 라이브러리에서 `ERC20.sol` 파일을 가져옵니다.
-   `contract MyToken is ERC20 { ... }`: `MyToken` 컨트랙트가 `ERC20` 컨트랙트의 모든 함수와 로직을 상속받도록 합니다.
-   `constructor(...) ERC20("My Token", "MTK")`: 컨트랙트가 배포될 때, 부모인 `ERC20` 컨트랙트의 생성자를 호출하여 토큰의 이름과 심볼을 설정합니다.
-   `_mint(msg.sender, initialSupply)`: `ERC20` 컨트랙트에 내장된 내부 함수 `_mint`를 사용하여, 컨트랙트 배포자에게 `initialSupply` 만큼의 초기 토큰을 발행해 줍니다.

---

## 3. Hardhat 로컬 노드에 ERC-20 토큰 배포 및 테스트

이제 작성한 `MyToken`을 Hardhat 로컬 네트워크에 배포하고, 주요 기능들을 테스트해 보겠습니다.

### **배포 스크립트 작성**

`scripts` 폴더에 있는 `deploy.ts` (또는 `deploy.js`) 파일을 다음과 같이 수정합니다.

```typescript
import { ethers } from "hardhat";

async function main() {
  // 컨트랙트 배포 시 초기 발행량을 설정합니다. (예: 1000개 토큰)
  // ERC20 생성자는 decimals를 18로 가정하므로, 1000 * 10^18 값을 전달합니다.
  const initialSupply = ethers.parseUnits("1000", 18);

  // MyToken 컨트랙트 팩토리를 가져옵니다.
  const MyToken = await ethers.getContractFactory("MyToken");

  // 컨트랙트를 배포하고, 생성자에 초기 발행량을 전달합니다.
  const myToken = await MyToken.deploy(initialSupply);

  // 배포가 완료될 때까지 기다립니다.
  await myToken.waitForDeployment();

  console.log(`MyToken deployed to: ${myToken.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

### **컨트랙트 배포**

먼저, Hardhat 로컬 노드를 실행합니다.

```bash
npx hardhat node
```

그리고 다른 터미널 창을 열어, 작성한 배포 스크립트를 실행합니다.

```bash
# --network localhost 옵션을 사용하여 로컬 노드에 배포합니다.
npx hardhat run scripts/deploy.ts --network localhost
```

배포가 성공하면 터미널에 컨트랙트 주소가 출력됩니다.
`MyToken deployed to: 0x...`

### **Hardhat 콘솔에서 함수 테스트**

Hardhat은 로컬 노드와 상호작용할 수 있는 대화형 콘솔을 제공합니다. 다음 명령어로 콘솔에 접속합니다.

```bash
npx hardhat console --network localhost
```

콘솔이 실행되면, JavaScript 코드를 사용하여 배포된 컨트랙트의 함수를 직접 호출해 볼 수 있습니다.

```javascript
// 1. 배포된 컨트랙트 인스턴스 가져오기
const tokenAddress = "0x..."; // 위에서 출력된 컨트랙트 주소를 붙여넣으세요.
const MyToken = await ethers.getContractFactory("MyToken");
const myToken = MyToken.attach(tokenAddress);

// 2. Hardhat이 제공하는 테스트 계정 가져오기
const [owner, addr1] = await ethers.getSigners();

// 3. 잔액 조회 (balanceOf)
// 배포자의 초기 잔액 확인 (1000 MTK)
(await myToken.balanceOf(owner.address)).toString();

// 4. 토큰 전송 (transfer)
// 배포자(owner)가 addr1에게 50 MTK를 전송
await myToken.transfer(addr1.address, ethers.parseUnits("50", 18));

// addr1의 잔액 확인
(await myToken.balanceOf(addr1.address)).toString();

// 5. 위임 및 전송 (approve & transferFrom)
// addr1이 owner에게 20 MTK를 다시 보내려고 합니다.
// 먼저, addr1은 owner의 주소에 20 MTK를 인출할 수 있도록 위임(approve)해야 합니다.
await myToken.connect(addr1).approve(owner.address, ethers.parseUnits("20", 18));

// owner가 addr1로부터 얼마나 인출할 수 있는지 확인 (allowance)
(await myToken.allowance(addr1.address, owner.address)).toString();

// 이제 owner는 transferFrom을 사용하여 addr1의 계정에서 자신의 계정으로 20 MTK를 가져올 수 있습니다.
await myToken.transferFrom(addr1.address, owner.address, ethers.parseUnits("20", 18));

// addr1의 최종 잔액 확인
(await myToken.balanceOf(addr1.address)).toString();
```

이 과정을 통해 우리는 OpenZeppelin을 사용하여 안전한 ERC-20 토큰을 손쉽게 만들고, Hardhat 환경에서 배포 및 테스트하는 전체 흐름을 경험했습니다. 이는 모든 DApp 개발의 가장 기본이 되는 중요한 과정입니다.
