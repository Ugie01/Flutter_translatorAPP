// lib/providers/translation_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator_app/api/translation_api_service.dart';
import 'package:translator_app/models/translation_state.dart';
import 'package:translator_app/services/stt_service.dart';
import 'package:translator_app/services/tts_service.dart';

// TranslationNotifier와 TranslationState를 연결하는 StateNotifierProvider를 생성
final translationProvider =
    StateNotifierProvider<TranslationNotifier, TranslationState>((ref) {
      return TranslationNotifier();
    });

// 번역 화면의 상태와 비즈니스 로직을 관리하는 클래스
class TranslationNotifier extends StateNotifier<TranslationState> {
  // 외부 서비스 인스턴스를 생성
  final TranslationApiService _apiService = TranslationApiService();
  final SttService _sttService = SttService();
  final TtsService _ttsService = TtsService();

  // 디바운싱을 위한 타이머를 저장
  Timer? _debounce;

  // 생성자: 초기 상태를 설정하고 STT 서비스를 초기화
  TranslationNotifier() : super(TranslationState()) {
    _sttService.initialize();
  }

  // 입력 텍스트를 업데이트하는 기능
  void setInputText(String text) {
    // 입력 텍스트를 업데이트하고 오류 메시지를 제거
    state = state.copyWith(inputText: text, clearError: true);

    // 기존 디바운스 타이머가 있으면 취소
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // 1초 뒤에 번역을 실행하도록 타이머를 설정
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      if (text.isNotEmpty) {
        _translate(); // 텍스트가 있으면 번역 실행
      } else {
        // 텍스트가 없으면 번역 결과도 비움
        state = state.copyWith(translatedText: '');
      }
    });
  }

  // 출발 언어를 설정하는 기능
  void setSourceLanguage(String languageCode) {
    state = state.copyWith(sourceLanguage: languageCode);
    _translate(); // 언어 변경 시 즉시 번역
  }

  // 도착 언어를 설정하는 기능
  void setTargetLanguage(String languageCode) {
    state = state.copyWith(targetLanguage: languageCode);
    _translate(); // 언어 변경 시 즉시 번역
  }

  // 출발 언어와 도착 언어를 교환하는 기능
  void swapLanguages() {
    final tempSource = state.sourceLanguage;
    state = state.copyWith(
      sourceLanguage: state.targetLanguage, // 도착 언어를 출발 언어로 설정
      targetLanguage: tempSource, // 기존 출발 언어를 도착 언어로 설정
      inputText: state.translatedText, // 이전 번역 결과를 입력 텍스트로 설정
      translatedText: '', // 번역 결과는 초기화
    );
    // 변경된 입력 텍스트로 즉시 번역 실행
    if (state.inputText.isNotEmpty) {
      _translate();
    }
  }

  // 텍스트를 번역하는 내부 메서드
  Future<void> _translate() async {
    // 입력 텍스트가 없으면 실행하지 않음
    if (state.inputText.isEmpty) return;

    // 로딩 상태를 true로 변경하고 오류 메시지를 제거
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // API 서비스를 통해 번역을 요청
      final result = await _apiService.translate(
        state.inputText,
        state.targetLanguage,
        state.sourceLanguage,
      );
      // 번역 성공 시, 결과를 상태에 반영하고 로딩 상태를 false로 변경
      state = state.copyWith(translatedText: result, isLoading: false);
    } catch (e) {
      // 번역 실패 시, 오류 메시지를 상태에 반영하고 로딩 상태를 false로 변경
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  // 음성 인식을 시작하는 기능
  void startListening() {
    // 듣기 상태를 true로 변경하고 입력창에 안내 문구 표시
    state = state.copyWith(isListening: true, inputText: '듣는 중...');
    _sttService.startListening(
      languageCode: state.sourceLanguage, // 출발 언어로 음성 인식
      onResult: (text) {
        setInputText(text); // 인식된 텍스트를 입력창에 설정
        state = state.copyWith(isListening: false); // 듣기 상태 종료
      },
      onDone: () {
        // 음성 인식이 완료되면 (결과가 있든 없든) 듣기 상태를 false로 변경
        if (state.isListening) {
          state = state.copyWith(isListening: false, inputText: '');
        }
      },
    );
  }

  // 음성 인식을 중지하는 기능
  void stopListening() {
    _sttService.stopListening();
    state = state.copyWith(isListening: false);
  }

  // 번역된 텍스트를 음성으로 읽어주는 기능
  void speakTranslatedText() {
    if (state.translatedText.isNotEmpty) {
      _ttsService.speak(state.translatedText, state.targetLanguage);
    }
  }

  // Notifier가 소멸될 때 리소스를 해제하는 기능
  @override
  void dispose() {
    _debounce?.cancel(); // 타이머 취소
    _sttService.dispose(); // STT 서비스 리소스 해제
    super.dispose();
  }
}
