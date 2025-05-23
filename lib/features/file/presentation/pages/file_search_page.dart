import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cubit/file_cubit.dart';
import '../../domain/entities/file.dart';

class FileSearchPage extends StatefulWidget {
  const FileSearchPage({super.key});

  @override
  State<FileSearchPage> createState() => _FileSearchPageState();
}

class _FileSearchPageState extends State<FileSearchPage> {
  final _searchController = TextEditingController();
  String _selectedAttribute = 'title';
  String _selectedFileType = 'all';
  bool _isSearching = false;

  final List<String> _searchAttributes = [
    'title',
    'description',
    'tags',
    'file type',
  ];

  final List<String> _fileTypes = [
    'all',
    'pdf',
    'word',
    'excel',
    'powerpoint',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_searchController.text.isNotEmpty) {
      setState(() => _isSearching = true);
      context.read<FileCubit>().searchFiles(
            query: _searchController.text,
            attribute: _selectedAttribute,
            fileType: _selectedFileType == 'all' ? null : _selectedFileType,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Files'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: 'Enter search term...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _performSearch,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedAttribute,
                        decoration: const InputDecoration(
                          labelText: 'Search in',
                          border: OutlineInputBorder(),
                        ),
                        items: _searchAttributes
                            .map((attr) => DropdownMenuItem(
                                  value: attr,
                                  child: Text(attr.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedAttribute = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFileType,
                        decoration: const InputDecoration(
                          labelText: 'File Type',
                          border: OutlineInputBorder(),
                        ),
                        items: _fileTypes
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedFileType = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<FileCubit, FileState>(
              builder: (context, state) {
                if (state is FileLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is FileError) {
                  return Center(child: Text(state.message));
                }

                if (state is FilesLoaded) {
                  if (state.files.isEmpty) {
                    return const Center(
                      child: Text('No files found matching your search criteria'),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.files.length,
                    itemBuilder: (context, index) {
                      final file = state.files[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                            ],
                          ),
                          trailing: Text(
                            'Version: ${file.currentVersion}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onTap: () => _openFile(file.url),
                        ),
                      );
                    },
                  );
                }

                return const Center(
                  child: Text('Enter search criteria to find files'),
                );
              },
            ),
          ),
        ],
      ),
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
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: $e')),
        );
      }
    }
  }
} 