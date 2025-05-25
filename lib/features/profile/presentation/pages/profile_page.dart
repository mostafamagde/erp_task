import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/profile_cubit.dart';
import '../../../../features/auth/data/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize with current user data
    final user = UserModel.instance;
    _nameController.text = user.name;
    _phoneController.text = user.phoneNumber ?? '';
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showEditDialog(UserModel profile,ProfileCubit cubit) {
    _nameController.text = profile.name;
    _phoneController.text = profile.phoneNumber ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
                keyboardType: TextInputType.phone,
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
              if (_formKey.currentState!.validate()) {
               cubit.updateProfile(
                      name: _nameController.text,
                      phoneNumber: _phoneController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Use UserModel.instance directly for the current state
          final profile = UserModel.instance;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profile.photoUrl != null
                        ? NetworkImage(profile.photoUrl!)
                        : null,
                    child: profile.photoUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoCard(
                  title: 'Name',
                  value: profile.name,
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Email',
                  value: profile.email,
                  icon: Icons.email,
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Phone',
                  value: profile.phoneNumber ?? 'Not set',
                  icon: Icons.phone,
                ),
                const SizedBox(height: 24),
                // Center(
                //   child: ElevatedButton.icon(
                //     onPressed: () => _showEditDialog(profile,context.read<ProfileCubit>()),
                //     icon: const Icon(Icons.edit),
                //     label: const Text('Edit Profile'),
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 