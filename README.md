# GLINT iOS 17.0+

> **이미지에 나를 입히고, 세상과 나누다** 📸

사용자가 직접 사진 필터를 제작 및 판매하고, 실시간 채팅과 커뮤니티를 통해 창작과 소통이 동시에 이루어지는 소셜 기반 서비스 앱

<p align="center">
  <img src="https://github.com/user-attachments/assets/placeholder1.png" width="18%">
  <img src="https://github.com/user-attachments/assets/placeholder2.png" width="18%">
  <img src="https://github.com/user-attachments/assets/placeholder3.png" width="18%">
  <img src="https://github.com/user-attachments/assets/placeholder4.png" width="18%">
  <img src="https://github.com/user-attachments/assets/placeholder5.png" width="18%">
</p>

---

## 📋 프로젝트 정보

| 항목 | 내용 |
|:---:|:---|
| **개발 기간** | 2025.05 - 2025.06 (4주) |
| **개발 인원** | 4인 프로젝트 \| 기획(1) · 디자인(1) · 서버(1) · iOS(1) |
| **최소 버전** | iOS 17.0+ |
| **GitHub** | [ParkSY0919/GLINT-iOS](https://github.com/ParkSY0919/GLINT-iOS) |

---

## 🛠 기술 스택

| 분류 | 기술 |
|:---:|:---|
| **Framework** | SwiftUI, UIKit, PhotosUI, Core Image, NWPathMonitor |
| **Architecture** | MVI, Clean Architecture |
| **Design Patterns** | DI, Adapter, Facade, Singleton, Observer, Interceptor |
| **Networking** | Alamofire, Socket.IO, Firebase FCM |
| **Reactive** | Combine, NotificationCenter, @Observable(Macro) |
| **Library** | Nuke, Firebase, KakaoSDK, SocketIO, iamport-ios |

---

## 🎯 주요 기능

### 사용자 인증 및 보안 관리
- 소셜로그인 연동 (애플/카카오)
- Keychain 기반 보안 토큰 저장
- 자동 토큰 갱신

### 이미지 편집
- 사진 필터 적용
- 필터 적용 전·후 비교
- 편집 히스토리 관리 (Undo/Redo)

### 실시간 채팅
- 실시간 메세지/이미지 송수신
- 전송 실패 메세지 재전송/삭제 기능
- 과거 메세지 검색 기능 및 Push 알림

### 필터 마켓플레이스 및 웹뷰 연동
- 커스텀 필터 제작 및 거래
- 역지오코딩 (GPS → 한국어 주소 변환)
- 웹브릿지 기반 출석체크

### 커뮤니티 및 결제
- 게시글 및 댓글 기능
- 간편 결제 지원 (PG)
- 결제 보안 이중 검증

---

## 🏗 아키텍처

### Clean Architecture + MVI 패턴

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│                (Views, ViewModels, Stores)                   │
│                     uses Entity only                         │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│          (UseCase, Repository Interface, Entity)             │
│            ❌ DTO를 알지 못함 (순수 비즈니스 로직)              │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │ implements
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│       (Repository Implementation, DTO, API Service)          │
│                 DTO → Entity 변환 수행                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                       Core Layer                             │
│           (Utilities, Managers, Shared Helpers)              │
│                 모든 레이어에서 공통 사용                       │
└─────────────────────────────────────────────────────────────┘
```

### MVI 패턴과 단방향 데이터 플로우

```
┌────────┐    User Action    ┌────────────┐    State Change    ┌───────────┐
│  View  │ ───────────────▶  │ ViewAction │ ────────────────▶  │ ViewState │
└────────┘                   └────────────┘                    └───────────┘
     ▲                                                               │
     │                        UI Update                              │
     └───────────────────────────────────────────────────────────────┘
```

SwiftUI의 SSOT(Single Source of Truth) 원칙을 준수하며, 상태 변화를 추적하고자 MVI 패턴과 단방향 데이터 플로우를 도입했습니다. ViewState, ViewAction, @Observable을 활용해 상태 변화를 체계적으로 관리했으며, View-Action-State-View 순환 구조로 UI 상태 변화의 예측 가능성을 확보했습니다.

---

## 📖 기술적 고려사항

### 1. 의존성 주입 방식 개선을 통한 성능 최적화

기존 프로토콜 기반 UseCase/Repository의 witness table 호출로 인한 성능 저하를 해결하기 위해 struct 기반 재설계와 SwiftUI DependencyKey 패턴을 도입했습니다.

```swift
// Before: Protocol 기반 (witness table 호출)
protocol AuthRepository {
    func signIn(_ request: SignInRequest) async throws -> SignInResponse
}

// After: Struct 기반 (직접 함수 호출)
struct AuthRepository {
    var signIn: @Sendable (_ email: String, _ password: String, _ deviceToken: String) async throws -> AuthEntity
}

extension AuthRepository {
    static let liveValue: AuthRepository = {
        let provider = NetworkService<AuthEndPoint>()
        return AuthRepository(
            signIn: { email, password, deviceToken in
                let request = SignInRequest(email: email, password: password, deviceToken: deviceToken)
                let response: SignInResponse = try await provider.request(.signIn(request))
                return response.toEntity()
            }
        )
    }()
}
```

**개선 효과:**
- 호출을 직접 함수 호출로 최적화
- `testValue`로 독립적인 단위 테스트 환경 구축
- 컴파일 타임 타입 안정성과 테스트 효율성 확보
- LoginViewStore의 유효성 검사 로직을 XCTest로 검증해 실제 동작의 신뢰성 보장

---

### 2. 제네릭 기반 네비게이션 라우터 설계

NavigationLink 한계를 해결하기 위해 NavigationStack path 기반 제네릭 타입 안전 NavigationRouter를 설계했습니다.

```swift
@MainActor
@Observable
final class NavigationRouter<Route: Hashable> {
    var path: [Route] = []
    private var dataStore: [ObjectIdentifier: Any] = [:]

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    // 제네릭 데이터 전달
    func setPopData<T>(_ data: T) {
        dataStore[ObjectIdentifier(T.self)] = data
    }

    func onPopData<T, U>(_ type1: T.Type, _ type2: U.Type,
                         perform: @escaping (T, U) -> Void) {
        // 타입 안전한 데이터 콜백
    }
}
```

```
┌──────────┐   앱 시작   ┌─────────────┐   토큰 유효 O   ┌──────────────────┐
│ Push알림 │ ─────────▶ │ 자동 로그인  │ ─────────────▶ │ RootRouter 상태   │
│   탭    │            │    검사     │                │ (Login → Tab)    │
└──────────┘            └─────────────┘                └──────────────────┘
                              │                              │
                              │ 토큰 유효 X                    │ 채팅 목록 로드
                              ▼                              ▼
                        ┌──────────┐                  ┌──────────────┐
                        │ 재 로그인 │                  │ 채팅 목록 화면 │
                        └──────────┘                  └──────────────┘
                                                            │
                                                            │ Push 알림 ID와
                                                            │ 각 채팅방 ID를 비교
                                                            ▼
                                                     ┌──────────────┐
                                                     │ 특정 채팅방   │
                                                     │    진입      │
                                                     └──────────────┘
```

**특징:**
- 조건부 라우팅 체인을 NavigationStack으로 관리해 다층 네비게이션 플로우를 안정적으로 처리
- 제네릭을 통해 화면 간 데이터 전달의 타입 안전성 보장

---

### 3. Nuke 라이브러리를 활용한 이미지 캐싱 최적화

사진 필터 앱의 특성상 반복적인 이미지 로딩으로 인한 성능 및 메모리 관리 한계가 발생했고, 이를 해결하기 위해 Nuke 라이브러리를 도입하여 네트워크 요청 최적화와 캐시 전략을 적용하여 이미지 처리 효율을 높였습니다.

특히 서버 업로드 시 이미지 파일당 5MB 제한하는 것을 고려해 `NetworkAwareCacheManager`로 네트워크 상태별 캐시 정책을 유연하게 조정했습니다.

| 네트워크 상태 | 메모리 캐시 | 디스크 캐시 | 다운샘플링 | 압축률 | 이미지 개수 제한 |
|:-----------:|:----------:|:---------:|:--------:|:-----:|:-------------:|
| WiFi | 50MB | 200MB | 800×800px | 90% | 50개 |
| 셀룰러 | 25MB | 100MB | 500×500px | 80% | 30개 |
| 오프라인 | 15MB | 50MB | - | 75% | 20개 |

**개선 효과:**
- Nuke의 다운샘플링과 LRU 기반 캐시 정책을 활용해 불필요한 네트워크 요청과 메모리 사용을 줄임
- 썸네일부터 원본 이미지 저장까지 로딩 속도를 개선한 결과, 앱의 전체 성능과 안정성이 향상
- 오프라인 환경에서도 캐시된 이미지를 최적화해 일관된 사용자 경험을 제공

---

### 4. CIFilter 기반 이미지 처리 최적화

iOS 사진 편집 앱에서 안정적인 필터 효과를 구현하기 위해 CIFilter 기반 이미지 처리 시스템을 설계했고, 이를 통해 아래 각 문제들에 대한 대비를 할 수 있었습니다.

**개선된 이미지 처리 설계:**
- **Extent 제한**: 무한 extent 설정을 방지하기 위해 원본 이미지 크기로 제한
- **체인 처리 구조**: 모든 필터를 CIImage 체인에서 처리하고 마지막에만 UIImage로 변환하여 화질 저하 방지
- **벡터 파라미터 추상화**: Float 값을 CIVector로 자동 변환하는 래퍼를 도입해 UI 구현 단순화
- **CIContext 공유**: 싱글톤 패턴으로 컨텍스트를 공유해 불필요한 GPU/메모리 낭비 차단

---

### 5. 실시간 필터 적용 시 성능 저하 문제 개선

실시간 필터 적용 과정에서 다양한 필터를 연속 적용하면 속도가 느려지고 메모리 점유율이 급격히 증가하는 문제가 발생했습니다.

```
┌────────────────────┐              ┌────────────────────┐
│   축소된 미리보기    │              │     원본 이미지     │
│  256px로 축소한     │              │  3000×4000 해상도의 │
│      이미지        │              │      이미지        │
└────────────────────┘              └────────────────────┘
```

이를 해결하고자 원본 이미지를 256px로 축소한 프리뷰로 필터 적용 미리보기를 처리하도록 최적화했습니다.

**Instruments 측정 결과:**

| 구분 | Persistent | # Persistent | # Transient | Total Bytes |
|:---:|:----------:|:------------:|:-----------:|:-----------:|
| **리사이징 이전** | 46.52 MiB | 1 | 28 | 1.32 GiB |
| **리사이징 이후** | 1.69 MiB | 1 | 60 | 102.94 MiB |

3000×4000 해상도의 이미지를 직접 처리하던 기존 방식은 약 4.62 MiB의 Persistent 메모리와 총 1.32 GiB 메모리를 사용했으나, 리사이징 적용 후에는 1.69 MiB Persistent, 총 102.94 MiB 메모리로 줄어 **각각 약 3배, 13배 감소**했습니다.

---

### 6. 실시간 메세지 송수신 안정화 및 최적화

기존 CoreData 기반 동기화는 네트워크 불안정 시 데이터 유실과 지연이 발생할 수 있었고, 이를 방지하기 위해 HTTP·WebSocket 실시간 송수신, CoreData 전송 대기 큐, 실패 메시지 제어로 구성된 플로우를 설계했습니다.

```
┌─────────────────────────────────────────┐      ┌─────────────────────────────┐
│              클라이언트                   │      │           서버              │
├─────────────────────────────────────────┤      ├─────────────────────────────┤
│                                         │      │                             │
│  ◀── 채팅방 입장 (CoreData 메시지 확인) ──│      │                             │
│         │                               │      │                             │
│         ▼                               │      │                             │
│  최신 메시지 조회 / 소켓 요청 ────────────│─────▶│                             │
│         │                               │      │                             │
│         ▼                               │◀─────│──── 최신 메시지가 있다면      │
│  CoreData 동기화, 이후 UI 메시지 표시    │      │     전송 / 소켓 승인         │
│         │                               │      │                             │
│         ▼                               │      │                             │
│  실시간 메시지 송신                      │      │                             │
│  1. 전송 이전 UI 표시 및 CoreData 저장   │      │                             │
│     (status: 0)                         │      │                             │
│  2. 서버 전송 및 결과에 따라 status 값   │      │                             │
│     변경                                │      │                             │
│     가. 성공: status 값 1로 변경         │      │                             │
│     나. 실패: status 값 0 유지           │      │                             │
│         │                               │      │                             │
│         ▼                               │      │                             │
│  실시간 메시지 수신                      │◀─────│                             │
│  UI 메시지 표시, 이후 CoreData 저장      │      │                             │
└─────────────────────────────────────────┘      └─────────────────────────────┘
```

**설계 특징:**

1. **HTTP 및 WebSocket 기반 실시간 송수신**
   - 채팅방 입장 시 CoreData에서 기존 메시지를 로드하고, 서버에서 최신 메시지를 HTTP GET으로 동기화
   - 이후 WebSocket으로 실시간 메시지를 수신해 UI에 즉시 반영하고 로컬에 저장

2. **CoreData 전송 대기 큐**
   - 메시지는 status 컬럼으로 상태를 관리하며, 전송 전에는 대기 상태로 저장하고 성공 시 완료로 업데이트
   - 실패 시에는 status=0을 유지해 재전송 대상으로 둠

3. **실패 메시지 사용자 제어**
   - 전송 실패 메시지에는 재전송/삭제 버튼을 제공
   - 재전송 시 기존 데이터를 삭제 후 새 타임스탬프로 재생성하고, 삭제 시에는 CoreData에서만 제거해 사용자가 직접 관리할 수 있도록 함

---

### 7. 웹브릿지 구현 및 데이터 처리

출석체크 기능 구현을 위해 웹뷰와 네이티브 앱 간 양방향 통신 시스템을 구축했습니다.

**구현 내용:**
- `WKScriptMessageHandler`와 `evaluateJavaScript`를 활용한 통신 구조를 설계
- 서버팀 협업을 통해 attendanceCount 파라미터의 다양한 형태를 처리하는 조건부 파싱 로직을 적용
- 네트워크 불안정과 토큰 만료에 대한 에러 분류 처리 및 실시간 감지 시스템을 구현하여 안정적인 웹브릿지 통신을 구현

---

### 8. 푸시 권한 대응 및 채팅 알림 제어

채팅 앱의 알림 기능은 푸시 권한 여부에 크게 의존하기 때문에, 권한이 거부되거나 일부만 허용된 경우에도 정상 작동하도록 권한 상태별 대응 로직을 구현했습니다.

```
                         ┌─────────────────────────────────────────┐
                         │            알림 거부 / 일부 허용          │
                         │  • 인앱 알림 + 배지 업데이트              │
                         │  • 설정 화면 안내 UX                     │
                         └─────────────────────────────────────────┘
                                           ▲
┌─────────┐    푸시 권한 확인    ───────────┤
│ 앱 실행 │ ─────────────────▶             │
└─────────┘                               │
                                          ▼
                         ┌─────────────────────────────────────────┐
                         │              알림 허용                   │    서버-클라이언트 활성
                         │  • 상황별 알림 로직 적용                  │───▶  상태 실시간 동기화
                         │  • 현재 채팅방 알림 차단                  │
                         │  • 다른 채팅방 새 메세지만 푸시            │
                         └─────────────────────────────────────────┘
```

**구현 효과:**
- 푸시가 허용되지 않은 환경에서는 인앱 알림과 배지 업데이트로 대체하기 등의 방법을 사용
- 권한이 허용된 환경에서는 룸 아이디 기반으로 현재 사용자가 머무르는 특정 채팅 룸의 푸시 알림은 동작하지 않도록 차단하고, 다른 채팅 방 메세지만 푸시 알림이 오도록 알림을 제어
- 그 결과 권한 상태와 관계없이 알림 경험이 안정적으로 유지되었고, 권한이 허용된 경우에도 불필요한 알림을 줄여 사용자의 집중도를 높일 수 있었습니다.

---

### 9. 토큰 갱신 동시성 제어

앱 사용 중 토큰 만료 시 발생할 수 있는 동시 요청 실패를 처리했습니다.

```
┌───────────┐  ┌───────────┐  ┌───────────┐     ┌─────────────────┐
│ Request 1 │  │ Request 2 │  │ Request 3 │     │  GTInterceptor  │
└─────┬─────┘  └─────┬─────┘  └─────┬─────┘     └────────┬────────┘
      │              │              │                    │
      │   StatusCode: 401           │                    │ • isRefreshing = false 이기에,
      │◀─────────────────────────────────────────────────│   토큰 갱신 시작, 이후 true로 전환
      │                             │                    │ • 대기 큐에 Request 1 추가
      │              │              │                    │
      │              │   StatusCode: 401                 │
      │              │◀──────────────────────────────────│ • isRefreshing = true 이기에,
      │              │              │                    │   갱신 요청 중복 방지됨
      │              │              │                    │ • 대기 큐에 Request 2, 3 추가
      │              │              │   StatusCode: 401  │
      │              │              │◀───────────────────│
      │              │              │                    │
      │              │              │                    │        토큰 갱신 성공
      │              │              │                    │ • isRefreshing = false
      │              │              │                    │ • processPendingRequests()
      │              │              │                    │
┌─────┴─────────────┴──────────────┴────┐               │
│  대기 큐 pendingRequests에 담긴 기존    │◀──────────────│
│  요청들 일괄 재시도                     │               │ pendingRequests.removeAll()
└───────────────────────────────────────┘               │
```

**구현 내용:**
- Interceptor 기반 토큰 갱신 로직에 `isRefreshing` 플래그로 중복 갱신을 방지
- `pendingRequests` 배열로 대기 요청을 일괄 재시도하도록 구성
- `DispatchQueue barrier`로 스레드 안정성을 확보하고, `DispatchGroup`으로 갱신 시점을 동기화
- 원본 토큰 정보를 저장해 상태 불일치를 사전에 감지

---

## 🔄 프로젝트 회고

GLINT 프로젝트는 저에게 기술적인 성과보다도 **개발자로서의 태도**를 돌아보게 만든 경험이었습니다.

처음에는 아키텍처 설계와 성능 최적화에만 몰두했지만, 시간이 갈수록 제가 만든 일정 지연이 동료들에게 부담이 된다는 사실을 깨달았습니다. 그로 인해 함께 노력하던 팀원들에게 미안한 마음이 컸고, 제 역할을 더 책임감 있게 수행해야 한다는 다짐을 하게 되었습니다.

위 경험을 통해 깨달은 것은, **개발자의 책임은 코드를 완성하는 것이 전부가 아니라는 점**입니다. 팀 전체의 목표와 흐름에 맞춰 균형 잡힌 선택을 하는 것, 그것이 진짜 책임이라는 것을 배웠습니다. 그래서 지금의 저는 완벽을 지향하기보다는, **핵심 가치를 지키면서도 현실적인 방법을 찾아 팀과 함께 앞으로 나아가는 개발자**가 되고자 합니다.

---

## 📁 프로젝트 구조

```
GLINT-iOS/
├── Source/
│   ├── Presentation/          # UI Layer
│   │   ├── Feature/           # 화면별 View + Store
│   │   │   ├── Auth/          # 로그인/회원가입
│   │   │   ├── Main/          # 메인 화면
│   │   │   ├── Detail/        # 필터 상세
│   │   │   ├── Make/          # 필터 제작
│   │   │   ├── Edit/          # 이미지 편집
│   │   │   ├── Chat/          # 실시간 채팅
│   │   │   ├── Community/     # 커뮤니티
│   │   │   └── Settings/      # 설정
│   │   └── DesignSystem/      # 공통 UI 컴포넌트
│   │
│   ├── Domain/                # Business Logic Layer
│   │   ├── Entity/            # 비즈니스 모델
│   │   ├── Repository/        # Repository 인터페이스
│   │   ├── UseCase/           # UseCase 인터페이스
│   │   └── UseCase+/          # UseCase 구현체
│   │
│   ├── Data/                  # Data Layer
│   │   ├── DTO/               # Data Transfer Objects
│   │   │   └── Extensions/    # DTO → Entity 변환
│   │   ├── Network/           # API Service
│   │   ├── Local/             # CoreData Manager
│   │   └── Repository+/       # Repository 구현체
│   │
│   └── Core/                  # Shared Utilities
│       ├── Utilities/         # Helper 클래스
│       ├── Manager/           # 앱 전역 Manager
│       ├── ImageFilter/       # CIFilter 래퍼
│       └── Services/          # 토큰 복구 등
│
└── Resources/                 # 에셋, 폰트, 로컬라이징
```

---

## 📄 라이선스

이 프로젝트는 개인 포트폴리오 목적으로 제작되었습니다.
