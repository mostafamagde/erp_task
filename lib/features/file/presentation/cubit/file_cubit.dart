import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/file.dart';
import '../../domain/repositories/file_repository.dart';

// Events
abstract class FileEvent   {
  const FileEvent();

}

class UploadFile extends FileEvent {
  final String folderId;
  final File file;
  final String title;
  final String description;
  final List<String> tags;

  const UploadFile({
    required this.folderId,
    required this.file,
    required this.title,
    required this.description,
    required this.tags,
  });

}

class DeleteFile extends FileEvent {
  final String fileId;

  const DeleteFile(this.fileId);

}

class LoadFiles extends FileEvent {
  final String folderId;

  const LoadFiles(this.folderId);

  }

class SearchFiles extends FileEvent {
  final String query;
  final String attribute;
  final String? fileType;

  const SearchFiles({
    required this.query,
    required this.attribute,
    this.fileType,
  });

  }

class UpdateFile extends FileEvent {
  final String fileId;
  final String title;
  final String description;
  final List<String> tags;

  const UpdateFile({
    required this.fileId,
    required this.title,
    required this.description,
    required this.tags,
  });


}

class UploadNewVersion extends FileEvent {
  final String fileId;
  final File file;

  const UploadNewVersion({
    required this.fileId,
    required this.file,
  });


}

class LoadVersionHistory extends FileEvent {
  final String fileId;

  const LoadVersionHistory(this.fileId);

}

//
abstract class FileState   {
  const FileState();


}

class FileInitial extends FileState {}

class FileLoading extends FileState {}

class FilesLoaded extends FileState {
  final List<FileEntity> files;

  const FilesLoaded(this.files);

}

class FileError extends FileState {
  final String message;

  const FileError(this.message);


}

// Cubit
class FileCubit extends Cubit<FileState> {
  final FileRepository _fileRepository;
  final String _userId;

  FileCubit({
    required FileRepository fileRepository,
    required String userId,
  })  : _fileRepository = fileRepository,
        _userId = userId,
        super(FileInitial());

  Future<void> uploadFile({
    required String folderId,
    required File file,
    required String title,
    required String description,
    required List<String> tags,
  }) async {
    try {
      emit(FileLoading());
      await _fileRepository.uploadFile(
        userId: _userId,
        folderId: folderId,
        file: file,
        title: title,
        description: description,
        tags: tags,
      );
      await loadFiles(folderId);
    } catch (e) {
      emit(FileError(e.toString()));
    }
  }

  Future<void> deleteFile(String fileId, String folderId) async {
    try {
      emit(FileLoading());
      await _fileRepository.deleteFile(_userId, fileId);
      await loadFiles(folderId);
    } catch (e) {
      emit(FileError(e.toString()));
    }
  }

  Future<void> loadFiles(String folderId) async {
    try {
      emit(FileLoading());
      final files = await _fileRepository.getFiles(
        userId: _userId,
        folderId: folderId,
      );
      emit(FilesLoaded(files));
    } catch (e) {
      emit(FileError(e.toString()));
    }
  }

  Future<void> searchFiles({
    required String query,
    required String attribute,
    String? fileType,
  }) async {
    try {
      emit(FileLoading());
      final files = await _fileRepository.searchFiles(
        userId: _userId,
        query: query,
        attribute: attribute,
        fileType: fileType,
      );
      emit(FilesLoaded(files));
    } catch (e) {
      emit(FileError(e.toString()));
    }
  }

  Future<void> updateFile({
    required String fileId,
    required String title,
    required String description,
    required List<String> tags,
  }) async {
    try {
      emit(FileLoading());
      await _fileRepository.updateFile(
        userId: _userId,
        fileId: fileId,
        title: title,
        description: description,
        tags: tags,
      );
      // Reload files after update
      final file = await _fileRepository.getFile(_userId, fileId);
      await loadFiles(file.folderId);
    } catch (e) {
      emit(FileError(e.toString()));
    }
  }

  Future<void> uploadNewVersion({
    required String fileId,
    required File file,
  }) async {
    try {
      emit(FileLoading());
      final updatedFile = await _fileRepository.uploadNewVersion(
        userId: _userId,
        fileId: fileId,
        file: file,
      );
      await loadFiles(updatedFile.folderId);
    } catch (e) {
      emit(FileError(e.toString()));
    }
  }

  Future<List<FileVersion>> getVersionHistory(String fileId) async {
    try {
      return await _fileRepository.getVersionHistory(
        userId: _userId,
        fileId: fileId,
      );
    } catch (e) {
      emit(FileError(e.toString()));
      return [];
    }
  }

  Future<FileVersion?> getVersion(String fileId, String version) async {
    try {
      return await _fileRepository.getVersion(
        userId: _userId,
        fileId: fileId,
        version: version,
      );
    } catch (e) {
      emit(FileError(e.toString()));
      return null;
    }
  }
} 