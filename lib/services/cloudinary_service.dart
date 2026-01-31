import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../config/env_config.dart';

/// Service for uploading media to Cloudinary
class CloudinaryService {
  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(
      EnvConfig.cloudinaryCloudName,
      EnvConfig.cloudinaryUploadPreset,
      cache: false,
    );
  }

  /// Upload image to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String> uploadImage(File image, {String folder = 'chat_images'}) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload voice message to Cloudinary
  /// Returns the secure URL of the uploaded audio
  Future<String> uploadVoice(File audio, {String folder = 'voice_messages'}) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          audio.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Video, // Audio uses video resource type
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload voice message: $e');
    }
  }

  /// Upload profile photo to Cloudinary
  /// Returns the secure URL of the uploaded photo
  Future<String> uploadProfilePhoto(File photo) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          photo.path,
          folder: 'profile_photos',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }
}
