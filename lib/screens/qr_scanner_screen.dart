import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QrScannerScreen extends StatefulWidget {
  final void Function(String uid, String username) onScanned;
  const QrScannerScreen({super.key, required this.onScanned});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _dialogShown = false;
  bool _isLoading = false;
  bool _scanHandled = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Extracts the username from a `connecta://profile/<username>` link.
  ///
  /// For `connecta://profile/aditya`, `Uri.parse` yields host `profile` and
  /// pathSegments `[aditya]`, so we validate the scheme + host and take the
  /// last path segment. Old Branch QR codes (`https://1efy2.app.link/<hash>`)
  /// are intentionally rejected — they never resolved to a username anyway.
  String? extractUsername(String code) {
    try {
      final uri = Uri.parse(code);
      if (uri.scheme == 'connecta' &&
          uri.host == 'profile' &&
          uri.pathSegments.isNotEmpty) {
        final username = uri.pathSegments.last.trim();
        return username.isEmpty ? null : username;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  void _handleDetection(String code) async {
    if (_scanHandled) return;
    final username = extractUsername(code);
    if (username != null && username.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('id')
            .eq('username', username)
            .maybeSingle();

        if (data != null && data['id'] != null) {
          final uid = data['id'] as String;
          _scanHandled = true;
          Navigator.pop(context);
          widget.onScanned(uid, username);
          return;
        }
      } catch (_) {
        // fall through to error dialog
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    if (_dialogShown) return;
    setState(() => _dialogShown = true);
    controller.stop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Scan Failed'),
        content: const Text(
          'This QR code does not point to a valid Connecta profile.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _dialogShown = false);
              controller.start();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Stack(
            children: [
              MobileScanner(
                controller: controller,
                fit: BoxFit.cover,
                onDetect: (BarcodeCapture capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final raw = barcodes.first.rawValue;
                    if (raw != null) _handleDetection(raw);
                  }
                },
              ),
              const _ScannerOverlay(
                holeWidthFraction: 0.75,
                overlayColor: Color(0x88000000),
                cornerColor: Colors.blue,
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: _FlashlightButton(controller: controller),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color overlayColor;
  final Color cornerColor;
  final double holeWidthFraction;

  ScannerOverlayPainter({
    required this.overlayColor,
    required this.cornerColor,
    required this.holeWidthFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double holeWidth = size.width * holeWidthFraction;
    final double holeHeight = holeWidth;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect holeRect = Rect.fromCenter(
      center: center,
      width: holeWidth,
      height: holeHeight,
    );

    final Rect fullScreenRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.saveLayer(fullScreenRect, Paint());

    canvas.drawRect(fullScreenRect, Paint()..color = overlayColor);
    canvas.drawRect(
      holeRect,
      Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.fill,
    );
    canvas.restore();

    const double strokeWidth = 4.0;
    const double cornerLen = 30.0;
    final Paint cornerPaint = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Offset tl = holeRect.topLeft;
    canvas.drawLine(tl, Offset(tl.dx + cornerLen, tl.dy), cornerPaint);
    canvas.drawLine(tl, Offset(tl.dx, tl.dy + cornerLen), cornerPaint);

    final Offset tr = holeRect.topRight;
    canvas.drawLine(tr, Offset(tr.dx - cornerLen, tr.dy), cornerPaint);
    canvas.drawLine(tr, Offset(tr.dx, tr.dy + cornerLen), cornerPaint);

    final Offset bl = holeRect.bottomLeft;
    canvas.drawLine(bl, Offset(bl.dx + cornerLen, bl.dy), cornerPaint);
    canvas.drawLine(bl, Offset(bl.dx, bl.dy - cornerLen), cornerPaint);

    final Offset br = holeRect.bottomRight;
    canvas.drawLine(br, Offset(br.dx - cornerLen, br.dy), cornerPaint);
    canvas.drawLine(br, Offset(br.dx, br.dy - cornerLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.overlayColor != overlayColor ||
        oldDelegate.cornerColor != cornerColor ||
        oldDelegate.holeWidthFraction != holeWidthFraction;
  }
}

class _ScannerOverlay extends StatelessWidget {
  final double holeWidthFraction;
  final Color overlayColor;
  final Color cornerColor;

  const _ScannerOverlay({
    this.holeWidthFraction = 0.75,
    this.overlayColor = const Color(0x88000000),
    this.cornerColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: ScannerOverlayPainter(
        holeWidthFraction: holeWidthFraction,
        overlayColor: overlayColor,
        cornerColor: cornerColor,
      ),
    );
  }
}

class _FlashlightButton extends StatefulWidget {
  final MobileScannerController controller;
  const _FlashlightButton({required this.controller});

  @override
  State<_FlashlightButton> createState() => _FlashlightButtonState();
}

class _FlashlightButtonState extends State<_FlashlightButton> {
  bool _isTorchOn = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await widget.controller.toggleTorch();
        setState(() => _isTorchOn = !_isTorchOn);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isTorchOn ? Icons.flashlight_on : Icons.flashlight_off,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
