import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:silent_signal/providers/providers.dart';
import 'package:silent_signal/services/upload_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final user = provider.user!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: const Color.fromARGB(255, 0, 15, 83),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: Center(
              child: CircleAvatar(
                radius: 111,
                backgroundColor: theme.brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                child: user.picture != null
                    ? CircleAvatar(
                        radius: 110,
                        backgroundImage: NetworkImage(user.picture!),
                      )
                    : CircleAvatar(
                        radius: 50,
                        child: Text(user.name.substring(0, 1)),
                      ),
              ),
            ),
          ),
          Text(
            user.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile != null) {
                  final file = File(pickedFile.path);
                  final service = UploadService();
                  await service.updatePicture(file);
                  await provider.provide();
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.camera_alt),
                  Text(
                    'Change picture',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
