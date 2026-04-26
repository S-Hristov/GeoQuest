import 'package:camera/camera.dart';

class CameraProofService {
  CameraController? _controller;
  CameraController? get controller => _controller;

  Future<CameraController?> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return null;
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    return _controller;
  }

  Future<XFile?> capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return null;
    return controller.takePicture();
  }

  Future<void> dispose() async => _controller?.dispose();
}
