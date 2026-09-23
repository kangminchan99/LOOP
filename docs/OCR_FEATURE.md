# 사진 속 글자 추출(OCR) 구현 계획

작성·문서 확인: 2026-09-23.
상태: **설계 문서만 작성됨. 패키지 설치·기능 구현·실기기 검증은 아직 하지 않았다.**

## 1. 만드는 기능

OCR(광학 문자 인식)은 사진 안의 글자를 편집 가능한 문자열로 추출하는 기능이다.
사진의 의미를 설명하거나 요약하는 생성형 AI 기능은 아니다.

사용 흐름:

```text
설정 → 사진 속 글자 추출
          ↓
사진 촬영 또는 갤러리에서 1장 선택
          ↓
미리보기 → 글자 추출 버튼
          ↓
인식 중 → 추출 결과 편집 → 복사
```

1차 화면 진입점은 기존 설정 화면에 메뉴를 추가하는 것으로 제안한다.
게시글 작성 화면 연동은 이후 별도 단계로 진행한다.

### 1차 포함

- Android/iOS에서 단일 사진 선택·촬영.
- 한국어 중심 글자 인식, 영문·숫자 혼합 결과 확인.
- 이미지 미리보기, 진행 표시, 결과 수정·전체 복사·다시 선택.
- 선택 취소, 권한 거부, 빈 결과, 파일 오류, 미지원 플랫폼 처리.
- 앱 잠금·화면 종료·Android 선택 결과 복구 처리.
- 다국어 문구, 다크 모드, 큰 글자·좁은 화면 대응.

### 이번에는 하지 않는 것

- 실시간 카메라 프레임 인식, 문서 모서리 자동 검출, 원근 보정, 자르기 UI.
- 여러 장/PDF 처리, 번역·요약, 표 구조 복원, 손글씨 정확도 보장.
- OCR 이력의 영구 저장, 게시글 자동 작성, S3 업로드, 서버 API 추가.

초기 버전은 '사진에서 글자 추출'이다. 자동 보정까지 제공하는 완성형 문서 스캐너와 구분한다.
영구 저장은 안 하지만 이미지 선택기가 임시 파일을 만들 수 있으므로 '기기에 전혀 저장되지 않는다'고 안내하지 않는다.

## 2. 현재 프로젝트에서 확인한 내용

| 위치 | 현재 상태 | 계획 |
| --- | --- | --- |
| `pubspec.yaml`, `pubspec.lock` | image_picker 선언 ^1.2.2, lock 1.2.2 | 기존 버전 재사용부터 검토, 무관한 업데이트 금지 |
| `pubspec.yaml` | google_mlkit_text_recognition 없음 | OCR 패키지만 별도 도입 |
| `lib/src/features/app_lock/` | Repository 추상화·UseCase·Riverpod 구조 | 새 기능도 같은 경계 적용 |
| `android/app/build.gradle.kts` | Flutter SDK 설정 상속, 기존 desugaring 사용 | 한국어 모델 의존성만 추가, 기존 설정 보존 |
| `ios/Podfile` | platform 행 주석 처리 | 배포 타깃과 한국어 모델 설정 검토 |
| `ios/Runner/Info.plist` | 카메라·사진 사용 목적 키 미확인(검색 결과 없음) | 실제 파일에서 확인 후 중복 없이 추가 |
| `lib/src/core/router/router_path.dart`, `router.dart` | 기존 go_router 라우팅 | OCR 경로와 설정 메뉴 연결 |
| `lib/l10n/app_ko.arb`, `app_en.arb` | 기존 다국어 | 버튼·안내·오류 문구 추가 |

경로는 Flutter 프로젝트 `/Volumes/T7/loop` 기준이다.
서버 프로젝트 `/Volumes/T7/loop_server`가 아니라 **Flutter 프로젝트에서 작업한다.**

## 3. 기술 선택과 플랫폼 준비

### 선택

- 이미지 획득: 기존 `image_picker`.
- OCR 후보: `google_mlkit_text_recognition`, 문서 확인 당시 0.17.1.
- 상태/의존성: 현재 Riverpod 2.x와 Freezed 3.x 방식 유지.
- 오류: 기존 `Either<Failure, ...>` 패턴을 사용하되 OCR 전용 오류 코드로 분류.
- 이미지 인식은 기기 내 네이티브 ML Kit가 담당. Loop 서버나 OpenAI 호출은 추가하지 않는다.

ML Kit 자체는 Google 기술이지만 이 Flutter 패키지는 **Google이 유지보수하는 공식 Flutter 플러그인이 아니다.**
지원 대상은 Android/iOS이며 웹·macOS·Windows의 OCR은 이번 대상이 아니다.
플랫폼 검사 전에 OCR 인스턴스를 생성하지 않고, 미지원 플랫폼의 직접 라우트 접근도 방어한다.
[플러그인 문서](https://pub.dev/packages/google_mlkit_text_recognition)

### 설치 전 확인

```bash
cd /Volumes/T7/loop
flutter --version
flutter doctor -v
```

Flutter/Dart, 실제 잠금 버전, Android SDK, Xcode·iOS 배포 타깃을 기록한다.
최신 pub.dev 버전이 프로젝트와 호환된다는 뜻은 아니므로 설치 후 lock과 네이티브 빌드로 확인한다.

- 플러그인 문서의 iOS 최소 타깃은 15.5. 실제 선택 버전의 Pod 요구사항과 Runner 타깃을 함께 맞춘다.
- Android는 Flutter가 정한 minSdk/compileSdk와 선택한 플러그인·한국어 모델의 요구사항을 모두 확인한다.
  문서별 최소 SDK 숫자가 다를 수 있으므로 낮은 값으로 임의 하향하지 않는다.
- 한국어는 Dart의 인식기 설정만으로 끝나지 않는다. Android/iOS 네이티브 한국어 의존성을 함께 추가한다.
- Android는 `build.gradle.kts`이므로 Groovy 예제를 그대로 붙이지 않고 Kotlin DSL 형식으로 적용한다.
- iOS는 기존 Podfile의 Firebase/Flutter 설정과 post_install 블록을 보존한다.
- 모델을 앱에 포함하는 방식을 우선 검토한다. 다운로드형을 선택하면 첫 실행 오프라인 동작이 달라짐을 별도로 검증한다.

[Android 네이티브 가이드](https://developers.google.com/ml-kit/vision/text-recognition/v2/android),
[iOS 네이티브 가이드](https://developers.google.com/ml-kit/vision/text-recognition/v2/ios)

### 권한

- iOS: `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` 사용 목적을 명확히 작성한다.
- 사진 OCR에는 마이크 권한이 필요하지 않다.
- Android: 선택한 image_picker 구현·기존 Manifest를 확인하고 동작에 필요하지 않은 광범위 저장소 권한을 추가하지 않는다.
- 사용자 취소는 오류가 아니다. 권한 거부와 구분한다.
- 영구 거부에는 기기 설정 안내를 제공한다. 설정 이동이 필요하면 그 단계에서 지원 API를 확인한다.

이미지 선택 취소/임시 파일/Android `retrieveLostData()` 정책은
[image_picker 유지보수자 문서](https://pub.dev/packages/image_picker)를 기준으로 한다.

## 4. 제안 폴더와 역할

다음은 **앞으로 만들 파일**이다. 현재 존재하거나 구현이 완료됐다는 뜻이 아니다.

```text
lib/src/features/ocr/
├── domain/
│   ├── models/
│   │   ├── ocr_result_model.dart
│   │   └── ocr_image_source.dart
│   ├── repositories/
│   │   └── abstract_ocr_repository.dart
│   └── usecases/
│       └── recognize_image_text_usecase.dart
├── data/
│   ├── data_sources/local/
│   │   ├── ocr_image_local_data_source.dart
│   │   └── text_recognition_local_data_source.dart
│   └── repositories/
│       └── ocr_repository_impl.dart
└── presentation/
    ├── providers/
    │   ├── ocr_providers.dart
    │   ├── ocr_state.dart
    │   └── ocr_notifier.dart
    ├── pages/
    │   └── ocr_page.dart
    └── widgets/
        ├── ocr_image_preview.dart
        └── ocr_result_editor.dart
```

- Model: Freezed 결과 모델. 우선 원문 문자열만 담고, 박스 좌표/원본 bytes는 필요해질 때 추가한다.
  프로젝트 규칙에 따라 JSON 생성 코드를 만들더라도 이것이 DB 저장/서버 전송을 의미하지는 않는다.
- ImageSource: camera/gallery를 앱 자체 enum으로 표현한다.
- 추상 Repository: 이미지 선택, 텍스트 인식 등 앱의 계약. 플러그인 타입을 외부에 노출하지 않는다.
- Local DataSource: `XFile`, `InputImage`, `TextRecognizer` 같은 SDK 타입을 다루는 곳.
- Repository 구현체: SDK 결과를 앱 모델로, 예외를 OCR Failure로 변환한다.
- UseCase: 빈 경로 방어 등 인식 작업 규칙과 Repository 호출. 화면/로딩 상태는 관리하지 않는다.
- Notifier: 선택→인식→결과 상태, 중복 실행 방지, 오래된 결과 무시.
- Provider: 생성과 수명 관리. OCR 화면에서만 사용하고 종료 후 자원 정리.
- Page/Widget: 미리보기, 버튼, 편집/복사 UI. SDK 직접 호출 금지.

OCR Failure는 기존 `lib/src/core/network/error/failures.dart`를 상속하는 별도 파일로 추가한다.
로컬 인식 실패를 `ServerFailure`로 감싸지 않는다. 오류 코드는 도메인/데이터 계층에서,
사용자 언어에 맞는 메시지는 UI에서 선택한다.

## 5. 상태와 수명 규칙

상태 흐름: idle → selecting → ready → recognizing → success/empty/failure.

- 취소: 이전 이미지·사용자가 편집 중인 텍스트 유지.
- selecting/recognizing 중 재실행 차단. 작업 ID로 늦은 완료 결과도 방어한다.
- 이미지 변경 전 편집 내용이 있으면 교체 확인. 새 OCR 결과로 사용자 수정을 몰래 덮어쓰지 않는다.
- 원본 인식 문자열과 편집 문자열을 구분. 복사는 **현재 편집 문자열**을 대상으로 한다.
- 편집기의 TextEditingController는 위젯 수명으로 관리한다. build마다 재생성하지 않는다.
- 타이핑마다 페이지 전체를 재빌드하지 않도록 구독 영역을 나눈다.
- 페이지 종료/로그아웃 시 상태 갱신 차단. Future를 무시하는 것과 네이티브 작업 취소는 다르다.
- 인식기 종료는 DataSource/Provider가 단일 소유한다.
  진행 작업 완료 후 close하도록 정리하여 processImage와 close가 충돌하지 않게 한다.
- 잠금 기능은 끄지 않는다. 외부 카메라/선택기에서 돌아오면 기존 잠금 정책을 따르고,
  잠금 해제 전 이미지나 텍스트를 노출하지 않는다.

### Android 선택 중 프로세스 종료

`retrieveLostData()`는 앱 시작 시 한 곳에서 회수하도록 설계한다.
현재 다른 image_picker 사용처(예: 프로필 사진 변경)와 소유권이 섞이면 안 된다.

선택 시작 전 최소한의 pending 작업 정보(기능 종류·계정·시각)를 기록하고,
복구 후 동일 계정과 잠금 상태를 확인한다. 이미지/OCR 본문은 이 정보에 넣지 않는다.
복구한 파일은 한 번만 소비하고, 오래된/다른 계정 작업은 안내 후 폐기한다.
원래 선택된 사진을 삭제하지 않고, 정리 대상은 앱이 소유한 임시 복사본으로 한정한다.

## 6. 성능·개인정보 원칙

- 첫 버전은 사진 한 장씩 처리. 실시간 프레임 인식으로 시작하지 않는다.
- 가능하면 파일 경로로 OCR에 전달한다. base64·원본 bytes를 상태에 반복 저장하지 않는다.
- 미리보기용 디코딩 크기와 OCR 입력 해상도를 구분한다.
  미리보기를 작게 보여준다는 이유로 인식 입력까지 과도하게 축소하지 않는다.
- 긴 텍스트와 큰 이미지에서도 화면 전환·스크롤을 확인한다.
- 네이티브 플러그인 호출을 무조건 isolate에 넣지 않는다.
  Dart 전처리에 병목이 측정될 때만 지원 조건을 확인하고 별도로 분리한다.
- 원본 사진·인식 문자열·개인 파일 경로를 로그/Analytics/Crash 보고에 남기지 않는다.
- 클립보드 전송은 사용자가 복사를 눌렀을 때만 한다.
- OCR 오류 가능성을 안내하고 사용자 수정 단계를 유지한다.
- 성능 측정은 [앱 전체 성능 가이드](APP_PERFORMANCE_GUIDE.md)를 따른다.
  에뮬레이터는 기능 확인용이며 성능 판단은 실기기 profile에서 한다.

## 7. 한 단계씩 진행할 순서

각 단계는 앞 단계의 확인 후 진행한다. 문서 작성만으로 체크하지 않는다.

| 단계 | 할 작업 | 다음으로 넘어가는 기준 |
| --- | --- | --- |
| 1 | 프로젝트 버전 확인, OCR 패키지 추가 | pub get 성공, lock 변경 확인 |
| 2 | Android 한국어 모델·SDK 설정 | Android 네이티브 빌드 성공 |
| 3 | iOS 한국어 모델·권한·배포 타깃 설정 | iOS 네이티브 빌드 성공 또는 미검증으로 명시 |
| 4 | 결과 Model·입력 enum·추상 Repository·Failure 정의 | Freezed 생성·analyze 성공 |
| 5 | 이미지 선택/인식 DataSource와 Repository 구현 | 샘플 이미지 인식, 취소/예외/자원 해제 확인 |
| 6 | UseCase·Provider·Notifier/State 구현 | 성공·빈 결과·중복 실행·늦은 완료 단위 테스트 |
| 7 | 미리보기·편집·복사 화면 구현 | 위젯 테스트, 다크 모드·다국어 확인 |
| 8 | 설정 메뉴·라우트 연결 | 열기·뒤로 가기·미지원 플랫폼 방어 확인 |
| 9 | 앱 잠금 복귀·lost data 복구 통합 | 계정 변경·OS 종료 시 결과 오연결 방지 |
| 10 | Android/iOS 실기기 기능·성능 검증 | 아래 체크리스트와 측정 기록 완료 |

1단계 명령(실행 안내용, 이번 문서 작업에서는 실행하지 않음):

```bash
cd /Volumes/T7/loop
flutter pub add google_mlkit_text_recognition
```

의존성 충돌 시 Flutter/Riverpod 등을 통째로 업그레이드하지 않고 충돌 원인부터 확인한다.
개별 코드와 주석은 실제 구현 단계에서 현재 파일에 맞춰 안내한다.

## 8. 검증과 완료 기준

### 자동 테스트

- Repository: SDK 성공/예외를 앱 결과/Failure로 변환, 선택 취소 정상 처리.
- UseCase: 유효하지 않은 입력 차단, 인식 호출 횟수 검증.
- Notifier: 로딩→성공/빈 결과/오류, 연타 시 한 번 호출, 종료 후 결과 무시.
- Widget: 인식 중 버튼 비활성, 편집된 값 복사, 취소 시 이전 내용 유지.
- 네이티브 OCR 자체를 Dart mock 통과만으로 검증했다고 하지 않는다.

### 실기기 체크리스트

- [ ] Android·iOS 각각 한국어 인쇄물과 영문/숫자 혼합 사진 확인.
- [ ] 갤러리·촬영, 가로/세로 사진과 회전 방향 확인.
- [ ] 글자 없는 이미지, 흐림, 작은 글씨, 큰 이미지, 긴 본문 처리.
- [ ] JPEG/PNG 기본 샘플, iPhone 사진 형식(HEIC 등) 실제 기기 확인.
- [ ] 최초 권한 거부·재시도·설정 변경, 선택 취소.
- [ ] 인식 중 뒤로 가기·연타·앱 잠금·로그아웃에서 상태 오염 없음.
- [ ] Android 선택 중 프로세스 종료 후 lost data 복구/안내.
- [ ] 비행기 모드에서 번들 모델 인식, 네트워크 전송 여부 점검.
- [ ] 미지원 플랫폼은 메뉴/직접 라우트 모두 안전하게 안내.
- [ ] 다크 모드·영어 UI·큰 글자·키보드가 열린 좁은 화면에서 overflow 없음.
- [ ] 실기기 profile에서 최초/반복 인식 시간·느린 프레임·메모리 기록.
- [ ] 화면 진입/종료 반복 후 인식기·편집기 자원 누수 여부 확인.

기능 완료는 패키지 설치가 아니라 위 흐름과 실패 처리가 검증된 상태다.
초기에는 대표 샘플별 기대 문자열과 실제 결과를 기록하고, 인식률/시간 목표는 기준선 측정 후 정한다.
미검증 플랫폼이나 시나리오는 완료로 표시하지 않는다.

## 9. 이후 확장 후보

자동 모서리 검출·자르기/원근 보정 → 여러 장 처리 → 사용자 동의 기반 이력 저장 →
게시글 작성 화면에 편집 텍스트 전달 순으로 별도 요구사항을 정한다.
서버 저장·공유가 필요해질 때 보관 정책과 API를 설계하며 현재 단계에서는 추가하지 않는다.

참고: [ML Kit Text Recognition 개요](https://developers.google.com/ml-kit/vision/text-recognition/v2)

