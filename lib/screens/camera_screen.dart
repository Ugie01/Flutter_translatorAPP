// lib/screens/camera_screen.dart

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator_app/screens/selection_screen.dart';

// 사용 가능한 카메라 목록을 비동기적으로 가져오는 FutureProvider를 생성
final camerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return await availableCameras();
});

// 카메라 화면을 표시하는 ConsumerStatefulWidget
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

// CameraScreen의 상태를 관리하는 클래스
class _CameraScreenState extends ConsumerState<CameraScreen> {
  // 카메라를 제어하는 컨트롤러를 저장
  CameraController? _controller;
  // 컨트롤러 초기화 과정을 추적하는 Future를 저장
  Future<void>? _initializeControllerFuture;
  // 이미지 처리 중인지 여부를 저장
  bool _isProcessing = false;

  // 위젯이 제거될 때 컨트롤러 리소스를 해제하는 기능
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // 카메라 컨트롤러를 초기화하는 기능
  void _initializeCamera(List<CameraDescription> cameras) {
    // 컨트롤러가 없고 사용 가능한 카메라가 있을 때 초기화 진행
    if (_controller == null && cameras.isNotEmpty) {
      // 첫 번째 카메라를 고화질로, 오디오는 비활성화하여 컨트롤러 생성
      _controller = CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);
      _initializeControllerFuture = _controller!.initialize();
    }
  }

  // 이미지를 촬영하고 SelectionScreen으로 이동하는 기능
  Future<void> _scanImage() async {
    // 컨트롤러가 준비되지 않았거나 처리 중이면 실행하지 않음
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;
    // 처리 중 상태로 변경하여 중복 실행을 방지
    setState(() => _isProcessing = true);

    try {
      // 사진을 촬영
      final image = await _controller!.takePicture();
      // 위젯이 아직 화면에 마운트된 상태인지 확인
      if (mounted) {
        // 촬영한 이미지 경로를 가지고 SelectionScreen으로 이동
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SelectionScreen(imagePath: image.path),
          ),
        );
      }
    } catch (e) {
      // 오류 발생 시 SnackBar로 사용자에게 알림
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    } finally {
      // 처리가 끝나면 처리 중 상태를 해제
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // 위젯의 UI를 빌드하는 메서드
  @override
  Widget build(BuildContext context) {
    // camerasProvider의 상태를 감시
    final camerasAsyncValue = ref.watch(camerasProvider);
    return Scaffold(
      // camerasProvider의 상태(data, loading, error)에 따라 다른 UI를 표시
      body: camerasAsyncValue.when(
        data: (cameras) {
          // 사용 가능한 카메라가 없을 때 메시지 표시
          if (cameras.isEmpty) {
            return const Center(child: Text('사용 가능한 카메라가 없습니다.'));
          }
          // 카메라 초기화 함수 호출
          _initializeCamera(cameras);
          // 카메라 컨트롤러 초기화가 완료될 때까지 기다린 후 UI를 빌드
          return FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              // 초기화가 완료되면 카메라 미리보기를 표시
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // 카메라 미리보기를 전체 화면에 표시
                    CameraPreview(_controller!),
                    // 촬영 버튼을 화면 하단 중앙에 배치
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FloatingActionButton(
                          onPressed: _scanImage,
                          // 처리 중이면 로딩 인디케이터, 아니면 카메라 아이콘 표시
                          child: _isProcessing
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Icon(Icons.camera_alt),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // 초기화 중이면 로딩 인디케이터 표시
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        },
        // 카메라 목록을 로딩 중일 때 로딩 인디케이터 표시
        loading: () => const Center(child: CircularProgressIndicator()),
        // 오류 발생 시 오류 메시지 표시
        error: (err, stack) => Center(child: Text('카메라 로딩 실패: $err')),
      ),
    );
  }
}