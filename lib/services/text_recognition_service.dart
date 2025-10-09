// lib/services/text_recognition_service.dart

import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// 이미지에서 텍스트를 인식하는 기능을 담당하는 서비스 클래스
class TextRecognitionService {
  // 한국어 스크립트를 인식하도록 설정된 TextRecognizer 인스턴스를 생성
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.korean,
  );

  // 주어진 이미지 파일 경로에서 텍스트를 인식하는 메서드
  Future<RecognizedText> processImage(String path) async {
    // 이미지 파일을 InputImage 객체로 변환
    final inputImage = InputImage.fromFile(File(path));
    // TextRecognizer를 사용하여 이미지에서 텍스트를 처리하고 결과를 반환
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText;
  }

  // 서비스가 더 이상 필요 없을 때 리소스를 해제하는 메서드
  void dispose() {
    _textRecognizer.close();
  }
}
