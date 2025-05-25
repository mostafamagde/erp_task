import 'package:erp_tassk/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../file/presentation/pages/file_search_page.dart';
import '../cubit/folder_cubit.dart';
import '../../domain/entities/folder.dart';
import '../../../file/presentation/cubit/file_cubit.dart';
import '../../../file/presentation/pages/file_upload_page.dart';
import '../../../file/presentation/pages/files_page.dart';

class FolderPage extends StatefulWidget {
  final String? parentId;

  const FolderPage({super.key, this.parentId});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.parentId == null
            ? _isSearching
                ? TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search folders...',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      context.read<FolderCubit>().searchFolders(value);
                    },
                  )
                : const Text('Folders')
            : FutureBuilder<Folder>(
                future: context.read<FolderCubit>().getFolder(widget.parentId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading...');
                  }
                  if (snapshot.hasError) {
                    return const Text('Error');
                  }
                  return Text(snapshot.data?.name ?? 'Folder');
                },
              ),
        actions: [
          if (widget.parentId ==
              null) // Only show search and create folder buttons in main folders page
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    context.read<FolderCubit>().searchFolders('');
                  }
                });
              },
            ),
          if (widget.parentId == null &&
              !_isSearching) // Only show create folder button when not searching
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateFolderDialog(context,context.read<FolderCubit>()),
            ),



          if (widget.parentId != null) // Only show upload button in folder view
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: () => _navigateToFileUpload(context),
            ),
        ],
      ),
      body: Column(
        children: [
          if (widget.parentId ==
              null) // Show folders list only in main folders page
            Expanded(
              child: BlocBuilder<FolderCubit, FolderState>(
                builder: (context, state) {
                  if (state is FolderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is FolderError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<FolderCubit>().loadFolders(parentId: widget.parentId),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is FoldersLoaded) {
                    if (state.folders.isEmpty) {
                      return Center(
                        child: Text(state.searchQuery != null
                            ? 'No folders found matching "${state.searchQuery}"'
                            : 'No folders found'),
                      );
                    }
                    return _buildFolderList(context, state.folders);
                  }

                  return const Center(child: Text('No folders found'));
                },
              ),
            ),
          if (widget.parentId != null) // Show files in folder view
            Expanded(
              child: FilesPage(folderId: widget.parentId!),
            ),
        ],
      ),
    );
  }

  Widget _buildFolderList(BuildContext context, List<Folder> folders) {
    if (folders.isEmpty) {
      return const Center(child: Text('No folders found'));
    }

    return ListView.builder(
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];
        return ListTile(
          leading: const Icon(Icons.folder),
          title: Text(folder.name),
          trailing: PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value, folder),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.file,
              arguments: folder.id,
            );
          },
        );
      },
    );
  }

  void _handleMenuAction(BuildContext context, String action, Folder folder) {
    switch (action) {
      case 'edit':
        _showEditFolderDialog(context, folder,context.read<FolderCubit>());
        break;
      case 'delete':
        _showDeleteConfirmation(context, folder);
        break;
    }
  }

  Future<void> _showCreateFolderDialog(BuildContext context, FolderCubit cubit) async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Folder Name',
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
                cubit.createFolder(
                      controller.text,
                      parentId: null, // Always create folders at root level
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditFolderDialog(
      BuildContext context, Folder folder,FolderCubit cubit) async {
    final controller = TextEditingController(text: folder.name);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Folder Name',
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
               cubit.updateFolder(
                      folder.id,
                      controller.text,
                      parentId: null, // Always update folders at root level
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, Folder folder) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text('Are you sure you want to delete "${folder.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FolderCubit>().deleteFolder(
                    folder.id,
                    parentId: null, // Always delete folders at root level
                  );
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToFileUpload(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileUploadPage(folderId: widget.parentId!),
      ),
    );
  }
}
