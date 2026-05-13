# CLAUDE.md

Flutter Clean Architecture + Riverpod 기반 멀티플랫폼 앱 초기 세팅 템플릿.

**핵심 스택**: Flutter 3.x / flutter_riverpod / go_router / Dio / fpdart / freezed / freezed_annotation / flutter_secure_storage / shared_preferences / cached_network_image

---

## 새 기능 추가 순서

```
1. domain/models/           → 모델 (Freezed + json_serializable)
2. domain/repositories/     → abstract Repository 인터페이스
3. data/data_sources/       → API, 로컬 저장소 래퍼
4. data/repositories/       → Repository 구현체
5. <feature>_providers.dart → Provider 정의 + 의존성 등록
6. presentation/pages|widgets/
7. route_paths.dart + router.dart → 라우트 등록
```

---

## 레이어별 작성 규칙

### Domain — 모델

```dart
part 'some_model.freezed.dart'; // build_runner 생성 — 직접 수정 금지
part 'some_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required int id,
    @JsonKey(name: 'user_email') required String email,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
```

요청 모델도 동일하게 Freezed로 작성하고, 서버로 다시 보낼 일이 없으면 `toJson` 호출만 하지 않으면 된다.

코드 생성: `dart run build_runner build --delete-conflicting-outputs`
`.freezed.dart`, `.g.dart` 파일은 git에 커밋.

### Domain — Repository 인터페이스

```dart
// abstract_<feature>_repository.dart
abstract class AbstractAuthRepository {
  Future<Either<Failure, UserModel>> login(LoginRequestModel request);
  Future<void> logout();
}
```

### Data — Repository 구현체

```dart
@override
Future<Either<Failure, UserModel>> login(LoginRequestModel request) async {
  try {
    final res = await _api.postLogin(request.toJson());
    final data = res.data;
    if (data == null) return const Left(ServerFailure('응답 없음', 500));

    // 로그인 응답(LoginResponseModel)에 id/email이 포함된 경우 getMe() 호출 불필요
    final parsed = LoginResponseModel.fromJson(data);
    await _secureStorage.saveTokens(
      accessToken: parsed.accessToken,
      refreshToken: parsed.refreshToken,
      email: parsed.email,
    );
    return Right(UserModel(id: parsed.id, email: parsed.email));
  } on DioException catch (e) {
    return Left(ServerFailure(extractDioErrorMessage(e), e.response?.statusCode));
  } catch (e) {
    return Left(ServerFailure(e.toString(), null));
  }
}

// 서버가 로그인 응답에 유저 정보를 충분히 담지 않는 경우 → 토큰 저장 후 getMe() 별도 호출
```

### Presentation — Provider + State

```dart
// <feature>_providers.dart
// 1. 간단한 상태: StateNotifier 사용
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier(this._repository) : super(AuthInitial());
  final AbstractAuthRepository _repository;

  Future<void> login(String email, String password) async {
    state = AuthLoading();
    final result = await _repository.login(LoginRequestModel(email: email, password: password));
    state = result.match(
      (failure) => AuthError(failure.errorMessage),
      (user)    => AuthAuthenticated(user),
    );
  }
}

final authProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.watch(authRepositoryProvider));
});

// 2. 복잡한 비동기 작업: AsyncNotifier 사용
class UserAsyncNotifier extends AsyncNotifier<UserModel> {
  @override
  Future<UserModel> build() async {
    // 초기 로드 로직
    final repo = ref.watch(authRepositoryProvider);
    final result = await repo.getMe();
    return result.fold(
      (failure) => throw Exception(failure.errorMessage),
      (user) => user,
    );
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    final repo = ref.watch(authRepositoryProvider);
    final result = await repo.updateProfile(updatedUser);
    state = result.fold(
      (failure) => AsyncValue.error(failure.errorMessage, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }
}

final userProvider = AsyncNotifierProvider<UserAsyncNotifier, UserModel>((ref) {
  return UserAsyncNotifier();
});

// <feature>_state.dart
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.loggingOut() = AuthLoggingOut; // 로그아웃 중 — redirect와 구분 필요
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.authenticated(UserModel user) = AuthAuthenticated;
  const factory AuthState.error(String message) = AuthError;
}
```

### Dependency Injection — Riverpod 방식

```dart
// <feature>_providers.dart
// 1. Repository 등록
final authRepositoryProvider = Provider<AbstractAuthRepository>((ref) {
  final api = ref.watch(authApiProvider);
  final storage = ref.watch(authSecureStorageProvider);
  return AuthRepositoryImpl(api, storage);
});

// 2. API 클라이언트
final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthApi(dio);
});

// 3. 로컬 저장소
final authSecureStorageProvider = Provider<AuthSecureStorage>((ref) {
  return AuthSecureStorage();
});

// core/providers.dart 에서 공용 provider 정의
final dioProvider = Provider<Dio>((ref) {
  return DioNetwork.appAPI;
});
```

---

## 핵심 규칙

### 1. 에러 처리 — Either 패턴

Repository 반환은 항상 `Either<Failure, T>`. StateNotifier/AsyncNotifier에서 `result.match(left, right)`로 처리.
`❌` null 강제 언래핑(`user!`), 레코드 타입 혼용 금지.

### 2. UseCase — 단순 CRUD는 생략

StateNotifier → Repository 직접 호출. UseCase는 **여러 Repository 조합** 또는 **복잡한 비즈니스 로직**일 때만.

### 3. Provider 선언 순서

```dart
// ✅ 의존성 역순으로 선언 (하단부터 상단으로 사용 가능)
final repositoryProvider = Provider((ref) => ...(ref.watch(apiProvider)));
final apiProvider = Provider((ref) => ...(ref.watch(dioProvider)));
final dioProvider = Provider((ref) => DioNetwork.appAPI);
```

### 4. ref.watch vs ref.read

```dart
// ✅ ref.watch: rebuild 시 의존성 추적 (대부분 이것 사용)
final state = ref.watch(userProvider);

// ✅ ref.read: 현재 값만 가져오기 (이벤트 처리 시)
Future<void> updateUser() async {
  final repo = ref.read(authRepositoryProvider);
  await repo.updateProfile(...);
}

// ❌ build() 메서드 안에서 ref.read 사용 금지 — watch 사용 필수
// ❌ 콜백/타이머 안에서 ref.watch 사용 금지 — read 사용 필수
```

### 5. 401 갱신 — Interceptor에서 처리

`DioNetwork.QueuedInterceptor`가 401 → refresh → 재시도 자동 처리.
StateNotifier는 최종 실패 시 logout만 처리. StateNotifier에서 별도 refresh 호출 시 **race condition 발생**.

### 6. 타입 캐스팅 — 방어적으로

```dart
// ✅
final token = data is Map<String, dynamic> ? data['accessToken'] as String? : null;
if (token == null) return Left(const ServerFailure('응답 오류', 500));

// ❌
final token = res.data!['accessToken'] as String; // 크래시 위험
```

### 7. 상수 — k prefix 필수

```dart
const String kAccessTokenKey = 'auth_access_token'; // ✅
const String accessToken = 'auth_access_token';     // ❌
```

### 8. Consumer 우선 사용 — 필요한 값만 구독

```dart
// ✅ 필요한 provider만 watch
Consumer(
  builder: (context, ref, child) {
    final user = ref.watch(userProvider);
    return UserProfile(user: user);
  },
)

// ✅ 여러 개 필요할 때
Consumer(
  builder: (context, ref, child) {
    final user = ref.watch(userProvider);
    final isLoggingOut = ref.watch(authProvider);
    return Stack(...);
  },
)

// ❌ Consumer 대신 전체 state 구독하는 방식 (rebuild 과다)
```

### 9. 상태 변경 모니터링 — ref.listen

```dart
// ✅ 특정 값 변경 시 부작용 처리
ref.listen(userProvider, (previous, next) {
  if (next is AsyncData) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(text: '프로필 업데이트됨'));
  }
});

// ref.listen은 build() 메서드 안에서만 사용 가능 (Consumer 사용 권장)
```

### 10. async/await 후 context 사용

```dart
// ✅ 연산 후 ref 사용
final ref = ref.read(authRepositoryProvider);
await ref.updateProfile(...);
ref.read(authProvider.notifier).logout(); // StateNotifier 메서드 호출

// ❌ await 후 context로 다른 provider 접근 (에러 발생 가능)
await ref.update();
context.go('/login'); // context는 widget 생명주기와 별개
```

## AppShell (Router 초기화)

```dart
// lib/loop_app_shell.dart
class LoopAppShell extends ConsumerWidget {
  const LoopAppShell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 앱 초기화: 토큰 복원, 사용자 정보 로드 등
    final authState = ref.watch(authProvider); // StateNotifier 상태 구독
    final router = ref.watch(routerProvider);  // go_router 인스턴스

    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
    );
  }
}

// main.dart
void main() async {
  WidgetsBinding.instance.deferFirstFrame();
  await initializeApp();
  runApp(const ProviderScope(child: LoopAppShell()));
}

// 인증 상태 기반 라우터
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomePage(),
        redirect: (context, state) {
          if (authState is! AuthAuthenticated) return '/login';
          return null; // 이동 진행
        },
      ),
    ],
    redirect: (context, state) {
      // 로그인 중 또는 초기화 중 redirect 처리
      if (authState is AuthLoading || authState is AuthInitial) return '/loading';
      if (authState is AuthUnauthenticated && state.matchedLocation != '/login') return '/login';
      return null;
    },
  );
});
```

---

## DefaultLayout 사용법

```dart
// AppBar 없음 → child에서 SafeArea 직접 처리
DefaultLayout(child: SafeArea(child: MyContent()))

// AppBar 있음 → 하단만 SafeArea
DefaultLayout(appBarTitle: 'Title', child: SafeArea(top: false, child: MyContent()))
```

> DefaultLayout 내부에 SafeArea 없음. child에서 직접 처리 필수.

---

## 공용 위젯

```dart
AppEmailField(controller: _emailController)   // 기본 이메일 validator 내장

AppPasswordField(
  controller: _passwordController,
  obscure: _obscurePassword,
  onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
)

AppNetworkImage(url: user.profileUrl)                          // 직사각형
AppNetworkImage(url: user.profileUrl, isCircle: true, size: 48) // 원형 아바타
// 캐시 설정: core/utils/app_cache_manager.dart (유효기간 7일, 최대 200개)

// 스켈레톤 UI (shimmer: ^3.0.0 추가 후)
AppShimmer(child: SkeletonBox(width: 200, height: 20))          // shimmer 래퍼 + 단위 박스
// AppShimmer는 하나만 감싸고 내부에 SkeletonBox 여러 개 배치 (중첩 금지 — 애니메이션 충돌)
// 스켈레톤 위젯명: _XxxSkeleton (private, 해당 파일 전용)
```

## 제네릭 페이지네이션

### 구조

```
shared/domain/entities/paginated_response.dart   — PaginatedResponse<T> (서버 응답 모델)
shared/presentation/providers/
  pagination_state.dart                          — PaginationState<T> (sealed class)
  pagination_notifier.dart                       — PaginationNotifier<T> (추상 AsyncNotifier)
shared/presentation/widgets/
  paginated_list_view.dart                       — PaginatedListView<T> (무한 스크롤 위젯)
```

### 피쳐에서 사용하는 법

```dart
// 1. Repository: Either<Failure, PaginatedResponse<T>> 반환
abstract class AbstractPostRepository {
  Future<Either<Failure, PaginatedResponse<PostModel>>> getPosts({required int page});
}

// 2. AsyncNotifier: PaginationNotifier<T> 상속 + fetchPage만 구현
class PostListNotifier extends PaginationNotifier<PostModel> {
  final AbstractPostRepository _repository;
  PostListNotifier(this._repository);

  @override
  Future<Either<Failure, PaginatedResponse<PostModel>>> fetchPage(int page) {
    return _repository.getPosts(page: page);
  }
}

final postListProvider = AsyncNotifierProvider<PostListNotifier, PaginationState<PostModel>>((ref) {
  return PostListNotifier(ref.watch(postRepositoryProvider));
});

// 3. Repository 구현체: PaginatedResponse.fromJson으로 파싱
@override
Future<Either<Failure, PaginatedResponse<PostModel>>> getPosts({required int page}) async {
  try {
    final res = await _api.getPosts(page: page);
    final data = res.data;
    if (data == null) return const Left(ServerFailure('응답 없음', 500));
    return Right(PaginatedResponse.fromJson(
      json: data,
      itemParser: (e) => PostModel.fromJson(e),
    ));
  } on DioException catch (e) {
    return Left(ServerFailure(extractDioErrorMessage(e), e.response?.statusCode));
  }
}

// 4. 위젯: Consumer + PaginatedListView
Consumer(
  builder: (context, ref, child) {
    final paginationState = ref.watch(postListProvider);
    return paginationState.when(
      loading: () => const PostListSkeleton(),
      error: (error, _) => Center(child: Text('오류: $error')),
      data: (state) => PaginatedListView<PostModel>(
        items: state.items,
        hasNextPage: state.hasNextPage,
        onLoadMore: () => ref.read(postListProvider.notifier).loadMore(),
        itemBuilder: (context, post, index) => PostCard(post: post),
        separatorBuilder: (_, __) => const Divider(),
        loadingWidget: const PostListSkeleton(),
        emptyWidget: const Center(child: Text('게시글이 없습니다.')),
      ),
    );
  },
)
```

### 서버 응답 형식

```json
{
  "items": [{ "id": 1, "title": "..." }, ...],
  "meta": { "currentPage": 1, "totalPages": 5, "totalItems": 47 }
}
```

서버 키가 다르면 `PaginatedResponse.fromJson`의 `itemsKey`, `metaKey` 등 조정.

### PaginationState 흐름

```
Initial → Loading → Loaded(items, hasNextPage)
                  → Error(message, items: [])         ← 첫 로드 실패: 전체 에러 화면
Loaded → Loaded(isLoadingMore: true) → Loaded(items 누적)
                                     → Error(items 유지) ← 추가 로드 실패: 하단 에러
```

---

## Isolate — CPU 집약 작업 분리

| 작업                                   | Isolate 필요? |
| -------------------------------------- | :-----------: |
| API 호출, SharedPreferences            |    ❌ I/O     |
| JSON 수백 건 이하                      |      ❌       |
| JSON 수천~수만 건, 이미지 처리, 암호화 |      ✅       |

### compute() — 단발성 작업

```dart
// top-level 함수 필수 (클로저/인스턴스 메서드 불가)
List<ItemModel> parseItemList(String json) =>
    (jsonDecode(json) as List).map((e) => ItemModel.fromJson(e)).toList();

// Repository에서 호출
final items = await compute(parseItemList, jsonEncode(rawJson));

// 인자 여러 개: record로 묶기
typedef _Args = ({String json, int page});
List<ItemModel> parseItemList(_Args args) { ... }
final items = await compute(parseItemList, (json: jsonEncode(rawJson), page: page));
```

### Isolate.spawn() — 실시간 양방향 통신 (웹소켓 등)

```dart
// top-level 진입점
void realtimeWorker(SendPort mainSendPort) {
  final port = ReceivePort();
  mainSendPort.send(port.sendPort); // 양방향 채널 수립
  port.listen((msg) {
    if (msg is String) mainSendPort.send(_parse(msg)); // 파싱 후 결과 전송
    if (msg == 'stop') port.close();
  });
}

// abstract에 dataStream 선언 필수 (없으면 의존성 역전 위반)
abstract class AbstractRealtimeRepository {
  Stream<List<RealtimeItem>> get dataStream;
  Future<void> startListening();
  Future<void> stopListening();
}

// ref.read로 구독 해제 및 isolate 정리 필수 (메모리 누수 방지)
```

**흐름**: `웹소켓 수신 → onRawData() → worker Isolate 파싱 → Stream.add → Provider → UI rebuild`

---

## flutter_native_splash

```yaml
flutter_native_splash:
  color: '#ffffff' # OS 시스템 다크모드 기준 (테마와 무관)
  color_dark: '#000000'
  android_12: { color: '#ffffff', color_dark: '#000000' }
```

재생성: `dart run flutter_native_splash:create`

```dart
// main.dart: FlutterNativeSplash.preserve(widgetsBinding: binding)
// splash_page.dart: Future.wait 완료 후 FlutterNativeSplash.remove()
// Consumer에서 authState 구독 후 ref.read로 라우팅
```

---

## CI/CD — GitHub Actions

### 브랜치 전략

```
feature/* → develop PR → ci.yml (테스트 + 빌드 검증)
develop   → main    PR → ci.yml
main에서 태그 (v1.0.0) → cd.yml (Play Store internal + TestFlight)
```

### ci.yml 핵심 구조

```yaml
on:
  pull_request: { branches: [main, develop] }
  push: { branches: [develop] }

jobs:
  test: # flutter analyze + flutter test --coverage
  build-android: # needs: test → flutter build apk --debug
  build-ios: # needs: test → flutter build ios --no-codesign (macos-latest)
```

### cd.yml 핵심 구조

```yaml
on:
  push: { tags: ['v*.*.*'] }

jobs:
  deploy-android: # flutter build appbundle --release → upload-google-play
  deploy-ios: # flutter build ipa --release → upload-testflight-build
```

### GitHub Secrets 목록

| Secret                                                               | 설명                         |
| -------------------------------------------------------------------- | ---------------------------- |
| `ENV_FILE`                                                           | `.env` 파일 전체 내용        |
| `KEYSTORE_BASE64`                                                    | Android keystore base64      |
| `KEY_ALIAS` / `KEYSTORE_PASSWORD` / `KEY_PASSWORD`                   | keystore 서명 정보           |
| `PLAY_STORE_JSON`                                                    | Google Play 서비스 계정 JSON |
| `IOS_CERT_BASE64` / `IOS_CERT_PASSWORD`                              | iOS 배포 인증서 (.p12)       |
| `APP_STORE_ISSUER_ID` / `APP_STORE_KEY_ID` / `APP_STORE_PRIVATE_KEY` | App Store Connect            |

```bash
# keystore 생성 + base64 인코딩 (최초 1회)
keytool -genkey -v -keystore android/app/keystore.jks -alias my_key -keyalg RSA -keysize 2048 -validity 10000
base64 -i android/app/keystore.jks | pbcopy
```

```kotlin
// android/app/build.gradle.kts — 환경변수로 서명
signingConfigs { create("release") {
  storeFile = file(System.getenv("KEYSTORE_PATH") ?: "keystore.jks")
  storePassword = System.getenv("KEYSTORE_PASSWORD")
  keyAlias = System.getenv("KEY_ALIAS")
  keyPassword = System.getenv("KEY_PASSWORD")
} }
```

---

## Git Commit Convention

`feat` / `fix` / `refactor` / `style` / `docs` / `test` / `chore`
예시: `feat(auth): 소셜 로그인 기능 추가`

---

## 라우터 인증 가드

```dart
// route_paths.dart에 라우트 추가 후 여기에만 등록하면 redirect 자동 처리
const _protectedRoutes = [AppRoute.home, AppRoute.myPage];
```

---

## 테스트 작성 패턴

```dart
// AsyncNotifier 테스트
void main() {
  late MockAbstractAuthRepository mockRepo;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockRepo = MockAbstractAuthRepository();
  });

  test('로그인 성공 시 UserModel 반환', () async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );

    when(mockRepo.getMe()).thenAnswer((_) async =>
        Right(UserModel(id: 1, email: 'test@test.com')));

    final state = await container.read(userProvider.future);
    expect(state.email, 'test@test.com');
  });

  // StateNotifier 테스트
  test('AuthStateNotifier 로그인 성공', () async {
    when(mockRepo.login(any)).thenAnswer((_) async =>
        Right(UserModel(id: 1, email: 'test@test.com')));

    final notifier = AuthStateNotifier(mockRepo);
    await notifier.login('test@test.com', 'password');

    expect(notifier.state, isA<AuthAuthenticated>());
  });
}
```

Mock 생성: `dart run build_runner build --delete-conflicting-outputs`

---

## Notes

- App namespace: `global.initsetting_app`
- Android 최소 SDK: 24 / Material Design 3
- 환경변수: `.env` (flutter_dotenv)
