import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:refactoring/view_models/upload_view_model.dart';
import 'package:refactoring/view_models/user_view_model.dart';
import 'package:refactoring/widgets/shared/custom_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<UserViewModel>(
      builder: (context, model, child) {
        return Scaffold(
          appBar: const CustomAppBar(
            isMainScreen: false,
            title: 'Profile',
            actions: [],
          ),
          body: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: Center(
                  child: Container(
                    width: 225,
                    height: 225,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: theme.brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(225),
                      color: theme.brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                    ),
                    child: model.user!.picture == null
                        ? Center(
                            child: Text(model.user!.name.substring(0, 1)),
                          )
                        : GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 30),
                                  child: InteractiveViewer(
                                    minScale: 0.1,
                                    maxScale: 4.0,
                                    child: Image.network(model.user!.picture!),
                                  ),
                                ),
                              ),
                            ),
                            child: FutureBuilder(
                              future: Future.microtask(
                                () async {
                                  final response = await http.get(
                                    Uri.parse(model.user!.picture!),
                                  );
                                  return response.statusCode == 200;
                                },
                              ),
                              builder: (context, snapshot) =>
                                  snapshot.connectionState ==
                                          ConnectionState.waiting
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            model.user!.picture!,
                                          ),
                                        ),
                            ),
                          ),
                  ),
                ),
              ),
              Text(
                model.user!.name,
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
                      final service = UploadViewModel();
                      await service.updatePicture(file);
                      await model.fetchUser();
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.camera_alt),
                      Text(
                        'Select a picture',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile != null) {
                      final file = File(pickedFile.path);
                      final service = UploadViewModel();
                      await service.updatePicture(file);
                      await model.fetchUser();
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.camera_alt),
                      Text(
                        'Take a picture',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
