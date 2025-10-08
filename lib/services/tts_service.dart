// lib/services/tts_service.dart

import 'package:flutter_tts/flutter_tts.dart';

// 텍스트-음성 변환(TTS) 기능을 담당하는 서비스 클래스
class TtsService {
  // flutter_tts 패키지의 메인 클래스 인스턴스를 생성
  final FlutterTts _flutterTts = FlutterTts();

  // 주어진 텍스트를 특정 언어의 음성으로 읽어주는 메서드
  Future<void> speak(String text, String languageCode) async {
    // 앱 언어 코드를 TTS가 요구하는 BCP 47 언어 코드로 변환
    String ttsLangCode = _mapToTtsLanguageCode(languageCode);
    // 음성 언어를 설정
    await _flutterTts.setLanguage(ttsLangCode);
    // 음성 높낮이를 설정 (1.0이 기본)
    await _flutterTts.setPitch(1.0);
    // 음성 속도를 설정 (0.0 ~ 1.0)
    await _flutterTts.setSpeechRate(0.5);
    // 텍스트 읽기를 시작
    await _flutterTts.speak(text);
  }

  // 앱 언어 코드를 TTS 패키지 언어 코드로 매핑하는 기능
  String _mapToTtsLanguageCode(String code) {
    switch (code) {
      case 'ko':
        return 'ko-KR';
      case 'en':
        return 'en-US';
      case 'ja':
        return 'ja-JP';
      case 'zh-Hans':
        return 'zh-CN';
      case 'de':
        return 'de-DE';
      case 'es':
        return 'es-ES';
      case 'fr':
        return 'fr-FR';
      default:
        return 'en-US'; // 기본값
    }
  }
}