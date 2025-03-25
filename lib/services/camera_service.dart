import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  static CameraService? _instance;
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  String? _lastError;
  int _retryCount = 0;
  static const int maxRetries = 3;

  // Singleton pattern
  static CameraService get instance {
    _instance ??= CameraService._();
    return _instance!;
  }

  CameraService._();

  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;
  String? get lastError => _lastError;

  Future<void> _releaseAllCameras() async {
    try {
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }
      _isInitialized = false;
      // Add a small delay to ensure camera is released
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error releasing cameras: $e');
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      await _releaseAllCameras();
    }

    try {
      // Check if we're on Windows
      if (defaultTargetPlatform == TargetPlatform.windows) {
        debugPrint('Initializing camera on Windows platform');
      }

      // Add a delay before initialization to ensure previous instances are cleaned up
      await Future.delayed(const Duration(seconds: 1));

      _cameras = await availableCameras();
      debugPrint('Available cameras: ${_cameras?.length ?? 0}');
      
      if (_cameras == null || _cameras!.isEmpty) {
        _lastError = 'No cameras found on device';
        throw CameraException('no_cameras', _lastError!);
      }

      // Print information about available cameras
      for (var i = 0; i < _cameras!.length; i++) {
        debugPrint('Camera $i: ${_cameras![i].name} (${_cameras![i].lensDirection})');
      }

      // Try to find a suitable camera (prefer front camera for form checking)
      var selectedCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras![0],
      );

      debugPrint('Selected camera: ${selectedCamera.name}');
      
      // Initialize with lower resolution for better compatibility
      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,  // Lower resolution for better compatibility
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888, // Add explicit format for Windows
      );

      await _controller!.initialize();
      _isInitialized = true;
      _lastError = null;
      _retryCount = 0;
      debugPrint('Camera initialized successfully');
    } on CameraException catch (e) {
      _lastError = 'Camera Error: ${e.description}';
      debugPrint(_lastError);
      
      // Retry logic for camera abort errors
      if ((e.description ?? '').contains('abort') && _retryCount < maxRetries) {
        _retryCount++;
        debugPrint('Retrying camera initialization (attempt $_retryCount)');
        await _releaseAllCameras();
        await Future.delayed(const Duration(seconds: 2));
        return initialize();
      }
      
      throw Exception(_lastError);
    } on PlatformException catch (e) {
      _lastError = 'Platform Error: ${e.message}';
      debugPrint(_lastError);
      throw Exception(_lastError);
    } catch (e) {
      _lastError = 'Error initializing camera: $e';
      debugPrint(_lastError);
      throw Exception(_lastError);
    }
  }

  Future<void> checkCameraAccess() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw CameraException('no_cameras', 'No cameras available on device');
      }
      debugPrint('Camera access check successful. Found ${_cameras!.length} cameras');
    } catch (e) {
      debugPrint('Camera access check failed: $e');
      rethrow;
    }
  }

  Future<void> startImageStream(Function(CameraImage) onImage) async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    await _controller!.startImageStream(onImage);
  }

  Future<void> stopImageStream() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }
  }

  Future<XFile?> takePicture() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    try {
      final XFile image = await _controller!.takePicture();
      return image;
    } catch (e) {
      throw Exception('Error taking picture: $e');
    }
  }

  Future<List<String>> getAvailableExercises() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8000/exercises'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['exercises']);
      } else {
        throw Exception('Failed to get exercises: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get exercises: $e');
    }
  }

  Future<Map<String, dynamic>> analyzeFrame(String exerciseName) async {
    if (!_isInitialized) {
      throw Exception('Camera not initialized');
    }

    try {
      // Capture frame
      final XFile image = await _controller!.takePicture();

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8000/analyze/$exerciseName'),
      );

      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'video_frame',
          image.path,
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Form analysis failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Form analysis failed: $e');
    }
  }

  Future<void> startVideoStream(
    String exerciseName,
    Function(Map<String, dynamic>) onAnalysis,
  ) async {
    if (!_isInitialized) {
      throw Exception('Camera not initialized');
    }

    try {
      await _controller!.startImageStream((CameraImage image) async {
        // Convert CameraImage to format suitable for analysis
        // This is a simplified version - you'll need to implement proper conversion
        final XFile convertedImage = await _convertImageToFile(image);
        
        // Analyze frame
        final result = await analyzeFrame(exerciseName);
        
        // Call callback with results
        onAnalysis(result);
      });
    } catch (e) {
      throw Exception('Failed to start video stream: $e');
    }
  }

  Future<void> stopVideoStream() async {
    if (!_isInitialized) return;
    await _controller!.stopImageStream();
  }

  Future<XFile> _convertImageToFile(CameraImage image) async {
    // TODO: Implement proper conversion from CameraImage to XFile
    // This is a placeholder - you'll need to implement the actual conversion
    throw UnimplementedError('Image conversion not implemented');
  }

  void dispose() {
    _releaseAllCameras();
    _lastError = null;
    _retryCount = 0;
  }
} 