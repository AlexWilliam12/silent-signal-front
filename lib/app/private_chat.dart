import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silent_signal/models/private_message.dart';
import 'package:silent_signal/models/sensitive_user.dart';
import 'package:silent_signal/services/private_chat_service.dart';

class PrivateChatListScreen extends StatefulWidget {
  final SensitiveUser user;

  const PrivateChatListScreen({
    super.key,
    required this.user,
  });

  @override
  State<PrivateChatListScreen> createState() => _PrivateChatListScreenState();
}

class _PrivateChatListScreenState extends State<PrivateChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final service = context.watch<PrivateChatService>();

    return StreamBuilder(
      stream: service.stream,
      builder: (context, snapshot) {
        if (service.messages.isEmpty) {
          return const Center(child: Text('no messages available yet'));
        } else {
          var messages = service.messages
              .map((json) => PrivateMessage.fromJson(json))
              .toList();

          final lastRecipientMessages = <String, PrivateMessage>{};
          for (final message in messages) {
            if (message.sender.name != widget.user.name) {
              if (lastRecipientMessages.containsKey(message.sender.name)) {
                final lastMessage = lastRecipientMessages[message.sender.name];
                if (message.createdAt.isAfter(lastMessage!.createdAt)) {
                  lastRecipientMessages[message.sender.name] = message;
                }
              } else {
                lastRecipientMessages[message.sender.name] = message;
              }
            }
          }
          final lastSenderMessages = <String, PrivateMessage>{};
          for (final message in messages) {
            if (message.sender.name == widget.user.name) {
              if (lastSenderMessages.containsKey(message.sender.name)) {
                final lastMessage = lastSenderMessages[message.sender.name];
                if (message.createdAt.isAfter(lastMessage!.createdAt)) {
                  lastSenderMessages[message.sender.name] = message;
                }
              } else {
                lastSenderMessages[message.sender.name] = message;
              }
            }
          }
          final recipientMessages = lastRecipientMessages.values.toList();
          final senderMessages = lastSenderMessages.values.toList();

          messages.clear();
          if (senderMessages.isEmpty) {
            messages.addAll(recipientMessages);
          } else if (recipientMessages.isEmpty) {
            messages.addAll(senderMessages);
          } else {
            for (var recipientMessage in recipientMessages) {
              for (var senderMessage in senderMessages) {
                final sender = senderMessage.sender.name;
                final recipient = recipientMessage.recipient.name;
                if (sender == recipient) {
                  if (senderMessage.createdAt
                      .isAfter(recipientMessage.createdAt)) {
                    messages.add(
                      PrivateMessage(
                        type: senderMessage.type,
                        content: 'You: ${senderMessage.content}',
                        sender: recipientMessage.sender,
                        recipient: senderMessage.recipient,
                        createdAt: senderMessage.createdAt,
                      ),
                    );
                  } else {
                    messages.add(recipientMessage);
                  }
                }
              }
            }
          }
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 0.2,
                      color: Colors.white,
                    ),
                  ),
                ),
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () => debugPrint('profile'),
                    child: CircleAvatar(
                      radius: 25,
                      child: message.sender.picture != null
                          ? Image.network(message.sender.picture!)
                          : Text(message.sender.name.substring(0, 1)),
                    ),
                  ),
                  title: Text(
                    message.sender.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    message.content,
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
                        user: widget.user,
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
  final SensitiveUser user;
  const PrivateChatScreen({super.key, required this.user});

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  bool _isTyping = false;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<PrivateChatService>(context);
    return StreamBuilder(
      stream: service.stream,
      builder: (context, snapshot) {
        if (service.messages.isEmpty) {
          return const CircularProgressIndicator();
        } else {
          final messages = service.messages
              .map((json) => PrivateMessage.fromJson(json))
              .map((message) {
            if (message.sender.name == widget.user.name ||
                message.recipient.name == widget.user.name) {
              return message;
            }
          }).toList();
          final otherUser = messages
              .map((message) {
                final sender = message!.sender;
                if (sender.name != widget.user.name) {
                  return message.sender;
                }
                final recipient = message.recipient;
                if (recipient.name != widget.user.name) {
                  return message.recipient;
                }
              })
              .toList()
              .first;
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.green,
                      child: otherUser!.picture != null
                          ? Image.network(otherUser.picture!)
                          : Text(otherUser.name.substring(0, 1)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 250,
                    child: Text(
                      otherUser.name,
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
              toolbarHeight: 65,
              backgroundColor: const Color.fromARGB(255, 0, 15, 83),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ChatBubble(
                        type: message!.type,
                        message: message.content,
                        isSentByMe: message.sender.name == widget.user.name,
                      );
                    },
                  ),
                ),
                Container(
                  height: 90,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 0.1,
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
                          child: TextFormField(
                            controller: _controller,
                            autocorrect: true,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Send a message...',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _isTyping = value.isNotEmpty;
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
                                      title: const Text('Image'),
                                      onTap: () {},
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.description),
                                      title: const Text('Document'),
                                      onTap: () {},
                                    ),
                                    ListTile(
                                      leading:
                                          const Icon(Icons.enhanced_encryption),
                                      title: const Text('Sensitive content'),
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
                            if (_isTyping) {
                              final message = {
                                'sender': widget.user,
                                'recipient': otherUser.name,
                                'type': 'text',
                                'content': _controller.text,
                              };
                              service.sendMessage(message);
                            }
                            setState(() {
                              _controller.clear();
                              _isTyping = false;
                            });
                          },
                          icon: Icon(_isTyping ? Icons.send : Icons.mic),
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

  Widget _renderContent() {
    switch (type) {
      case 'text':
        return Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        );
      case 'image':
        return Image.network(message);
      case 'file':
        return Row(
          children: [
            const Icon(Icons.attach_file, color: Colors.white),
            Text('File: ${message.split('/').last}',
                style: const TextStyle(color: Colors.white)),
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
            child: _renderContent(),
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
