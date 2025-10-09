# GoSungTalk: Flutter 기반 다기능 실시간 번역 애플리케이션

GoSungTalk은 Flutter 기반의 다기능 실시간 번역 애플리케이션이다. 텍스트, 음성, 이미지를 통해 언어 장벽을 극복하는 것을 목표로 한다. Riverpod를 통한 상태 관리와 Microsoft Translator API를 활용하여 빠르고 정확한 번역 기능을 구현했다.

https://github.com/user-attachments/assets/ec853d19-8b2b-4c2d-a59e-7747006be549


---

## 🎯 주요 기능 (Features)

### 1. 텍스트 번역
- **실시간 번역**: 사용자 텍스트 입력 시 **Debouncing** 기술을 통해 API 요청을 최적화하고 실시간에 가까운 번역 결과를 제공한다.
- **언어 자동 감지 및 선택**: 출발 및 도착 언어를 자유롭게 선택할 수 있으며, **Swap** 기능으로 편의성을 높였다.
- **음성 출력 (TTS)**: 번역된 결과를 음성으로 출력하는 **Text-To-Speech** 기능을 지원한다.
- **음성 입력 (STT)**: 키보드 대신 음성으로 텍스트를 입력하는 **Speech-To-Text** 기능을 지원한다.

<img width="270" height="600" alt="trans" src="https://github.com/user-attachments/assets/8f9b5384-9899-49bb-891c-15422525727f" />

### 2. 카메라 번역 (OCR)
- **이미지 텍스트 인식**: `google_ml_kit_text_recognition` 라이브러리를 활용하여 카메라로 촬영한 이미지 속 텍스트를 인식한다.
- **선택적 번역**: 인식된 텍스트 블록 중 사용자가 번역을 원하는 부분만 선택하여 번역한다.
- **자동 언어 감지**: 선택된 텍스트의 언어를 자동으로 감지하여 출발 언어로 설정한다.

<img width="270" height="600" alt="select" src="https://github.com/user-attachments/assets/34c1e4a3-3565-4d95-9054-de15e5ff5508" />

### 3. 채팅 번역
- **양방향 실시간 번역**: 두 사용자가 각자 설정한 언어로 메시지를 입력하면, 상대방의 언어로 자동 번역되어 메시지를 표시한다.
- **낙관적 UI 업데이트 (Optimistic UI)**: 메시지 전송 시 로딩 상태를 UI에 먼저 반영하여 사용자 경험을 향상시켰다.
- **자동 음성 출력**: 상대방의 번역된 메시지를 자동으로 읽어주는 **TTS** 기능이 포함되어 있다.

<img width="270" height="600" alt="chat" src="https://github.com/user-attachments/assets/488b9d40-b9d4-48c7-ba01-eb8e86f24ae4" />


### 4. 사용자 경험 (UX)
- **테마 전환**: 사용자의 선호에 따라 **라이트 모드**와 **다크 모드**를 자유롭게 전환할 수 있다.
- **직관적인 UI**: 하단 네비게이션 바를 통해 각 기능에 쉽게 접근하도록 설계했다.

---

## 🛠️ 기술 스택 및 아키텍처 (Tech Stack & Architecture)

- **Development Environment**:
    - `Flutter`: 3.35.5
    - `Dart`: 3.9.2
    - `DevTools`: 2.48.0
    - `Android Studio`: Narwhal | 2025.1.3
- **State Management**: `Riverpod`
    - `StateNotifierProvider`와 `StateProvider`를 사용하여 앱의 상태를 반응형으로 관리하고, UI와 비즈니스 로직을 분리했다.
- **API**: `Microsoft Translator API`
    - 텍스트 번역 및 언어 감지를 위해 사용했다.
- **Asynchronous Programming**: `Future`, `async/await`를 활용하여 비동기 API 통신 및 데이터 처리를 구현했다.
- **Key Libraries**:
    - `dio`: HTTP 통신
    - `google_ml_kit_text_recognition`: 이미지 내 텍스트 인식 (OCR)
    - `speech_to_text`: 음성-텍스트 변환 (STT)
    - `flutter_tts`: 텍스트-음성 변환 (TTS)
    - `camera`: 카메라 기능 구현
    - `flutter_dotenv`: API 키 등 민감 정보 관리
- **Architecture**:
    - **Provider-Service Pattern**: `Riverpod Provider`가 UI 상태를 관리하고, 실제 비즈니스 로직(API 호출, 데이터 처리 등)은 `Service` 클래스에 위임하여 역할을 명확히 분리했다.
    - **Immutable State**: `copyWith` 메서드를 활용한 불변 객체로 상태를 관리하여 데이터의 일관성과 예측 가능성을 확보했다.

---

## 🚀 시작하기 (Getting Started)

#### 1. 프로젝트 클론
```bash
git clone https://github.com/your-username/gosungtalk.git
cd gosungtalk
```
#### 2. Flutter 패키지 설치
```bash
flutter pub get
```
#### 3. 환경 변수 설정 (.env)
프로젝트 루트 디렉터리에 .env 파일을 생성하고 아래 내용을 채운다.

# Microsoft Azure Cognitive Services - Translator
```bash
API_KEY="YOUR_MICROSOFT_TRANSLATOR_API_KEY"
API_REGION="YOUR_API_REGION"
API_ENDPOINT="https://api.cognitive.microsofttranslator.com"
```

<img width="699" height="177" alt="image" src="https://github.com/user-attachments/assets/7602d613-081d-4f20-876e-a93253cb8989" />


#### 4. 앱 실행
flutter run

---

## 📂 프로젝트 구조 (Project Structure)
```
lib
├── api/
│   └── translation_api_service.dart  # 외부 API 통신 담당
├── models/
│   ├── chat_state.dart               # 채팅 관련 데이터 모델
│   └── translation_state.dart        # 번역 관련 데이터 모델
├── providers/
│   ├── chat_provider.dart            # 채팅 화면 상태 및 로직 관리
│   ├── main_screen_provider.dart     # 메인 화면 탭 상태 관리
│   ├── theme_provider.dart           # 테마 상태 관리
│   └── translation_provider.dart     # 번역 화면 상태 및 로직 관리
├── screens/
│   ├── camera_screen.dart            # 카메라 화면 UI
│   ├── chat_screen.dart              # 채팅 화면 UI
│   ├── main_screen.dart              # 앱의 메인 프레임 (하단 탭)
│   ├── selection_screen.dart         # OCR 결과 선택 화면 UI
│   └── translation_screen.dart       # 번역 화면 UI
├── services/
│   ├── stt_service.dart              # Speech-To-Text 서비스 로직
│   ├── text_recognition_service.dart # 텍스트 인식 서비스 로직
│   └── tts_service.dart              # Text-To-Speech 서비스 로직
├── widgets/
│   └── chat_bubble.dart              # 채팅 말풍선 위젯
└── main.dart                         # 앱 시작점
```
