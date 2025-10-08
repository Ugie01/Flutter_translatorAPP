// lib/api/translation_api_service.dart

import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:translator_app/models/translation_state.dart';

// Microsoft Translator API와의 통신을 담당하는 서비스 클래스
class TranslationApiService {
  // HTTP 통신을 위한 Dio 인스턴스를 생성
  final Dio _dio = Dio();
  // .env 파일에서 API 키를 가져와 저장
  static final String _apiKey = dotenv.env['API_KEY'] ?? 'API_KEY_NOT_FOUND';
  // .env 파일에서 API 지역을 가져와 저장
  static final String _apiRegion = dotenv.env['API_REGION'] ?? 'API_REGION_NOT_FOUND';
  // .env 파일에서 API 엔드포인트를 가져와 저장
  static final String _endpoint = dotenv.env['API_ENDPOINT'] ?? 'API_ENDPOINT_NOT_FOUND';

  // 입력된 텍스트의 언어를 감지하는 메서드
  Future<String?> detectLanguage(String text) async {
    // API 키가 없거나 텍스트가 비어있으면 null을 반환하는 기능
    if (_apiKey == 'API_KEY_NOT_FOUND' || text.trim().isEmpty) {
      return null;
    }

    // API 요청 본문을 생성
    final List<Map<String, String>> requestBody = [
      {'Text': text},
    ];

    try {
      // 언어 감지 API에 POST 요청을 보내는 기능
      final response = await _dio.post(
        '$_endpoint/detect?api-version=3.0',
        data: jsonEncode(requestBody),
        options: Options(
          headers: {
            'Ocp-Apim-Subscription-Key': _apiKey,
            'Ocp-Apim-Subscription-Region': _apiRegion,
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      // 응답 코드가 200(성공)인 경우 처리
      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data;
        // 응답 데이터가 있고 언어 코드가 감지된 경우
        if (responseData.isNotEmpty && responseData[0]['language'] != null) {
          final detectedLangCode = responseData[0]['language'];
          // 앱에서 지원하는 언어 코드 목록을 가져옴
          final supportedCodes = TranslationState.supportedLanguages.values;
          // 감지된 언어가 지원 목록에 포함되어 있으면 해당 코드를 반환
          if (supportedCodes.contains(detectedLangCode)) {
            return detectedLangCode;
          }
        }
        return null; // 감지 실패 또는 미지원 언어인 경우 null 반환
      } else {
        // API 요청이 실패한 경우 예외를 발생시킴
        throw Exception('API 언어 감지 실패: ${response.statusMessage}');
      }
    } catch (e) {
      // 오류 발생 시 콘솔에 출력하고 null을 반환
      print('언어 감지 오류: $e');
      return null;
    }
  }

  // 텍스트를 번역하는 메서드
  Future<String> translate(
      String text,
      String toLanguage,
      String fromLanguage,
      ) async {
    // API 키 또는 지역 정보가 없으면 안내 메시지를 반환
    if (_apiKey == 'API_KEY_NOT_FOUND' || _apiRegion == 'API_REGION_NOT_FOUND') {
      return "API 키와 지역을 설정해주세요.";
    }
    // 번역할 텍스트가 없으면 빈 문자열을 반환
    if (text.isEmpty) {
      return "";
    }
    // API 요청 본문을 생성
    final List<Map<String, String>> requestBody = [{'Text': text}];

    try {
      // 번역 API에 POST 요청을 보내는 기능
      final response = await _dio.post(
        '$_endpoint/translate?api-version=3.0&to=$toLanguage&from=$fromLanguage',
        data: jsonEncode(requestBody),
        options: Options(
          headers: {
            'Ocp-Apim-Subscription-Key': _apiKey,
            'Ocp-Apim-Subscription-Region': _apiRegion,
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      // 응답 코드가 200(성공)인 경우 처리
      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data;
        // 번역 결과가 있는지 확인
        if (responseData.isNotEmpty &&
            responseData[0]['translations'] != null &&
            responseData[0]['translations'].isNotEmpty) {
          // 번역된 텍스트를 반환
          return responseData[0]['translations'][0]['text'];
        }
        return "번역 결과를 찾을 수 없습니다.";
      } else {
        // API 요청이 실패한 경우 예외를 발생시킴
        throw Exception('API 번역 실패: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // Dio 통신 오류 처리
      String errorMessage = '네트워크 오류가 발생했습니다.';
      if (e.response != null && e.response?.data['error'] != null) {
        errorMessage = '오류: ${e.response?.statusCode} - ${e.response?.data['error']['message']}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // 그 외 알 수 없는 오류 처리
      throw Exception('알 수 없는 오류: $e');
    }
  }
}