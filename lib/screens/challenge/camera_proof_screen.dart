import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/geo_models.dart';
import '../../services/camera_proof_service.dart';
import '../../widgets/app_components.dart';

class CameraProofScreen extends StatefulWidget {
  const CameraProofScreen({super.key, required this.challenge});
  final Challenge challenge;
  @override
  State<CameraProofScreen> createState() => _CameraProofScreenState();
}

class _CameraProofScreenState extends State<CameraProofScreen> {
  final service = CameraProofService();
  CameraController? controller;
  XFile? proof;
  Object? error;
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = await service.initialize();
      if (mounted) setState(() => controller = c);
    } catch (e) {
      if (mounted) setState(() => error = e);
    }
  }

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    try {
      final f = await service.capture();
      if (mounted) setState(() => proof = f);
    } catch (e) {
      if (mounted) setState(() => error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (proof != null)
      return _ConfirmPhoto(
        challenge: widget.challenge,
        file: proof!,
        onRetake: () => setState(() => proof = null),
      );
    final ready = controller?.value.isInitialized == true;
    return MobileFrame(
      backgroundColor: Colors.black,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: ready
                  ? _CameraFillPreview(controller: controller!)
                  : Image.asset(widget.challenge.imageAsset, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: .24)),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: IconButton.filled(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
            Positioned(
              left: 36,
              right: 36,
              bottom: 30,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: ready
                        ? _capture
                        : () => setState(() => proof = XFile('')),
                    child: Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5),
                      ),
                      child: const Center(
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    AppLocalizations.of(context).positionLandmark,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmPhoto extends StatelessWidget {
  const _ConfirmPhoto({
    required this.challenge,
    required this.file,
    required this.onRetake,
  });
  final Challenge challenge;
  final XFile file;
  final VoidCallback onRetake;
  @override
  Widget build(BuildContext context) => MobileFrame(
    child: Scaffold(
      body: Column(
        children: [
          Expanded(
            child: file.path.isEmpty || kIsWeb
                ? Image.asset(
                    challenge.imageAsset,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : Image.file(
                    File(file.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
          ),
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                GradientButton(
                  label: AppLocalizations.of(context).confirm,
                  onPressed: () {
                    final proof = file.path.isEmpty
                        ? ''
                        : '?proof=${Uri.encodeComponent(file.path)}';
                    Navigator.pushReplacementNamed(
                      context,
                      '/uploading-proof/${challenge.id}$proof',
                    );
                  },
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: onRetake,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: Text(AppLocalizations.of(context).retake),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _CameraFillPreview extends StatelessWidget {
  const _CameraFillPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.previewSize;
    if (size == null) return CameraPreview(controller);
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.height,
          height: size.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}
