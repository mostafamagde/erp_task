import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';

// Events
abstract class FolderEvent extends Equatable {
  const FolderEvent();

  @override
  List<Object?> get props => [];
}

class CreateFolder extends FolderEvent {
  final String name;
  final String? parentId;

  const CreateFolder({required this.name, this.parentId});

  @override
  List<Object?> get props => [name, parentId];
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

  @override
  List<Object?> get props => [id, name, parentId];
}

class DeleteFolder extends FolderEvent {
  final String id;

  const DeleteFolder(this.id);

  @override
  List<Object> get props => [id];
}

class LoadFolders extends FolderEvent {
  final String? parentId;

  const LoadFolders({this.parentId});

  @override
  List<Object?> get props => [parentId];
}

// States
abstract class FolderState extends Equatable {
  const FolderState();

  @override
  List<Object?> get props => [];
}

class FolderInitial extends FolderState {}

class FolderLoading extends FolderState {}

class FoldersLoaded extends FolderState {
  final List<Folder> folders;

  const FoldersLoaded(this.folders);

  @override
  List<Object> get props => [folders];
}

class FolderError extends FolderState {
  final String message;

  const FolderError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class FolderCubit extends Cubit<FolderState> {
  final FolderRepository _folderRepository;

  FolderCubit({required FolderRepository folderRepository})
      : _folderRepository = folderRepository,
        super(FolderInitial());

  Future<void> createFolder(String name, {String? parentId}) async {
    try {
      emit(FolderLoading());
      await _folderRepository.createFolder(name: name, parentId: parentId);
      await loadFolders(parentId: parentId);
    } catch (e) {
      emit(FolderError(e.toString()));
    }
  }

  Future<void> updateFolder(String id, String name, {String? parentId}) async {
    try {
      emit(FolderLoading());
      await _folderRepository.updateFolder(
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
      await _folderRepository.deleteFolder(id);
      await loadFolders(parentId: parentId);
    } catch (e) {
      emit(FolderError(e.toString()));
    }
  }

  Future<void> loadFolders({String? parentId}) async {
    try {
      emit(FolderLoading());
      final folders = await _folderRepository.getFolders(parentId: parentId);
      emit(FoldersLoaded(folders));
    } catch (e) {
      emit(FolderError(e.toString()));
    }
  }
} 