import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../profile_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class ManageProfilesScreen extends StatelessWidget {
  const ManageProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Profiles')),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          final profiles = profileProvider.profiles;
          final active = profileProvider.activeProfile;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: profiles.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final profile = profiles[i];
              final isActive = active?.id == profile.id;
              return ListTile(
                leading: profile.avatarPath.isNotEmpty
                    ? (kIsWeb && profile.avatarPath.startsWith('data:image/')
                          ? CircleAvatar(
                              backgroundImage: MemoryImage(
                                base64Decode(
                                  profile.avatarPath.split(',').last,
                                ),
                              ),
                            )
                          : CircleAvatar(
                              backgroundImage: FileImage(
                                File(profile.avatarPath),
                              ),
                            ))
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(
                  profile.name,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit Profile',
                      onPressed: () async {
                        final nameController = TextEditingController(
                          text: profile.name,
                        );
                        String? avatarPath = profile.avatarPath;
                        await showDialog(
                          context: context,
                          builder: (context) => StatefulBuilder(
                            builder: (context, setState) => AlertDialog(
                              title: const Text('Edit Profile'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      if (kIsWeb) {
                                        // Web avatar picker
                                        // TODO: Implement web avatar picker
                                      } else {
                                        final picker = ImagePicker();
                                        final picked = await picker.pickImage(
                                          source: ImageSource.gallery,
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            avatarPath = picked.path;
                                          });
                                        }
                                      }
                                    },
                                    child: CircleAvatar(
                                      radius: 32,
                                      backgroundImage:
                                          (avatarPath != null &&
                                              avatarPath!.isNotEmpty)
                                          ? (kIsWeb &&
                                                    avatarPath!.startsWith(
                                                      'data:image/',
                                                    )
                                                ? MemoryImage(
                                                    base64Decode(
                                                      avatarPath!
                                                          .split(',')
                                                          .last,
                                                    ),
                                                  )
                                                : FileImage(File(avatarPath!))
                                                      as ImageProvider)
                                          : null,
                                      child:
                                          (avatarPath == null ||
                                              avatarPath!.isEmpty)
                                          ? const Icon(Icons.person, size: 32)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (nameController.text.isNotEmpty) {
                                      // Comment out or replace editProfile call
                                      // await profileProvider.editProfile(profile.id, nameController.text, avatarPath ?? '');
                                      // TODO: Implement editProfile in ProfileProvider or replace with valid method
                                    }
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          ),
                        );
                        nameController.dispose();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete Profile',
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Profile'),
                            content: Text(
                              'Are you sure you want to delete the profile "${profile.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await profileProvider.deleteProfile(profile.id);
                        }
                      },
                    ),
                    if (!isActive)
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        tooltip: 'Switch to this profile',
                        onPressed: () =>
                            profileProvider.switchProfile(profile.id),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
