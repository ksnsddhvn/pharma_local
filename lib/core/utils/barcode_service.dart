import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Size;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

/// Wraps google_mlkit_barcode_scanning for on-device barcode decoding.
/// On non-mobile platforms, provides a manual-entry fallback.
class BarcodeService {
  static bool get isSupportedPlatform =>
      Platform.isAndroid || Platform.isIOS;

  /// Scans a single barcode from a CameraImage frame (Android/iOS).
  /// Returns the raw barcode string or null if nothing detected.
  static Future<String?> scanFromCameraImage(
    CameraImage image,
    CameraDescription camera,
  ) async {
    if (!isSupportedPlatform) return null;

    final scanner = BarcodeScanner(formats: [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.qrCode,
    ]);

    try {
      final inputImage = _convertCameraImage(image, camera);
      if (inputImage == null) return null;

      final barcodes = await scanner.processImage(inputImage);
      return barcodes.isNotEmpty ? barcodes.first.rawValue : null;
    } finally {
      scanner.close();
    }
  }

  static InputImage? _convertCameraImage(
      CameraImage image, CameraDescription camera) {
    try {
      final rotation = InputImageRotationValue.fromRawValue(
              camera.sensorOrientation) ??
          InputImageRotation.rotation0deg;

      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

      return InputImage.fromBytes(
        bytes: _concatenatePlanes(image.planes),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint('BarcodeService: image conversion error: $e');
      return null;
    }
  }

  static Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }
}
