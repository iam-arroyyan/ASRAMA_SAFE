// lib/services/image_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  
  // Max size for Base64 storage (80KB compressed)
  static const int maxCompressedSize = 80 * 1024; // 80KB
  
  /// Pick image from gallery or camera
  static Future<File?> pickImage({
    required ImageSource source,
    required BuildContext context,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,  // Resize saat pick
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Show dialog to choose image source
  static Future<File?> showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Foto Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.blue),
                ),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await pickImage(
                    source: ImageSource.gallery,
                    context: context,
                  );
                  if (context.mounted && file != null) {
                    Navigator.pop(context, file);
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.green),
                ),
                title: const Text('Ambil Foto'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await pickImage(
                    source: ImageSource.camera,
                    context: context,
                  );
                  if (context.mounted && file != null) {
                    Navigator.pop(context, file);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Compress image heavily for Base64 storage
  static Future<Uint8List?> compressImage(File file) async {
    try {
      final filePath = file.absolute.path;
      
      // First compression attempt - quality 70
      Uint8List? result = await FlutterImageCompress.compressWithFile(
        filePath,
        minWidth: 256,
        minHeight: 256,
        quality: 70,
        format: CompressFormat.jpeg,
      );
      
      if (result == null) return null;
      
      // If still too large, compress more aggressively
      if (result.length > maxCompressedSize) {
        result = await FlutterImageCompress.compressWithFile(
          filePath,
          minWidth: 200,
          minHeight: 200,
          quality: 50,
          format: CompressFormat.jpeg,
        );
      }
      
      // If STILL too large, compress even more
      if (result != null && result.length > maxCompressedSize) {
        result = await FlutterImageCompress.compressWithFile(
          filePath,
          minWidth: 150,
          minHeight: 150,
          quality: 40,
          format: CompressFormat.jpeg,
        );
      }
      
      // Final check
      if (result != null && result.length > maxCompressedSize) {
        result = await FlutterImageCompress.compressWithFile(
          filePath,
          minWidth: 128,
          minHeight: 128,
          quality: 30,
          format: CompressFormat.jpeg,
        );
      }
      
      print('📸 Compressed image size: ${result?.length ?? 0} bytes');
      return result;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  /// Convert image file to Base64 string (compressed)
  static Future<String?> fileToBase64(File file) async {
    try {
      final compressed = await compressImage(file);
      if (compressed == null) return null;
      
      final base64String = base64Encode(compressed);
      print('📸 Base64 string length: ${base64String.length}');
      return base64String;
    } catch (e) {
      print('Error converting to base64: $e');
      return null;
    }
  }

  /// Convert Base64 string back to image bytes
  static Uint8List? base64ToBytes(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      print('Error decoding base64: $e');
      return null;
    }
  }

  /// Build profile image widget from Base64 or show default icon
  static Widget buildProfileImage({
    String? base64String,
    double radius = 50,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    final bytes = base64ToBytes(base64String);
    
    if (bytes != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(bytes),
        backgroundColor: backgroundColor ?? Colors.grey[200],
      );
    }
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[200],
      child: Icon(
        Icons.person,
        size: radius,
        color: iconColor ?? Colors.grey[400],
      ),
    );
  }
}
