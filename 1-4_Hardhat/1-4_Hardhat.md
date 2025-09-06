# 실무 개발 환경 구축: Hardhat

태그: Blockchain, Hardhat, Metamask, Development Environment
프로젝트: 블록체인 강의

## 📜 들어가며: 왜 Hardhat을 사용할까?

스마트 컨트랙트를 개발하고, 테스트하며, 배포하는 전체 과정을 효율적으로 관리하기 위해서는 전문적인 개발 도구가 필수적입니다. **Hardhat**은 이더리움 소프트웨어 개발을 위한 강력하고 유연한 개발 환경 프레임워크입니다.

Hardhat을 사용하면 다음과 같은 이점들을 얻을 수 있습니다.

-   **로컬 이더리움 네트워크**: 실제 이더리움 네트워크와 유사한 환경을 내 컴퓨터에 빠르고 쉽게 구축할 수 있습니다. 이를 통해 실제 자산을 소모하지 않고도 컨트랙트 배포와 테스트를 무제한으로 진행할 수 있습니다.
-   **자동화된 테스트 환경**: Solidity 코드에 대한 단위 테스트 및 통합 테스트를 JavaScript(Mocha, Chai) 기반으로 쉽게 작성하고 실행할 수 있습니다.
-   **간편한 배포 스크립트**: 작성한 스마트 컨트랙트를 로컬, 테스트넷, 메인넷 등 원하는 네트워크에 손쉽게 배포할 수 있는 스크립트를 작성하고 관리할 수 있습니다.
-   **강력한 디버깅 기능**: `console.log`를 Solidity 코드 내에서 직접 사용하여 변수 값을 출력하는 등 편리한 디버깅 기능을 제공합니다.

이번 실습에서는 Hardhat을 사용하여 새로운 프로젝트를 시작하고, 로컬 테스트 노드를 실행한 뒤, MetaMask 지갑을 연동하여 이전 실습에서 Geth로 생성했던 계정을 가져오는 과정을 진행합니다.

---

## 1. 필수 도구 최종 점검

Hardhat을 사용하기 위해서는 다음과 같은 도구들이 사전에 설치되어 있어야 합니다.

-   **Node.js**: Hardhat은 Node.js 기반으로 동작합니다. 터미널에서 `node -v` 명령어를 실행하여 `v16.0` 이상의 버전이 설치되어 있는지 확인합니다.
-   **VSCode**: 코드 편집기로, [Solidity 확장 프로그램](https://marketplace.visualstudio.com/items?itemName=JuanBlanco.solidity)을 설치하면 코드 하이라이팅 및 자동 완성 기능을 편리하게 사용할 수 있습니다.
-   **MetaMask**: 브라우저 확장 프로그램 형태의 암호화폐 지갑입니다. 아직 설치하지 않았다면 [공식 홈페이지](https://metamask.io/)에서 설치를 진행합니다.

---

## 2. Hardhat 프로젝트 생성 및 로컬 노드 실행

### **프로젝트 생성**

1.  터미널을 열고, 새로운 프로젝트를 생성할 디렉토리로 이동합니다.
2.  다음 명령어를 순서대로 입력하여 Hardhat 프로젝트를 초기화합니다.

    ```bash
    # 프로젝트 폴더 생성 및 이동
    mkdir my-hardhat-project
    cd my-hardhat-project

    # npm 프로젝트 초기화
    npm init -y

    # Hardhat 설치
    npm install --save-dev hardhat
    ```

3.  이제 Hardhat 프로젝트를 설정합니다.

    ```bash
    # Hardhat 프로젝트 생성
    npx hardhat init
    ```

    명령어를 실행하면 몇 가지 질문이 나타납니다. 우리는 TypeScript 기반의 프로젝트를 생성할 것이므로, 다음과 같이 선택합니다.

    -   `What do you want to do?`: `Create a TypeScript project` 선택
    -   `Hardhat project root`: 기본값(현재 디렉토리)으로 Enter
    -   `Do you want to add a .gitignore file?`: `y` (yes)
    -   `Do you want to install this sample project's dependencies with npm?`: `y` (yes)

    설치가 완료되면 프로젝트 폴더에 `contracts`, `scripts`, `test` 등의 디렉토리와 `hardhat.config.ts` 파일이 생성된 것을 확인할 수 있습니다.

### **로컬 노드 실행**

Hardhat은 자체적으로 로컬 테스트 네트워크를 구동하는 기능을 내장하고 있습니다. 다음 명령어를 사용하여 로컬 노드를 실행하세요.

```bash
# Hardhat 로컬 노드 실행
npx hardhat node
```

명령어를 실행하면, 터미널에 다음과 같은 정보가 출력됩니다.

```
Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545/

Accounts
========

WARNING: These accounts, and their private keys, are publicly known.
Any funds sent to them will be lost.

Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

Account #1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000 ETH)
Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e8b8b7b4655944a7267c33c6329d0

... (총 20개의 테스트 계정이 생성됨)
```

-   `http://127.0.0.1:8545/`: 이것이 바로 내 컴퓨터에서 실행되고 있는 로컬 이더리움 노드의 **RPC URL**입니다. MetaMask나 다른 애플리케이션이 이 주소를 통해 로컬 블록체인과 통신하게 됩니다.
-   **Accounts**: Hardhat은 테스트를 위해 10000 ETH의 잔액을 가진 20개의 테스트 계정을 자동으로 생성해 줍니다. 각 계정의 주소와 **개인키(Private Key)** 가 함께 제공되므로, 이 계정들을 사용하여 DApp을 테스트할 수 있습니다.

---

## 3. MetaMask 연동 및 계정 가져오기

### **로컬 네트워크 추가**

1.  브라우저에서 MetaMask를 열고, 좌측 상단의 네트워크 선택 메뉴를 클릭합니다.
2.  `네트워크 추가(Add network)` 버튼을 클릭한 뒤, `수동으로 네트워크 추가(Add a network manually)`를 선택합니다.
3.  다음 정보를 입력하여 Hardhat 로컬 네트워크를 추가합니다.
    -   **네트워크 이름**: `Hardhat Local`
    -   **새 RPC URL**: `http://127.0.0.1:8545`
    -   **체인 ID**: `31337`
    -   **통화 기호**: `ETH`
4.  `저장` 버튼을 누르면 MetaMask가 성공적으로 로컬 노드에 연결됩니다.

### **Geth 계정 가져오기**

이제 이전 실습에서 Geth로 생성했던 계정을 MetaMask로 가져와 보겠습니다. 이를 위해서는 해당 계정의 **개인키**가 필요합니다.

> 🔐 **개인키 추출**: 실제 상황에서는 Geth 키스토어 파일과 비밀번호를 사용하여 개인키를 추출하는 별도의 도구나 스크립트가 필요합니다. (예: MyEtherWallet, `web3.js` 스크립트 등). 이번 실습에서는 개인키를 이미 알고 있다고 가정합니다.

1.  MetaMask에서 우측 상단의 계정 아이콘을 클릭하고, `계정 가져오기(Import account)`를 선택합니다.
2.  '개인 키 문자열 붙여넣기' 필드에 Geth 계정의 **개인키**를 입력하고 `가져오기(Import)` 버튼을 클릭합니다.
    -   **주의**: 개인키는 `0x` 접두사를 포함하거나 포함하지 않을 수 있습니다. Hardhat이 생성해준 테스트 계정의 개인키 중 하나를 복사하여 테스트해 볼 수도 있습니다.

가져오기가 완료되면, MetaMask에 새로운 계정이 추가된 것을 볼 수 있습니다. 처음에는 잔액이 `0 ETH`로 표시될 것입니다.

### **테스트 이더 전송**

이제 Hardhat이 기본으로 제공하는 테스트 계정 중 하나를 사용하여, 방금 가져온 Geth 계정으로 테스트 이더를 전송해 보겠습니다.

1.  MetaMask에서 Hardhat 기본 계정(예: Account #0)을 선택합니다. 이 계정은 10000 ETH의 잔액을 가지고 있습니다.
2.  `보내기(Send)` 버튼을 클릭합니다.
3.  받는 사람 주소에 방금 가져온 Geth 계정의 주소를 붙여넣습니다.
4.  보낼 금액(예: `100 ETH`)을 입력하고 `다음` -> `확인`을 눌러 트랜잭션을 전송합니다.

트랜잭션이 성공적으로 처리되면, Hardhat 노드를 실행 중인 터미널에 해당 트랜잭션 정보가 출력됩니다.

```
eth_sendTransaction
  Contract deployment: Greeter
  From: 0xf39fd6e51aad88F6F4ce6aB8827279cffFb92266
  To:   0x... (방금 가져온 Geth 계정 주소)
  Value: 100 ETH
  ...
```

다시 MetaMask에서 Geth 계정을 선택해 보면, 잔액이 `100 ETH`로 업데이트된 것을 확인할 수 있습니다.

이로써 우리는 실무와 거의 동일한 스마트 컨트랙트 개발 환경을 모두 구축했습니다. 이제 이 환경 위에서 Solidity 코드를 작성하고, 테스트하며, 배포하는 본격적인 개발 과정을 진행할 준비가 완료되었습니다.
