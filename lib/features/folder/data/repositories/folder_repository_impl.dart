import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';

class FolderRepositoryImpl implements FolderRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'folders';

  FolderRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Folder> createFolder({
    required String name,
    String? parentId,
  }) async {
    final docRef = _firestore.collection(_collection).doc();
    final now = DateTime.now();
    
    final folder = Folder(
      id: docRef.id,
      name: name,
      parentId: parentId,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set({
      'name': folder.name,
      'parentId': folder.parentId,
      'createdAt': folder.createdAt.toIso8601String(),
      'updatedAt': folder.updatedAt.toIso8601String(),
    });

    return folder;
  }

  @override
  Future<Folder> updateFolder({
    required String id,
    required String name,
    String? parentId,
  }) async {
    final docRef = _firestore.collection(_collection).doc(id);
    final now = DateTime.now();

    await docRef.update({
      'name': name,
      'parentId': parentId,
      'updatedAt': now.toIso8601String(),
    });

    final doc = await docRef.get();
    return _mapDocumentToFolder(doc);
  }

  @override
  Future<void> deleteFolder(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<Folder> getFolder(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) {
      throw Exception('Folder not found');
    }
    return _mapDocumentToFolder(doc);
  }

  @override
  Future<List<Folder>> getFolders({String? parentId}) async {
    Query query = _firestore.collection(_collection);
    
    if (parentId != null) {
      query = query.where('parentId', isEqualTo: parentId);
    } else {
      query = query.where('parentId', isNull: true);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => _mapDocumentToFolder(doc))
        .toList();
  }

  Folder _mapDocumentToFolder(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Folder(
      id: doc.id,
      name: data['name'] as String,
      parentId: data['parentId'] as String?,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }
} 