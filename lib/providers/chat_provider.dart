// lib/providers/chat_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator_app/api/translation_api_service.dart';
import 'package:translator_app/models/chat_state.dart';
import 'package:translator_app/services/stt_service.dart';
import 'package:translator_app/services/tts_service.dart';
import 'package:uuid/uuid.dart';

// ChatNotifier와 ChatState를 연결하는 StateNotifierProvider를 생성
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

// 채팅 화면의 상태와 비즈니스 로직을 관리하는 클래스
class ChatNotifier extends StateNotifier<ChatState> {
  // 외부 서비스 인스턴스를 생성
  final TranslationApiService _apiService = TranslationApiService();
  final SttService _sttService = SttService();
  final TtsService _ttsService = TtsService();

  // 고유 ID 생성을 위한 Uuid 인스턴스
  final Uuid _uuid = const Uuid();

  // ChatNotifier 생성자. 초기 상태를 설정하고 STT 서비스를 초기화
  ChatNotifier() : super(ChatState()) {
    _sttService.initialize();
  }

  // 왼쪽 사용자의 언어를 설정하는 기능
  void setLeftLanguage(String languageCode) {
    state = state.copyWith(leftLanguage: languageCode);
  }

  // 오른쪽 사용자의 언어를 설정하는 기능
  void setRightLanguage(String languageCode) {
    state = state.copyWith(rightLanguage: languageCode);
  }

  // 메시지를 보내고 번역하는 기능
  Future<void> sendMessage(String text, MessageSender sender) async {
    // 텍스트가 비어있으면 아무것도 하지 않음
    if (text.isEmpty) return;

    // 메시지를 보낸 사람에 따라 출발/도착 언어를 결정
    final fromLanguage = sender == MessageSender.left
        ? state.leftLanguage
        : state.rightLanguage;
    final toLanguage = sender == MessageSender.left
        ? state.rightLanguage
        : state.leftLanguage;

    // 1. 로딩 상태의 임시 메시지를 생성
    final messageId = _uuid.v4();
    final tempMessage = ChatMessage(
      id: messageId,
      originalText: text,
      sender: sender,
      isLoading: true,
    );
    // 2. 임시 메시지를 UI에 먼저 추가하여 즉각적인 피드백을 제공
    state = state.copyWith(messages: [...state.messages, tempMessage]);

    try {
      // 3. API를 통해 텍스트를 번역
      final translatedText = await _apiService.translate(
        text,
        toLanguage,
        fromLanguage,
      );

      // 4. 번역된 텍스트와 함께 메시지를 업데이트
      final updatedMessage = tempMessage.copyWith(
        translatedText: translatedText,
        isLoading: false,
      );

      // 5. 메시지 목록에서 해당 ID의 메시지를 찾아 업데이트된 내용으로 교체
      final updatedList = state.messages
          .map((m) => m.id == messageId ? updatedMessage : m)
          .toList();
      state = state.copyWith(messages: updatedList);

      // 6. 번역된 텍스트를 음성으로 재생
      _ttsService.speak(translatedText, toLanguage);
    } catch (e) {
      // 오류 발생 시, 메시지를 '번역 실패'로 업데이트하고 오류 메시지를 상태에 저장
      final errorHandledMessage = tempMessage.copyWith(
        translatedText: "번역 실패",
        isLoading: false,
      );
      final updatedList = state.messages
          .map((m) => m.id == messageId ? errorHandledMessage : m)
          .toList();
      state = state.copyWith(messages: updatedList, errorMessage: e.toString());
    }
  }

  // 음성 인식을 시작하는 기능
  void startListening(MessageSender sender, Function(String) onResult) {
    // 음성 인식을 할 언어를 결정
    final languageCode = sender == MessageSender.left
        ? state.leftLanguage
        : state.rightLanguage;
    // 듣기 상태를 true로 변경
    state = state.copyWith(isListening: true);

    _sttService.startListening(
      languageCode: languageCode,
      onResult: (text) {
        onResult(text); // 인식된 텍스트를 콜백 함수로 전달
        state = state.copyWith(isListening: false);
      },
      onDone: () {
        // 음성 인식이 완료되면 듣기 상태를 false로 변경
        if (state.isListening) {
          state = state.copyWith(isListening: false);
        }
      },
    );
  }

  // 음성 인식을 중지하는 기능
  void stopListening() {
    _sttService.stopListening();
    state = state.copyWith(isListening: false);
  }

  // Notifier가 소멸될 때 리소스를 해제하는 기능
  @override
  void dispose() {
    _sttService.dispose();
    super.dispose();
  }

  // 왼쪽과 오른쪽 언어를 서로 바꾸는 기능
  void swapLanguages() {
    final tempSource = state.leftLanguage;
    state = state.copyWith(
      leftLanguage: state.rightLanguage,
      rightLanguage: tempSource,
    );
  }
}
