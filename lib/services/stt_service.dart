// lib/services/stt_service.dart

import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

// 음성-텍스트 변환(STT) 기능을 담당하는 서비스 클래스
class SttService {
  // speech_to_text 패키지의 인스턴스를 생성
  final SpeechToText _speechToText = SpeechToText();

  // STT 엔진이 초기화되었는지 여부를 저장
  bool _isInitialized = false;

  // STT 서비스를 초기화하는 메서드
  Future<void> initialize() async {
    if (!_isInitialized) {
      // 디바이스의 STT 엔진을 초기화하고 권한을 요청
      _isInitialized = await _speechToText.initialize();
    }
  }

  // 음성 인식을 시작하는 메서드
  void startListening({
    required String languageCode, // 인식할 언어 코드
    required Function(String) onResult, // 최종 인식 결과 콜백
    required Function() onDone, // 음성 인식 종료 콜백
  }) {
    // 초기화되지 않았으면 실행하지 않음
    if (!_isInitialized) return;

    // 앱 언어 코드를 STT 패키지가 사용하는 로케일 ID로 변환
    final localeId = _mapToSttLocaleId(languageCode);

    // 음성 인식을 시작
    _speechToText
        .listen(
          // 음성 인식 결과가 수신될 때마다 호출되는 콜백
          onResult: (SpeechRecognitionResult result) {
            // 최종 결과일 때만 onResult 콜백을 호출
            if (result.finalResult) {
              onResult(result.recognizedWords);
            }
          },
          localeId: localeId, // 인식할 언어를 설정
        )
        .then((_) => onDone()); // listen이 완료되면 onDone 콜백을 호출
  }

  // 진행 중인 음성 인식을 중지하는 메서드
  void stopListening() {
    _speechToText.stop();
  }

  // 서비스 리소스를 해제하는 메서드
  void dispose() {
    _speechToText.stop();
  }

  // 앱 언어 코드를 STT 패키지 로케일 ID로 매핑하는 기능
  String _mapToSttLocaleId(String code) {
    switch (code) {
      case 'ko':
        return 'ko_KR';
      case 'en':
        return 'en_US';
      case 'ja':
        return 'ja_JP';
      case 'zh-Hans':
        return 'zh_CN';
      case 'de':
        return 'de_DE';
      case 'es':
        return 'es_ES';
      case 'fr':
        return 'fr_FR';
      default:
        return 'en_US'; // 기본값
    }
  }
}
