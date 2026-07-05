import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QRCodeWithImage extends StatelessWidget {
  final String data;
  final ImageProvider imageProvider;
  final double width;
  final Color qrColor;
  
  const QRCodeWithImage({
    super.key,
    required this.data,
    required this.imageProvider,
    this.width = 300,
    this.qrColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    // Create QR code data
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.H, // Highest error correction
    );
    
    // Create QR image
    final qrImage = QrImage(qrCode);
    
    // Create decoration
    final decoration = PrettyQrDecoration(
      image: PrettyQrDecorationImage(
        image: imageProvider,
        position: PrettyQrDecorationImagePosition.embedded,
      ),
      shape: PrettyQrSmoothSymbol(
        color: qrColor,
      ),
      background: Colors.white,
    );
    
    // Return a container with fixed width to control size
    return SizedBox(
      width: width,
      height: width,
      child: PrettyQrView(
        qrImage: qrImage,
        decoration: decoration,
      ),
    );
  }
}

// Example usage:
//
// QRCodeWithImage(
//   data: 'https://flutter.dev',
//   imageProvider: AssetImage('assets/logo.png'),
//   width: 300,
//   qrColor: Colors.blue,
// )