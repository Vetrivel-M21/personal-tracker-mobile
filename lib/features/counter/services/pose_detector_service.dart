import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../config/rep_counter_config.dart';
import '../engine/rep_counter_engine.dart';

class PoseDetectorService {
  late final PoseDetector _poseDetector;
  bool _isProcessing = false;
  DateTime _lastFrameTime = DateTime.now();

  PoseDetectorService() {
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.base, // Optimized for low-end Android hardware
      ),
    );
  }

  /// Processes camera image frame with rate-limiting to preserve CPU on budget devices.
  Future<Map<int, PoseKeypoint>?> processCameraImage(
    CameraImage image,
    CameraDescription camera,
  ) async {
    final now = DateTime.now();
    if (_isProcessing ||
        now.difference(_lastFrameTime).inMilliseconds < RepCounterConfig.throttleIntervalMs) {
      return null;
    }

    _isProcessing = true;
    _lastFrameTime = now;

    try {
      final inputImage = _convertCameraImageToInputImage(image, camera);
      if (inputImage == null) return null;

      final List<Pose> poses = await _poseDetector.processImage(inputImage);
      if (poses.isEmpty) return null;

      final pose = poses.first;
      final Map<int, PoseKeypoint> landmarks = {};

      pose.landmarks.forEach((type, landmark) {
        landmarks[type.index] = PoseKeypoint(
          x: landmark.x,
          y: landmark.y,
          z: landmark.z,
          confidence: landmark.likelihood,
        );
      });

      return landmarks;
    } catch (_) {
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image, CameraDescription camera) {
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (image.planes.isEmpty) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Future<void> dispose() async {
    await _poseDetector.close();
  }
}
