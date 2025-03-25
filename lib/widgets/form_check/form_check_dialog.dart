import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../services/camera_service.dart';
import '../../services/form_analysis_service.dart';

class FormCheckDialog extends StatefulWidget {
  final String exerciseName;

  const FormCheckDialog({
    Key? key,
    required this.exerciseName,
  }) : super(key: key);

  @override
  State<FormCheckDialog> createState() => _FormCheckDialogState();
}

class _FormCheckDialogState extends State<FormCheckDialog> {
  final CameraService _cameraService = CameraService.instance;
  final FormAnalysisService _formAnalysisService = FormAnalysisService.instance;
  bool _isLoading = true;
  String? _error;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.checkCameraAccess();
      await _cameraService.initialize();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _getErrorMessage(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleAnalysis() async {
    if (_isAnalyzing) {
      await _formAnalysisService.stopAnalysis();
    } else {
      try {
        await _formAnalysisService.startAnalysis(widget.exerciseName);
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = 'Failed to start analysis: $e';
          });
        }
        return;
      }
    }

    if (mounted) {
      setState(() {
        _isAnalyzing = !_isAnalyzing;
      });
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('No cameras')) {
      return 'No camera found on your device. Please make sure you have a working camera.';
    } else if (error.contains('camera in use')) {
      return 'Camera is being used by another application. Please close other apps using the camera (like Zoom, Teams, or mmhmm) and try again.';
    } else if (error.contains('permission')) {
      return 'Camera permission denied. Please enable camera access in your system settings.';
    } else if (error.contains('only supported on Windows')) {
      return 'Form check is currently only supported on Windows.\nSupport for other platforms coming soon.';
    }
    return 'Failed to initialize camera: $error\n\nPlease ensure no other apps are using your camera and try again.';
  }

  @override
  void dispose() {
    _formAnalysisService.dispose();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Form Check - ${widget.exerciseName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    _initializeCamera();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Calculate the available width considering padding
    final availableWidth = MediaQuery.of(context).size.width * 0.9 - 32.0; // 90% of screen width minus padding
    final availableHeight = MediaQuery.of(context).size.height * 0.8 - 120.0; // 80% of screen height minus header and padding
    
    // Calculate the size that fits both constraints while maintaining aspect ratio
    final targetAspectRatio = 4.0 / 3.0; // Standard webcam aspect ratio
    final width = availableWidth;
    final height = width / targetAspectRatio;
    
    // If height is too large, recalculate based on available height
    final finalHeight = height > availableHeight ? availableHeight : height;
    final finalWidth = finalHeight * targetAspectRatio;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: finalWidth,
            height: finalHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CameraPreview(_cameraService.controller!),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: Icon(_isAnalyzing ? Icons.stop : Icons.play_arrow),
                label: Text(_isAnalyzing ? 'Stop Analysis' : 'Start Analysis'),
                onPressed: _toggleAnalysis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAnalyzing ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
          if (_isAnalyzing) ...[
            const SizedBox(height: 16),
            const Text(
              'Analyzing form...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
} 