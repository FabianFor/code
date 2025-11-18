import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio para guardar imágenes en la galería
/// Compatible con todas las versiones de Android SIN paquetes externos problemáticos
class GallerySaver {
  /// Guarda una imagen en la galería del dispositivo
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

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        print('📱 Android SDK: $sdkInt');

        // Android 10+ (API 29+) - Scoped Storage
        // Guardar en Pictures/MiNegocio
        final Directory? externalDir = await getExternalStorageDirectory();
        
        if (externalDir == null) {
          throw Exception('No se pudo acceder al almacenamiento externo');
        }

        // Navegar hacia arriba para llegar a /storage/emulated/0/
        final String basePath = externalDir.path.split('/Android')[0];
        final String targetPath = '$basePath/Pictures/MiNegocio';
        
        final Directory targetDir = Directory(targetPath);
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
          print('📁 Carpeta creada: $targetPath');
        }

        // Copiar archivo
        final String newPath = '$targetPath/$fileName';
        await file.copy(newPath);
        
        print('✅ Imagen guardada en: $newPath');
        
        // Notificar al sistema (Media Scanner)
        await _scanFile(newPath);
        
        return newPath;
      } else {
        // iOS
        final directory = await getApplicationDocumentsDirectory();
        final newPath = '${directory.path}/$fileName';
        await file.copy(newPath);
        return newPath;
      }
    } catch (e, stackTrace) {
      print('❌ Error en saveImageToGallery: $e');
      print('Stack: $stackTrace');
      rethrow;
    }
  }

  /// Notifica al sistema que un nuevo archivo fue creado (Media Scanner)
  static Future<void> _scanFile(String path) async {
    try {
      if (Platform.isAndroid) {
        // Comando para refrescar la galería en Android
        final result = await Process.run('am', [
          'broadcast',
          '-a',
          'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
          '-d',
          'file://$path'
        ]);
        
        if (result.exitCode == 0) {
          print('📷 Media Scanner notificado');
        } else {
          print('⚠️ Media Scanner no disponible (normal en emuladores)');
        }
      }
    } catch (e) {
      print('⚠️ No se pudo notificar al Media Scanner: $e');
      // No es crítico, la imagen ya está guardada
    }
  }

  /// Genera un nombre único para el archivo
  static String generateFileName(int invoiceNumber) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'boleta_${invoiceNumber}_$timestamp.png';
  }

  /// Guarda la boleta en galería
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