import '../entities/folder.dart';

abstract class FolderRepository {
  Future<Folder> createFolder({
    required String userId,
    required String name,
    String? parentId,
  });

  Future<Folder> updateFolder({
    required String userId,
    required String id,
    required String name,
    String? parentId,
  });

  Future<void> deleteFolder(String userId, String id);

  Future<Folder> getFolder(String userId, String id);

  Future<List<Folder>> getFolders({
    required String userId,
    String? parentId,
  });
} 