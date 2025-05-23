import 'package:equatable/equatable.dart';

class FileVersion extends Equatable {
  final String version;
  final String url;
  final DateTime createdAt;
  final String uploadedBy;

  const FileVersion({
    required this.version,
    required this.url,
    required this.createdAt,
    required this.uploadedBy,
  });

  @override
  List<Object?> get props => [version, url, createdAt, uploadedBy];
}

class FileEntity extends Equatable {
  final String id;
  final String name;
  final String title;
  final String description;
  final List<String> tags;
  final String url;
  final String type;
  final String folderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String currentVersion;
  final List<FileVersion> versions;

  const FileEntity({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.tags,
    required this.url,
    required this.type,
    required this.folderId,
    required this.createdAt,
    required this.updatedAt,
    required this.currentVersion,
    required this.versions,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        title,
        description,
        tags,
        url,
        type,
        folderId,
        createdAt,
        updatedAt,
        currentVersion,
        versions,
      ];
} 