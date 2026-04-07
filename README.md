# fortune_app

Flutter 기반 사주/운세 MVP입니다. 현재 범위는 `web + iOS + Android` 공용 구조, 무료 사주/오늘 운세/랜덤카드, 정밀 사주 확장 구조까지 포함합니다.

## 현재 상태

- 무료 흐름
  - 생년월일 입력
  - 빠른 사주 결과
  - 오늘의 운세
  - 1~100000 랜덤 카드
- 정밀 흐름
  - 결과 화면에서 `정밀 사주 보기`
  - `양력/음력`, `윤달`, `정확한 시각/시지 단위` 추가 입력
  - 절기 반영형 정밀 사주 결과
- 연결 준비만 된 부분
  - Firebase Auth / Firestore
  - 보상형 광고 잠금 해제

## 폴더 구조

```text
lib/
├─ app.dart
├─ main.dart
├─ router/
│  └─ app_router.dart
├─ screens/
│  ├─ home_screen.dart
│  ├─ birth_screen.dart
│  ├─ saju_screen.dart
│  └─ cards_screen.dart
├─ widgets/
│  ├─ app_button.dart
│  ├─ card_box.dart
│  ├─ fortune_box.dart
│  ├─ precise_saju_box.dart
│  └─ precise_saju_input_sheet.dart
├─ logic/
│  ├─ saju_logic.dart
│  ├─ precise_saju_logic.dart
│  ├─ fortune_logic.dart
│  └─ cards_logic.dart
├─ models/
│  ├─ birth_input.dart
│  ├─ saju_result.dart
│  ├─ precise_saju_input.dart
│  ├─ precise_saju_result.dart
│  ├─ precise_pillar.dart
│  ├─ fortune_result.dart
│  └─ card_draw_result.dart
├─ services/
│  ├─ firebase_init.dart
│  ├─ auth_service.dart
│  ├─ firestore_service.dart
│  └─ reward_unlock_service.dart
└─ utils/
   └─ date_utils.dart
```

## 핵심 설계

### 1. 무료 사주

- 엔트리: `lib/logic/saju_logic.dart`
- 역할:
  - 빠른 입력값 기준으로 즉시 결과 제공
  - 정밀 사주 엔진의 일부 신호를 요약판처럼 가져와 무료 결과의 신뢰도 보강
- 출력:
  - 한 줄 성향
  - 겉/속 해석
  - 일/관계 해석
  - 보완 포인트

### 2. 정밀 사주

- 엔트리: `lib/logic/precise_saju_logic.dart`
- 역할:
  - `연주/월주/일주/시주`
  - 오행 분포
  - 일간 중심 해석
  - 강약, 반복되는 기운, 지장간, 명궁/신궁/태원/태식
- 입력 모델:
  - `lib/models/precise_saju_input.dart`

### 3. 오늘 운세

- 엔트리: `lib/logic/fortune_logic.dart`
- 카테고리:
  - `종합`
  - `금전운`
  - `애정운`
  - `건강운`
- 특징:
  - 빠른 사주만 보지 않고, 출생정보로부터 정밀 명리 프로필을 먼저 만든 뒤 카테고리별 점수를 계산
  - 각 카테고리마다 별도 서술 문장을 생성

### 4. 랜덤 카드

- 엔트리: `lib/logic/cards_logic.dart`
- 구조:
  - `5개 슬롯 x 슬롯당 10개 표현 = 100000 조합`
- 데이터:
  - `assets/content/cards/`

## 콘텐츠 위치

- 오늘 운세 공통 문장: `assets/content/fortune.json`
- 랜덤 카드 슬롯 문장: `assets/content/cards/`

## Firebase 연결 포인트

실제 프로젝트 연결 전까지는 placeholder/fallback 구조를 유지합니다.

- Firebase 옵션 파일:
  - `lib/firebase_options.dart`
- 초기화:
  - `lib/services/firebase_init.dart`
- 인증:
  - `lib/services/auth_service.dart`
- 저장:
  - `lib/services/firestore_service.dart`

실제 연결 시 해야 할 일:

1. `flutterfire configure`로 `firebase_options.dart` 생성/교체
2. Firebase 프로젝트 ID 및 플랫폼 설정 반영
3. `firestore.rules`, `firestore.indexes.json` 배포

## 광고 연결 포인트

광고 SDK는 아직 붙이지 않았고, 잠금 해제 인터페이스만 준비되어 있습니다.

- 인터페이스:
  - `lib/services/reward_unlock_service.dart`
- 현재 기본 구현:
  - `AlwaysUnlockedRewardUnlockService`

실제 광고 연결 시 해야 할 일:

1. 모바일 AdMob 또는 웹용 provider 구현 추가
2. `RewardUnlockRegistry.instance`에 새 구현 연결
3. `정밀 사주 보기` 흐름은 그대로 두고 unlock 동작만 교체

## 로컬 실행

```bash
flutter pub get
flutter run -d chrome
flutter run -d emulator-5554
```

## 검증 명령

```bash
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

## 현재 우선순위

1. 무료 사주 문장 고도화
2. 오늘 운세 문장 템플릿 외부화
3. 위젯/플로우 테스트 추가
4. Firebase 실연결
5. 보상형 광고 provider 연결
