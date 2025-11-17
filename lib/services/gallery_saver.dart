import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio para guardar imágenes en la galería
/// Compatible con todas las versiones de Android y políticas de Play Store
class GallerySaver {
  /// Guarda una imagen en la galería del dispositivo
  /// Retorna la ruta donde se guardó la imagen
  static Future<String> saveImageToGallery({
    required String imagePath,
    required String fileName,
  }) async {
    try {
      print('💾 Guardando imagen en galería...');
      
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('El archivo no existe: $imagePath');
      }

      final bytes = await file.readAsBytes();
      print('📦 Bytes leídos: ${bytes.length}');

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        print('📱 Android SDK: $sdkInt');

        // Guardar en la galería usando image_gallery_saver
        // Este paquete maneja automáticamente Scoped Storage y MediaStore
        final result = await ImageGallerySaver.saveImage(
          bytes,
          quality: 100,
          name: fileName,
        );

        print('✅ Resultado: $result');

        if (result['isSuccess'] == true) {
          final savedPath = result['filePath'] ?? 'Galería';
          print('✅ Imagen guardada en: $savedPath');
          return savedPath;
        } else {
          throw Exception('Error al guardar en galería');
        }
      } else {
        // iOS
        final result = await ImageGallerySaver.saveImage(bytes);
        if (result['isSuccess'] == true) {
          return result['filePath'] ?? 'Galería';
        } else {
          throw Exception('Error al guardar en galería');
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error en saveImageToGallery: $e');
      print('Stack: $stackTrace');
      rethrow;
    }
  }

  /// Genera un nombre único para el archivo
  static String generateFileName(int invoiceNumber) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'boleta_${invoiceNumber}_$timestamp.png';
  }

  /// Guarda temporalmente la imagen y luego la copia a la galería
  static Future<String> saveInvoiceToGallery({
    required String tempImagePath,
    required int invoiceNumber,
  }) async {
    try {
      final fileName = generateFileName(invoiceNumber);
      final savedPath = await saveImageToGallery(
        imagePath: tempImagePath,
        fileName: fileName,
      );
      
      // Eliminar archivo temporal
      try {
        await File(tempImagePath).delete();
        print('🗑️ Archivo temporal eliminado');
      } catch (e) {
        print('⚠️ No se pudo eliminar archivo temporal: $e');
      }
      
      return savedPath;
    } catch (e) {
      print('❌ Error en saveInvoiceToGallery: $e');
      rethrow;
    }
  }
}