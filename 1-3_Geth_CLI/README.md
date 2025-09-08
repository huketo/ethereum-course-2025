# Geth(Go Ethereum) Workshop: 개인 노드 구축 실습

## 📜 들어가며: 왜 Geth를 사용할까?

이더리움 네트워크에 참여하고, 블록체인 데이터를 직접 다루기 위해서는 **이더리움 클라이언트**라는 소프트웨어가 필요합니다. 클라이언트는 이더리움 네트워크의 규칙을 실행하고, 다른 노드와 통신하며, 블록체인의 현재 상태를 유지하는 역할을 합니다.

**Geth(Go Ethereum)** 는 Go 언어로 개발된 가장 대표적이고 널리 사용되는 공식 이더리움 클라이언트입니다. Geth를 활용하면 이더리움의 핵심 개념들을 실제로 체험하고 이해할 수 있습니다.

이번 실습에서는 Geth를 사용하여:
- **개인 이더리움 네트워크**를 구축하고
- **외부 소유 계정(EOA, Externally Owned Account)** 을 생성하며
- **키스토어(Keystore) 파일**을 분석하여 **개인키, 공개키, 주소** 사이의 암호학적 관계를 이해하고
- **노드 간 통신**과 **트랜잭션 처리**를 직접 경험해보겠습니다.

## Prerequisites

실습을 시작하기 전에 다음 도구들을 설치해주세요:

- **Geth 설치**: https://geth.ethereum.org/downloads
  - 환경변수 PATH에 Geth 설치 경로 추가 필요
- **Windows Terminal** (권장): https://aka.ms/terminal
- **PowerShell 7 이상** (권장): https://aka.ms/powershell
- **VSCode** (권장): https://code.visualstudio.com

> ⚠️ **주의사항**: 이 실습에서는 Windows 환경의 PowerShell을 기준으로 설명하지만, Linux/macOS 환경에서도 명령어만 약간 수정하면 동일하게 실행 가능합니다.

---

## 1. 환경 설정 및 초기화

### 1.1 Geth 설치 확인

설치가 완료되었다면, 터미널(PowerShell)을 열고 다음 명령어를 입력하여 Geth가 정상적으로 설치되었는지 확인합니다.

```powershell
# Geth 버전 확인
geth version
```

버전 정보가 정상적으로 출력된다면 설치가 성공한 것입니다.

```powershell
# Geth 명령어 도움말 보기
geth --help
```

### 1.2 작업 폴더 생성

실습용 폴더 구조를 만들어보겠습니다.

```powershell
# 실습용 폴더 생성 및 이동
mkdir geth-workshop
cd geth-workshop

# 각 노드가 사용할 폴더 생성
mkdir node1
mkdir node2
```

---

## 2. 서명자(Signer) 계정 생성

개인 네트워크에서 블록을 생성할 서명자 계정들을 만들어보겠습니다.

각 명령 실행 시 암호를 입력하라고 나옵니다. 실습이므로 간단한 암호를 설정하고 꼭 기억하세요.
실행 후 출력되는 `Public address of the key:` 값을 복사해두세요. 이 주소는 제네시스 파일에 필요합니다.

```powershell
# 첫 번째 서명자 계정 생성 (node1용)
geth account new --datadir ./node1
# password: node1
# Public address of the key: <복사해두세요>

# 두 번째 서명자 계정 생성 (node2용)
geth account new --datadir ./node2
# password: node2
# Public address of the key: <복사해두세요>
```

### 💡 계정 생성 과정에서 일어나는 일들

이 명령어들을 실행하면 Geth는 다음과 같은 과정을 거칩니다:

1. **개인키 생성**: 암호학적으로 안전한 256비트 난수 생성
2. **공개키 도출**: 타원곡선 암호(ECDSA)를 사용하여 개인키로부터 공개키 계산
3. **주소 생성**: 공개키를 Keccak-256으로 해시하여 마지막 20바이트를 주소로 사용
4. **키스토어 파일 생성**: 개인키를 비밀번호로 암호화하여 JSON 형태로 저장

---

## 3. 제네시스 파일 작성

개인 네트워크의 초기 상태를 정의하는 `genesis.json` 파일을 생성합니다.

`genesis.json` 파일을 생성하고 아래 내용을 복사해 붙여넣습니다:

```json
{
  "config": {
    "chainId": 7788,
    "terminalTotalDifficulty": 0,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "berlinBlock": 0,
    "clique": {
      "period": 5,
      "epoch": 30000
    }
  },
  "difficulty": "1",
  "gasLimit": "8000000",
  "extraData": "0x0000000000000000000000000000000000000000000000000000000000000000ACCOUNT1_ADDRESS_NO_0xACCOUNT2_ADDRESS_NO_0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  "alloc": {
    "ACCOUNT1_ADDRESS_WITH_0x": { "balance": "500000000000000000000" },
    "ACCOUNT2_ADDRESS_WITH_0x": { "balance": "500000000000000000000" }
  }
}
```

> 🔧 **중요한 수정 사항**: 
> - `ACCOUNT1_ADDRESS_NO_0x`와 `ACCOUNT2_ADDRESS_NO_0x` 부분을 복사해 둔 두 계정의 주소로 바꾸세요. **반드시 맨 앞의 0x를 제거해야 합니다.**
> - `ACCOUNT1_ADDRESS_WITH_0x`와 `ACCOUNT2_ADDRESS_WITH_0x` 부분은 0x를 포함한 전체 주소로 교체합니다.

### 💡 extraData 필드 이해하기

`extraData` 필드는 세 부분으로 구성된 하나의 긴 16진수 문자열입니다:

```
0x + 32바이트 0 + 서명자 주소들 + 65바이트 0 (Vanity)
```

1. **32바이트 제로 패딩**: 고정된 헤더 공간
   - `0x0000000000000000000000000000000000000000000000000000000000000000`
2. **서명자 주소들**: 블록 생성 권한을 가진 계정들의 주소 (0x 제거)
3. **65바이트 베니티 데이터**: 블록 서명을 위한 여분 공간 (0이 130개)

---

## 4. 노드 초기화 및 실행

### 4.1 노드 초기화

```powershell
# 노드1 초기화
geth --datadir .\node1 init genesis.json

# 노드2 초기화
geth --datadir .\node2 init genesis.json
```

### 4.2 노드1 (부트노드) 실행

첫 번째 PowerShell 창에서:

```powershell
# NODE_1_SIGNER를 실제 node1의 주소로 변경
geth --datadir .\node1 --networkid 7788 --port 30303 --http --http.port 8545 --miner.etherbase "NODE_1_SIGNER"
```

### 4.3 노드2 실행

두 번째 PowerShell 창에서:

```powershell
# NODE_2_SIGNER를 실제 node2의 주소로 변경
# enode 주소는 노드1 실행 후 콘솔에서 확인 가능
geth --datadir .\node2 --networkid 7788 --port 30304 --http --http.port 8546 --unlock "NODE_2_SIGNER" --password node2 --mine --miner.etherbase "NODE_2_SIGNER" --bootnodes "enode://노드1의_enode_주소@127.0.0.1:30303" --ipcpath geth2.ipc --authrpc.port 8552 --allow-insecure-unlock
```

---

## 5. 노드 상태 확인 및 조작

### 5.1 노드 콘솔 접속

```powershell
# 노드1 콘솔 접속
geth attach \\.\pipe\geth.ipc

# 노드2 콘솔 접속 (별도 창에서)
geth attach \\.\pipe\geth2.ipc
```

### 5.2 기본 상태 확인

콘솔에서 다음 명령어들을 실행해보세요:

```javascript
// 현재 블록 번호 확인
eth.blockNumber

// 계정 목록 확인
eth.accounts

// 계정 잔액 확인
eth.getBalance(eth.accounts[0])

// 네트워크 정보 확인
admin.nodeInfo

// 피어 정보 확인
admin.peers
```

### 5.3 트랜잭션 테스트

노드1 콘솔에서 노드2로 1 ETH를 전송해보겠습니다:

```javascript
// 계정 잠금 해제 (필요시)
personal.unlockAccount(eth.accounts[0])

// ETH 전송
eth.sendTransaction({
  from: "NODE_1_SIGNER", 
  to: "NODE_2_SIGNER", 
  value: web3.toWei(1, "ether")
})

// 트랜잭션 확인
eth.pendingTransactions
```

---
## 6. 키스토어(Keystore) 파일 분석하기

실습을 통해 생성된 키스토어 파일의 구조를 이해해보겠습니다.

### 6.1 키스토어 파일 위치 확인

```powershell
# node1의 키스토어 파일 확인
ls .\node1\keystore\

# node2의 키스토어 파일 확인
ls .\node2\keystore\
```

### 6.2 키스토어 파일 내용 분석

Geth가 생성한 키스토어 파일은 암호화된 개인키를 담고 있는 JSON 형식의 텍스트 파일입니다. 파일 이름은 보통 `UTC--`로 시작하며, 생성된 시간과 계정 주소를 포함하고 있습니다.

```powershell
# 키스토어 파일 내용 확인 (실제 파일명으로 변경)
Get-Content .\node1\keystore\UTC--2024-...
```

파일을 열어보면 다음과 같은 JSON 구조를 볼 수 있습니다:

```json
{
  "address": "...",
  "crypto": {
    "cipher": "aes-128-ctr",
    "ciphertext": "...",
    "cipherparams": {
      "iv": "..."
    },
    "kdf": "scrypt",
    "kdfparams": {
      "dklen": 32,
      "n": 262144,
      "p": 1,
      "r": 8,
      "salt": "..."
    },
    "mac": "..."
  },
  "id": "...",
  "version": 3
}
```

### 6.3 키스토어 구조 이해

- **`address`**: 이 키스토어 파일에 해당하는 이더리움 주소
- **`crypto.ciphertext`**: 개인키를 암호화한 결과 (가장 중요한 부분)
- **`crypto.kdf`**: 'Key Derivation Function' - 비밀번호를 암호화 키로 변환하는 알고리즘
- **`crypto.kdfparams`**: KDF에 사용되는 파라미터들
- **`crypto.mac`**: 'Message Authentication Code' - 파일 무결성 검증용

**핵심은, 이 키스토어 파일 자체는 개인키가 아니라는 점입니다.** 이것은 **개인키를 비밀번호로 암호화하여 안전하게 보관하는 '금고'** 와 같습니다.

---

## 7. 실습을 통한 개념 이해

### 7.1 개인키, 공개키, 주소의 관계

실습을 통해 우리는 이더리움 계정의 핵심 구성 요소들이 어떻게 생성되고 연결되는지 확인했습니다:

```
개인키(Private Key) → 공개키(Public Key) → 주소(Address)
```

1. **개인키 (Private Key)**
   - **생성**: 암호학적으로 안전한 256비트 난수
   - **역할**: 트랜잭션 서명, 자산 소유권 증명
   - **보안**: 절대로 외부에 노출되어서는 안 됨

2. **공개키 (Public Key)**
   - **생성**: 타원곡선 암호(ECDSA)로 개인키에서 도출
   - **역할**: 서명 검증
   - **특성**: 단방향 변환 (공개키에서 개인키 역산 불가능)

3. **주소 (Address)**
   - **생성**: 공개키의 Keccak-256 해시의 마지막 20바이트
   - **역할**: 공개된 식별자 (은행 계좌번호와 유사)
   - **특성**: 다른 사람과 공유 가능

### 7.2 블록체인 네트워크의 작동 원리

실습을 통해 확인한 개념들:

- **합의 메커니즘**: Clique PoA (Proof of Authority)
- **네트워크 ID**: 7788 (메인넷과 구분하기 위한 고유 식별자)
- **제네시스 블록**: 네트워크의 시작점
- **노드 간 통신**: P2P 네트워킹을 통한 블록 동기화
- **트랜잭션 풀**: 미처리 트랜잭션들의 대기열

### 7.3 실제 네트워크와의 차이점

우리가 구축한 개인 네트워크와 실제 이더리움 메인넷의 차이점:

| 구분 | 개인 네트워크 | 메인넷 |
|------|---------------|--------|
| 합의 메커니즘 | Clique PoA | Proof of Stake |
| 블록 생성 시간 | 5초 | 12초 |
| 참여자 수 | 2개 노드 | 수십만 개 노드 |
| 네트워크 ID | 7788 | 1 |
| 초기 잔액 | 임의 설정 | 실제 구매/채굴 |

---

## 🎯 실습 완료 후 확인사항

실습을 성공적으로 완료했다면 다음 내용을 이해했을 것입니다:

✅ **기술적 이해**
- [ ] Geth 클라이언트의 역할과 기능
- [ ] 이더리움 계정(EOA)의 생성 과정
- [ ] 개인키, 공개키, 주소의 암호학적 관계
- [ ] 키스토어 파일의 구조와 보안 메커니즘
- [ ] 제네시스 블록과 네트워크 초기화
- [ ] 노드 간 P2P 통신과 블록 동기화

✅ **실무적 경험**
- [ ] 개인 이더리움 네트워크 구축
- [ ] 다중 노드 환경에서의 트랜잭션 처리
- [ ] Geth 콘솔을 통한 네트워크 상태 모니터링
- [ ] 계정 잠금 해제와 트랜잭션 전송

### 💡 다음 단계 학습 방향

이 실습을 바탕으로 다음 주제들을 학습하실 수 있습니다:

1. **스마트 컨트랙트 배포**: Hardhat과 연동하여 컨트랙트 배포
2. **Web3 인터페이스**: JavaScript를 통한 블록체인 상호작용
3. **토큰 생성**: ERC-20/ERC-721 토큰 구현 및 배포
4. **DApp 개발**: 프론트엔드와 블록체인 연결
5. **테스트넷 활용**: Sepolia, Goerli 등 공개 테스트넷 사용

### 🔒 보안 주의사항

실습 과정에서 생성된 키들은 절대로 실제 자산에 사용하지 마세요:
- 키스토어 파일과 비밀번호는 안전하게 보관
- 개인키는 절대로 다른 사람과 공유하지 않음
- 실제 메인넷 사용 시에는 하드웨어 지갑 등 보안 솔루션 활용 권장

---

## 📚 참고 자료

- [Geth 공식 문서](https://geth.ethereum.org/docs/)
- [이더리움 개발자 문서](https://ethereum.org/developers/)
- [Clique PoA 합의 메커니즘](https://eips.ethereum.org/EIPS/eip-225)
- [EIP-155: 체인 ID 표준](https://eips.ethereum.org/EIPS/eip-155)

Geth는 이 모든 과정을 내부적으로 처리한 뒤, 가장 중요한 **개인키**를 여러분이 입력한 **비밀번호**로 암호화하여 **키스토어 파일**이라는 안전한 형태로 저장해 준 것입니다. 앞으로 MetaMask와 같은 지갑에 이 계정을 사용하고 싶다면, 이 키스토어 파일과 비밀번호를 이용하거나, 파일에서 추출한 개인키를 직접 '가져오기(Import)'하면 됩니다.
