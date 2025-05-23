import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/file.dart';
import '../../domain/repositories/file_repository.dart';

class FileRepositoryImpl implements FileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String _collection = 'files';

  FileRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  String _getUserCollectionPath(String userId) => 'users/$userId/$_collection';

  String _getStoragePath(String userId, String folderId, String fileName) =>
      'users/$userId/folders/$folderId/$fileName';

  @override
  Future<FileEntity> uploadFile({
    required String userId,
    required String folderId,
    required File file,
    required String title,
    required String description,
    required List<String> tags,
  }) async {
    // Validate file type
    final fileType = _getFileType(file.path);
    if (!_isValidFileType(fileType)) {
      throw Exception('Invalid file type. Only PDF, Word, Excel, and PowerPoint files are allowed.');
    }

    // Upload file to Firebase Storage
    final storageRef = _storage.ref().child(_getStoragePath(userId, folderId, file.path.split('/').last));
    final uploadTask = await storageRef.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // Create file document in Firestore
    final docRef = _firestore.collection(_getUserCollectionPath(userId)).doc();
    final now = DateTime.now();
    const initialVersion = '1.0';

    final version = FileVersion(
      version: initialVersion,
      url: downloadUrl,
      createdAt: now,
      uploadedBy: userId,
    );

    final fileEntity = FileEntity(
      id: docRef.id,
      name: file.path.split('/').last,
      title: title,
      description: description,
      tags: tags,
      url: downloadUrl,
      type: fileType,
      folderId: folderId,
      createdAt: now,
      updatedAt: now,
      currentVersion: initialVersion,
      versions: [version],
    );

    await docRef.set({
      'name': fileEntity.name,
      'title': fileEntity.title,
      'description': fileEntity.description,
      'tags': fileEntity.tags,
      'url': fileEntity.url,
      'type': fileEntity.type,
      'folderId': fileEntity.folderId,
      'createdAt': fileEntity.createdAt.toIso8601String(),
      'updatedAt': fileEntity.updatedAt.toIso8601String(),
      'currentVersion': fileEntity.currentVersion,
      'versions': [
        {
          'version': version.version,
          'url': version.url,
          'createdAt': version.createdAt.toIso8601String(),
          'uploadedBy': version.uploadedBy,
        },
      ],
    });

    return fileEntity;
  }

  @override
  Future<void> deleteFile(String userId, String fileId) async {
    final docRef = _firestore.collection(_getUserCollectionPath(userId)).doc(fileId);
    final doc = await docRef.get();
    
    if (!doc.exists) {
      throw Exception('File not found');
    }

    final data = doc.data() as Map<String, dynamic>;
    final storageRef = _storage.ref().child(_getStoragePath(
      userId,
      data['folderId'] as String,
      data['name'] as String,
    ));

    // Delete from Storage
    await storageRef.delete();
    // Delete from Firestore
    await docRef.delete();
  }

  @override
  Future<FileEntity> getFile(String userId, String fileId) async {
    final doc = await _firestore.collection(_getUserCollectionPath(userId)).doc(fileId).get();
    if (!doc.exists) {
      throw Exception('File not found');
    }
    return _mapDocumentToFile(doc);
  }

  @override
  Future<List<FileEntity>> getFiles({
    required String userId,
    required String folderId,
  }) async {
    final querySnapshot = await _firestore
        .collection(_getUserCollectionPath(userId))
        .where('folderId', isEqualTo: folderId)
        .get();

    return querySnapshot.docs.map(_mapDocumentToFile).toList();
  }

  @override
  Future<List<FileEntity>> searchFiles({
    required String userId,
    required String query,
    required String attribute,
    String? fileType,
  }) async {
    Query queryRef = _firestore.collection(_getUserCollectionPath(userId));

    // Apply file type filter if specified
    if (fileType != null) {
      queryRef = queryRef.where('type', isEqualTo: fileType);
    }

    // Apply search based on attribute
    switch (attribute) {
      case 'title':
        queryRef = queryRef
            .where('title', isGreaterThanOrEqualTo: query)
            .where('title', isLessThanOrEqualTo: query + '\uf8ff');
        break;
      case 'description':
        queryRef = queryRef
            .where('description', isGreaterThanOrEqualTo: query)
            .where('description', isLessThanOrEqualTo: query + '\uf8ff');
        break;
      case 'tags':
        queryRef = queryRef.where('tags', arrayContains: query);
        break;
      case 'file type':
        queryRef = queryRef.where('type', isEqualTo: query);
        break;
      default:
        // Default to title search
        queryRef = queryRef
            .where('title', isGreaterThanOrEqualTo: query)
            .where('title', isLessThanOrEqualTo: query + '\uf8ff');
    }

    final querySnapshot = await queryRef.get();
    return querySnapshot.docs.map(_mapDocumentToFile).toList();
  }

  @override
  Future<void> updateFile({
    required String userId,
    required String fileId,
    required String title,
    required String description,
    required List<String> tags,
  }) async {
    final docRef = _firestore.collection(_getUserCollectionPath(userId)).doc(fileId);
    final doc = await docRef.get();
    
    if (!doc.exists) {
      throw Exception('File not found');
    }

    await docRef.update({
      'title': title,
      'description': description,
      'tags': tags,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<FileEntity> uploadNewVersion({
    required String userId,
    required String fileId,
    required File file,
  }) async {
    final docRef = _firestore.collection(_getUserCollectionPath(userId)).doc(fileId);
    final doc = await docRef.get();
    
    if (!doc.exists) {
      throw Exception('File not found');
    }

    final data = doc.data() as Map<String, dynamic>;
    final currentVersion = data['currentVersion'] as String;
    final newVersion = _incrementVersion(currentVersion);

    // Upload new version to Storage
    final storageRef = _storage.ref().child(_getStoragePath(
      userId,
      data['folderId'] as String,
      '${file.path.split('/').last}_v$newVersion',
    ));
    final uploadTask = await storageRef.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // Create new version object
    final version = FileVersion(
      version: newVersion,
      url: downloadUrl,
      createdAt: DateTime.now(),
      uploadedBy: userId,
    );

    // Update Firestore document
    final versions = List<Map<String, dynamic>>.from(data['versions'] as List);
    versions.add({
      'version': version.version,
      'url': version.url,
      'createdAt': version.createdAt.toIso8601String(),
      'uploadedBy': version.uploadedBy,
    });

    await docRef.update({
      'currentVersion': newVersion,
      'url': downloadUrl,
      'versions': versions,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    return _mapDocumentToFile(await docRef.get());
  }

  @override
  Future<List<FileVersion>> getVersionHistory({
    required String userId,
    required String fileId,
  }) async {
    final doc = await _firestore.collection(_getUserCollectionPath(userId)).doc(fileId).get();
    if (!doc.exists) {
      throw Exception('File not found');
    }

    final data = doc.data() as Map<String, dynamic>;
    final versions = List<Map<String, dynamic>>.from(data['versions'] as List);
    
    return versions.map((v) => FileVersion(
      version: v['version'] as String,
      url: v['url'] as String,
      createdAt: DateTime.parse(v['createdAt'] as String),
      uploadedBy: v['uploadedBy'] as String,
    )).toList();
  }

  @override
  Future<FileVersion> getVersion({
    required String userId,
    required String fileId,
    required String version,
  }) async {
    final versions = await getVersionHistory(userId: userId, fileId: fileId);
    return versions.firstWhere(
      (v) => v.version == version,
      orElse: () => throw Exception('Version not found'),
    );
  }

  String _incrementVersion(String currentVersion) {
    final parts = currentVersion.split('.');
    final major = int.parse(parts[0]);
    final minor = int.parse(parts[1]);
    return '$major.${minor + 1}';
  }

  String _getFileType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'word';
      case 'xls':
      case 'xlsx':
        return 'excel';
      case 'ppt':
      case 'pptx':
        return 'powerpoint';
      default:
        return extension;
    }
  }

  bool _isValidFileType(String fileType) {
    return ['pdf', 'word', 'excel', 'powerpoint'].contains(fileType);
  }

  FileEntity _mapDocumentToFile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final versions = List<Map<String, dynamic>>.from(data['versions'] as List);
    
    return FileEntity(
      id: doc.id,
      name: data['name'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      tags: List<String>.from(data['tags'] as List),
      url: data['url'] as String,
      type: data['type'] as String,
      folderId: data['folderId'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      currentVersion: data['currentVersion'] as String,
      versions: versions.map((v) => FileVersion(
        version: v['version'] as String,
        url: v['url'] as String,
        createdAt: DateTime.parse(v['createdAt'] as String),
        uploadedBy: v['uploadedBy'] as String,
      )).toList(),
    );
  }
} 