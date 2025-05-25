import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/routes/app_router.dart';
import '../cubit/file_cubit.dart';
import '../../domain/entities/file.dart';
import '../pages/file_search_page.dart';

class FilesPage extends StatefulWidget {
  final String folderId;

  const FilesPage({
    super.key,
    required this.folderId,
  });

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  @override
  void initState() {
    super.initState();
    // Load files when the page is opened
    context.read<FileCubit>().loadFiles(widget.folderId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload files when dependencies change (e.g., when returning from file upload)
    context.read<FileCubit>().loadFiles(widget.folderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => _showSearchDialog(context),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.fileUpload, arguments: widget.folderId), // Pass folderId as an argument(,
            icon: const Icon(Icons.upload_file),
          ),
        ],
      ),
      body: BlocBuilder<FileCubit, FileState>(
        builder: (context, state) {
          if (state is FileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<FileCubit>().loadFiles(widget.folderId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is FilesLoaded) {
            if (state.files.isEmpty) {
              return const Center(
                child: Text('No files in this folder'),
              );
            }
            return _buildFileList(context, state.files);
          }

          return const Center(child: Text('No files found'));
        },
      ),
    );
  }

  Widget _buildFileList(BuildContext context, List<FileEntity> files) {
    if (files.isEmpty) {
      return const Center(child: Text('No files found'));
    }

    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: _getFileIcon(file.type),
            title: Text(file.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.description),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: file.tags
                      .map((tag) => Chip(
                            label: Text(tag),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version: ${file.currentVersion}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _showVersionHistory(context, file),
                  icon: const Icon(Icons.history, color: Colors.blue),
                ),
                IconButton(
                  onPressed: () => _showEditDialog(context, file),
                  icon: const Icon(Icons.edit, color: Colors.blue),
                ),
                IconButton(
                  onPressed: () => _showDeleteConfirmation(context, file),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            onTap: () => _openFile(file.url),
          ),
        );
      },
    );
  }

  Widget _getFileIcon(String fileType) {
    IconData iconData;
    Color iconColor;

    switch (fileType) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'word':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'excel':
        iconData = Icons.table_chart;
        iconColor = Colors.green;
        break;
      case 'powerpoint':
        iconData = Icons.slideshow;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(iconData, color: iconColor),
    );
  }

  Future<void> _openFile(String url) async {
    try {
      final uri = Uri.parse(url);

      await launchUrl(
        uri,mode:LaunchMode.externalApplication
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, FileEntity file) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FileCubit>().deleteFile(file.id, widget.folderId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSearchDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Files'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Search by title or tags',
            hintText: 'Enter search terms...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<FileCubit>().searchFiles(
                  query: controller.text,
                  attribute: 'title', // Default to title search
                  fileType: null,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, FileEntity file) async {
    final titleController = TextEditingController(text: file.title);
    final descriptionController = TextEditingController(text: file.description);
    final tagsController = TextEditingController(text: file.tags.join(', '));

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit File'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma-separated)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., important, project, draft',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final tags = tagsController.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList();

              context.read<FileCubit>().updateFile(
                    fileId: file.id,
                    title: titleController.text,
                    description: descriptionController.text,
                    tags: tags,
                  );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showVersionHistory(BuildContext context, FileEntity file) async {
    final versions = await context.read<FileCubit>().getVersionHistory(file.id);
    
    if (!context.mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Version History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: versions.length,
            itemBuilder: (context, index) {
              final version = versions[index];
              return ListTile(
                title: Text('Version ${version.version}'),
                subtitle: Text(
                  'Uploaded on ${version.createdAt.toString().split('.')[0]}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (version.version != file.currentVersion)
                      IconButton(
                        onPressed: () => _openFile(version.url),
                        icon: const Icon(Icons.visibility),
                      ),
                    IconButton(
                      onPressed: () => _uploadNewVersion(context, file),
                      icon: const Icon(Icons.upload_file),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadNewVersion(BuildContext context, FileEntity file) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'],
      );

      if (result != null && context.mounted) {
        final newFile = File(result.files.single.path!);
        await context.read<FileCubit>().uploadNewVersion(
              fileId: file.id,
              file: newFile,
            );
        Navigator.pop(context); // Close version history dialog
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading new version: $e')),
        );
      }
    }
  }
}
