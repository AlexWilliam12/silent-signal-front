import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:refactoring/models/sensitive_user_model.dart';
import 'package:refactoring/models/user_model.dart';
import 'package:refactoring/view_models/chat_view_model.dart';
import 'package:refactoring/view_models/upload_view_model.dart';
import 'package:refactoring/view_models/user_view_model.dart';
import 'package:refactoring/widgets/chats/chat_input.dart';
import 'package:refactoring/widgets/shared/chat_bubble.dart';
import 'package:refactoring/widgets/shared/custom_app_bar.dart';
import 'package:refactoring/widgets/shared/modal_bottom_sheet_action.dart';

import 'private_chat_widgets.dart';

class PrivateChatScreen extends StatefulWidget {
  final UserModel contact;
  const PrivateChatScreen({super.key, required this.contact});

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
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
  }

  void sendTextMessage(PrivateChatViewModel model, SensitiveUserModel user) {
    final message = {
      'sender': user,
      'recipient': widget.contact.name,
      'type': 'text',
      'content': controller.text,
    };
    model.sendMessage(message);
    controller.clear();
  }

  Future<void> sendImageFile(
    PrivateChatViewModel model,
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
          'recipient': widget.contact.name,
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
    PrivateChatViewModel model,
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
          'recipient': widget.contact.name,
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
    PrivateChatViewModel model,
    SensitiveUserModel user,
  ) async {}
  Future<void> sendVideoFile(
    PrivateChatViewModel model,
    SensitiveUserModel user,
  ) async {}
  Future<void> sendRecordedVideo(
    PrivateChatViewModel model,
    SensitiveUserModel user,
  ) async {}
  Future<void> sendAudioFile(
    PrivateChatViewModel model,
    SensitiveUserModel user,
  ) async {}

  Future<void> sendAudioMessage(
    File file,
    PrivateChatViewModel model,
    SensitiveUserModel user,
  ) async {
    final response = await UploadViewModel().uploadChatFile(file);
    if (response.isNotEmpty) {
      model.sendMessage({
        'sender': user.name,
        'recipient': widget.contact.name,
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

  Future<void> startRecord() async {
    recordingNotifier.value = true;
    final directory = await getTemporaryDirectory();
    await recorder.start(path: '${directory.path}/temp_audio.aac');
  }

  Future<void> stopRecord(
    PrivateChatViewModel model,
    SensitiveUserModel user,
  ) async {
    recordingNotifier.value = false;
    final path = await recorder.stop();
    await sendAudioMessage(File(path!), model, user);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserViewModel>(context).user!;
    final model = Provider.of<PrivateChatViewModel>(context);

    final messages = model.filterByUsers(
      user.name,
      widget.contact.name,
      model.wrapList(),
    );

    return Scaffold(
      appBar: CustomAppBar(
        isMainScreen: false,
        customTitle: PrivateChatAppBarTitle(contact: widget.contact),
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
                          'Send a message to ${widget.contact.name}',
                        ),
                      )
                    : ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return ChatBubble(
                            type: message.type,
                            message: message.content,
                            isSentByMe: message.sender.name == user.name,
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
                    await startRecord();
                  } else {
                    await stopRecord(model, user);
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
