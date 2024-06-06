import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:refactoring/models/group_model.dart';
import 'package:refactoring/models/sensitive_user_model.dart';
import 'package:refactoring/screens/group_chat/group_chat_widgets.dart';
import 'package:refactoring/utils/fortmat_file.dart';
import 'package:refactoring/view_models/chat_view_model.dart';
import 'package:refactoring/view_models/upload_view_model.dart';
import 'package:refactoring/view_models/user_view_model.dart';
import 'package:refactoring/widgets/chats/chat_input.dart';
import 'package:refactoring/widgets/shared/chat_bubble.dart';
import 'package:refactoring/widgets/shared/custom_app_bar.dart';
import 'package:refactoring/widgets/shared/modal_bottom_sheet_action.dart';

class GroupChatScreen extends StatefulWidget {
  final GroupModel group;
  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final typingNotifier = ValueNotifier<bool>(false);
  final recordingNotifier = ValueNotifier<bool>(false);
  final controller = TextEditingController();
  final recorder = FlutterSoundRecord();

  @override
  void initState() {
    super.initState();
    requestPermissions().then((_) async => await recorder.hasPermission());
  }

  @override
  void dispose() {
    controller.dispose();
    typingNotifier.dispose();
    recordingNotifier.dispose();
    recorder.dispose();
    super.dispose();
  }

  Future<void> requestPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
    status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  void sendTextMessage(GroupChatViewModel model, SensitiveUserModel user) {
    final message = {
      'sender': user,
      'group': widget.group.name,
      'type': 'text',
      'content': controller.text,
    };
    model.sendMessage(message);
    controller.clear();
  }

  Future<void> sendImageFile(
    GroupChatViewModel model,
    SensitiveUserModel user,
  ) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (mounted) {
      Navigator.pop(context);
    }
    if (file != null) {
      final response = await UploadViewModel().uploadChatFile(File(file.path));
      if (response.isNotEmpty) {
        model.sendMessage({
          'sender': user.name,
          'group': widget.group.name,
          'type': lookupMimeType(file.path) ?? 'application/octet-stream',
          'content': response,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(milliseconds: 500),
              content: Text('Sending...'),
            ),
          );
        }
      }
    }
  }

  Future<void> sendTakedPicture(
    GroupChatViewModel model,
    SensitiveUserModel user,
  ) async {
    final file = await ImagePicker().pickImage(source: ImageSource.camera);
    if (mounted) {
      Navigator.pop(context);
    }
    if (file != null) {
      final response = await UploadViewModel().uploadChatFile(File(file.path));
      if (response.isNotEmpty) {
        model.sendMessage({
          'sender': user.name,
          'group': widget.group.name,
          'type': lookupMimeType(file.path) ?? 'application/octet-stream',
          'content': response,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(milliseconds: 500),
              content: Text('Sending...'),
            ),
          );
        }
      }
    }
  }

  Future<void> sendDocumentFile(
    GroupChatViewModel model,
    SensitiveUserModel user,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (mounted) {
      Navigator.pop(context);
    }
    if (result != null) {
      final path = result.files.single.path;
      if (path != null) {
        final file = File(path);
        final response = await UploadViewModel().uploadChatFile(file);
        if (response.isNotEmpty) {
          model.sendMessage({
            'sender': user.name,
            'group': widget.group.name,
            'type': lookupMimeType(file.path) ?? 'application/octet-stream',
            'content': response,
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(milliseconds: 500),
                content: Text('Sending...'),
              ),
            );
          }
        }
      }
    }
  }

  Future<void> sendVideoFile(
    GroupChatViewModel model,
    SensitiveUserModel user,
  ) async {
    final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (mounted) {
      Navigator.pop(context);
    }
    if (file != null) {
      final response = await UploadViewModel().uploadChatFile(File(file.path));
      if (response.isNotEmpty) {
        model.sendMessage({
          'sender': user.name,
          'group': widget.group.name,
          'type': lookupMimeType(file.path) ?? 'application/octet-stream',
          'content': response,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(milliseconds: 500),
              content: Text('Sending...'),
            ),
          );
        }
      }
    }
  }

  Future<void> sendRecordedVideo(
    GroupChatViewModel model,
    SensitiveUserModel user,
  ) async {
    final file = await ImagePicker().pickVideo(source: ImageSource.camera);
    if (mounted) {
      Navigator.pop(context);
    }
    if (file != null) {
      final response = await UploadViewModel().uploadChatFile(File(file.path));
      if (response.isNotEmpty) {
        model.sendMessage({
          'sender': user.name,
          'group': widget.group.name,
          'type': lookupMimeType(file.path) ?? 'application/octet-stream',
          'content': response,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(milliseconds: 500),
              content: Text('Sending...'),
            ),
          );
        }
      }
    }
  }

  Future<void> sendAudioFile(
    GroupChatViewModel model,
    SensitiveUserModel user,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (mounted) {
      Navigator.pop(context);
    }
    if (result != null) {
      final path = result.files.single.path;
      if (path != null) {
        final file = File(path);
        final response = await UploadViewModel().uploadChatFile(file);
        if (response.isNotEmpty) {
          model.sendMessage({
            'sender': user.name,
            'group': widget.group.name,
            'type': lookupMimeType(file.path) ?? 'application/octet-stream',
            'content': response,
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(milliseconds: 500),
                content: Text('Sending...'),
              ),
            );
          }
        }
      }
    }
  }

  Future<void> sendAudioMessage(
    File originalFile,
    GroupChatViewModel model,
    SensitiveUserModel user,
  ) async {
    final file = formatFile(originalFile, 'mp3');
    final response = await UploadViewModel().uploadChatFile(file);
    if (response.isNotEmpty) {
      model.sendMessage({
        'sender': user.name,
        'group': widget.group.name,
        'type': lookupMimeType(file.path) ?? 'application/octet-stream',
        'content': response,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(milliseconds: 500),
            content: Text('Sending...'),
          ),
        );
      }
    }
  }

  Future<void> startAudioRecord() async {
    recordingNotifier.value = true;
    final directory = await getTemporaryDirectory();
    await recorder.start(path: '${directory.path}/temp_audio.aac');
  }

  Future<void> stopAudioRecord(
    GroupChatViewModel model,
    SensitiveUserModel user,
  ) async {
    recordingNotifier.value = false;
    final path = await recorder.stop();
    await sendAudioMessage(File(path!), model, user);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserViewModel>(context).user!;
    final model = Provider.of<GroupChatViewModel>(context);

    final messages = model.filterByGroup(widget.group.name, model.wrapList());

    return Scaffold(
      appBar: CustomAppBar(
        isMainScreen: false,
        customTitle: GroupChatAppBarTitle(group: widget.group),
        actions: const [],
      ),
      body: StreamBuilder(
        stream: model.stream,
        builder: (context, snapshot) {
          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          'Send a message in the ${widget.group.name} group',
                        ),
                      )
                    : ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return ChatBubble(
                            type: message.type,
                            content: message.content,
                            isSentByMe: message.sender.name == user.name,
                            sender: message.sender.name,
                            createdAt: message.createdAt,
                          );
                        },
                      ),
              ),
              ChatInput(
                controller: controller,
                actions: [
                  ModalBottomSheetAction(
                    onTap: () async => await sendImageFile(
                      model,
                      user,
                    ),
                    icon: Icons.image,
                    title: 'Gallery',
                  ),
                  ModalBottomSheetAction(
                    onTap: () async => await sendTakedPicture(
                      model,
                      user,
                    ),
                    icon: Icons.camera_alt,
                    title: 'Photo',
                  ),
                  ModalBottomSheetAction(
                    onTap: () async => await sendDocumentFile(
                      model,
                      user,
                    ),
                    icon: Icons.description,
                    title: 'Document',
                  ),
                  ModalBottomSheetAction(
                    onTap: () async => await sendVideoFile(
                      model,
                      user,
                    ),
                    icon: Icons.video_file,
                    title: 'Video',
                  ),
                  ModalBottomSheetAction(
                    onTap: () async => await sendRecordedVideo(
                      model,
                      user,
                    ),
                    icon: Icons.video_camera_back,
                    title: 'Record',
                  ),
                  ModalBottomSheetAction(
                    onTap: () async => await sendAudioFile(
                      model,
                      user,
                    ),
                    icon: Icons.audio_file,
                    title: 'Audio',
                  ),
                ],
                onChanged: (value) {
                  typingNotifier.value = value.isNotEmpty;
                },
                recordingNotifier: recordingNotifier,
                typingNotifier: typingNotifier,
                onPressed: () async {
                  if (typingNotifier.value) {
                    sendTextMessage(model, user);
                    return;
                  }
                  if (!recordingNotifier.value) {
                    await startAudioRecord();
                  } else {
                    await stopAudioRecord(model, user);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
