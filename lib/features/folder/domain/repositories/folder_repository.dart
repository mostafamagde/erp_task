import '../entities/folder.dart';

abstract class FolderRepository {
  Future<Folder> createFolder({
    required String name,
    String? parentId,
  });

  Future<Folder> updateFolder({
    required String id,
    required String name,
    String? parentId,
  });

  Future<void> deleteFolder(String id);

  Future<Folder> getFolder(String id);

  Future<List<Folder>> getFolders({String? parentId});
} 