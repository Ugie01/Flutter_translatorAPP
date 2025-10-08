// lib/screens/selection_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:translator_app/api/translation_api_service.dart';
import 'package:translator_app/providers/main_screen_provider.dart';
import 'package:translator_app/providers/translation_provider.dart';
import 'package:translator_app/services/text_recognition_service.dart';
import 'dart:ui' as ui;
import 'dart:async';

// 촬영된 이미지에서 텍스트를 선택하는 화면
class SelectionScreen extends ConsumerStatefulWidget {
  // 카메라 화면에서 전달받은 이미지 파일 경로를 저장
  final String imagePath;
  const SelectionScreen({super.key, required this.imagePath});

  @override
  ConsumerState<SelectionScreen> createState() => _SelectionScreenState();
}

// SelectionScreen의 상태를 관리하는 클래스
class _SelectionScreenState extends ConsumerState<SelectionScreen> {
  // 외부 서비스 인스턴스를 생성
  final TextRecognitionService _textRecognitionService = TextRecognitionService();
  final TranslationApiService _apiService = TranslationApiService();

  // 상태 변수들을 선언
  RecognizedText? _recognizedText; // 이미지에서 인식된 텍스트 데이터를 저장
  final Set<TextBlock> _selectedBlocks = {}; // 사용자가 선택한 텍스트 블록들을 저장
  ui.Image? _image; // 이미지의 크기 정보를 계산하기 위해 저장
  bool _isProcessing = false; // 완료 버튼 클릭 후 처리 중인지 여부를 저장

  // 위젯이 생성될 때 한 번 호출되는 초기화 메서드
  @override
  void initState() {
    super.initState();
    _loadImageAndProcessText(); // 이미지 로드와 텍스트 인식을 시작
  }

  // 위젯이 제거될 때 서비스 리소스를 해제하는 기능
  @override
  void dispose() {
    _textRecognitionService.dispose();
    super.dispose();
  }

  // 이미지를 로드하고 텍스트를 인식하는 기능
  Future<void> _loadImageAndProcessText() async {
    final imageFile = File(widget.imagePath);
    final imageData = await imageFile.readAsBytes(); // 파일을 바이트로 읽음
    final image = await decodeImageFromList(imageData); // 바이트를 이미지 객체로 디코딩
    // 텍스트 인식 서비스로 이미지에서 텍스트를 추출
    final recognizedText = await _textRecognitionService.processImage(widget.imagePath);

    // 상태를 업데이트하여 화면을 다시 그리게 함
    setState(() {
      _image = image;
      _recognizedText = recognizedText;
    });
  }

  // 사용자가 텍스트 블록을 탭했을 때 호출되는 기능
  void _onTextBlockTap(TextBlock block) {
    setState(() {
      // 이미 선택된 블록이면 선택 해제, 아니면 선택 목록에 추가 (토글)
      if (_selectedBlocks.contains(block)) {
        _selectedBlocks.remove(block);
      } else {
        _selectedBlocks.add(block);
      }
    });
  }

  // '완료' 버튼을 눌렀을 때 선택된 텍스트들을 처리하는 기능
  Future<void> _processSelection() async {
    // 선택된 텍스트가 없으면 사용자에게 알림
    if (_selectedBlocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("텍스트를 선택해주세요.")));
      return;
    }

    // 처리 중 상태로 변경
    setState(() => _isProcessing = true);

    // 선택된 텍스트 블록의 글자들을 줄바꿈으로 합쳐 하나의 문자열로 만듦
    final fullText = _selectedBlocks.map((b) => b.text).join('\n');

    // 합쳐진 텍스트가 비어있지 않은 경우
    if (fullText.trim().isNotEmpty) {
      // API를 통해 텍스트의 언어를 감지
      final detectedLanguage = await _apiService.detectLanguage(fullText);
      // 언어가 감지되면 번역 화면의 출발 언어를 해당 언어로 설정
      if (detectedLanguage != null) {
        ref.read(translationProvider.notifier).setSourceLanguage(detectedLanguage);
      }
      // 도착언어를 한국어로 설정
      ref.read(translationProvider.notifier).setTargetLanguage('ko');
      // 번역 화면의 입력 텍스트를 선택된 텍스트로 설정
      ref.read(translationProvider.notifier).setInputText(fullText);
    }

    // 번역 탭(인덱스 0)으로 이동
    ref.read(mainScreenProvider.notifier).state = 0;
    // 현재 선택 화면을 닫음
    if (mounted) Navigator.of(context).pop();
  }

  // 위젯의 UI를 빌드하는 메서드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("번역할 텍스트 선택"),
        actions: [
          // 완료 버튼 (선택된 텍스트가 있을 때만 활성화)
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _selectedBlocks.isEmpty ? null : _processSelection,
            tooltip: '선택 완료',
          )
        ],
      ),
      // 처리 중이면 로딩 인디케이터, 아니면 이미지와 텍스트 블록을 표시
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : _buildInteractiveImage(),
    );
  }

  // 사용자가 상호작용할 수 있는 이미지 UI를 생성하는 메서드
  Widget _buildInteractiveImage() {
    // 이미지나 인식된 텍스트가 아직 준비되지 않았으면 로딩 인디케이터 표시
    if (_image == null || _recognizedText == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // InteractiveViewer: 사용자가 이미지를 확대/축소/이동할 수 있게 함
    return InteractiveViewer(
      maxScale: 5.0,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: _image!.width.toDouble(),
          height: _image!.height.toDouble(),
          child: Stack(
            children: [
              // 1. 배경 이미지 표시
              Image.file(File(widget.imagePath)),

              // 2. 인식된 각 텍스트 블록 위에 선택 가능한 영역을 오버레이
              ..._recognizedText!.blocks.map((block) {
                return Positioned(
                  left: block.boundingBox.left,
                  top: block.boundingBox.top,
                  width: block.boundingBox.width,
                  height: block.boundingBox.height,
                  child: GestureDetector(
                    onTap: () => _onTextBlockTap(block),
                    child: Container(
                      decoration: BoxDecoration(
                        // 선택 여부에 따라 색상과 테두리를 다르게 표시
                        color: _selectedBlocks.contains(block)
                            ? Colors.blue.withOpacity(0.5)
                            : Colors.yellow.withOpacity(0.4),
                        border: Border.all(
                          color: _selectedBlocks.contains(block)
                              ? Colors.blueAccent
                              : Colors.yellow.shade700,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}