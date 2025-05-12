import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/folder_cubit.dart';
import '../../domain/entities/folder.dart';

class FolderPage extends StatelessWidget {
  final String? parentId;

  const FolderPage({super.key, this.parentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateFolderDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<FolderCubit, FolderState>(
        builder: (context, state) {
          if (state is FolderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is FolderError) {
            return Center(child: Text(state.message));
          }
          
          if (state is FoldersLoaded) {
            return _buildFolderList(context, state.folders);
          }
          
          return const Center(child: Text('No folders found'));
        },
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FolderPage(parentId: folder.id),
              ),
            );
          },
        );
      },
    );
  }

  void _handleMenuAction(BuildContext context, String action, Folder folder) {
    switch (action) {
      case 'edit':
        _showEditFolderDialog(context, folder);
        break;
      case 'delete':
        _showDeleteConfirmation(context, folder);
        break;
    }
  }

  Future<void> _showCreateFolderDialog(BuildContext context) async {
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
                context.read<FolderCubit>().createFolder(
                  controller.text,
                  parentId: parentId,
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

  Future<void> _showEditFolderDialog(BuildContext context, Folder folder) async {
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
                context.read<FolderCubit>().updateFolder(
                  folder.id,
                  controller.text,
                  parentId: parentId,
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

  Future<void> _showDeleteConfirmation(BuildContext context, Folder folder) async {
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
                parentId: parentId,
              );
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 