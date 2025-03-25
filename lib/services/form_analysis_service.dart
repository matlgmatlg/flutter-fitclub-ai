import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

class FormAnalysisService {
  static FormAnalysisService? _instance;
  bool _isAnalyzing = false;
  Process? _pythonProcess;
  StreamSubscription? _outputSubscription;
  StreamSubscription? _errorSubscription;

  static FormAnalysisService get instance {
    _instance ??= FormAnalysisService._();
    return _instance!;
  }

  FormAnalysisService._();

  bool get isAnalyzing => _isAnalyzing;

  Future<void> startAnalysis(String exerciseName) async {
    if (_isAnalyzing) return;
    _isAnalyzing = true;

    try {
      // Get the path to the Python script
      final scriptPath = await _getScriptPath(exerciseName);
      debugPrint('Starting analysis with script: $scriptPath');

      // Get Python executable path
      final pythonPath = await _getPythonPath();
      debugPrint('Using Python at: $pythonPath');

      // Start the Python process
      _pythonProcess = await Process.start(
        pythonPath,
        [scriptPath],
        mode: ProcessStartMode.normal,
        runInShell: true,
      );

      // Handle process output using utf8 decoder
      _outputSubscription = _pythonProcess!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        debugPrint('Python output: $line');
      });

      // Handle process errors
      _errorSubscription = _pythonProcess!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        debugPrint('Python error: $line');
      });

      // Handle process exit
      _pythonProcess!.exitCode.then((code) {
        debugPrint('Python process exited with code: $code');
        _isAnalyzing = false;
      });

    } catch (e) {
      debugPrint('Error starting analysis: $e');
      _isAnalyzing = false;
      rethrow;
    }
  }

  Future<void> stopAnalysis() async {
    if (!_isAnalyzing) return;

    try {
      // Cancel stream subscriptions
      await _outputSubscription?.cancel();
      await _errorSubscription?.cancel();
      _outputSubscription = null;
      _errorSubscription = null;

      // Kill the Python process
      _pythonProcess?.kill();
      _pythonProcess = null;
      _isAnalyzing = false;
    } catch (e) {
      debugPrint('Error stopping analysis: $e');
      rethrow;
    }
  }

  Future<String> _getPythonPath() async {
    try {
      if (Platform.isWindows) {
        // On Windows, try to find Python in standard locations
        final username = Platform.environment['USERNAME'] ?? '';
        final possiblePaths = [
          r'C:\Python39\python.exe',
          r'C:\Python310\python.exe',
          r'C:\Python311\python.exe',
          r'C:\Program Files\Python39\python.exe',
          r'C:\Program Files\Python310\python.exe',
          r'C:\Program Files\Python311\python.exe',
          'C:\\Users\\$username\\AppData\\Local\\Programs\\Python\\Python39\\python.exe',
          'C:\\Users\\$username\\AppData\\Local\\Programs\\Python\\Python310\\python.exe',
          'C:\\Users\\$username\\AppData\\Local\\Programs\\Python\\Python311\\python.exe',
        ];

        for (final pythonPath in possiblePaths) {
          if (await File(pythonPath).exists()) {
            return pythonPath;
          }
        }

        // If not found in standard locations, try using 'where'
        final result = await Process.run('where', ['python'], runInShell: true);
        if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
          final paths = result.stdout.toString().trim().split('\n');
          return paths.first.trim();
        }
      }

      // Default to 'python' command as fallback
      return 'python';
    } catch (e) {
      debugPrint('Error finding Python path: $e');
      return 'python';
    }
  }

  Future<String> _getScriptPath(String exerciseName) async {
    final normalizedName = exerciseName.toLowerCase().trim();
    
    final scriptMap = {
      'barbell back squat': 'Squat.py',
      'barbell back squats': 'Squat.py',
      'back squat': 'Squat.py',
      'back squats': 'Squat.py',
      'squat': 'Squat.py',
      'squats': 'Squat.py',
    };

    final scriptName = scriptMap[normalizedName];
    if (scriptName == null) {
      throw Exception('No script found for exercise: $exerciseName');
    }

    try {
      final scriptPath = path.join(
        Directory.current.path,
        'assets',
        'FitClub AI',
        'Exercises',
        scriptName,
      );

      final normalizedPath = path.normalize(scriptPath);
      debugPrint('Looking for script at: $normalizedPath');
      
      if (!await File(normalizedPath).exists()) {
        throw Exception('Script not found at path: $normalizedPath');
      }

      return normalizedPath;
    } catch (e) {
      debugPrint('Error getting script path: $e');
      rethrow;
    }
  }

  void dispose() {
    stopAnalysis();
  }
} 