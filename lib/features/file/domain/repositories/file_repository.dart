import 'dart:io';
import '../entities/file.dart';

abstract class FileRepository {
  Future<FileEntity> uploadFile({
    required String userId,
    required String folderId,
    required File file,
    required String title,
    required String description,
    required List<String> tags,
  });

  Future<void> deleteFile(String userId, String fileId);

  Future<FileEntity> getFile(String userId, String fileId);

  Future<List<FileEntity>> getFiles({
    required String userId,
    required String folderId,
  });

  Future<List<FileEntity>> searchFiles({
    required String userId,
    required String query,
    required String attribute,
    String? fileType,
  });

  Future<void> updateFile({
    required String userId,
    required String fileId,
    required String title,
    required String description,
    required List<String> tags,
  });

  Future<FileEntity> uploadNewVersion({
    required String userId,
    required String fileId,
    required File file,
  });

  Future<List<FileVersion>> getVersionHistory({
    required String userId,
    required String fileId,
  });

  Future<FileVersion> getVersion({
    required String userId,
    required String fileId,
    required String version,
  });
} 