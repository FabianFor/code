import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AppPermissionHandler {
  /// Solicita permisos para GUARDAR imágenes en la galería según versión de Android
  /// Compatible con políticas de Google Play Store
  static Future<bool> requestStoragePermission(BuildContext context) async {
    try {
      if (!Platform.isAndroid) {
        return true; // iOS maneja permisos automáticamente
      }

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      print('📱 Android SDK: $sdkInt');

      // Android 13+ (API 33+) - No necesita permisos para guardar en galería
      // Usa MediaStore API que no requiere permisos
      if (sdkInt >= 33) {
        print('✅ Android 13+: No requiere permisos para guardar (usa MediaStore)');
        return true;
      } 
      // Android 10-12 (API 29-32) - Scoped Storage
      // No necesita permisos para guardar en directorios públicos
      else if (sdkInt >= 29) {
        print('✅ Android 10-12: No requiere permisos (Scoped Storage)');
        return true;
      } 
      // Android 9 y anteriores (API 28-) - Necesita WRITE_EXTERNAL_STORAGE
      else {
        print('📱 Android 9-: Verificando permisos de almacenamiento...');
        
        final status = await Permission.storage.status;
        
        if (status.isGranted) {
          print('✅ Permisos ya otorgados');
          return true;
        }
        
        if (status.isDenied) {
          final result = await Permission.storage.request();
          
          if (result.isGranted) {
            print('✅ Permisos otorgados');
            return true;
          } else if (result.isPermanentlyDenied) {
            _showPermissionDeniedDialog(context, true);
            return false;
          } else {
            _showPermissionDeniedDialog(context, false);
            return false;
          }
        }
        
        if (status.isPermanentlyDenied) {
          _showPermissionDeniedDialog(context, true);
          return false;
        }
        
        return false;
      }
    } catch (e) {
      print('❌ Error al verificar permisos: $e');
      return false;
    }
  }

  /// Solicita permisos para LEER/ACCEDER a la galería (al seleccionar imágenes)
  /// Compatible con políticas de Google Play Store
  static Future<bool> requestGalleryPermission(BuildContext context) async {
    try {
      if (!Platform.isAndroid) {
        return true;
      }

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      print('📷 Solicitando permisos de galería - SDK: $sdkInt');

      // Android 13+ (API 33+) - READ_MEDIA_IMAGES
      if (sdkInt >= 33) {
        final status = await Permission.photos.status;
        
        if (status.isGranted) {
          print('✅ Permiso de fotos otorgado');
          return true;
        }
        
        if (status.isDenied) {
          final result = await Permission.photos.request();
          
          if (result.isGranted) {
            print('✅ Permiso de fotos otorgado');
            return true;
          } else if (result.isPermanentlyDenied) {
            _showGalleryPermissionDialog(context);
            return false;
          }
          
          return false;
        }
        
        if (status.isPermanentlyDenied) {
          _showGalleryPermissionDialog(context);
          return false;
        }
        
        return false;
      } 
      // Android 10-12 (API 29-32) - READ_EXTERNAL_STORAGE
      else if (sdkInt >= 29) {
        final status = await Permission.storage.status;
        
        if (status.isGranted) {
          return true;
        }
        
        final result = await Permission.storage.request();
        
        if (result.isPermanentlyDenied) {
          _showGalleryPermissionDialog(context);
          return false;
        }
        
        return result.isGranted;
      } 
      // Android 9- (API 28-) - READ_EXTERNAL_STORAGE
      else {
        final status = await Permission.storage.status;
        
        if (status.isGranted) {
          return true;
        }
        
        final result = await Permission.storage.request();
        
        if (result.isPermanentlyDenied) {
          _showGalleryPermissionDialog(context);
          return false;
        }
        
        return result.isGranted;
      }
    } catch (e) {
      print('❌ Error al solicitar permisos de galería: $e');
      return false;
    }
  }

  /// Solicita permisos de cámara
  static Future<bool> requestCameraPermission(BuildContext context) async {
    try {
      final status = await Permission.camera.status;
      
      if (status.isGranted) {
        print('✅ Permiso de cámara ya otorgado');
        return true;
      }
      
      if (status.isDenied) {
        final result = await Permission.camera.request();
        
        if (result.isGranted) {
          print('✅ Permiso de cámara otorgado');
          return true;
        } else if (result.isPermanentlyDenied) {
          _showCameraPermissionDialog(context);
          return false;
        }
        
        return false;
      }
      
      if (status.isPermanentlyDenied) {
        _showCameraPermissionDialog(context);
        return false;
      }
      
      return false;
    } catch (e) {
      print('❌ Error al solicitar permiso de cámara: $e');
      return false;
    }
  }

  // ==================== DIÁLOGOS ====================

  static void _showPermissionDeniedDialog(BuildContext context, bool isPermanent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Permisos necesarios'),
          ],
        ),
        content: Text(
          isPermanent
              ? 'Los permisos de almacenamiento han sido denegados permanentemente.\n\n'
                'Para guardar boletas, necesitas habilitar los permisos manualmente desde la configuración.'
              : 'Para guardar boletas en tu dispositivo, necesitamos acceso al almacenamiento.',
        ),
        actions: [
          if (!isPermanent)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              if (isPermanent) {
                openAppSettings();
              }
            },
            icon: Icon(isPermanent ? Icons.settings : Icons.check),
            label: Text(isPermanent ? 'Abrir Configuración' : 'Entendido'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }

  static void _showGalleryPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.photo_library, color: Color(0xFF2196F3), size: 28),
            SizedBox(width: 12),
            Text('Acceso a galería'),
          ],
        ),
        content: const Text(
          'Para seleccionar imágenes de la galería, necesitas habilitar los permisos desde la configuración.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            icon: const Icon(Icons.settings),
            label: const Text('Configuración'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }

  static void _showCameraPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.camera_alt, color: Color(0xFF2196F3), size: 28),
            SizedBox(width: 12),
            Text('Acceso a cámara'),
          ],
        ),
        content: const Text(
          'Para tomar fotos, necesitas habilitar el permiso de cámara desde la configuración.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            icon: const Icon(Icons.settings),
            label: const Text('Configuración'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }
}