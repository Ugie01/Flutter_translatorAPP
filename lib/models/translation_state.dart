// lib/models/translation_state.dart

// 번역 화면의 상태를 나타내는 데이터 클래스 (불변 객체)
class TranslationState {
  // 사용자가 입력한 텍스트를 저장
  final String inputText;

  // 번역된 결과 텍스트를 저장
  final String translatedText;

  // 출발 언어 코드를 저장 (예: 'ko')
  final String sourceLanguage;

  // 도착 언어 코드를 저장 (예: 'en')
  final String targetLanguage;

  // 번역 API 호출 중인지 여부를 저장
  final bool isLoading;

  // 음성 인식 중인지 여부를 저장
  final bool isListening;

  // 오류 발생 시 표시할 메시지를 저장
  final String? errorMessage;

  // 앱에서 지원하는 언어 목록 (UI 표시 이름: API 코드)
  static const Map<String, String> supportedLanguages = {
    '한국어': 'ko',
    'English': 'en',
    '日本語': 'ja',
    '中文 (간체)': 'zh-Hans',
    'Deutsch': 'de',
    'Español': 'es',
    'Français': 'fr',
  };

  // TranslationState 객체를 생성하는 생성자
  TranslationState({
    this.inputText = '',
    this.translatedText = '',
    this.sourceLanguage = 'ko', // 기본 출발 언어: 한국어
    this.targetLanguage = 'en', // 기본 도착 언어: 영어
    this.isLoading = false,
    this.isListening = false,
    this.errorMessage,
  });

  // 기존 상태 객체를 복사하면서 일부 값만 변경하여 새로운 상태 객체를 생성하는 메서드
  TranslationState copyWith({
    String? inputText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    bool? isLoading,
    bool? isListening,
    String? errorMessage,
    bool clearError = false, // 이 플래그가 true이면 errorMessage를 null로 초기화
  }) {
    return TranslationState(
      inputText: inputText ?? this.inputText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      isLoading: isLoading ?? this.isLoading,
      isListening: isListening ?? this.isListening,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
