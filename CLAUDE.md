# Loop 앱 아키텍처 및 개발 기준

문서·코드 확인 기준: 2026-09-28. 이 문서는 개발 규칙과 목표 설계다. 별도로 명시한 현재 파일 구조 외에는 구현·테스트·운영 검증 완료를 의미하지 않는다.

## 문서 사용 순서

- 기능 변경 전 현재 코드, `pubspec.yaml`, `pubspec.lock`, 해당 기능 문서를 함께 확인한다.
- 성능·네트워크·동시성 작업: [앱 전체 성능 가이드](docs/APP_PERFORMANCE_GUIDE.md).
- 게시글 캐시: [오프라인 캐시 정책](docs/POST_OFFLINE_CACHE.md).
- 기기 기능: [BLE 계획](docs/BLE_FEATURE.md), [OCR 계획](docs/OCR_FEATURE.md).
- 이 문서는 공통 책임·의존성 기준을, 기능 문서는 데이터 계약·수명·검증 기준을 담당한다. 내용이 충돌하면 실제 동작을 확인하고 명시적으로 결정한다.
- 패키지의 최신 문서와 설치 버전은 다를 수 있다. API와 마이그레이션을 확인하지 않은 채 예제를 복사하지 않는다.
- 규모는 다운로드 수로 판단하지 않는다. 지원 기기, 활성 사용자, 피크 요청률, 데이터 크기, 지연·오류 목표로 검증한다. 문서나 레이어 분리만으로 무병목·무프레임드랍을 보장하지 않는다.

## 1. 현재 기준과 소유 위치

`pubspec.lock` 확인 버전: flutter_riverpod 2.6.1, go_router 17.2.2, Dio 5.9.2, Freezed 3.2.5. Dart 제약은 ^3.9.2이며 실제 SDK는 `flutter --version`으로 확인한다. Riverpod 3 전용 API·자동 재시도 동작을 현재 앱에 있다고 가정하지 않는다.

| 책임 | 현재 위치 |
| --- | --- |
| 초기화·MaterialApp·세션/잠금 조정 | `lib/main.dart`의 `LoopApp` |
| 하단/측면 내비게이션 | `lib/loop_app_shell.dart`의 `LoopAppShell` |
| 경로·라우터·NavigatorKey | `lib/src/core/router/router_path.dart`, `router.dart`, `navigator_key.dart` |
| 테마·언어 | `lib/src/core/theme/theme_mode_provider.dart`, `lib/src/core/localization/locale_provider.dart` |
| 다국어 | `lib/l10n/app_ko.arb`, `app_en.arb`, `l10n.yaml` |
| 통신·인증 인터셉터 | `lib/src/core/network/dio_network.dart` |
| 세션 상태 | `lib/src/features/auth/presentation/providers/login/` |
| 앱 잠금 | `lib/src/features/app_lock/` |
| 기능별 코드 | `lib/src/features/<feature>/` |
| 공통 커서 페이지네이션 | `lib/src/shared/`의 `cursor_*` 파일 |
| 설정 구성·화면 | `lib/src/features/settings/` |

현재 위치를 그대로 좋은 설계로 인정하거나, 목표 폴더가 이미 존재한다고 해석하지 않는다. 이동할 때 import와 테스트를 함께 확인한다.

## 2. 레이어와 의존성

```text
Page/Widget → Notifier/Provider → UseCase(필요할 때) → 추상 Repository
                                                        ↑ 구현
                                                Repository 구현 → DataSource → SDK/API/DB
```

위 도식의 앞쪽 화살표는 호출 흐름이다. 코드 의존성은 Data 구현이 Domain 계약을 구현하는 방향이며, Domain이 Data 구현을 import하지 않는다.

| 구성 요소 | 담당 | 넣지 않는 것 |
| --- | --- | --- |
| Page/Widget | 렌더링, 입력, 간단한 이동·다이얼로그 | API·영속 저장소 직접 조작, 인증 갱신 |
| Notifier | 로딩·실패·성공, 사용자 작업 순서, 오래된 결과 방어 | BuildContext, 위젯, 번역 문자열 기반 분기 |
| Provider | 의존성 조립, 상태 구독·파생값, 수명 소유 | 렌더링마다 실행하는 외부 쓰기 |
| UseCase | 재사용 규칙, 복수 작업 조합, 독립적으로 검증할 업무 흐름 | 화면 이동·Snackbar·로딩 표시 |
| 추상 Repository | 앱이 요구하는 기능·반환 계약 | Dio Response, XFile 등 외부 SDK 타입 |
| Repository 구현 | 데이터 소스 조정, 모델·실패 변환, 캐시 정합성 | UI 표시 문구 선택 |
| DataSource | HTTP·DB·파일·플러그인 호출 | 화면 상태와 라우팅 |

- UseCase는 모든 함수에 필수인 레이어가 아니다. 단순 메뉴 이동에는 만들지 않는다. 단순 전달 UseCase를 유지한다면 프로젝트의 일관성·향후 규칙 등 목적을 명시한다.
- 기능 간 연결은 계약·공개 Provider 또는 명시적 조정자로 제한한다. 다른 기능의 private 구현을 직접 조작하지 않는다.
- `core`는 인프라·디자인 공통 기능, `shared`는 실제 여러 기능에서 쓰는 계약·위젯에 사용한다. 한 기능 전용 코드를 이름만 공통으로 만들어 옮기지 않는다.
- 인증·언어·테마의 원본 상태는 한 곳에서 관리한다. Settings가 별도 사본을 저장하지 않는다.

### 모델 구분

| 종류 | 위치 기준 | 직렬화 |
| --- | --- | --- |
| 앱 의미를 표현하는 데이터 | `domain/models/` | 외부 계약이 있을 때만 |
| API/DB 전용 DTO | 필요 시 Data 내부 | 계약에 맞춰 사용 |
| 화면 상태 | `presentation/providers/` | 보통 불필요 |
| 메뉴·아이콘·클릭 콜백 같은 UI 구성 | `presentation/models/`, `presentation/config/` | 불필요 |

단순 API 모델을 재사용할 수 있지만 외부 계약과 앱 의미가 달라지면 DTO와 앱 모델을 분리한다. 도메인에 `Widget`, `BuildContext`, `IconData`, 번역 객체, 화면 콜백을 넣지 않는다. UI용 enum/immutable class는 Freezed·Repository·JSON 생성을 강제하지 않는다.

Freezed 3 모델 예시(프로젝트 적용 시 파일명·타입 조정):

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'example_model.freezed.dart';
part 'example_model.g.dart';

@freezed
abstract class ExampleModel with _$ExampleModel {
  const factory ExampleModel({required String id}) = _ExampleModel;

  factory ExampleModel.fromJson(Map<String, dynamic> json) =>
      _$ExampleModelFromJson(json);
}
```

- 현재 `.gitignore`는 `.g.dart`, `.freezed.dart`, `.mocks.dart`를 제외한다. 생성물은 직접 수정하지 않으며 로컬·CI에서 재생성한다. 추적 정책 변경은 별도 결정한다.
- UI 상태에는 JSON이 필요하지 않다. 불변 상태의 값 비교와 copyWith가 필요한 경우 Freezed를 사용한다.
- 네트워크 숫자·문자열·null은 실제 응답 계약대로 파싱하고 실패를 경계에서 처리한다. 무조건적인 `as`·`!`로 숨기거나 모든 타입을 임의 변환하지 않는다.
- 상수는 관련 기능 가까이에 둔다. 기존 `kAccessTokenKey` 등 공유 키의 이름·값을 임의 변경하지 않는다. 저장 키 변경에는 이전 값 읽기·마이그레이션 정책이 필요하다.

## 3. 상태 관리와 수명

- 기존 기능은 StateNotifier 패턴과 설치된 Riverpod 2 API를 존중한다. 새 기능의 AsyncNotifier 도입은 상태 형태와 팀 일관성을 기준으로 결정하며, '복잡하면 무조건 교체'하지 않는다.
- `watch`: UI나 Provider의 반응형 의존성. `read`: 버튼·콜백에서 동작 호출. `listen`: 상태 변화에 대한 UI 부작용.
- `Consumer`/`ConsumerWidget` 중 어느 이름을 썼느냐보다 구독 범위가 중요하다. 큰 화면에서 필요한 값만 구독하고 측정된 문제에 `select`를 적용한다.
- 위젯의 `build`에서는 API·저장·라우팅을 실행하지 않는다. Provider를 watch해서 데이터를 선언적으로 구독하는 것과 직접 API를 반복 호출하는 것은 다르다.
- WidgetRef.listen은 build에서, initState 등에서는 설치 버전의 listenManual을 사용한다. Provider 내부의 ref.listen도 가능하다. 수동 생성한 listener/container는 소유자가 정리한다.
- Provider 선언 순서는 실행 순서가 아니다. 의존성을 읽기 쉽게 그룹화하고 순환 의존성을 만들지 않는다.

### 수명 정책

| 범위 | 예시 | 정리 기준 |
| --- | --- | --- |
| 앱 | 테마·언어, 공용 클라이언트/DB | 앱/소유 Scope 종료 |
| 세션 | 개인 데이터, 권한, 구독 | 로그아웃·계정 전환·세션 만료 |
| 화면/작업 | 검색, 상세, OCR | 마지막 구독 해제·작업 완료 |

- 수동 선언 Provider는 `.autoDispose` 여부를 직접 정한다. 코드 생성 방식의 기본값과 혼동하지 않는다.
- autoDispose는 '다른 화면을 열면 즉시 해제'가 아니다. IndexedStack의 숨은 탭이나 다른 구독자가 상태를 유지할 수 있다.
- HTTP client, socket, subscription, timer, recognizer의 소유자를 하나로 정한다. 공유 객체를 한 화면이 임의 close하지 않는다.
- `onDispose`는 정리용이다. 여기서 다른 Provider 변경·라우팅 같은 업무 부작용을 실행하지 않는다.
- 종료 콜백이 비동기 정리 완료를 보장한다고 가정하지 않는다. 순서가 중요한 logout/세션 정리는 명시적으로 await하는 작업으로 구현한다.
- 플러그인 작업이 취소 불가능하면 완료 결과를 무시하되 자원은 안전한 시점에 정리한다. OCR은 현재 DataSource의 작업 완료 후 finally에서 recognizer를 닫는다.

근거: [Riverpod 2 Provider 읽기](https://docs-v2.riverpod.dev/docs/concepts/reading), [수명과 정리](https://docs-v2.riverpod.dev/docs/essentials/auto_dispose). 최신 메이저 API를 적용하기 전 별도로 호환성을 확인한다.

## 4. 비동기·실패·세션 안전성

### UI 생명주기와 작업 유효성

```dart
// 위젯 콜백 안에서 기존 Notifier의 로그아웃 작업 호출 예시.
// 오류 정책은 호출된 작업 계약에서 정의하고 이 예시와 별도로 테스트한다.
final loginNotifier = ref.read(loginProvider.notifier);
await loginNotifier.logout();
if (!context.mounted) return;
context.go(AppRoute.login.path);
```

- await 뒤 BuildContext 접근 전 mounted를 확인한다. StateNotifier의 상태 반영 전에는 해당 notifier의 mounted를 확인한다. [Flutter API](https://api.flutter.dev/flutter/widgets/BuildContext/mounted.html)
- mounted는 계정·검색어가 여전히 같은지 증명하지 않는다. 요청 ID/세션 세대값을 시작 시 캡처하고 결과 반영·캐시 저장 전에 확인한다.
- Riverpod 2의 모든 Ref에 Riverpod 3 `ref.mounted`를 적용하지 않는다. 해당 객체에서 지원되는 수명 API 또는 dispose 플래그를 사용한다.
- 로딩·진행 중 플래그는 실패에서도 해제한다. `finally`에도 소유자/요청 유효성 검사가 필요하며 이전 작업이 새 작업의 로딩을 해제하지 않게 한다.
- 연타는 UI 비활성화와 실행부 in-flight guard를 함께 적용한다. 이것은 서버의 멱등성·DB 제약을 대체하지 않는다.
- 결과 확인이 필요한 작업은 await한다. 의도적인 fire-and-forget은 오류 처리·소유 수명·실패 정책을 정의한다.

### 실패 계약

- 실패할 수 있는 Repository 비동기 작업은 기본적으로 `Either<Failure, T>`를 사용한다. 기존 다른 반환 타입을 바꿀 때는 모든 호출부·테스트까지 함께 이행한다.
- 통신 실패, 응답 오류, 취소, 로컬 저장 실패, 권한 거부를 구분한다. 모든 예외를 ServerFailure 또는 '오프라인'으로 만들지 않는다.
- 취소는 정상적인 사용자 행동일 수 있다. OCR 선택 취소의 Right(null)처럼 기능 계약에 명시한다.
- 실패 코드와 진단 정보는 사용자 문구와 분리한다. UI는 ARB에서 문구를 선택하며 raw exception·서버 내부 메시지를 그대로 노출하지 않는다.
- 401/403/429/5xx의 UI·재시도 정책을 구분한다. 연결 실패만으로 토큰을 지우거나 로그아웃하지 않는다.

### 인증과 로그아웃 목표 계약

- 현재 DioNetwork는 Authorization 주입·401 갱신 경로가 있다. 큐 인터셉터만으로 단일 refresh·무한 재시도 방지·세션 격리가 보장되지는 않는다.
- 목표는 동시 401의 refresh 결과 공유, 이미 갱신된 토큰 재사용, 한 요청의 재전송 상한, refresh 자체 재귀 금지다. 자격증명 없는 로그인 실패를 refresh로 처리하지 않는다.
- refresh token 회전이 서버 계약에 포함되면 두 토큰을 일관되게 저장한다. 과거 세션의 refresh 결과가 새 세션을 덮어쓰지 않게 한다.
- 세션 종료는 개인 캐시·메모리·구독·기기 토큰 연결·진행 요청을 조정하는 한 경로에서 처리한다. 서버 통신 실패와 로컬 로그아웃 성공을 구분해 복구 정책을 정의한다.
- FCM 연결 해제는 인증이 필요한 서버 계약이면 자격증명 폐기 전에 시도한다. 실패했다고 로컬 로그아웃을 무한히 막지 않으며, 이전 계정의 인증 자격증명을 보관해 재시도하지 않는다. FCM 기기 토큰과 로그인 Access/Refresh Token은 다른 값이다. 재로그인 시 기기 소유권 재등록과 서버 유효성 정책을 함께 검증한다.
- 분석 이벤트 실패가 로그인/로그아웃의 사용자 결과를 뒤집지 않게 한다. 계정 변경 때 관찰·캐시 범위를 교체한다.

위 항목은 검증할 목표 계약이다. 현재 구현이 모두 충족한다고 취급하지 않는다.

## 5. 설정 메뉴 등 구성형 화면의 기준

아래는 설정 리팩토링 적용 기준이다. 현재 문자열 라벨 기반 분기를 유지하라는 규칙이 아니다.

### 메뉴 계약

설정 구현 위치:

| 책임 | 파일 |
| --- | --- |
| 메뉴 ID·UI 메타데이터 | `lib/src/features/settings/presentation/models/settings_menu.dart` |
| 공통 메뉴·노출 조합 | `lib/src/features/settings/presentation/config/settings_sections.dart` |
| 순수 메뉴 UI·설정값 구독 | `setting_section_widget.dart`, `setting_item_widget.dart`, `settings_menu_tile.dart` |
| 사진 선택·업로드·로그아웃 조정 | `presentation/providers/settings_actions_notifier.dart`, `settings_actions_provider.dart` |
| 저장값 초기화·직렬 저장 | `lib/src/core/preferences/persisted_preference_notifier.dart` |
| 설정 단위·위젯·이동 테스트 | `test/features/settings/` |

위젯·Provider의 축약 경로는 `lib/src/features/settings/` 아래다. 미구현 알림 설정·차단·지원 메뉴는 준비 중으로 표시하며 고정된 '켜짐' 값은 표시하지 않는다. 설정 진입/프로필 이미지 오류로 인증 복원을 실행하지 않는다. 앱 버전의 고정 문자열은 표시하지 않으며, 실제 빌드 메타데이터 노출은 별도 연결 대상이다.

검증 명령: `flutter test test/features/settings`, `flutter test test/features`. OS 권한 복귀·실제 사진 업로드·FCM·실기기 성능 검증은 Fake 기반 테스트와 별도다.

- 안정적인 enum ID로 메뉴를 식별한다. 표시 문구·이모지·목록 index를 기능 식별자로 사용하지 않는다.
- UI 전용 메뉴 정의는 Presentation에 둔다. 번역과 Flutter 아이콘은 UI에서 해석한다.
- 공통 메뉴는 한 번 정의하고 로그인·권한·지원 플랫폼에 맞게 섹션을 조합한다. 필터 후 빈 섹션·구분선을 제거한다.
- 노출 조건과 클릭 가능 조건을 구분한다. 서버 권한은 API에서 다시 검증한다. 숨긴 메뉴나 role 문자열은 보안 경계가 아니다.
- 공통 Row/Section 위젯은 표시 데이터·enabled·callback을 받는다. 내부에 기능별 라우팅·서비스 호출·한국어 비교를 누적하지 않는다.
- 이동·다이얼로그 선택은 화면 또는 Presentation의 명시적 action handler에서 처리한다. 모든 메뉴를 수용하는 전역 서비스 로케이터를 만들지 않는다.
- 새 메뉴는 ID·번역·행동·노출 조건·테스트를 함께 추가한다. 동작 없는 빈 메뉴는 만들지 않는다. 미구현 기능은 숨기거나 비활성 이유를 제공한다.

### 설정 화면 구성 기준

| 섹션 | 후보 메뉴 | 노출 기준 |
| --- | --- | --- |
| 내 활동 | 내 댓글, 채팅, 출석, 알림 목록 | 로그인 |
| 도구 | OCR, Bluetooth | OCR은 현재 요구대로 로그인, 나머지는 기존 정책과 플랫폼 확인 |
| 앱 설정·보안 | 언어, 화면 모드, 알림 설정, 앱 잠금 | 공통 설정과 로그인 필요 항목을 구분 |
| 지원 | 공지, 문의, 약관 | 실제 동작이 있는 항목 |
| 관리자 | 관리자 웹뷰, 서버 상태 | 관리자 표시 + 서버 인가 |

재분류와 권한 확대는 별개다. 이동만 하는 단계에서 기존 노출 정책을 임의 변경하지 않는다. 로그아웃은 로그인 상태의 계정 액션으로 분리한다. OCR은 하단 탭이 아닌 설정에서 여는 독립 화면으로 유지한다.

### 설정값의 원본과 저장

- 언어와 테마는 기존 localeProvider/themeModeProvider를 구독한다. 선택한 ThemeMode.system과 실제 OS 밝기는 다른 값이다.
- 알림은 앱의 수신 선호·OS 권한·서버 기기 등록을 구분한다. FCM 토큰 존재만으로 '켜짐'을 표시하지 않는다. 상태 조회 중/실패를 임의의 on/off로 치환하지 않는다.
- OS 설정에서 돌아올 때 필요한 권한 상태만 재조회한다. 화면 rebuild마다 권한 팝업·토큰 등록·전체 API 요청을 실행하지 않는다.
- 기기 공통 설정과 계정별 설정의 저장 범위를 명시한다. 언어·테마의 기존 기기 저장 정책을 리팩토링만으로 바꾸지 않는다. 앱 잠금 등 계정별 값은 계정 전환에 맞춰 정리한다.
- 비밀이 아닌 UI 설정만 preferences에 저장한다. 토큰·비밀은 안전한 저장소와 서버 인증 정책을 사용한다.
- 초기 저장값 로드와 빠른 사용자 변경이 경합하지 않게 한다. 로드 완료 전에 편집을 막거나 요청 순서/세대값으로 늦은 초기값을 무시한다.
- 저장 순서가 역전되지 않도록 변경을 직렬화하거나 최신 의도 우선 정책을 설계한다. 저장 실패 시 rollback/재시도 안내와 UI 상태를 일치시킨다.
- 앱 버전은 패키지 빌드 메타데이터 또는 배포 과정의 단일 원본을 사용한다. 별도 상수에 같은 버전을 중복 입력하지 않는다.

### 리팩토링 순서와 회귀 기준

1. 메뉴·노출·이동·저장 정책을 표로 기록하고 기존 동작을 테스트로 고정한다.
2. enum ID와 UI 모델을 추가해 문자열 분기를 교체한다. 이 단계에서는 분류·권한·동작을 동시에 바꾸지 않는다.
3. 공통 섹션 조합과 순수 UI 위젯을 분리하고 빈 항목을 제거한다.
4. ARB·실제 설정값 구독을 연결한다. 현재 저장 키·기본값·재시작 후 복원을 유지한다.
5. 프로필 업로드·로그아웃은 기존 서비스 계약을 재사용해 실행 상태/오류를 분리한다. 전체 인증 구조의 일괄 교체는 별도 작업으로 한다.
6. 승인된 메뉴 분류를 적용하고 로그인/권한별 동작·뒤로 가기·다국어·성능을 검증한다.

- 단위: 메뉴 ID 중복 없음, 공통 메뉴 중복 없음, 노출/클릭 정책, 저장 실패·역전 방어.
- 위젯: 비로그인/일반/관리자 메뉴, OCR 단일 이동, 테마·언어 즉시 반영, 비활성 이유, 200% 글자와 긴 번역.
- 통합: 복원 중 조작, 프로필 요청 중 로그아웃, 다른 계정 전환, OS 권한 변경 후 복귀, OCR 진입·복귀.
- 요청: 테마·언어 변경과 순수 rebuild로 /me·FCM·refresh가 추가 호출되지 않음. 필요한 최신화 트리거와 허용 호출 수를 테스트에 명시한다.
- 프로필 사진 실패는 placeholder와 제한된 이미지 재시도로 처리한다. 이미지 오류마다 restoreSession을 호출해 인증·/me 요청이 반복되거나 로그인 상태가 바뀌지 않게 한다.
- 한 단계씩 analyze·테스트를 통과시킨다. 화면만 같은 것을 기능·정합성 동일로 판단하지 않는다.

## 6. 다국어·접근성·반응형

- 사용자 문구는 ARB에서 관리한다. 런타임 언어에 따라 build에서 해석하며 번역된 메뉴 목록을 전역 static 값으로 캐시하지 않는다.
- 숫자·날짜·복수형·변수 포함 문장은 placeholder/locale 형식을 사용한다. 문장 조각을 이어 번역하지 않는다.
- 기본 한국어와 저장된 언어 복원은 현재 정책을 유지한다. 지원하지 않는 저장 locale은 명시적인 fallback을 적용한다.
- 테마는 ColorScheme/TextTheme를 사용한다. 배경·텍스트 색을 각각 고정해 다크 모드 대비를 깨지 않는다.
- 메뉴 행은 ListTile 또는 Material/InkWell 등 포커스·버튼 의미·눌림 피드백을 제공하는 구성으로 만든다. 장식 아이콘과 접근성 레이블을 구분한다.
- 텍스트·터치 영역을 화면 비율로 축소하지 않는다. 긴 값에는 Flexible/Expanded/Wrap, 충분한 최소 높이와 스크롤을 제공한다.
- 큰 화면은 MaxWidthContainer, 구조 전환은 ResponsiveLayout을 사용한다. 단순 설정 목록에 복잡한 반응형 분기를 과도하게 추가하지 않는다.
- DefaultLayout은 본문 SafeArea를 자동 제공하지 않는다. AppBar 유무와 부모 Shell의 안전 영역을 확인해 중복 여백을 피한다.
- 검증: 360px 내외, 실제 breakpoint 전후, 200% 글자, 한국어/영어, 밝음/어두움, 키보드 포커스·스크린리더.

근거: [Flutter 국제화](https://docs.flutter.dev/ui/internationalization). ARB 생성 명령은 `flutter gen-l10n`이다.

## 7. 라우팅·잠금·플랫폼

- MaterialApp.router는 `lib/main.dart`, 탭 표현은 LoopAppShell, 경로 정의는 router_path.dart/router.dart의 역할을 유지한다.
- 테마·언어·프로필 일부 변경 때문에 GoRouter나 NavigatorKey를 매번 재생성하지 않는다. 인증 갱신은 수명 안정적인 라우터의 재평가 방식으로 설계한다.
- 라우터를 Provider에서 생성했다면 소유 Provider가 dispose 시 라우터와 인증 재평가용 listener도 정리한다. 새 라우터 생성과 기존 listener 해제를 서로 다른 화면에 흩어 놓지 않는다.
- 각 StatefulShellBranch는 고유 NavigatorKey를 가진다. 탭 개수·순서와 NavigationBar/NavigationRail 항목을 일치시킨다.
- `push`는 기존 화면으로 돌아갈 상세/도구 화면, `go`는 위치·스택 교체가 필요한 흐름에 사용한다. 루트/Branch Navigator 선택과 뒤로 가기를 테스트한다.
- 메뉴 숨김은 직접 URL·딥링크 접근을 차단하지 않는다. 보호 경로는 세션 복원 중/실패/로그아웃/권한 없음의 동작을 별도로 정한다. 현재 전체 라우터에 공통 인증 가드가 구현됐다고 가정하지 않는다.
- 앱 잠금은 인증 세션과 다르다. 로그인 상태여도 잠긴 화면·알림 이동·다이얼로그에서 보호 데이터를 노출하지 않는다.
- IndexedStack은 화면을 보존하므로 탭 전환과 dispose는 같지 않다. 구독 정리·백그라운드 정책은 명시한다. [StatefulShellRoute](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html)
- native SDK 지원은 Android/iOS/macOS/Web별로 확인한다. 메뉴·직접 진입·실행부에서 안전한 미지원 처리를 제공한다.

## 8. 네트워크·캐시·대규모 사용

전체 시나리오·부하 절차·SLO는 [성능 가이드](docs/APP_PERFORMANCE_GUIDE.md)가 담당한다. 여기서는 구현 시 지켜야 할 경계를 정의한다.

- 사용자 수 증가는 서버 부하이고, 한 기기의 데이터량·이미지·rebuild는 클라이언트 부하다. 별도로 측정하고 통합 시나리오로 연결한다.
- 요청 식별에는 계정/권한 범위·쿼리·cursor를 포함한다. 진행 중 동일 읽기를 합쳐도 다른 계정 결과를 공유하지 않는다.
- 취소와 타임아웃은 서버 작업 취소/rollback을 의미하지 않는다. 쓰기 자동 재시도에는 서버 멱등 계약이 필요하다.
- 자동 재시도는 한 계층에서 횟수·총 기한·backoff·jitter를 관리한다. 인터셉터와 Notifier의 중첩 재시도를 피한다.
- 병렬 요청·업로드·사전 로드·이미지 캐시·리스트 누적·이벤트 버퍼에는 상한이 필요하다. 무제한 Future.wait·재연결·전체 invalidate를 기본값으로 두지 않는다.
- 캐시는 공개/개인 데이터, TTL, 최대 크기, 삭제·수정·로그아웃 정책을 명시한다. 디스크 200행 제한은 화면 메모리 제한이 아니다.
- 원격 기능 플래그는 점진 배포·중단에 사용할 수 있지만 권한 검증을 대체하지 않는다. 플래그 서버 장애 시 기본값과 보존기간을 정한다.
- 호환성은 구버전 앱까지 포함한다. API 응답 필드/enum 추가, 필드 제거, 로컬 DB 변경 시 fallback·마이그레이션·복구를 검증한다.

### 커서 페이지네이션

현재 공통 구현:

```text
lib/src/shared/domain/models/cursor_paginated_response.dart
lib/src/shared/presentation/providers/cursor_pagination_state.dart
lib/src/shared/presentation/providers/cursor_pagination_notifier.dart
lib/src/shared/presentation/widgets/cursor_paginated_list_view.dart
```

- 서버 계약은 items/nextCursor/hasNext다. 임의의 page/totalPages 모델로 교체하지 않는다.
- 같은 cursor의 중복 조회 방지, 검색 세대 분리, 추가 로딩 실패 시 기존 목록 유지, ID 기준 중복 병합을 검증한다.
- 캐시 전용 표시에서는 서버 cursor를 합성하지 않는다. 기존 PostListNotifier의 캐시·세션 방어를 확인하고 공통 load 흐름에 억지로 합치지 않는다.

## 9. 프레임·CPU·자원

- 앱 상태는 하나의 거대한 Provider에 모으지 않는다. 불변 데이터와 작은 구독으로 변경 범위를 제한하고 DevTools로 확인한다.
- 정렬·JSON 파싱·압축이 CPU 병목일 때 isolate를 검토한다. await는 CPU 작업을 병렬화하지 않는다. HTTP I/O만 분리하거나 작은 메뉴 조합에 isolate를 추가하지 않는다.
- compute 콜백은 전달 가능한 데이터/객체 조건을 만족해야 한다. top-level/static 함수는 캡처를 줄이는 권장 형태이지 모든 클로저의 문법적 금지는 아니다. Web compute는 별도 isolate 병렬 실행을 보장하지 않는다. [Flutter compute](https://api.flutter.dev/flutter/foundation/compute.html)
- 이미지 메모리는 압축 파일 크기와 다르다. 썸네일·cacheWidth 등 표시 해상도를 제한하고 OCR 입력 원본과 미리보기를 분리한다.
- ListView.builder/sliver로 긴 목록을 지연 생성한다. RepaintBoundary·blur 제거·스켈레톤 추가는 측정 근거가 있을 때 적용한다.
- Stream 이벤트가 UI보다 빠르면 최신 상태 병합·버퍼 상한·일괄 반영을 설계한다. 채팅 메시지처럼 유실 불가한 데이터는 서버 재조회/순서 계약으로 복구한다.
- socket/SSE는 재연결 jitter·상한과 구독 중복 방지를 갖추고 백그라운드·세션 종료 정책을 정의한다.
- 로딩·오류 개선이 인증·잠금·데이터 정합성을 우회하는 수단이 되어서는 안 된다.

## 10. 보안·관찰

- 앱 asset의 `.env`와 앱에 포함된 키는 비밀 저장소가 아니다. DB/AWS/OpenAI 서버 비밀키를 앱에 넣지 않는다. 환경변수는 주소·공개 설정 분리에 사용한다.
- 운영 통신은 HTTPS/WSS를 사용하고 WebView origin·JS bridge 입력·토큰 전달 경계를 검증한다. 화면 숨김이나 생체 잠금은 서버 인가를 대체하지 않는다.
- 로그에는 토큰·쿠키·인증 헤더·본문·OCR 원문·사진 경로·개인정보를 남기지 않는다. 개발 로그도 안전한 필드 허용 목록을 기준으로 한다.
- trace ID는 요청 추적, 멱등 키는 중복 쓰기 제어다. 계정/게시글 ID를 metric label로 무제한 사용하지 않는다.
- 오류 수집·analytics는 비용·샘플링·보존기간·동의 정책을 정한다. 관찰 기능의 실패가 사용자 작업을 실패로 바꾸지 않게 한다.

## 11. 테스트·CI·배포 기준

### 새 기능과 리팩토링 순서

1. 목표·비목표·기존 동작·노출/권한·반환 계약을 정의한다.
2. 수명·실패·계정 변경·저장 범위·요청 예산을 정의한다.
3. 필요한 모델/계약 → DataSource/Repository → UseCase(필요 시) → Provider/Notifier → UI/라우트 순으로 작은 단위로 구현한다. 메뉴 재구성만이라면 불필요한 Data/Domain을 만들지 않는다.
4. 단위/위젯/통합 테스트로 성공뿐 아니라 취소·부분 실패·늦은 완료를 검증한다.
5. 실기기 profile 기준선과 동일 조건으로 비교하고 작은 범위로 배포한다. 운영 관찰과 중단·복구 조건을 정한다.

### 자동화 목표

- Fake Repository/플러그인 wrapper로 네트워크·플랫폼 없이 로직을 검증한다. Mockito 등은 의존성·생성 설정이 있을 때만 사용한다.
- ProviderContainer와 유지용 구독은 테스트 종료에 정리한다. autoDispose 테스트는 필요한 동안 구독을 유지한다.
- 기존 `test/features/post/`, `test/features/app_lock/` 회귀 테스트를 보존한다. 문서의 신규 시나리오는 실제 테스트 파일이 존재할 때만 완료로 표시한다.
- 의존성 재현은 앱 lockfile과 고정 SDK를 사용한다. 생성 파일이 Git에서 제외되므로 fresh checkout에서 생성·분석·테스트가 가능해야 한다.
- 네이티브 빌드 설정·의존성 잠금·권한·모델 의존성은 서명 비밀과 분리해 소스 관리 대상을 검토한다. 현재 `.gitignore`는 `ios/Podfile`, `ios/Podfile.lock`도 제외하므로 한국어 OCR 모델 설정 등이 새 체크아웃에 재현되는지 별도 확인해야 한다. 현재 추적 정책이 Android/iOS 빌드 재현성을 충족한다고 가정하지 않는다. 추적 정책·네이티브 파일 수정은 구현 작업에서 승인된 범위로 처리한다.

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter analyze --no-pub
flutter test
```

- 생성 명령은 소스 생성물을 덮어쓸 수 있으므로 실행 전 Git 상태를 확인한다. 포맷 검사와 Android 빌드, macOS 러너의 iOS 빌드를 PR 정책에 맞게 추가한다.
- CI는 실제 workflow 파일 존재·실행 결과로 확인한다. 위 명령 목록은 구성 기준이며 현재 CI 가동 증거가 아니다.
- CD는 서명·환경 분리·내부 테스트 배포·점진 배포·관찰 기준을 갖춘 후 활성화한다. 앱 스토어 배포는 서버처럼 즉시 전체 rollback되지 않으므로 구버전 API 호환과 기능 중단 전략이 필요하다.
- Keystore·인증서·서비스 계정·환경 비밀은 CI secret으로 관리한다. 일반 workflow 로그·아티팩트에 포함하지 않는다.
- DB/캐시 스키마·저장 키 변경은 이전 앱 데이터로 업그레이드 테스트한다. 단순 코드 revert가 데이터 rollback을 보장하지 않는다.

### 완료 기준

- 기능·권한·수명·실패·접근성 테스트 통과.
- 변경 범위의 정적 분석과 기존 회귀 테스트 통과.
- 사용자 데이터 유실·다른 계정 노출·중복 쓰기 없음.
- 성능 변경은 환경·원본 측정·정상 응답률·오류/복구 자료를 함께 제출.
- 구현, 자동 테스트, 실기기 확인, 부하 검증을 각각 구분해 기록. 미검증 항목은 남겨 둔다.

## 12. 문서와 커밋

- 기능 설계와 측정 결과를 구분한다. 문서에는 기준·계약·현재 확인 사항·미검증 범위를 쓰고 구현하지 않은 기능을 완료로 표현하지 않는다.
- 다른 문서에 같은 상세 규칙을 복제하지 않고 해당 문서로 연결한다. 파일명·경로는 실제 저장소와 일치시킨다.
- `feat` / `fix` / `refactor` / `style` / `docs` / `test` / `chore`로 변경 의도를 구분한다.
- 문서만 변경한 작업은 `docs`를 사용한다. 설계 변경과 앱 동작 변경을 같은 완료 문장으로 묶지 않는다.

## 참고

- [Flutter 아키텍처 권장사항](https://docs.flutter.dev/app-architecture/recommendations): 책임 분리·불변 모델·조건부 Domain 적용의 참고. 이 프로젝트의 Riverpod 구조를 다른 상태 관리 패키지로 교체하라는 지침이 아니다.
- [Flutter 성능 모범 사례](https://docs.flutter.dev/perf/best-practices)
- [Flutter isolate 가이드](https://docs.flutter.dev/perf/isolates)
- 패키지별 링크의 API는 설치 버전과 대조한다. 문서의 선택 사항은 목적·검증 없이 자동 도입하지 않는다.
