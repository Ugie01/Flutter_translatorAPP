// lib/models/chat_state.dart

enum MessageSender { left, right }

// 채팅 메시지 하나의 데이터를 표현하는 클래스
class ChatMessage {
  // 메시지 고유 ID를 저장
  final String id;

  // 원본 텍스트를 저장
  final String originalText;

  // 번역된 텍스트를 저장
  final String translatedText;

  // 메시지를 보낸 사람을 저장 ('left' 또는 'right')
  final MessageSender sender;

  // 번역이 진행 중인지 여부를 저장
  final bool isLoading;

  // ChatMessage 객체를 생성하는 생성자
  ChatMessage({
    required this.id,
    required this.originalText,
    this.translatedText = '',
    required this.sender,
    this.isLoading = false,
  });

  // 기존 ChatMessage 객체를 복사하여 일부 값만 변경된 새 객체를 생성하는 메서드
  ChatMessage copyWith({
    String? id,
    String? originalText,
    String? translatedText,
    MessageSender? sender,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      sender: sender ?? this.sender,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 채팅 화면 전체의 상태를 표현하는 클래스
class ChatState {
  // 전체 채팅 메시지 목록을 저장
  final List<ChatMessage> messages;

  // 왼쪽 사용자의 언어 코드를 저장
  final String leftLanguage;

  // 오른쪽 사용자의 언어 코드를 저장
  final String rightLanguage;

  // 음성 인식이 진행 중인지 여부를 저장
  final bool isListening;

  // 오류 메시지를 저장
  final String? errorMessage;

  // ChatState 객체를 생성하는 생성자
  ChatState({
    this.messages = const [],
    this.leftLanguage = 'ko', // 기본값: 한국어
    this.rightLanguage = 'en', // 기본값: 영어
    this.isListening = false,
    this.errorMessage,
  });

  // 기존 ChatState 객체를 복사하여 일부 값만 변경된 새 객체를 생성하는 메서드
  ChatState copyWith({
    List<ChatMessage>? messages,
    String? leftLanguage,
    String? rightLanguage,
    bool? isListening,
    String? errorMessage,
    bool clearError = false, // 오류 메시지를 지울지 결정하는 플래그
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      leftLanguage: leftLanguage ?? this.leftLanguage,
      rightLanguage: rightLanguage ?? this.rightLanguage,
      isListening: isListening ?? this.isListening,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
