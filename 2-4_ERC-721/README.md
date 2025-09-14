# NFT 컨트랙트 개발 및 배포 (ERC-721)

## 📜 들어가며: ERC-721과 NFT란?

**NFT(Non-Fungible Token)** 는 **'대체 불가능한 토큰'** 을 의미합니다. ERC-20 토큰이 모든 토큰이 동일한 가치를 지닌 '화폐'와 같다면, NFT는 각각의 토큰이 고유한 ID와 특성을 가져 서로 대체할 수 없는 '자산'과 같습니다. 

![NFT](imgs/nft.png)

ERC-721은 2018년 1월에 공식 표준으로 제정된 이더리움의 NFT 표준으로, 다음과 같은 실제 자산들을 토큰화할 수 있습니다:

- **물리적 자산**: 부동산, 고유한 예술작품
- **가상 수집품**: 게임 아이템, 디지털 아트
- **권리나 자격증**: 학위, 자격증, 멤버십

**ERC-721 표준의 핵심 특징**:
- 각 토큰은 고유한 `tokenId`를 가짐
- 블록체인상에서 개별 소유권 추적 가능
- 표준화된 인터페이스로 다양한 플랫폼에서 호환 가능

## 🎯 학습 목표

이번 장에서는 다음과 같은 실습을 통해 NFT 개발의 전 과정을 경험합니다:

1. **ERC-721 표준 완전 이해**
   - 필수 함수와 이벤트 구조 파악
   - 메타데이터와 tokenURI 개념
   - 안전한 전송 메커니즘 (safeTransferFrom)

2. **실습환경 구축**
   - Hardhat 프로젝트 초기화
   - OpenZeppelin 라이브러리 설치 및 활용
   - 테스트넷 환경 설정

3. **NFT 컨트랙트 개발**
   - OpenZeppelin 기반 안전한 NFT 컨트랙트 작성
   - 민팅(Minting) 기능 구현
   - 메타데이터 URI 관리

4. **테스트넷 배포 및 검증**
   - Sepolia 테스트넷에 배포
   - Etherscan을 통한 컨트랙트 검증
   - 실제 NFT 민팅 및 확인

5. **NFT 생태계 이해**
   - OpenSea 테스트넷에서 NFT 확인
   - 메타데이터 JSON 스키마
   - 실제 사용 사례 분석

---

## 1. ERC-721 표준 심화 이해

### 1.1 ERC-721의 필수 인터페이스

ERC-721 표준은 ERC-165(Standard Interface Detection)를 기반으로 하며, 다음 필수 인터페이스를 구현해야 합니다:

![ERC-721 Interface](imgs/erc721-interface.png)

```solidity
// ERC-721 핵심 인터페이스
interface IERC721 {
    // 이벤트
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // 필수 함수
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
```

### 1.2 주요 함수별 상세 설명

#### **소유권 조회 함수들**

-   **`ownerOf(uint256 tokenId)`**: 특정 `tokenId`를 가진 토큰의 현재 소유자 주소를 반환합니다. NFT의 소유권을 확인하는 가장 기본적인 함수입니다.
-   **`balanceOf(address owner)`**: 특정 주소가 몇 개의 NFT를 소유하고 있는지 그 개수를 반환합니다. (ERC-20의 `balanceOf`와 이름은 같지만, 반환하는 값이 토큰의 양이 아닌 NFT의 개수라는 점이 다릅니다.)

#### **전송 관련 함수들**

-   **`transferFrom(address from, address to, uint256 tokenId)`**: `from` 주소의 소유인 `tokenId`를 `to` 주소로 이전합니다. 소유권 이전의 핵심 함수입니다.
-   **`safeTransferFrom(...)`**: `transferFrom`의 안전한 버전입니다. 토큰을 받는 주소가 스마트 컨트랙트일 경우, 해당 컨트랙트가 NFT를 받을 준비가 되어 있는지(ERC-721 수신 인터페이스를 구현했는지) 확인하는 기능이 추가되어 있습니다.

⚠️ **중요**: `safeTransferFrom`을 사용하는 이유는 토큰이 의도치 않게 사용 불가능한 컨트랙트로 전송되어 영원히 갇히는 사고를 방지하기 위함입니다.

#### **승인(Approval) 시스템**

-   **`approve(address to, uint256 tokenId)`**: 특정 `tokenId`에 대한 소유권을 다른 주소(`to`)가 대신 이전할 수 있도록 위임합니다. 예를 들어, 내가 소유한 NFT를 마켓플레이스 컨트랙트가 판매할 수 있도록 허락할 때 사용됩니다.
-   **`getApproved(uint256 tokenId)`**: 특정 `tokenId`에 대해 `approve`로 위임받은 주소를 확인합니다.
-   **`setApprovalForAll(address operator, bool approved)`**: 특정 주소(`operator`)에게 내가 소유한 **모든** NFT에 대한 처분 권한을 부여하거나 철회합니다. 매번 NFT를 거래할 때마다 `approve`를 호출할 필요 없이, 마켓플레이스에 한 번만 전체 권한을 위임하는 데 사용됩니다.
-   **`isApprovedForAll(address owner, address operator)`**: `operator`가 `owner`의 모든 NFT에 대한 권한을 가지고 있는지 확인합니다.

### 1.3 선택적 확장 (Extensions)

#### ERC721Metadata
```solidity
interface IERC721Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
```

#### ERC721Enumerable
```solidity
interface IERC721Enumerable {
    function totalSupply() external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}
```

### 1.4 메타데이터 JSON 스키마

NFT의 `tokenURI`는 다음과 같은 JSON 스키마를 따릅니다:

```json
{
    "name": "Asset Name",
    "description": "Asset Description", 
    "image": "https://example.com/image.png",
    "attributes": [
        {
            "trait_type": "Color",
            "value": "Blue"
        },
        {
            "trait_type": "Rarity",
            "value": "Rare"
        }
    ]
}
```

![Metadata Schema](imgs/metadata-schema.png)

#### 1.4.1 IPFS를 활용한 분산 저장

![IPFS Structure](imgs/ipfs-structure.png)

중앙화된 서버 대신 **IPFS(InterPlanetary File System)**를 사용하여 메타데이터와 이미지를 저장하는 것이 바람직합니다.

_IPFS(InterPlanetary File System)는 분산형 P2P 네트워크에서 데이터를 저장하고 공유하기 위한 프로토콜입니다. '콘텐트 어드레싱'을 사용해 파일의 내용 자체를 기반으로 고유한 주소를 생성하며, 이는 중앙 서버 대신 여러 노드에 데이터를 분산 저장하고 접근하여 웹의 탈중앙화와 효율성을 높이는 데 기여합니다._

---

## 2. 개발환경 구축

### 2.1 사전 요구사항

다음 도구들이 설치되어 있어야 합니다:
- **Node.js** (v22 이상)
- **VS Code** (권장 IDE)
- **MetaMask** (브라우저 확장 프로그램)

### 2.2 새로운 Hardhat 프로젝트 생성

```powershell
# 새 디렉토리 생성 및 이동
mkdir my-nft-project
cd my-nft-project

# Hardhat 프로젝트 초기화
npx hardhat --init
```

![Hardhat Init](imgs/hardhat-init.png)


### 2.3 OpenZeppelin 계약 라이브러리 설치

```powershell
# OpenZeppelin Contracts 라이브러리 설치
npm install @openzeppelin/contracts
```

### 2.4 프로젝트 구조

설치 후 프로젝트 구조는 다음과 같습니다:

```powershell
➜ Get-PSTree -Exclude 'node_modules' -Depth 3


   Source: C:\Users\huketo\workspace\my-nft-project

Mode            Length Hierarchy
----            ------ ---------
d-----       148.75 KB my-nft-project
-a----       243.00  B ├── .gitignore
-a----       922.00  B ├── hardhat.config.ts
-a----       592.00  B ├── package.json
-a----       144.65 KB ├── package-lock.json
-a----         2.05 KB ├── README.md
-a----       345.00  B ├── tsconfig.json
d-----         1.06 KB ├── contracts
-a----       332.00  B │   ├── Counter.sol
-a----       758.00  B │   └── Counter.t.sol
d-----         0.00  B ├── ignition
d-----       230.00  B │   └── modules
-a----       230.00  B │       └── Counter.ts
d-----       483.00  B ├── scripts
-a----       483.00  B │   └── send-op-tx.ts
d-----         1.04 KB └── test
-a----         1.04 KB     └── Counter.ts
```

## 3. OpenZeppelin을 활용한 NFT 컨트랙트 개발

### 3.1 OpenZeppelin이란?

**OpenZeppelin**은 이더리움 스마트 컨트랙트 개발을 위한 가장 신뢰받는 라이브러리입니다. ERC-20과 마찬가지로, 안전하고 표준화된 NFT 컨트랙트를 만들기 위해 OpenZeppelin 라이브러리를 사용하는 것이 가장 좋은 방법입니다.

**OpenZeppelin의 장점**:
- 보안 검증이 완료된 코드
- 가스 최적화
- 모듈식 설계
- 광범위한 테스트 커버리지
- 활발한 커뮤니티 지원

### 3.2 NFT 컨트랙트 작성

`contracts` 폴더에 `MyNFT.sol` 파일을 생성하고 다음 코드를 작성합니다:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// OpenZeppelin의 ERC721 표준 구현체와 추가 기능을 가져옵니다.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// ERC721, ERC721URIStorage, Ownable 컨트랙트를 상속받습니다.
contract MyNFT is ERC721, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    // ERC721 생성자에 NFT의 이름과 심볼을 전달합니다.
    constructor(
        address initialOwner
    ) ERC721("My NFT Collection", "MNFT") Ownable(initialOwner) {}

    // 외부에서 호출하여 새로운 NFT를 발행(민팅)하는 함수입니다.
    // to: NFT를 받을 주소
    // uri: NFT의 메타데이터가 담긴 JSON 파일의 주소
    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // 다음에 발행될 토큰 ID 조회 함수
    function getNextTokenId() public view returns (uint256) {
        return _nextTokenId;
    }

    // ERC721URIStorage가 요구하는 내부 함수 오버라이드
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721) returns (address) {
        return super._update(to, tokenId, auth);
    }

    // OpenZeppelin의 ERC721URIStorage가 요구하는 내부 함수 오버라이드
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    // ERC-165 인터페이스 지원 확인
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
```

### 3.3 코드 상세 분석

#### **import 문 분석**
- **`ERC721`**: 기본 NFT 기능을 제공하는 핵심 컨트랙트
- **`ERC721URIStorage`**: 각 NFT의 메타데이터(이름, 설명, 이미지 등)를 담고 있는 `tokenURI`를 관리하는 확장 기능
- **`Ownable`**: 컨트랙트 소유권 개념을 추가하여, `safeMint`와 같은 민감한 함수를 오직 컨트랙트 배포자만 호출할 수 있도록 제한하는(`onlyOwner` 수식자) 기능

#### **핵심 변수와 함수**

- **`_nextTokenId`**: 다음에 발행될 NFT의 `tokenId`를 추적하기 위한 내부 카운터 변수입니다.
- **`safeMint(address to, string memory uri)`**: 새로운 NFT를 발행하는 핵심 함수입니다.
  - `onlyOwner` 수식자로 인해 오직 컨트랙트 소유자만 이 함수를 호출할 수 있습니다.
  - `_nextTokenId`를 1 증가시켜 새로운 `tokenId`를 할당합니다.
  - `_safeMint(to, tokenId)`: OpenZeppelin의 내부 함수를 호출하여 `to` 주소에게 새로운 `tokenId`의 소유권을 부여합니다.
  - `_setTokenURI(tokenId, uri)`: 해당 `tokenId`에 메타데이터 URI를 연결합니다.

#### **함수 오버라이드**
- **`override`**: 상속받은 여러 부모 컨트랙트에 동일한 이름의 함수가 있을 경우, 어떤 것을 사용할지 명확히 지정하기 위해 `override` 키워드를 사용해야 합니다.

### 3.4 컨트랙트 컴파일

```bash
# 컨트랙트 컴파일
npx hardhat build # 또는 npx hardhat compile
```

## 4. 로컬 테스트 및 검증

### 4.1 NFT 컨트랙트 테스트 작성

`test` 폴더에 `MyNFT.test.ts` 파일을 생성합니다:

```typescript
import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("MyNFT", function () {
  async function deployFixture() {
    const [owner, user1, user2] = await ethers.getSigners();
    const MyNFT = await ethers.getContractFactory("MyNFT");
    const nft = await MyNFT.deploy(owner.address);
    await nft.waitForDeployment();
    return { nft, owner, user1, user2 };
  }

  it("배포: 이름/심볼/초기상태 확인", async function () {
    const { nft, owner } = await deployFixture();
    expect(await nft.name()).to.equal("My NFT Collection");
    expect(await nft.symbol()).to.equal("MNFT");
    expect(await nft.owner()).to.equal(owner.address);
    expect(await nft.getNextTokenId()).to.equal(0n);
  });

  it("민팅: 소유자만 safeMint 가능 및 상태 갱신", async function () {
    const { nft, user1 } = await deployFixture();
    const uri = "https://example.com/metadata/1.json";
    await expect(nft.safeMint(user1.address, uri))
      .to.emit(nft, "Transfer")
      .withArgs(ethers.ZeroAddress, user1.address, 0n);

    expect(await nft.ownerOf(0n)).to.equal(user1.address);
    expect(await nft.tokenURI(0n)).to.equal(uri);
    expect(await nft.balanceOf(user1.address)).to.equal(1n);
    expect(await nft.getNextTokenId()).to.equal(1n);

    // 소유자 아닌 계정이 민팅 시도 -> OpenZeppelin Ownable(v5) custom error: OwnableUnauthorizedAccount(address)
    await expect(
      nft.connect(user1).safeMint(user1.address, uri)
    ).to.be.revertedWithCustomError(nft, "OwnableUnauthorizedAccount").withArgs(
      user1.address
    );
  });

  it("다중 민팅: 연속 tokenId 증가", async function () {
    const { nft, user1, user2 } = await deployFixture();
    await nft.safeMint(user1.address, "ipfs://hash1");
    await nft.safeMint(user2.address, "ipfs://hash2");

    expect(await nft.ownerOf(0n)).to.equal(user1.address);
    expect(await nft.ownerOf(1n)).to.equal(user2.address);
    expect(await nft.getNextTokenId()).to.equal(2n);
  });

  it("소유권 이전 후 새 소유자 민팅 가능", async function () {
    const { nft, owner, user1, user2 } = await deployFixture();
    await nft.safeMint(user1.address, "ipfs://meta1");

    await expect(nft.transferOwnership(user1.address))
      .to.emit(nft, "OwnershipTransferred")
      .withArgs(owner.address, user1.address);

    await expect(nft.connect(user1).safeMint(user2.address, "ipfs://meta2"))
      .to.emit(nft, "Transfer")
      .withArgs(ethers.ZeroAddress, user2.address, 1n);

    expect(await nft.ownerOf(1n)).to.equal(user2.address);
    expect(await nft.getNextTokenId()).to.equal(2n);
  });

  it("approve + transferFrom 동작", async function () {
    const { nft, user1, user2 } = await deployFixture();
    await nft.safeMint(user1.address, "ipfs://meta1");

    await expect(nft.connect(user1).approve(user2.address, 0n))
      .to.emit(nft, "Approval")
      .withArgs(user1.address, user2.address, 0n);

    expect(await nft.getApproved(0n)).to.equal(user2.address);

    await expect(
      nft.connect(user2).transferFrom(user1.address, user2.address, 0n)
    )
      .to.emit(nft, "Transfer")
      .withArgs(user1.address, user2.address, 0n);

    expect(await nft.ownerOf(0n)).to.equal(user2.address);
  });

  it("직접 transferFrom (소유자) 동작", async function () {
    const { nft, user1, user2 } = await deployFixture();
    await nft.safeMint(user1.address, "ipfs://meta1");

    await expect(
      nft.connect(user1).transferFrom(user1.address, user2.address, 0n)
    )
      .to.emit(nft, "Transfer")
      .withArgs(user1.address, user2.address, 0n);

    expect(await nft.ownerOf(0n)).to.equal(user2.address);
    expect(await nft.balanceOf(user1.address)).to.equal(0n);
    expect(await nft.balanceOf(user2.address)).to.equal(1n);
  });

  it("존재하지 않는 토큰 조회 revert", async function () {
    const { nft } = await deployFixture();
    await expect(nft.ownerOf(999n))
      .to.be.revertedWithCustomError(nft, "ERC721NonexistentToken")
      .withArgs(999n);
    await expect(nft.tokenURI(999n))
      .to.be.revertedWithCustomError(nft, "ERC721NonexistentToken")
      .withArgs(999n);
  });

  it("supportsInterface 확인", async function () {
    const { nft } = await deployFixture();
    expect(await nft.supportsInterface("0x01ffc9a7")).to.equal(true);
    expect(await nft.supportsInterface("0x80ac58cd")).to.equal(true);
    expect(await nft.supportsInterface("0x5b5e139f")).to.equal(true);
  });

  it("Transfer 이벤트 검증 (민팅)", async function () {
    const { nft, user1 } = await deployFixture();
    await expect(nft.safeMint(user1.address, "ipfs://m"))
      .to.emit(nft, "Transfer")
      .withArgs(ethers.ZeroAddress, user1.address, 0n);
  });
});
```

### 4.2 테스트 실행

```bash
npx hardhat test
```

### 4.3 로컬 네트워크에서 배포 테스트

`ignition/modules` 폴더에 `MyNFT.ts` 파일을 생성합니다:

```typescript
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("MyNFTModule", (m) => {
  const initialOwner = m.getAccount(0);
  const myNFT = m.contract("MyNFT", [initialOwner]);

  return { myNFT };
});
```

`hatdhat.config.ts` 파일에 다음 내용을 추가합니다:

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
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
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
      chainId: 31337, // Hardhat Network의 기본 체인 ID
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


로컬 네트워크에서 테스트:

```bash
# 터미널 1: 로컬 Hardhat 네트워크 시작
npx hardhat node

# 터미널 2: 로컬 네트워크에 배포
npx hardhat ignition deploy --network local ignition/modules/MyNFT.ts
```

## 5. Sepolia 테스트넷 배포

지금까지는 로컬 컴퓨터에서만 동작하는 Hardhat 네트워크에 배포했지만, 이번에는 전 세계 개발자들이 사용하는 공개 테스트 네트워크인 **Sepolia 테스트넷**에 직접 배포해 보겠습니다.

### 5.1 사전 준비사항

1. **MetaMask 지갑 생성 및 Sepolia 네트워크 추가**
2. **테스트 이더(ETH) 확보**
3. **Alchemy에서 Sepolia용 RPC 노드 설정**
4. **MetaMask에서 개인키 추출**
5. **Etherscan API Key 발급 (컨트랙트 검증용)**
6. **Pinata 계정 생성 (메타데이터 IPFS 업로드용)**

#### 1단계: MetaMask 설치 및 Sepolia 네트워크 추가

[MetaMask](https://metamask.io/)를 설치하고, Sepolia 테스트넷을 추가합니다.

1. MetaMask 홈페이지 접속, `MetaMask 받기` 버튼 클릭:
![MetaMask Page](imgs/metamask-page.png)

</br>

2. MetaMask 확장 프로그램 설치:
![MetaMask Extension Page](imgs/metamask-extension-page.png)

</br>

3. MetaMask 설치 완료 후, 화면 `시작하기` 클릭:
![MetaMask Get Started](imgs/metamask-get-started.png)

</br>

4. 이용약관 동의:
![MetaMask Terms](imgs/metamask-terms.png)

</br>

5. `새 지갑 생성` 클릭:
![MetaMask Create Wallet](imgs/metamask-create-wallet.png)

</br>

6. 실습에서는 `비밀복구구문으로 계속` 옵션을 선택합니다:
![MetaMask Secret Recovery Phrase](imgs/metamask-secret-recovery-phrase.png)

</br>

7. 비밀번호 설정:
![MetaMask Create Password](imgs/metamask-create-password.png)

</br>

8. 비밀 복구 구문(시드 구문) 백업 - 실습용 계정이기 때문에 필수는 아님:
![MetaMask Secret Recovery Phrase Backup 1](imgs/metamask-secret-recovery-phrase-backup-1.png)
![MetaMask Secret Recovery Phrase Backup 2](imgs/metamask-secret-recovery-phrase-backup-2.png)
![MetaMask Secret Recovery Phrase Backup 3](imgs/metamask-secret-recovery-phrase-backup-3.png)
![MetaMask Secret Recovery Phrase Backup 4](imgs/metamask-secret-recovery-phrase-backup-4.png)

</br>

9. 지갑 생성 완료:
![MetaMask Wallet Created](imgs/metamask-wallet-created.png)

</br>

10. 브라우저 우측 상단에 고정:
![MetaMask Extension Pinned](imgs/metamask-extension-pinned.png)

</br>

11. 설정 메뉴 클릭:
![MetaMask Settings](imgs/metamask-settings.png)

</br>

12. 설정 - 고급 탭 클릭 후 - `테스트넷에 전환 표시`, `테스트 네트워크 보기` 활성화:
![MetaMask Advanced Settings](imgs/metamask-advanced-settings.png)

</br>

13. 네트워크 드롭다운 클릭 후 `Custom` 탭에서 Sepolia 네트워크 선택:
![MetaMask Custom Network](imgs/metamask-custom-network.png)
![MetaMask Custom Network Selected](imgs/metamask-custom-network-selected.png)

</br>

#### 2단계: 테스트 이더(ETH) 확보

테스트넷에서 컨트랙트를 배포하려면 수수료로 사용할 테스트용 ETH가 필요합니다.

**Sepolia 테스트 ETH 받는 방법**:
- [Google Sepolia Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia) - Google 계정 필요
- [Sepolia PoW Faucet](https://sepolia-faucet.pk910.de/) - [Human Passport](https://app.passport.xyz/) 인증 필요
- [Alchemy Sepolia Faucet](https://www.alchemy.com/faucets/ethereum-sepolia) - 메인넷 0.001 ETH 보유로 인증
- [Chainlink Faucets](https://faucets.chain.link/) - 메인넷 1LINK 보유로 인증

**주의사항**:
- 하루에 받을 수 있는 테스트 ETH 양이 제한됩니다
- 실제 가치는 없지만 테스트에는 충분합니다

> Google Sepolia Faucet에서 0.05 ETH를 받는 예시:
> 
> Google Sepolia Faucet 접속:
> ![Google Sepolia Faucet 1](imgs/google-sepolia-faucet-1.png)
> 
> 브라우저 우측에서 MetaMask 아이콘 클릭 후, 계정 복사: 
> ![Google Sepolia Faucet 2](imgs/google-sepolia-faucet-2.png)
>
> 주소 붙여넣기 후 `Receive 0.05 Sepolia ETH` 클릭:
> ![Google Sepolia Faucet 3](imgs/google-sepolia-faucet-3.png)
>
> 트랜잭션 완료:
> ![Google Sepolia Faucet 4](imgs/google-sepolia-faucet-4.png)

#### 3단계: RPC 노드 설정 (Alchemy)

실제 네트워크와 통신하려면 블록체인 노드에 접속해야 합니다.

**Alchemy 설정 방법**:
1. [Alchemy](https://www.alchemy.com/) 가입
2. "Create App" 클릭
3. 네트워크를 "Ethereum Sepolia"로 선택
4. API Key 복사

#### 4단계: MetaMask 개인키 추출

⚠️ **보안 주의사항**: 테스트넷 전용 계정을 사용하세요!

**개인키 추출 방법**:
1. MetaMask에서 계정 메뉴 클릭
2. "계정 세부 정보" 선택  
3. "개인 키 내보내기" 클릭
4. 비밀번호 입력 후 개인키 복사

#### 5단계: Etherscan API Key 발급

Etherscan에서 컨트랙트를 검증하려면 API Key가 필요합니다.

1. [Etherscan](https://etherscan.io/) 가입
2. "API Keys" 메뉴에서 새 키 생성

#### 6단계: Pinata 계정 생성 및 NFT 콘텐츠와 메타데이터 업로드

1. [Pinata](https://pinata.cloud/) 가입
2. 이미지 파일 업로드
3. 메타데이터 JSON 파일 업로드
   ```json
   {
       "name": "My First NFT",
       "description": "This is my first NFT using ERC-721 standard!",
       "image": "ipfs://<IMAGE_IPFS_HASH>",
       "attributes": [
           {
               "trait_type": "Background",
               "value": "Blue"
           },
           {
               "trait_type": "Eyes",
               "value": "Green"
           }
       ]
   }
   ```
4. 업로드된 메타데이터의 IPFS 해시 복사

![Pinata Upload Success](imgs/pinata-upload-success.png)

`tokenURI` 에 `ipfs://<IPFS_HASH>` 형식으로 사용

### 5.2 환경 설정

`hardhat-keystore` 플러그인으로 변수를 관리합니다.

```shell
npx hardhat keystore set SEPOLIA_PRIVATE_KEY # MetaMask 개인키
npx hardhat keystore set SEPOLIA_RPC_URL # Alchemy Sepolia RPC URL
npx hardhat keystore set ETHERSCAN_API_KEY # Etherscan API Key
```

#### hardhat.config.ts 업데이트

```typescript
import type { HardhatUserConfig } from "hardhat/config";

import hardhatToolboxMochaEthersPlugin from "@nomicfoundation/hardhat-toolbox-mocha-ethers";
import hardhatVerify from "@nomicfoundation/hardhat-verify";
import { configVariable } from "hardhat/config";

const config: HardhatUserConfig = {
  plugins: [hardhatToolboxMochaEthersPlugin, hardhatVerify],
  solidity: {
    profiles: {
      default: {
        version: "0.8.28",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
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
      chainId: 31337, // Hardhat Network의 기본 체인 ID
      url: "http://localhost:8545",
    },
    sepolia: {
      type: "http",
      chainType: "l1",
      url: configVariable("SEPOLIA_RPC_URL"),
      accounts: [configVariable("SEPOLIA_PRIVATE_KEY")],
    },
  },
  verify: {
    etherscan: {
      apiKey: configVariable("ETHERSCAN_API_KEY"),
    },
    blockscout: {
      enabled: false,
    }
  },
};

export default config;
```

### 5.3 Sepolia 네트워크에 배포

```bash
# Sepolia 테스트넷에 배포
npx hardhat ignition deploy --network sepolia ignition/modules/MyNFT.ts
```

배포 완료 화면:
![Deployment Success](imgs/deployment-success.png)


### 5.4 스마트 컨트랙트 검증

배포 후, Hardhat Verify 플러그인을 사용하여 Etherscan에서 컨트랙트를 검증할 수 있습니다.

_Etherscan은 Ethereum 블록체인 탐색기이자 분석 플랫폼으로, 스마트 컨트랙트의 소스 코드를 공개하여 투명성을 제공하고, 사용자들이 컨트랙트의 기능과 동작을 쉽게 이해할 수 있도록 돕습니다._

</br>

Hardhat Verify 플러그인 설치:
```shell
npm install --save-dev @nomicfoundation/hardhat-verify
```

Verify 관련 `hardhat.config.ts` 설정은 위에서 이미 추가했습니다.

검증 명령어:
```shell
npx hardhat verify --network sepolia <DEPLOYED_CONTRACT_ADDRESS> <CONSTRUCTOR_ARGUMENTS>
```

`<DEPLOYED_CONTRACT_ADDRESS>`는 배포된 컨트랙트의 주소로, 배포 명령의 출력에서 찾을 수 있습니다. `<CONSTRUCTOR_ARGUMENTS>`는 컨트랙트 생성자에 전달된 인수입니다.

MyNFT 컨트랙트의 경우, 생성자는 초기 소유자의 주소를 인수로 받습니다.

예시:
```shell
# Example:
npx hardhat verify --network sepolia 0x18422A420283749E20cc8207E93F0BB3c2484629 0x80CDA1c403bBC1ceFD03C2Fb2A3FEdc19eD9D790
```

검증된 컨트랙트는 Etherscan에서 소스 코드와 ABI를 볼 수 있습니다.
다음은 [MyNFT 컨트랙트의 검증된 예시](https://sepolia.etherscan.io/address/0x18422A420283749E20cc8207E93F0BB3c2484629#code)입니다.

![검증된 MyNFT 컨트랙트](imgs/verified-contract.png)

### 5.5 NFT 민팅

배포된 컨트랙트와 상호작용하여 NFT를 민팅하는 스크립트를 작성합니다.

`scripts/mint-nft-sepolia.ts` 파일 생성:

```typescript
import { network } from "hardhat"
import readline from "node:readline/promises";
import { stdin as input, stdout as output } from "node:process";
import path from "node:path";
import fs from "node:fs";
import { fileURLToPath } from "node:url";

const { ethers } = await network.connect();

async function main() {
  // 인터랙티브 모드: 실행 시 사용자 입력으로 tokenURI 받기
  let tokenURI: string | undefined;

  const rl = readline.createInterface({ input, output });
  try {
    tokenURI = (await rl.question("민팅할 NFT의 tokenURI (메타데이터 URL/IPFS 경로)를 입력하세요:\n> ")).trim();
  } finally {
    rl.close();
  }

  if (!tokenURI) {
    console.error("tokenURI 가 비어있습니다. 작업을 종료합니다.");
    process.exit(1);
  }

  // 배포 정보 파일 경로 설정
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = path.dirname(__filename);
  const deploymentDir = path.join(__dirname, "..", "ignition", "deployments", "chain-11155111");
  const addressesFilePath = path.join(deploymentDir, "deployed_addresses.json");
  const artifactFilePath = path.join(deploymentDir, "artifacts", "MyNFTModule#MyNFT.json");

  // 배포 디렉토리 존재 확인
  if (!fs.existsSync(deploymentDir)) {
    console.error(`배포 디렉토리를 찾을 수 없습니다: ${deploymentDir}`);
    console.error("먼저 컨트랙트를 배포해주세요: npx hardhat ignition deploy --network local ignition/modules/MyNFT.ts");
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
  const contractAddress = deployedAddresses["MyNFTModule#MyNFT"];

  if (!contractAddress) {
    console.error("MyNFT 컨트랙트 주소를 찾을 수 없습니다.");
    process.exit(1);
  }
  
  // 컨트랙트 ABI 읽기
  const artifact = JSON.parse(fs.readFileSync(artifactFilePath, "utf8"));
  const contractABI = artifact.abi;
  
  console.log("배포 정보를 성공적으로 로드했습니다:");
  console.log("- 컨트랙트 주소:", contractAddress);
  console.log("- ABI 함수 개수:", contractABI.length);

  // 컨트랙트 인스턴스 생성
  const [signer] = await ethers.getSigners();
  const MyNFT = new ethers.Contract(contractAddress, contractABI, signer);

  console.log("\nMyNFT 컨트랙트에 연결됨:", contractAddress);
  console.log("사용자 계정 주소:", await signer.getAddress());

  // 다음 토큰 ID 미리 조회 (민팅 전에 예상 ID)
  const nextId: bigint = await MyNFT.getNextTokenId();
  console.log(`다음 발행 예정 토큰 ID: ${nextId}`);

  console.log("NFT 민팅 트랜잭션 전송 중...");
  const recipient = await signer.getAddress();
  const tx = await MyNFT.safeMint(recipient, tokenURI);
  console.log("트랜잭션 해시:", tx.hash);

  console.log("트랜잭션 확인 대기 중...");
  const receipt = await tx.wait();
  console.log("Receipt received:", {
    status: receipt?.status,
    blockNumber: receipt?.blockNumber,
    gasUsed: receipt?.gasUsed?.toString()
  });
  
  if (!receipt || receipt.status !== 1) {
    console.error("트랜잭션 실패 또는 상태 불명확");
    console.error("Receipt status:", receipt?.status);
    process.exit(1);
  }

  // 간단화: 연속적 증가이므로 minted tokenId 는 nextId 값과 동일
  const mintedTokenId = nextId;

  // tokenURI 조회
  const storedTokenURI = await MyNFT.tokenURI(mintedTokenId);

  console.log("\n민팅 성공!");
  console.log("- Token ID:", mintedTokenId.toString());
  console.log("- 입력한 tokenURI:", tokenURI);
  console.log("- 저장된 tokenURI:", storedTokenURI);
  console.log("- Gas Used:", receipt.gasUsed.toString());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("오류 발생:", error);
    process.exit(1);
  });
```

이 스크립트는 사용자로부터 `tokenURI`를 입력받아, 배포된 MyNFT 컨트랙트에 연결한 후 `safeMint` 함수를 호출하여 NFT를 민팅합니다.

```shell
npx hardhat run --network sepolia scripts/mint-nft-sepolia.ts

민팅할 NFT의 tokenURI (메타데이터 URL/IPFS 경로)를 입력하세요: ipfs://<IPFS_HASH>
> ipfs://<IPFS_HASH>
```
![NFT Mint Success in Etherscan 1](imgs/nft-mint-success-1.png)
![NFT Mint Success in Etherscan 2](imgs/nft-mint-success-2.png)

### 6. 실제 사용 사례

#### **게임 아이템 NFT**
- 게임 내 무기, 방어구, 스킨 등을 NFT로 구현
- 게임 간 호환성 제공
- 플레이어 간 거래 가능

#### **멤버십 NFT**
- 커뮤니티 멤버십을 NFT로 발행
- 특별한 권한과 혜택 제공
- 전송 불가능한 SBT(Soul Bound Token)로도 구현 가능

#### **디지털 아트 NFT**
- 아티스트의 작품을 NFT로 발행
- 로열티를 통한 지속적인 수익
- 소유권 증명 및 진품 보증

---

## 🔗 참고자료

### 공식 문서
- [EIP-721: Non-Fungible Token Standard](https://eips.ethereum.org/EIPS/eip-721)
- [OpenZeppelin Contracts: ERC721](https://docs.openzeppelin.com/contracts/5.x/erc721)
- [Hardhat Verify Docs](https://hardhat.org/docs/learn-more/smart-contract-verification)

### 도구 및 서비스
- [OpenZeppelin Wizard](https://wizard.openzeppelin.com/#erc721) - 컨트랙트 코드 생성기
- [OpenSea](https://opensea.io/) - NFT 마켓플레이스
- [Sepolia Etherscan](https://sepolia.etherscan.io/) - 테스트넷 블록 익스플로러
- [Alchemy](https://www.alchemy.com/) - 블록체인 노드 서비스
- [Pinata](https://pinata.cloud/) - IPFS 파일 고정 서비스

### 커뮤니티 및 학습
- [OpenZeppelin Forum](https://forum.openzeppelin.com/)
- [Ethereum Stack Exchange](https://ethereum.stackexchange.com/)
- [NFT 메타데이터 표준](https://docs.opensea.io/docs/metadata-standards)