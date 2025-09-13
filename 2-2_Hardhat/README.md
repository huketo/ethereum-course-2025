# 실무 개발 환경 구축: Hardhat

- **🔰 현재 단계의 실습을 완료한 코드는 [Simple Storage Contract](https://github.com/huketo/simple-storage-contract) 레포지토리에서 확인할 수 있습니다.**

## 📜 들어가며: 왜 Hardhat을 사용할까?

스마트 컨트랙트를 개발하고, 테스트하며, 배포하는 전체 과정을 효율적으로 관리하기 위해서는 전문적인 개발 도구가 필수적입니다. **Hardhat**은 이더리움 소프트웨어 개발을 위한 강력하고 유연한 개발 환경 프레임워크입니다.

Hardhat을 사용하면 다음과 같은 이점들을 얻을 수 있습니다.

-   **로컬 이더리움 네트워크**: 실제 이더리움 네트워크와 유사한 환경을 내 컴퓨터에 빠르고 쉽게 구축할 수 있습니다. 이를 통해 실제 자산을 소모하지 않고도 컨트랙트 배포와 테스트를 무제한으로 진행할 수 있습니다.
-   **자동화된 테스트 환경**: Solidity 코드에 대한 단위 테스트 및 통합 테스트를 JavaScript(Mocha, Chai) 기반으로 쉽게 작성하고 실행할 수 있습니다.
-   **간편한 배포 스크립트**: 작성한 스마트 컨트랙트를 로컬, 테스트넷, 메인넷 등 원하는 네트워크에 손쉽게 배포할 수 있는 스크립트를 작성하고 관리할 수 있습니다.
-   **강력한 디버깅 기능**: `console.log`를 Solidity 코드 내에서 직접 사용하여 변수 값을 출력하는 등 편리한 디버깅 기능을 제공합니다.

이전 실습에서 만든 SimpleStorage 스마트 컨트랙트를 Hardhat 환경으로 옮겨와서, 실제로 배포하고 테스트하는 과정을 통해 Hardhat의 강력한 기능들을 체험해 보겠습니다.

---

## 1. 필수 도구 최종 점검

Hardhat을 사용하기 위해서는 다음과 같은 도구들이 사전에 설치되어 있어야 합니다.

- **Windows 터미널**: 최신 Windows는 기본적으로 Windows 터미널이 설치되어 있습니다. 만약 설치되어 있지 않다면, [Microsoft Store](https://aka.ms/terminal)에서 무료로 다운로드할 수 있습니다. 
-   **Node.js**: Hardhat은 Node.js 기반으로 동작합니다. [fnm(Fast Node Manager)](https://github.com/Schniz/fnm) Node.js 버전 관리 도구를 사용하여 Node.js를 설치하고 관리하는 것을 권장합니다.
-   **VSCode**: 코드 편집기로, [Solidity 확장 프로그램](https://marketplace.visualstudio.com/items?itemName=NomicFoundation.hardhat-solidity)을 설치하면 코드 하이라이팅 및 자동 완성 기능을 편리하게 사용할 수 있습니다.
-   **MetaMask**: 브라우저 확장 프로그램 형태의 암호화폐 지갑입니다. 아직 설치하지 않았다면 [공식 홈페이지](https://metamask.io/)에서 설치를 진행합니다.

### Node.js 설치 확인

터미널을 열고 다음 명령어를 입력하여 Node.js가 설치되어 있는지 확인합니다.

```powershell
$ node -v
v22.19.0 
$ npm -v
10.9.0
```

만약 Node.js가 설치되어 있지 않다면, fnm을 사용하여 설치합니다.

```powershell
# fnm 설치 (PowerShell)
$ winget install Schniz.Fnm
```

powershell 에 fnm 초기화 스크립트 추가

```powershell
# 터미널 profile 설정 파일 열기
$ notepad $PROFILE
```

`fnm env --use-on-cd | Out-String | Invoke-Expression` 내용을 복사하여 프로필 파일에 추가하고 저장한 뒤, 터미널을 재시작합니다.


최신 LTS 버전의 Node.js 설치 및 설정

```powershell
# fnm을 사용하여 Node.js 최신 LTS 버전 설치
$ fnm install --lts
Installing Node v22.19.0 (x64)
# 설치한 LTS 버전을 기본 버전으로 설정
$ fnm default v22.19.0
# 현재 터미널 세션에 적용
$ fnm use v22.19.0
```

Node.js와 npm이 정상적으로 설치되었는지 다시 한 번 확인합니다.

```powershell
# 설치 확인
$ node -v
v22.19.0
$ npm -v
10.9.0
```

---

## 2. Hardhat 프로젝트 생성 및 로컬 노드 실행

### 프로젝트 생성

- 터미널을 열고, 새로운 프로젝트를 생성할 디렉토리로 이동합니다.

```powershell
cd ~\workspace
mkdir simple-storage
cd simple-storage
```

- 다음 명령어를 순서대로 입력하여 Hardhat 프로젝트를 초기화합니다.

```powershell
# hardhat 프로젝트 초기화
npx hardhat --init
```

</br>

- `y`를 입력하고 Enter를 눌러 hardhat 패키지 설치

![hardhat-install-01](./imgs/hardhat-install-01.png)

</br>

- `Hardhat 3 Beta (recommended for new projects)` 선택 (Enter)

![hardhat-install-02](./imgs/hardhat-install-02.png)

</br>

- 설치 경로 기본값(현재 디렉토리) `.` (Enter)

![hardhat-install-03](./imgs/hardhat-install-03.png)

</br>

- `↓` 방향키를 눌러 `A TypeScript Hardhat project using Mocha and Ethers.js` 선택 후 (Enter)

![hardhat-install-04](./imgs/hardhat-install-04.png)

</br>

-  기본값 `true` (Enter)

![hardhat-install-05](./imgs/hardhat-install-05.png)

</br>

- 설치 완료 🚀

![hardhat-install-06](./imgs/hardhat-install-06.png)

</br>



디렉토리 구조:

![hardhat-install-07](./imgs/hardhat-install-07.png)

```
simple-storage // 프로젝트 디렉토리 구조
├── .gitignore // Git 무시 파일
├── hardhat.config.ts // Hardhat 설정 파일
├── package-lock.json // npm 패키지 잠금 파일
├── package.json // npm 패키지 설정 파일
├── README.md // 프로젝트 설명 파일
├── tsconfig.json // TypeScript 설정 파일
├── contracts // 스마트 컨트랙트 소스 코드 디렉토리
│   ├── Counter.sol // Counter 스마트 컨트랙트
│   └── Counter.t.sol // Counter 스마트 컨트랙트 테스트 코드 (Foundry 스타일)
├── ignition // Hardhat Ignition 설정 디렉토리 - 배포를 위한 코드
│   └── Counter.ts // Counter 배포 스크립트
├── scripts // 블록체인 상에서 실행할 스크립트 디렉토리
│   └── send-op-tx.ts // 옵티미스틱 롤업 트랜잭션 전송 스크립트
└── test // 테스트 코드 디렉토리
    └── Counter.t.ts // Counter 스마트 컨트랙트 테스트 코드 (Mocha 스타일)
```

* _Foundry: Rust 로 만들어진 스마트 컨트랙트 개발 프레임워크, 빠른 컴파일 속도와 강력한 테스트 기능 제공으로 주목받고 있습니다._
* _Mocha: JavaScript 테스트 프레임워크로, 비동기 테스트 지원과 유연한 구조를 제공합니다._

---

### Hardhat 로컬 노드 실행

명령어 도움 확인:

```powershell
npx hardhat --help
```

로컬 Hardhat 노드 실행:

```powershell
➜ npx hardhat node
Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545/

Accounts
========

WARNING: Funds sent on live network to accounts with publicly known private keys WILL BE LOST.

Account #0:  0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266 (10000 ETH)
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

Account #1:  0x70997970c51812dc3a010c7d01b50e0d17dc79c8 (10000 ETH)
Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

Account #2:  0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc (10000 ETH)
Private Key: 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a

Account #3:  0x90f79bf6eb2c4f870365e785982e1f101e93b906 (10000 ETH)
Private Key: 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6

Account #4:  0x15d34aaf54267db7d7c367839aaf71a00a2c6a65 (10000 ETH)
Private Key: 0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a

Account #5:  0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc (10000 ETH)
Private Key: 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba

Account #6:  0x976ea74026e726554db657fa54763abd0c3a0aa9 (10000 ETH)
Private Key: 0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e

Account #7:  0x14dc79964da2c08b23698b3d3cc7ca32193d9955 (10000 ETH)
Private Key: 0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356

Account #8:  0x23618e81e3f5cdf7f54c3d65f7fbc0abf5b21e8f (10000 ETH)
Private Key: 0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97

Account #9:  0xa0ee7a142d267c1f36714e4a8f75612f20a79720 (10000 ETH)
Private Key: 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6

Account #10: 0xbcd4042de499d14e55001ccbb24a551f3b954096 (10000 ETH)
Private Key: 0xf214f2b2cd398c806f84e317254e0f0b801d0643303237d97a22a48e01628897

Account #11: 0x71be63f3384f5fb98995898a86b02fb2426c5788 (10000 ETH)
Private Key: 0x701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82

Account #12: 0xfabb0ac9d68b0b445fb7357272ff202c5651694a (10000 ETH)
Private Key: 0xa267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1

Account #13: 0x1cbd3b2770909d4e10f157cabc84c7264073c9ec (10000 ETH)
Private Key: 0x47c99abed3324a2707c28affff1267e45918ec8c3f20b8aa892e8b065d2942dd

Account #14: 0xdf3e18d64bc6a983f673ab319ccae4f1a57c7097 (10000 ETH)
Private Key: 0xc526ee95bf44d8fc405a158bb884d9d1238d99f0612e9f33d006bb0789009aaa

Account #15: 0xcd3b766ccdd6ae721141f452c550ca635964ce71 (10000 ETH)
Private Key: 0x8166f546bab6da521a8369cab06c5d2b9e46670292d85c875ee9ec20e84ffb61

Account #16: 0x2546bcd3c84621e976d8185a91a922ae77ecec30 (10000 ETH)
Private Key: 0xea6c44ac03bff858b476bba40716402b03e41b8e97e276d1baec7c37d42484a0

Account #17: 0xbda5747bfd65f08deb54cb465eb87d40e51b197e (10000 ETH)
Private Key: 0x689af8efa8c651a91ad287602527f3af2fe9f6501a7ac4b061667b5a93e037fd

Account #18: 0xdd2fd4581271e230360230f9337d5c0430bf44c0 (10000 ETH)
Private Key: 0xde9be858da4a475276426320d5e9262ecfc3ba460bfac56360bfa6c4c28b4ee0

Account #19: 0x8626f6940e2eb28930efb4cef49b2d1f2c9c1199 (10000 ETH)
Private Key: 0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e

WARNING: Funds sent on live network to accounts with publicly known private keys WILL BE LOST.
```

- 위와 같이 20개의 테스트 계정과 프라이빗 키가 생성되고, 각 계정에 10,000 ETH가 할당됩니다.
- 이 프라이빗 키들은 오직 로컬 테스트 환경에서만 사용해야 하며, 실제 네트워크에서는 절대 사용해서는 안 됩니다.
- 터미널을 닫지 않고, 새로운 터미널을 열어 다음 단계를 진행합니다.

---

## 3. SimpleStorage 스마트 컨트랙트 Hardhat 프로젝트로 이전

```powershell
# 현재 위치가 simple-storage 디렉토리인지 확인
code . # VSCode로 현재 디렉토리 열기
```

### 3.1. 기존 SimpleStorage 코드 복사

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleStorage {
    uint256 myFavoriteNumber;

    struct Person {
        uint256 favoriteNumber;
        string name;
    }

    Person[] public listOfPeople;
    mapping(string => uint256) public nameToFavoriteNumber;

    function store(uint256 _favoriteNumber) public {
        myFavoriteNumber = _favoriteNumber;
    }

    function retrieve() public view returns (uint256) {
        return myFavoriteNumber;
    }

    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        listOfPeople.push(Person(_favoriteNumber, _name));
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }

    function getPeopleCount() public view returns (uint256) {
        return listOfPeople.length;
    }
}
```

- `contracts` 디렉토리 내에 `SimpleStorage.sol` 파일을 생성하고, 위 코드를 복사하여 붙여넣습니다.


### 3.1. 테스트 코드 작성

#### 3.1.1. Solidity 테스트 코드 작성

`contracts` 디렉토리 내에 `SimpleStorage.t.sol` 파일을 생성하고, 다음 코드를 복사하여 붙여넣습니다.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SimpleStorage} from "./SimpleStorage.sol";
import {Test} from "forge-std/Test.sol";

contract SimpleStorageTest is Test {
    SimpleStorage simpleStorage;

    function setUp() public {
        simpleStorage = new SimpleStorage();
    }

    function test_InitialValue() public view {
        require(simpleStorage.retrieve() == 0, "Initial value should be 0");
    }

    function test_StoreAndRetrieve() public {
        simpleStorage.store(42);
        require(simpleStorage.retrieve() == 42, "Stored value should be 42");
    }

    function test_AddPerson() public {
        simpleStorage.addPerson("Alice", 7);
        (uint256 favNum, string memory name) = simpleStorage.listOfPeople(0);
        require(favNum == 7, "Favorite number should be 7");
        require(
            keccak256(bytes(name)) == keccak256(bytes("Alice")),
            "Name should be Alice"
        );
        require(
            simpleStorage.nameToFavoriteNumber("Alice") == 7,
            "Mapping should return favorite number 7 for Alice"
        );
    }

    function testFuzz_Store(uint256 x) public {
        simpleStorage.store(x);
        require(
            simpleStorage.retrieve() == x,
            "Stored value should match the input"
        );
    }

    function testFuzz_AddPerson(string memory name, uint256 favNum) public {
        // Skip empty names as they might cause issues
        vm.assume(bytes(name).length > 0);

        uint256 initialLength = simpleStorage.getPeopleCount();
        simpleStorage.addPerson(name, favNum);

        // Check the person was added to the array
        require(
            simpleStorage.getPeopleCount() == initialLength + 1,
            "Array length should increase by 1"
        );

        // Check the person data in the array
        (uint256 storedFavNum, string memory storedName) = simpleStorage
            .listOfPeople(initialLength);
        require(storedFavNum == favNum, "Favorite number should match");
        require(
            keccak256(bytes(storedName)) == keccak256(bytes(name)),
            "Name should match"
        );

        // Check the mapping
        require(
            simpleStorage.nameToFavoriteNumber(name) == favNum,
            "Mapping should return correct favorite number"
        );
    }

    function test_AddMultiplePeople() public {
        simpleStorage.addPerson("Alice", 7);
        simpleStorage.addPerson("Bob", 42);
        simpleStorage.addPerson("Charlie", 99);

        require(simpleStorage.getPeopleCount() == 3, "Should have 3 people");

        // Check Alice
        (uint256 favNum1, string memory name1) = simpleStorage.listOfPeople(0);
        require(
            favNum1 == 7 && keccak256(bytes(name1)) == keccak256(bytes("Alice"))
        );
        require(simpleStorage.nameToFavoriteNumber("Alice") == 7);

        // Check Bob
        (uint256 favNum2, string memory name2) = simpleStorage.listOfPeople(1);
        require(
            favNum2 == 42 && keccak256(bytes(name2)) == keccak256(bytes("Bob"))
        );
        require(simpleStorage.nameToFavoriteNumber("Bob") == 42);

        // Check Charlie
        (uint256 favNum3, string memory name3) = simpleStorage.listOfPeople(2);
        require(
            favNum3 == 99 &&
                keccak256(bytes(name3)) == keccak256(bytes("Charlie"))
        );
        require(simpleStorage.nameToFavoriteNumber("Charlie") == 99);
    }

    function test_AddPersonWithEmptyName() public {
        simpleStorage.addPerson("", 42);

        (uint256 favNum, string memory name) = simpleStorage.listOfPeople(0);
        require(favNum == 42, "Favorite number should be stored correctly");
        require(
            keccak256(bytes(name)) == keccak256(bytes("")),
            "Empty name should be stored"
        );
        require(
            simpleStorage.nameToFavoriteNumber("") == 42,
            "Mapping should work with empty string"
        );
    }

    function test_OverwritePersonMapping() public {
        // Add person first time
        simpleStorage.addPerson("Alice", 7);
        require(simpleStorage.nameToFavoriteNumber("Alice") == 7);

        // Add same person with different favorite number
        simpleStorage.addPerson("Alice", 100);

        // Mapping should be overwritten
        require(
            simpleStorage.nameToFavoriteNumber("Alice") == 100,
            "Mapping should be overwritten to 100"
        );

        // Array should have both entries
        require(
            simpleStorage.getPeopleCount() == 2,
            "Array should have 2 entries"
        );

        // Check first entry
        (uint256 favNum1, string memory name1) = simpleStorage.listOfPeople(0);
        require(
            favNum1 == 7 && keccak256(bytes(name1)) == keccak256(bytes("Alice"))
        );

        // Check second entry
        (uint256 favNum2, string memory name2) = simpleStorage.listOfPeople(1);
        require(
            favNum2 == 100 &&
                keccak256(bytes(name2)) == keccak256(bytes("Alice"))
        );
    }

    function test_StoreZero() public {
        simpleStorage.store(42); // Set to non-zero first
        simpleStorage.store(0); // Then set to zero
        require(simpleStorage.retrieve() == 0, "Should be able to store zero");
    }

    function test_StoreMaxUint256() public {
        uint256 maxValue = type(uint256).max;
        simpleStorage.store(maxValue);
        require(
            simpleStorage.retrieve() == maxValue,
            "Should be able to store max uint256 value"
        );
    }

    function test_AddPersonWithMaxUint256() public {
        uint256 maxValue = type(uint256).max;
        simpleStorage.addPerson("MaxUser", maxValue);

        (uint256 favNum, string memory name) = simpleStorage.listOfPeople(0);
        require(favNum == maxValue, "Should handle max uint256 value");
        require(
            keccak256(bytes(name)) == keccak256(bytes("MaxUser")),
            "Name should be stored correctly"
        );
        require(
            simpleStorage.nameToFavoriteNumber("MaxUser") == maxValue,
            "Mapping should store max value correctly"
        );
    }

    function test_NonExistentMapping() public view {
        // Test accessing mapping with non-existent key
        uint256 result = simpleStorage.nameToFavoriteNumber("NonExistent");
        require(result == 0, "Non-existent mapping should return 0");
    }
}
```

#### 3.1.2. JavaScript 테스트 코드 작성

`test` 디렉토리 내에 `SimpleStorage.ts` 파일을 생성하고, 다음 코드를 복사하여 붙여넣습니다.

```typescript
import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("SimpleStorage", function () {
  it("Should have initial value of 0", async function () {
    const simpleStorage = await ethers.deployContract("SimpleStorage");
    
    expect(await simpleStorage.retrieve()).to.equal(0n);
  });

  it("Should store and retrieve a value correctly", async function () {
    const simpleStorage = await ethers.deployContract("SimpleStorage");
    
    await simpleStorage.store(42n);
    expect(await simpleStorage.retrieve()).to.equal(42n);
  });

  it("Should store zero value correctly", async function () {
    const simpleStorage = await ethers.deployContract("SimpleStorage");
    
    // Set to non-zero first, then set to zero
    await simpleStorage.store(42n);
    await simpleStorage.store(0n);
    expect(await simpleStorage.retrieve()).to.equal(0n);
  });

  it("Should store maximum uint256 value correctly", async function () {
    const simpleStorage = await ethers.deployContract("SimpleStorage");
    const maxValue = 2n ** 256n - 1n; // Maximum uint256 value
    
    await simpleStorage.store(maxValue);
    expect(await simpleStorage.retrieve()).to.equal(maxValue);
  });

  it("Should add a person correctly", async function () {
    const simpleStorage = await ethers.deployContract("SimpleStorage");
    
    await simpleStorage.addPerson("Alice", 7n);
    
    // Check array entry
    const person = await simpleStorage.listOfPeople(0);
    expect(person.favoriteNumber).to.equal(7n);
    expect(person.name).to.equal("Alice");
    
    // Check mapping
    expect(await simpleStorage.nameToFavoriteNumber("Alice")).to.equal(7n);
    
    // Check people count
    expect(await simpleStorage.getPeopleCount()).to.equal(1n);
  });

  it("Should add multiple people correctly", async function () {
    const simpleStorage = await ethers.deployContract("SimpleStorage");
    
    await simpleStorage.addPerson("Alice", 7n);
    await simpleStorage.addPerson("Bob", 42n);
    await simpleStorage.addPerson("Charlie", 99n);
    
    expect(await simpleStorage.getPeopleCount()).to.equal(3n);
    
    // Check Alice
    const alice = await simpleStorage.listOfPeople(0);
    expect(alice.favoriteNumber).to.equal(7n);
    expect(alice.name).to.equal("Alice");
    expect(await simpleStorage.nameToFavoriteNumber("Alice")).to.equal(7n);
    
    // Check Bob
    const bob = await simpleStorage.listOfPeople(1);
    expect(bob.favoriteNumber).to.equal(42n);
    expect(bob.name).to.equal("Bob");
    expect(await simpleStorage.nameToFavoriteNumber("Bob")).to.equal(42n);
    
    // Check Charlie
    const charlie = await simpleStorage.listOfPeople(2);
    expect(charlie.favoriteNumber).to.equal(99n);
    expect(charlie.name).to.equal("Charlie");
    expect(await simpleStorage.nameToFavoriteNumber("Charlie")).to.equal(99n);
  });

  it("Should handle empty name correctly", async function () {
    const simpleStorage = await ethers.deployContract("SimpleStorage");
    
    await simpleStorage.addPerson("", 42n);
    
    const person = await simpleStorage.listOfPeople(0);
    expect(person.favoriteNumber).to.equal(42n);
    expect(person.name).to.equal("");
    expect(await simpleStorage.nameToFavoriteNumber("")).to.equal(42n);
  });

  it("Should overwrite mapping when adding person with same name", async function () {
    const simpleStorage = await ethers.deployContract("SimpleStorage");
    
    // Add Alice first time
    await simpleStorage.addPerson("Alice", 7n);
    expect(await simpleStorage.nameToFavoriteNumber("Alice")).to.equal(7n);
    
    // Add Alice second time with different favorite number
    await simpleStorage.addPerson("Alice", 100n);
    
    // Mapping should be overwritten
    expect(await simpleStorage.nameToFavoriteNumber("Alice")).to.equal(100n);
    
    // Array should have both entries
    expect(await simpleStorage.getPeopleCount()).to.equal(2n);
    
    const firstAlice = await simpleStorage.listOfPeople(0);
    expect(firstAlice.favoriteNumber).to.equal(7n);
    expect(firstAlice.name).to.equal("Alice");
    
    const secondAlice = await simpleStorage.listOfPeople(1);
    expect(secondAlice.favoriteNumber).to.equal(100n);
    expect(secondAlice.name).to.equal("Alice");
  });

  it("Should return 0 for non-existent mapping", async function () {
    const simpleStorage = await ethers.deployContract("SimpleStorage");
    
    expect(await simpleStorage.nameToFavoriteNumber("NonExistent")).to.equal(0n);
  });

  it("Should handle maximum uint256 favorite number", async function () {
    const simpleStorage = await ethers.deployContract("SimpleStorage");
    const maxValue = 2n ** 256n - 1n; // Maximum uint256 value
    
    await simpleStorage.addPerson("MaxUser", maxValue);
    
    const person = await simpleStorage.listOfPeople(0);
    expect(person.favoriteNumber).to.equal(maxValue);
    expect(person.name).to.equal("MaxUser");
    expect(await simpleStorage.nameToFavoriteNumber("MaxUser")).to.equal(maxValue);
  });

  it("Should maintain state consistency across multiple operations", async function () {
    const simpleStorage = await ethers.deployContract("SimpleStorage");
    
    // Store a favorite number
    await simpleStorage.store(777n);
    expect(await simpleStorage.retrieve()).to.equal(777n);
    
    // Add some people
    await simpleStorage.addPerson("User1", 1n);
    await simpleStorage.addPerson("User2", 2n);
    
    // Check that storing favorite number doesn't affect people
    expect(await simpleStorage.getPeopleCount()).to.equal(2n);
    expect(await simpleStorage.nameToFavoriteNumber("User1")).to.equal(1n);
    expect(await simpleStorage.nameToFavoriteNumber("User2")).to.equal(2n);
    
    // Check that adding people doesn't affect stored favorite number
    expect(await simpleStorage.retrieve()).to.equal(777n);
    
    // Change stored favorite number
    await simpleStorage.store(888n);
    expect(await simpleStorage.retrieve()).to.equal(888n);
    
    // People data should remain unchanged
    expect(await simpleStorage.getPeopleCount()).to.equal(2n);
    expect(await simpleStorage.nameToFavoriteNumber("User1")).to.equal(1n);
    expect(await simpleStorage.nameToFavoriteNumber("User2")).to.equal(2n);
  });

  describe("Edge Cases", function () {
    it("Should handle very long names", async function () {
      const simpleStorage = await ethers.deployContract("SimpleStorage");
      const longName = "A".repeat(1000); // Very long name
      
      await simpleStorage.addPerson(longName, 123n);
      
      const person = await simpleStorage.listOfPeople(0);
      expect(person.favoriteNumber).to.equal(123n);
      expect(person.name).to.equal(longName);
      expect(await simpleStorage.nameToFavoriteNumber(longName)).to.equal(123n);
    });

    it("Should handle special characters in names", async function () {
      const simpleStorage = await ethers.deployContract("SimpleStorage");
      const specialName = "Alice@#$%^&*()_+-=[]{}|;':\",./<>?`~";
      
      await simpleStorage.addPerson(specialName, 456n);
      
      const person = await simpleStorage.listOfPeople(0);
      expect(person.favoriteNumber).to.equal(456n);
      expect(person.name).to.equal(specialName);
      expect(await simpleStorage.nameToFavoriteNumber(specialName)).to.equal(456n);
    });

    it("Should handle unicode characters in names", async function () {
      const simpleStorage = await ethers.deployContract("SimpleStorage");
      const unicodeName = "Alice김철수🎉";
      
      await simpleStorage.addPerson(unicodeName, 789n);
      
      const person = await simpleStorage.listOfPeople(0);
      expect(person.favoriteNumber).to.equal(789n);
      expect(person.name).to.equal(unicodeName);
      expect(await simpleStorage.nameToFavoriteNumber(unicodeName)).to.equal(789n);
    });
  });
});
```

- 테스트 코드 작성이 완료되면, 터미널에서 다음 명령어를 입력하여 테스트를 실행합니다.

```powershell
npx hardhat test
```

### 3.2. Hardhat 설정 파일 수정

`hardhat.config.ts` 파일을 열고, 다음과 같이 수정합니다.

```typescript
import type { HardhatUserConfig } from "hardhat/config";

import hardhatToolboxMochaEthersPlugin from "@nomicfoundation/hardhat-toolbox-mocha-ethers";
import { configVariable } from "hardhat/config";

const config: HardhatUserConfig = {
  plugins: [hardhatToolboxMochaEthersPlugin],
  solidity: {
    profiles: {
      default: {
        version: "0.8.28",
      },
      production: {
        version: "0.8.28",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    },
  },
  networks: {
    hardhatMainnet: {
      type: "edr-simulated",
      chainType: "l1",
    },
    hardhatOp: {
      type: "edr-simulated",
      chainType: "op",
    },
    local: {
      type: "http",
      chainId: 31337, // Hardhat 네트워크의 기본 체인 ID
      url: "http://localhost:8545",
    },
    sepolia: {
      type: "http",
      chainType: "l1",
      url: configVariable("SEPOLIA_RPC_URL"),
      accounts: [configVariable("SEPOLIA_PRIVATE_KEY")],
    },
  },
};

export default config;
```

### 3.3. 로컬노드에 스마트 컨트랙트 배포

`ignition/modules` 디렉토리 내에 `SimpleStorage.ts` 파일을 생성하고, 다음 코드를 복사하여 붙여넣습니다.

```typescript
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("SimpleStorageModule", (m) => {
  const simpleStorage = m.contract("SimpleStorage");
  
  return { simpleStorage };
});
```

다음 명령어를 입력하여 스마트 컨트랙트를 로컬 Hardhat 노드에 배포합니다.

```powershell
npx hardhat ignition deploy --network local ignition/modules/SimpleStorage.ts
```

결과:

```plaintext
Hardhat Ignition 🚀

Deploying [ SimpleStorageModule ]

Batch #1
  Executed SimpleStorageModule#SimpleStorage

[ SimpleStorageModule ] successfully deployed 🚀

Deployed Addresses

SimpleStorageModule#SimpleStorage - 0x5FbDB2315678afecb367f032d93F642f64180aa3
```

- 배포가 완료되면, 로컬 노드가 실행 중인 터미널에 트랜잭션 로그가 출력됩니다.

### 3.4. 배포된 스마트 컨트랙트와 상호작용

`scripts` 디렉토리 내에 `add-person-local.ts` 파일을 생성하고, 다음 코드를 복사하여 붙여넣습니다.

```typescript
import { ethers } from "ethers";
import path from "node:path";
import fs from "node:fs";
import { fileURLToPath } from "node:url";

async function main() {
  // 배포 정보 파일 경로 설정
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = path.dirname(__filename);
  const deploymentDir = path.join(__dirname, "..", "ignition", "deployments", "chain-31337");
  const addressesFilePath = path.join(deploymentDir, "deployed_addresses.json");
  const artifactFilePath = path.join(deploymentDir, "artifacts", "SimpleStorageModule#SimpleStorage.json");
  
  // 배포 디렉토리 존재 확인
  if (!fs.existsSync(deploymentDir)) {
    console.error(`배포 디렉토리를 찾을 수 없습니다: ${deploymentDir}`);
    console.error("먼저 컨트랙트를 배포해주세요: npx hardhat ignition deploy --network local ignition/modules/SimpleStorage.ts");
    process.exit(1);
  }
  
  // 주소 파일 존재 확인
  if (!fs.existsSync(addressesFilePath)) {
    console.error(`주소 파일을 찾을 수 없습니다: ${addressesFilePath}`);
    process.exit(1);
  }
  
  // 아티팩트 파일 존재 확인
  if (!fs.existsSync(artifactFilePath)) {
    console.error(`아티팩트 파일을 찾을 수 없습니다: ${artifactFilePath}`);
    process.exit(1);
  }
  
  // 배포된 주소 읽기
  const deployedAddresses = JSON.parse(fs.readFileSync(addressesFilePath, "utf8"));
  const contractAddress = deployedAddresses["SimpleStorageModule#SimpleStorage"];
  
  if (!contractAddress) {
    console.error("SimpleStorage 컨트랙트 주소를 찾을 수 없습니다.");
    process.exit(1);
  }
  
  // 컨트랙트 ABI 읽기
  const artifact = JSON.parse(fs.readFileSync(artifactFilePath, "utf8"));
  const contractABI = artifact.abi;
  
  console.log("배포 정보를 성공적으로 로드했습니다:");
  console.log("- 컨트랙트 주소:", contractAddress);
  console.log("- ABI 함수 개수:", contractABI.length);
  
  // 로컬 네트워크에 연결
  const provider = new ethers.JsonRpcProvider("http://localhost:8545");
  const signer = await provider.getSigner();
  
  // 컨트랙트 인스턴스 생성
  const simpleStorage = new ethers.Contract(contractAddress, contractABI, signer);
  
  console.log("\nSimpleStorage 컨트랙트에 연결됨:", contractAddress);
  console.log("사용자 주소:", await signer.getAddress());
  
  // 현재 사람 수 확인
  const initialCount = await simpleStorage.getPeopleCount();
  console.log("초기 사람 수:", initialCount.toString());
  
  // 새로운 사람 추가
  const name = "Alice";
  const favoriteNumber = 42;
  
  console.log(`\n${name}을(를) 추가하는 중... (좋아하는 번호: ${favoriteNumber})`);
  const tx = await simpleStorage.addPerson(name, favoriteNumber);
  await tx.wait();
  
  console.log("트랜잭션 해시:", tx.hash);
  
  // 추가 후 사람 수 확인
  const newCount = await simpleStorage.getPeopleCount();
  console.log("추가 후 사람 수:", newCount.toString());
  
  // 추가된 사람 정보 확인
  const personIndex = newCount - 1n; // 마지막으로 추가된 사람
  const person = await simpleStorage.listOfPeople(personIndex);
  console.log(`\n추가된 사람 정보 (인덱스 ${personIndex}):`);
  console.log("- 이름:", person.name);
  console.log("- 좋아하는 번호:", person.favoriteNumber.toString());
  
  // 매핑을 통해 이름으로 번호 조회
  const favoriteNumberFromMapping = await simpleStorage.nameToFavoriteNumber(name);
  console.log(`\n매핑으로 조회한 ${name}의 좋아하는 번호:`, favoriteNumberFromMapping.toString());
  
  // 추가로 다른 사람도 추가해보기
  const name2 = "Bob";
  const favoriteNumber2 = 77;
  
  console.log(`\n${name2}을(를) 추가하는 중... (좋아하는 번호: ${favoriteNumber2})`);
  const tx2 = await simpleStorage.addPerson(name2, favoriteNumber2);
  await tx2.wait();
  
  // 최종 상태 확인
  const finalCount = await simpleStorage.getPeopleCount();
  console.log("\n=== 최종 상태 ===");
  console.log("총 사람 수:", finalCount.toString());
  
  // 모든 사람 목록 출력
  console.log("\n모든 사람 목록:");
  for (let i = 0; i < finalCount; i++) {
    const person = await simpleStorage.listOfPeople(i);
    console.log(`${i}: ${person.name} - ${person.favoriteNumber}`);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("오류 발생:", error);
    process.exit(1);
  });
```

- 터미널에서 다음 명령어를 입력하여 스크립트를 실행합니다.

```powershell
npx hardhat run --network local scripts/add-person-local.ts
```

결과:

```plaintext
Compiling your Solidity contracts...                                               
Compiled 1 Solidity file with solc 0.8.28 (evm target: cancun)

배포 정보를 성공적으로 로드했습니다:
- 컨트랙트 주소: 0x5FbDB2315678afecb367f032d93F642f64180aa3
- ABI 함수 개수: 6

SimpleStorage 컨트랙트에 연결됨: 0x5FbDB2315678afecb367f032d93F642f64180aa3
사용자 주소: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
초기 사람 수: 0

Alice을(를) 추가하는 중... (좋아하는 번호: 42)
트랜잭션 해시: 0x1d0fb4098fd168147e6926f6c17ddc615641bf66493de29af37589aabef2f3f4
추가 후 사람 수: 1

추가된 사람 정보 (인덱스 0):
- 이름: Alice
- 좋아하는 번호: 42

매핑으로 조회한 Alice의 좋아하는 번호: 42

Bob을(를) 추가하는 중... (좋아하는 번호: 77)

=== 최종 상태 ===
총 사람 수: 2

모든 사람 목록:
0: Alice - 42
1: Bob - 77
```

🎉 축하합니다. 이제 Hardhat 환경에서 SimpleStorage 스마트 컨트랙트를 성공적으로 배포하고, 상호작용하는 방법을 익혔습니다.

다음 단계에서는 ERC(Ethereum Request for Comments) 표준에 대해서 학습하고, ERC-20 토큰 스마트 컨트랙트를 작성해보겠습니다.