import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';

// Events
abstract class FolderEvent   {
  const FolderEvent();

}

class CreateFolder extends FolderEvent {
  final String name;
  final String? parentId;

  const CreateFolder({required this.name, this.parentId});

}

class UpdateFolder extends FolderEvent {
  final String id;
  final String name;
  final String? parentId;

  const UpdateFolder({
    required this.id,
    required this.name,
    this.parentId,
  });


}

class DeleteFolder extends FolderEvent {
  final String id;

  const DeleteFolder(this.id);

}

class LoadFolders extends FolderEvent {
  final String? parentId;

  const LoadFolders({this.parentId});


}

// States
abstract class FolderState   {
  const FolderState();


}

class FolderInitial extends FolderState {}

class FolderLoading extends FolderState {}

class FoldersLoaded extends FolderState {
  final List<Folder> folders;
  final String? searchQuery;

  const FoldersLoaded(this.folders, {this.searchQuery});


}

class FolderError extends FolderState {
  final String message;

  const FolderError(this.message);


}

// Cubit
class FolderCubit extends Cubit<FolderState> {
  final FolderRepository _folderRepository;
  final String _userId;
  String? _currentSearchQuery;

  FolderCubit({
    required FolderRepository folderRepository,
    required String userId,
  })  : _folderRepository = folderRepository,
        _userId = userId,
        super(FolderInitial());

  Future<void> createFolder(String name, {String? parentId}) async {
    try {
      emit(FolderLoading());
      await _folderRepository.createFolder(
        userId: _userId,
        name: name,
        parentId: parentId,
      );
      await loadFolders(parentId: parentId);
    } catch (e) {
      emit(FolderError(e.toString()));
    }
  }

  Future<void> updateFolder(String id, String name, {String? parentId}) async {
    try {
      emit(FolderLoading());
      await _folderRepository.updateFolder(
        userId: _userId,
        id: id,
        name: name,
        parentId: parentId,
      );
      await loadFolders(parentId: parentId);
    } catch (e) {
      emit(FolderError(e.toString()));
    }
  }

  Future<void> deleteFolder(String id, {String? parentId}) async {
    try {
      emit(FolderLoading());
      await _folderRepository.deleteFolder(_userId, id);
      await loadFolders(parentId: parentId);
    } catch (e) {
      emit(FolderError(e.toString()));
    }
  }

  Future<void> searchFolders(String query) async {
    try {
      emit(FolderLoading());
      _currentSearchQuery = query.isEmpty ? null : query;
      final folders = await _folderRepository.getFolders(
        userId: _userId,
        parentId: null,
      );
      
      if (_currentSearchQuery != null) {
        final filteredFolders = folders.where((folder) =>
          folder.name.toLowerCase().contains(_currentSearchQuery!.toLowerCase())
        ).toList();
        emit(FoldersLoaded(filteredFolders, searchQuery: _currentSearchQuery));
      } else {
        emit(FoldersLoaded(folders));
      }
    } catch (e) {
      emit(FolderError(e.toString()));
    }
  }

  Future<void> loadFolders({String? parentId}) async {
    try {
      emit(FolderLoading());
      final folders = await _folderRepository.getFolders(
        userId: _userId,
        parentId: parentId,
      );
      
      if (_currentSearchQuery != null) {
        final filteredFolders = folders.where((folder) =>
          folder.name.toLowerCase().contains(_currentSearchQuery!.toLowerCase())
        ).toList();
        emit(FoldersLoaded(filteredFolders, searchQuery: _currentSearchQuery));
      } else {
        emit(FoldersLoaded(folders));
      }
    } catch (e) {
      emit(FolderError(e.toString()));
    }
  }

  Future<Folder> getFolder(String id) async {
    try {
      return await _folderRepository.getFolder(_userId, id);
    } catch (e) {
      throw Exception('Failed to get folder: ${e.toString()}');
    }
  }
} 