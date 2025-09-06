# NFT 컨트랙트 개발 및 배포 (ERC-721)

태그: Blockchain, Solidity, ERC721, NFT, OpenZeppelin
프로젝트: 블록체인 강의

## 📜 들어가며: ERC-721과 NFT란?

**NFT(Non-Fungible Token)** 는 **'대체 불가능한 토큰'** 을 의미합니다. ERC-20 토큰이 모든 토큰이 동일한 가치를 지닌 '화폐'와 같다면, NFT는 각각의 토큰이 고유한 ID와 특성을 가져 서로 대체할 수 없는 '자산'과 같습니다. 세상에 단 하나뿐인 미술품, 한정판 운동화, 게임 아이템 등이 NFT의 좋은 예시입니다.

**ERC-721**은 이러한 대체 불가능한 토큰을 이더리움 블록체인 상에서 구현하기 위한 표준 인터페이스입니다. 이 표준은 NFT의 **소유권**을 추적하고 이전하는 데 필요한 핵심 기능들을 정의합니다. 모든 ERC-721 NFT는 고유한 **`tokenId`** 를 가지며, 블록체인은 "어떤 `tokenId`를 어떤 주소가 소유하고 있는가"를 기록합니다.

ERC-721 표준 덕분에, 모든 NFT는 다양한 마켓플레이스(예: OpenSea), 지갑, 게임 등에서 동일한 방식으로 거래되고 전시될 수 있습니다.

---

## 1. ERC-721 표준 해설

ERC-721 표준의 핵심은 **토큰의 소유권 관리**에 있습니다. 주요 함수들은 다음과 같습니다.

-   **`ownerOf(uint256 tokenId)`**: 특정 `tokenId`를 가진 토큰의 현재 소유자 주소를 반환합니다. NFT의 소유권을 확인하는 가장 기본적인 함수입니다.
-   **`balanceOf(address owner)`**: 특정 주소가 몇 개의 NFT를 소유하고 있는지 그 개수를 반환합니다. (ERC-20의 `balanceOf`와 이름은 같지만, 반환하는 값이 토큰의 양이 아닌 NFT의 개수라는 점이 다릅니다.)
-   **`transferFrom(address from, address to, uint256 tokenId)`**: `from` 주소의 소유인 `tokenId`를 `to` 주소로 이전합니다. 소유권 이전의 핵심 함수입니다.
-   **`safeTransferFrom(...)`**: `transferFrom`의 안전한 버전입니다. 토큰을 받는 주소가 스마트 컨트랙트일 경우, 해당 컨트랙트가 NFT를 받을 준비가 되어 있는지(ERC-721 수신 인터페이스를 구현했는지) 확인하는 기능이 추가되어 있습니다. 토큰이 의도치 않게 사용 불가능한 컨트랙트로 전송되어 영원히 갇히는 사고를 방지하기 위해 강력히 권장되는 함수입니다.
-   **`approve(address to, uint256 tokenId)`**: 특정 `tokenId`에 대한 소유권을 다른 주소(`to`)가 대신 이전할 수 있도록 위임합니다. 예를 들어, 내가 소유한 NFT를 마켓플레이스 컨트랙트가 판매할 수 있도록 허락할 때 사용됩니다.
-   **`getApproved(uint256 tokenId)`**: 특정 `tokenId`에 대해 `approve`로 위임받은 주소를 확인합니다.
-   **`setApprovalForAll(address operator, bool approved)`**: 특정 주소(`operator`)에게 내가 소유한 **모든** NFT에 대한 처분 권한을 부여하거나 철회합니다. 매번 NFT를 거래할 때마다 `approve`를 호출할 필요 없이, 마켓플레이스에 한 번만 전체 권한을 위임하는 데 사용됩니다.
-   **`isApprovedForAll(address owner, address operator)`**: `operator`가 `owner`의 모든 NFT에 대한 권한을 가지고 있는지 확인합니다.

---

## 2. OpenZeppelin을 활용하여 NFT 컨트랙트 작성

ERC-20과 마찬가지로, 안전하고 표준화된 NFT 컨트랙트를 만들기 위해 **OpenZeppelin** 라이브러리를 사용하는 것이 가장 좋은 방법입니다.

### **NFT 컨트랙트 코드**

`contracts` 폴더에 `MyNFT.sol` 파일을 생성하고 다음 코드를 작성합니다.

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
    constructor() ERC721("My NFT", "MNFT") {}

    // 외부에서 호출하여 새로운 NFT를 발행(민팅)하는 함수입니다.
    // to: NFT를 받을 주소
    // uri: NFT의 메타데이터가 담긴 JSON 파일의 주소
    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // OpenZeppelin의 ERC721URIStorage가 요구하는 내부 함수 오버라이드
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    // OpenZeppelin의 ERC721URIStorage가 요구하는 내부 함수 오버라이드
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
```

### **코드 해설**

-   **`import` 문**: `ERC721` 외에 두 가지를 더 가져옵니다.
    -   **`ERC721URIStorage`**: 각 NFT의 메타데이터(이름, 설명, 이미지 주소 등)를 담고 있는 `tokenURI`를 관리하는 확장 기능입니다.
    -   **`Ownable`**: 컨트랙트의 소유권(owner) 개념을 추가하여, `safeMint`와 같은 민감한 함수를 오직 컨트랙트 배포자만 호출할 수 있도록 제한하는(`onlyOwner` 수식자) 기능을 제공합니다.
-   **`_nextTokenId`**: 다음에 발행될 NFT의 `tokenId`를 추적하기 위한 내부 카운터 변수입니다.
-   **`safeMint(address to, string memory uri)`**: 새로운 NFT를 발행하는 핵심 함수입니다.
    -   `onlyOwner` 수식자로 인해 오직 컨트랙트 소유자만 이 함수를 호출할 수 있습니다.
    -   `_nextTokenId`를 1 증가시켜 새로운 `tokenId`를 할당합니다.
    -   `_safeMint(to, tokenId)`: OpenZeppelin의 내부 함수를 호출하여 `to` 주소에게 새로운 `tokenId`의 소유권을 부여합니다.
    -   `_setTokenURI(tokenId, uri)`: 해당 `tokenId`에 메타데이터 URI를 연결합니다. 이 URI는 보통 IPFS에 업로드된 JSON 파일을 가리킵니다.
-   **`override`**: 상속받은 여러 부모 컨트랙트에 동일한 이름의 함수가 있을 경우, 어떤 것을 사용할지 명확히 지정하기 위해 `override` 키워드를 사용해야 합니다.

---

## 3. Sepolia 테스트넷에 NFT 컨트랙트 배포

지금까지는 로컬 컴퓨터에서만 동작하는 Hardhat 네트워크에 배포했지만, 이번에는 전 세계 개발자들이 사용하는 공개 테스트 네트워크인 **Sepolia 테스트넷**에 직접 배포해 보겠습니다. 이를 통해 실제 블록체인에 내 컨트랙트를 올리는 경험을 할 수 있습니다.

### **사전 준비**

1.  **Sepolia 테스트 이더(ETH) 확보**: 테스트넷에서 컨트랙트를 배포하려면 수수료로 사용할 테스트용 ETH가 필요합니다. [Sepolia Faucet](https://sepoliafaucet.com/)과 같은 수도꼭지 사이트에서 자신의 MetaMask 계정 주소로 소량의 Sepolia ETH를 받아둡니다.
2.  **블록체인 노드 접속 정보 (RPC URL)**: 실제 네트워크와 통신하려면 해당 네트워크의 노드에 접속해야 합니다. **[Alchemy](https://www.alchemy.com/)** 나 **[Infura](https://www.infura.io/)** 와 같은 노드 제공 서비스에 가입하여 Sepolia 네트워크용 RPC URL을 발급받습니다.
3.  **배포자 개인키**: Sepolia 테스트넷에 배포할 계정의 개인키가 필요합니다. MetaMask에서 해당 계정의 개인키를 내보내기하여 안전하게 준비합니다. **(⚠️ 절대로 실제 자산이 있는 메인넷 개인키를 사용하거나 코드에 하드코딩하지 마세요!)**

### **Hardhat 설정 파일 수정**

`.env` 파일을 프로젝트 루트에 만들고, 발급받은 RPC URL과 개인키를 저장합니다. (먼저 `npm install dotenv` 실행)

```
# .env 파일
SEPOLIA_RPC_URL="https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY"
PRIVATE_KEY="YOUR_PRIVATE_KEY"
```

`hardhat.config.ts` 파일을 수정하여 Sepolia 네트워크 정보를 추가합니다.

```typescript
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config"; // dotenv 임포트

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "",
      accounts: [process.env.PRIVATE_KEY || ""],
    },
  },
};

export default config;

```

### **배포 스크립트 실행**

`scripts/deploy.ts` 파일을 `MyNFT` 컨트랙트에 맞게 수정합니다. (ERC-20 배포 스크립트와 거의 동일하며, 생성자 인자가 없을 뿐입니다.)

```typescript
import { ethers } from "hardhat";

async function main() {
  const MyNFT = await ethers.getContractFactory("MyNFT");
  const myNFT = await MyNFT.deploy();

  await myNFT.waitForDeployment();

  console.log(`MyNFT deployed to: ${myNFT.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

이제 다음 명령어를 사용하여 Sepolia 테스트넷에 컨트랙트를 배포합니다.

```bash
npx hardhat run scripts/deploy.ts --network sepolia
```

배포가 성공적으로 완료되면, 터미널에 출력된 컨트랙트 주소를 복사하여 **[Sepolia Etherscan](https://sepolia.etherscan.io/)** 과 같은 블록 탐색기에서 검색해 보세요. 여러분이 방금 배포한 컨트랙트가 전 세계 누구나 볼 수 있는 공개 블록체인 상에 실제로 존재하는 것을 확인할 수 있습니다.

이제 이 컨트랙트의 `safeMint` 함수를 호출하여 나만의 NFT를 발행하고, **[OpenSea 테스트넷](https://testnets.opensea.io/)** 과 같은 마켓플레이스에서 내 지갑에 들어온 NFT를 직접 눈으로 확인할 수 있습니다.
