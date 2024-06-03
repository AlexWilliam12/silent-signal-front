import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:silent_signal/models/private_message.dart';
import 'package:silent_signal/models/sensitive_user.dart';
import 'package:silent_signal/models/user.dart';
import 'package:silent_signal/providers/providers.dart';
import 'package:silent_signal/services/upload_service.dart';
import 'package:silent_signal/services/websocket_service.dart';

class PrivateChatListScreen extends StatefulWidget {
  const PrivateChatListScreen({super.key});

  @override
  State<PrivateChatListScreen> createState() => _PrivateChatListScreenState();
}

class _PrivateChatListScreenState extends State<PrivateChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final service = Provider.of<PrivateChatProvider>(context, listen: false);
    final user = Provider.of<UserProvider>(context).user!;

    return StreamBuilder(
      stream: service.stream,
      builder: (context, snapshot) {
        if (service.messages.isEmpty) {
          return const Center(child: Text('No contact messages available yet'));
        } else {
          var messages = service.messages
              .map((json) => PrivateMessage.fromJson(json))
              .toList();

          final lastMessages = <String, PrivateMessage>{};
          for (var message in messages) {
            User otherUser;
            if (message.sender.name == user.name) {
              otherUser = message.recipient;
            } else if (message.recipient.name == user.name) {
              otherUser = message.sender;
            } else {
              continue;
            }

            if (!lastMessages.containsKey(otherUser.name) ||
                lastMessages[otherUser.name]!
                    .createdAt
                    .isBefore(message.createdAt)) {
              lastMessages[otherUser.name] = message;
            }
          }

          messages = lastMessages.values.toList();
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                      width: 0.2,
                    ),
                  ),
                ),
                child: ListTile(
                  leading: message.sender.name == user.name
                      ? message.recipient.picture != null
                          ? CircleAvatar(
                              radius: 25,
                              backgroundColor: const Color.fromARGB(
                                255,
                                76,
                                78,
                                175,
                              ),
                              backgroundImage: NetworkImage(
                                message.recipient.picture!,
                              ),
                            )
                          : CircleAvatar(
                              radius: 25,
                              backgroundColor: const Color.fromARGB(
                                255,
                                76,
                                78,
                                175,
                              ),
                              child: Text(
                                message.recipient.name.substring(0, 1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                      : message.sender.picture != null
                          ? CircleAvatar(
                              radius: 25,
                              backgroundColor: const Color.fromARGB(
                                255,
                                76,
                                78,
                                175,
                              ),
                              backgroundImage: NetworkImage(
                                message.sender.picture!,
                              ),
                            )
                          : CircleAvatar(
                              radius: 25,
                              backgroundColor: const Color.fromARGB(
                                255,
                                76,
                                78,
                                175,
                              ),
                              child: Text(
                                message.sender.name.substring(0, 1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                  title: Text(
                    message.sender.name == user.name
                        ? message.recipient.name
                        : message.sender.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    message.sender.name == user.name
                        ? 'You: ${message.content}'
                        : message.content,
                    overflow: TextOverflow.ellipsis,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrivateChatScreen(
                        contact: message.sender.name != user.name
                            ? message.sender
                            : message.recipient,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class PrivateChatScreen extends StatefulWidget {
  final User contact;
  const PrivateChatScreen({super.key, required this.contact});

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  bool isTyping = false;
  final controller = TextEditingController();

  Future<void> sendPhoto(WebsocketService channel, SensitiveUser user) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      final service = UploadService();
      final response = await service.uploadPrivateChatFile(
        File(file.path),
        widget.contact.name,
      );
      if (response['location'] != null) {
        channel.sendMessage({
          'sender': user.name,
          'recipient': widget.contact.name,
          'type': lookupMimeType(file.path) ?? 'application/octet-stream',
          'content': response['location'],
        });
      }
    }
  }

  Future<void> sendImage(WebsocketService channel, SensitiveUser user) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final service = UploadService();
      final response = await service.uploadPrivateChatFile(
        File(file.path),
        widget.contact.name,
      );
      if (response['location'] != null) {
        channel.sendMessage({
          'sender': user.name,
          'recipient': widget.contact.name,
          'type': lookupMimeType(file.path) ?? 'application/octet-stream',
          'content': response['location'],
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<PrivateChatProvider>(context, listen: false);
    final user = Provider.of<UserProvider>(context, listen: false).user!;
    return StreamBuilder(
      stream: service.stream,
      builder: (context, snapshot) {
        if (service.messages.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.green,
                    child: widget.contact.picture != null
                        ? CircleAvatar(
                            radius: 25,
                            backgroundColor: const Color.fromARGB(
                              255,
                              76,
                              78,
                              175,
                            ),
                            backgroundImage: NetworkImage(
                              widget.contact.picture!,
                            ),
                          )
                        : CircleAvatar(
                            radius: 25,
                            backgroundColor: const Color.fromARGB(
                              255,
                              76,
                              78,
                              175,
                            ),
                            child: Text(
                              widget.contact.name.substring(0, 1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 250,
                    child: Text(
                      widget.contact.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color.fromARGB(255, 0, 15, 83),
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text('Send a message to ${widget.contact.name}'),
                  ),
                ),
                Container(
                  height: 90,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 0.2,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          width: 300,
                          child: TextField(
                            controller: controller,
                            autocorrect: true,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Send a message...',
                            ),
                            onChanged: (value) {
                              setState(() {
                                isTyping = value.isNotEmpty;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.image),
                                      title: const Text('Gallery'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        sendImage(service, user);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text('Photo'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        sendPhoto(service, user);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.description),
                                      title: const Text('Document'),
                                      onTap: () {},
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.attach_file),
                        ),
                        IconButton(
                          onPressed: () {
                            if (isTyping) {
                              final message = {
                                'sender': user,
                                'recipient': widget.contact.name,
                                'type': 'text',
                                'content': controller.text,
                              };
                              service.sendMessage(message);
                            }
                            setState(() {
                              controller.clear();
                              isTyping = false;
                            });
                          },
                          icon: Icon(isTyping ? Icons.send : Icons.mic),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          final messages = service.messages
              .map((json) => PrivateMessage.fromJson(json))
              .where((message) =>
                  (message.sender.name == user.name &&
                      message.recipient.name == widget.contact.name) ||
                  (message.recipient.name == user.name &&
                      message.sender.name == widget.contact.name))
              .toList();
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.green,
                    child: widget.contact.picture != null
                        ? CircleAvatar(
                            radius: 25,
                            backgroundColor: const Color.fromARGB(
                              255,
                              76,
                              78,
                              175,
                            ),
                            backgroundImage: NetworkImage(
                              widget.contact.picture!,
                            ),
                          )
                        : CircleAvatar(
                            radius: 25,
                            backgroundColor: const Color.fromARGB(
                              255,
                              76,
                              78,
                              175,
                            ),
                            child: Text(
                              widget.contact.name.substring(0, 1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 250,
                    child: Text(
                      widget.contact.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color.fromARGB(255, 0, 15, 83),
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
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
                Container(
                  height: 90,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 0.2,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          width: 300,
                          child: TextField(
                            controller: controller,
                            autocorrect: true,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Send a message...',
                            ),
                            onChanged: (value) {
                              setState(() {
                                isTyping = value.isNotEmpty;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.image),
                                      title: const Text('Gallery'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        sendImage(service, user);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text('Photo'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        sendPhoto(service, user);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.description),
                                      title: const Text('Document'),
                                      onTap: () {},
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.attach_file),
                        ),
                        IconButton(
                          onPressed: () {
                            if (isTyping) {
                              final message = {
                                'sender': user,
                                'recipient': widget.contact.name,
                                'type': 'text',
                                'content': controller.text,
                              };
                              service.sendMessage(message);
                            }
                            setState(() {
                              controller.clear();
                              isTyping = false;
                            });
                          },
                          icon: Icon(isTyping ? Icons.send : Icons.mic),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String type;
  final String message;
  final bool isSentByMe;

  const ChatBubble({
    super.key,
    required this.type,
    required this.message,
    required this.isSentByMe,
  });

  Widget renderContent(BuildContext context) {
    switch (type) {
      case 'text':
        return Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        );
      case 'image/jpeg' || 'image/jpg' || 'image/png':
        return SizedBox(
          height: 300,
          width: MediaQuery.of(context).size.width,
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 30),
                  child: InteractiveViewer(
                    minScale: 0.1,
                    maxScale: 4.0,
                    child: Image.network(message),
                  ),
                ),
              ),
            ),
            child: FutureBuilder(
              future: Future.microtask(
                () async {
                  final response = await http.get(Uri.parse(message));
                  return response.statusCode == 200;
                },
              ),
              builder: (context, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : Image.network(message, fit: BoxFit.cover),
            ),
          ),
        );
      case 'file':
        return Row(
          children: [
            const Icon(Icons.attach_file, color: Colors.white),
            Text(
              'File: ${message.split('/').last}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        );
      case 'audio':
        return Row(
          children: [
            const Icon(Icons.audiotrack, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Audio: ${message.split('/').last}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        );
      default:
        return const Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        child: CustomPaint(
          painter: ChatBubblePainter(isSentByMe: isSentByMe),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isSentByMe
                  ? Colors.blue
                  : const Color.fromARGB(255, 114, 0, 108),
              borderRadius: BorderRadius.circular(15),
            ),
            child: renderContent(context),
          ),
        ),
      ),
    );
  }
}

class ChatBubblePainter extends CustomPainter {
  final bool isSentByMe;

  ChatBubblePainter({required this.isSentByMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          isSentByMe ? Colors.blue : const Color.fromARGB(255, 114, 0, 108);
    final path = Path();

    if (isSentByMe) {
      path.moveTo(size.width, size.height - 10);
      path.lineTo(size.width - 10, size.height);
      path.lineTo(size.width - 10, size.height - 10);
    } else {
      path.moveTo(0, size.height - 10);
      path.lineTo(10, size.height);
      path.lineTo(10, size.height - 10);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
