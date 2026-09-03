import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/riqsi_theme.dart';
import '../../../../state/app_state.dart';

class CameraSimulator extends StatefulWidget {
  final AppState state;

  const CameraSimulator({super.key, required this.state});

  @override
  State<CameraSimulator> createState() => _CameraSimulatorState();
}

class _CameraSimulatorState extends State<CameraSimulator> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  
  Timer? _frameTimer;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final backCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras!.first,
        );

        _cameraController = CameraController(
          backCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        print("[CAMERA] No hay cámaras físicas disponibles.");
      }
    } catch (e) {
      print("[CAMERA] Error de inicialización: $e");
    }
  }

  Future<Uint8List?> _getLastCapturedImageFromCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = tempDir.listSync();
      
      final jpgFiles = files.whereType<File>().where((file) {
        final name = file.path.split(Platform.pathSeparator).last;
        return name.startsWith('CAP') && name.endsWith('.jpg');
      }).toList();
      
      if (jpgFiles.isEmpty) return null;
      
      jpgFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      final newestFile = jpgFiles.first;
      
      final diff = DateTime.now().difference(newestFile.lastModifiedSync());
      if (diff.inSeconds < 5) {
        return await newestFile.readAsBytes();
      }
    } catch (e) {
      print("[CAMERA] Error al recuperar imagen del cache: $e");
    }
    return null;
  }

  void _startFrameSending() {
    _frameTimer?.cancel();
    _frameTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) async {
      final status = widget.state.assistanceState;
      final isScanning = status != AssistanceState.inactive;
      
      if (!isScanning || !_isCameraInitialized || _cameraController == null || !_cameraController!.value.isInitialized) {
        return;
      }
      
      if (!widget.state.isConnected) {
        return;
      }

      if (_isCapturing) return;

      try {
        _isCapturing = true;
        
        Uint8List? bytes;
        try {
          final XFile file = await _cameraController!.takePicture();
          bytes = await file.readAsBytes();
        } catch (e) {
          print("[CAMERA] Falló takePicture (Exif bug). Intentando recuperar del cache...");
          bytes = await _getLastCapturedImageFromCache();
          if (bytes == null) {
            rethrow;
          }
        }
        
        widget.state.sendFrameBytes(bytes);
      } catch (e) {
        print("[CAMERA] Error de captura de frame: $e");
      } finally {
        _isCapturing = false;
      }
    });
  }

  void _stopFrameSending() {
    _frameTimer?.cancel();
    _frameTimer = null;
  }

  @override
  void dispose() {
    _stopFrameSending();
    _scanController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.state.assistanceState;
    final isScanning = status != AssistanceState.inactive;

    if (isScanning && widget.state.isConnected) {
      if (_frameTimer == null) {
        _startFrameSending();
      }
    } else {
      _stopFrameSending();
    }

    Widget cameraContent;
    if (isScanning && _isCameraInitialized && _cameraController != null && _cameraController!.value.isInitialized) {
      cameraContent = ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _cameraController!.value.previewSize!.height,
            height: _cameraController!.value.previewSize!.width,
            child: CameraPreview(_cameraController!),
          ),
        ),
      );
    } else {
      cameraContent = _buildCameraBackground(status);
    }

    return Center(
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: status == AssistanceState.riskDetected
                      ? RiqsiTheme.alertHigh
                      : (status == AssistanceState.objectDetected
                          ? RiqsiTheme.accentCyan
                          : RiqsiTheme.textSecondary.withOpacity(0.2)),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: status == AssistanceState.riskDetected
                        ? RiqsiTheme.alertHigh.withOpacity(0.25)
                        : Colors.black45,
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  cameraContent,

                  if (!isScanning)
                    _buildInactiveOverlay()
                  else ...[
                    AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: _scanAnimation.value * (MediaQuery.of(context).size.height * 0.45),
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: status == AssistanceState.riskDetected
                                      ? RiqsiTheme.alertHigh
                                      : RiqsiTheme.accentCyan,
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (widget.state.activeDetection != null) ...[
                      if (widget.state.activeDetection!.objects.isNotEmpty)
                        ...widget.state.activeDetection!.objects.map((obj) => _buildIndividualObjectBox(obj))
                      else
                        _buildDetectionBoundingBox(widget.state.activeDetection!),
                    ],
                  ],
                  if (widget.state.isCameraError)
                    _buildCameraErrorOverlay(),
                  if (!widget.state.isConnected)
                    _buildOfflineOverlay(),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildCameraBackground(AssistanceState status) {
    return Container(
      color: const Color(0xFF0D0D0D),
      child: CustomPaint(
        painter: GridPainter(
          gridColor: status == AssistanceState.riskDetected
              ? RiqsiTheme.alertHigh.withOpacity(0.1)
              : RiqsiTheme.textSecondary.withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildInactiveOverlay() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: RiqsiTheme.darkBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: RiqsiTheme.textSecondary.withOpacity(0.3), width: 2),
                ),
                child: const Icon(
                  Icons.visibility_off_rounded,
                  size: 44,
                  color: RiqsiTheme.accentCyan,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Asistencia Inactiva",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Toca el botón central abajo para iniciar el asistente de visión.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: RiqsiTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetectionBoundingBox(DetectionEvent detection) {
    final isHighRisk = detection.riskLevel == 'Alto';
    final accentColor = isHighRisk ? RiqsiTheme.alertHigh : RiqsiTheme.accentCyan;

    double left = 40.0;
    double top = 80.0;
    double width = 200.0;
    double height = 220.0;

    if (detection.relativePosition == 'Derecha') {
      left = 130.0;
      top = 100.0;
    } else if (detection.relativePosition == 'Izquierda') {
      left = 20.0;
      top = 120.0;
    }

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height - 40,
            decoration: BoxDecoration(
              border: Border.all(color: accentColor, width: 3.5),
              borderRadius: BorderRadius.circular(16),
              color: accentColor.withOpacity(0.08),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: accentColor, width: 3),
                        left: BorderSide(color: accentColor, width: 3),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: accentColor, width: 3),
                        right: BorderSide(color: accentColor, width: 3),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    isHighRisk ? Icons.report_problem_rounded : Icons.center_focus_strong,
                    color: accentColor,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isHighRisk ? Icons.warning_amber_rounded : Icons.radar,
                  color: isHighRisk ? Colors.white : Colors.black,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  "${detection.label} (${detection.relativePosition})",
                  style: TextStyle(
                    color: isHighRisk ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualObjectBox(DetectedObject obj) {
    final isHighRisk = obj.riskLevel == 'Alto';
    final accentColor = isHighRisk ? RiqsiTheme.alertHigh : RiqsiTheme.accentCyan;

    double left = 40.0;
    double top = 80.0;
    double width = 160.0;
    double height = 180.0;

    if (obj.relativePosition == 'Derecha') {
      left = 180.0;
      top = 110.0;
    } else if (obj.relativePosition == 'Izquierda') {
      left = 15.0;
      top = 130.0;
    } else {
      left = 100.0;
      top = 70.0;
    }

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height - 40,
            decoration: BoxDecoration(
              border: Border.all(color: accentColor, width: 3.0),
              borderRadius: BorderRadius.circular(12),
              color: accentColor.withOpacity(0.06),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    isHighRisk ? Icons.report_problem_rounded : Icons.center_focus_strong,
                    color: accentColor,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isHighRisk ? Icons.warning_amber_rounded : Icons.radar,
                  color: isHighRisk ? Colors.white : Colors.black,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  "${obj.label} (${obj.relativePosition})",
                  style: TextStyle(
                    color: isHighRisk ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraErrorOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam_off_rounded, size: 48, color: RiqsiTheme.alertHigh),
                const SizedBox(height: 12),
                Text(
                  "Error de Cámara",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: RiqsiTheme.alertHigh,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "No se pudo acceder a la cámara. Verifique los permisos en el sistema.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.amber),
                const SizedBox(height: 12),
                Text(
                  "Sin Conexión",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Riqsi está funcionando sin conexión. Las descripciones pueden verse reducidas.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color gridColor;

  GridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    const double gridSpacing = 40.0;

    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
