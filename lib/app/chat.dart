import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silent_signal/main.dart';
import 'package:silent_signal/models/sensitive_user.dart';
import 'package:silent_signal/services/user_service.dart';
import 'package:silent_signal/services/websocket_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final service = UserService();
  final _channel = WebSocketService();
  final List<dynamic> _chats = [];
  final Map<String, dynamic> _lastMessages = {};
  String _user = "";
  bool _isTyping = false;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<SensitiveUser?> fetchUser() async {
    return await service.fetchUser();
  }

  // Future<void> fetchUser() async {
  //   final response = await _service.fetchUserData();
  //   if (response['error'] != null) {
  //     debugPrint(response['error']);
  //   } else {
  //     debugPrint(response.toString());
  //     user =
  //     final pref = await SharedPreferences.getInstance();
  //     await pref.setString('hash', response['credentials_hash']);
  //     setState(() {
  //       _user = response['name'];
  //       _filterLast();
  //     });
  //   }
  // }

  Future<void> initChannel() async {
    final pref = await SharedPreferences.getInstance();
    final token = pref.get('token') as String;
    final host = pref.get('host') as String;
    await _channel.connect('ws://$host/chat/private', token);
    _channel.messages.listen((message) {
      setState(() {
        _chats.add(message);
      });
    });
  }

  void _filterLast() {
    for (Map<String, dynamic> element in _chats) {
      if (element['sender'] != _user) {
        if (!_lastMessages.containsKey(element['sender']) ||
            DateTime.parse(element['createdAt']).isAfter(
              DateTime.parse(_lastMessages[element['sender']]['createdAt']),
            )) {
          _lastMessages[element['sender']] = element;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadScreen();
        } else if (!snapshot.hasData) {
          return const LoadScreen();
        } else {
          final user = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Silent Signal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
              toolbarHeight: 65,
              backgroundColor: const Color.fromARGB(255, 0, 15, 83),
              actions: [
                Container(
                  margin: const EdgeInsets.only(
                    right: 15,
                  ),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.green,
                      child: user.picture != null
                          ? Image(
                              image: NetworkImage(user.picture!),
                              fit: BoxFit.cover,
                            )
                          : Text(user.name.substring(0, 1)),
                    ),
                  ),
                ),
              ],
            ),
            body: _chats.isEmpty
                ? const Center(child: Text('No chats available'))
                : ListView.builder(
                    itemCount: _lastMessages.length,
                    itemBuilder: (context, index) {
                      String sender = _lastMessages.keys.elementAt(index);
                      var message = _lastMessages[sender];
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
                              child: message['senderPicture'].isNotEmpty
                                  ? Image.network(message['senderPicture'])
                                  : Text(message['sender'].substring(0, 1)),
                            ),
                          ),
                          title: Text(
                            message['sender'],
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            message['content'],
                            overflow: TextOverflow.ellipsis,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                var otherUser = _chats.firstWhere(
                                        (element) => element['sender'] != _user)
                                    as Map<String, dynamic>;
                                return Scaffold(
                                  appBar: AppBar(
                                    title: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {},
                                          child: CircleAvatar(
                                            radius: 22,
                                            backgroundColor: Colors.green,
                                            child: otherUser['senderPicture']
                                                    .isNotEmpty
                                                ? Image.network(
                                                    otherUser['senderPicture'])
                                                : Text(otherUser['sender']
                                                    .substring(0, 1)),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        SizedBox(
                                          width: 250,
                                          child: Text(
                                            otherUser['sender'],
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
                                    backgroundColor:
                                        const Color.fromARGB(255, 0, 15, 83),
                                  ),
                                  body: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: _chats.length,
                                          itemBuilder: (context, index) {
                                            var element = _chats[index];
                                            return ChatBubble(
                                              type: element['type'],
                                              message: element['content'],
                                              isSentByMe:
                                                  element['sender'] == _user,
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                width: 300,
                                                child: TextFormField(
                                                  controller: _controller,
                                                  autocorrect: true,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText:
                                                        'Send a message...',
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _isTyping =
                                                          value.isNotEmpty;
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
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          ListTile(
                                                            leading: const Icon(
                                                                Icons.image),
                                                            title: const Text(
                                                                'Image'),
                                                            onTap: () {},
                                                          ),
                                                          ListTile(
                                                            leading: const Icon(
                                                                Icons
                                                                    .description),
                                                            title: const Text(
                                                                'Document'),
                                                            onTap: () {},
                                                          ),
                                                          ListTile(
                                                            leading: const Icon(
                                                                Icons
                                                                    .enhanced_encryption),
                                                            title: const Text(
                                                                'Sensitive content'),
                                                            onTap: () {},
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: const Icon(
                                                    Icons.attach_file),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  if (_isTyping) {
                                                    final message = {
                                                      'sender': _user,
                                                      'recipient':
                                                          otherUser['sender'],
                                                      'type': 'text',
                                                      'content':
                                                          _controller.text,
                                                    };
                                                    _channel
                                                        .sendMessage(message);
                                                  }
                                                  _controller.clear();
                                                  setState(() {
                                                    _isTyping = false;
                                                    debugPrint(message);
                                                    _chats.add(message);
                                                  });
                                                },
                                                icon: Icon(_isTyping
                                                    ? Icons.send
                                                    : Icons.mic),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'chats',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.groups),
                  label: 'groups',
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => debugPrint('works'),
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}

class ChatBody extends StatefulWidget {
  final WebSocketService channel;
  final List<dynamic> chats;
  final String user;

  const ChatBody({
    super.key,
    required this.chats,
    required this.user,
    required this.channel,
  });

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  final Map<String, dynamic> _lastMessages = {};

  @override
  void initState() {
    _filterLast();
    super.initState();
  }

  void _filterLast() {
    for (Map<String, dynamic> element in widget.chats) {
      if (element['sender'] != widget.user) {
        if (!_lastMessages.containsKey(element['sender']) ||
            DateTime.parse(element['createdAt']).isAfter(
              DateTime.parse(_lastMessages[element['sender']]['createdAt']),
            )) {
          _lastMessages[element['sender']] = element;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _lastMessages.length,
      itemBuilder: (context, index) {
        String sender = _lastMessages.keys.elementAt(index);
        var message = _lastMessages[sender];
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
                child: message['senderPicture'].isNotEmpty
                    ? Image.network(message['senderPicture'])
                    : Text(message['sender'].substring(0, 1)),
              ),
            ),
            title: Text(
              message['sender'],
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              message['content'],
              overflow: TextOverflow.ellipsis,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            onTap: () => Navigator.pushNamed(
              context,
              '/chat',
              arguments: {
                'chats': widget.chats.map((e) {
                  if (sender == e['sender'] || sender == e['recipient']) {
                    return e;
                  }
                }).toList(),
                'user': widget.user,
                'channel': widget.channel,
              },
            ),
          ),
        );
      },
    );
  }
}

class ChatRoom extends StatefulWidget {
  final List<dynamic> chats;
  final String user;
  final WebSocketService channel;

  const ChatRoom({
    super.key,
    required this.chats,
    required this.user,
    required this.channel,
  });

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  bool _isTyping = false;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var otherUser =
        widget.chats.firstWhere((element) => element['sender'] != widget.user)
            as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {},
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.green,
                child: otherUser['senderPicture'].isNotEmpty
                    ? Image.network(otherUser['senderPicture'])
                    : Text(otherUser['sender'].substring(0, 1)),
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 250,
              child: Text(
                otherUser['sender'],
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
              itemCount: widget.chats.length,
              itemBuilder: (context, index) {
                var element = widget.chats[index];
                return ChatBubble(
                  type: element['type'],
                  message: element['content'],
                  isSentByMe: element['sender'] == widget.user,
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
                                leading: const Icon(Icons.enhanced_encryption),
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
                          'recipient': otherUser['sender'],
                          'type': 'text',
                          'content': _controller.text,
                        };
                        widget.channel.sendMessage(message);
                      }
                      _controller.clear();
                      setState(() {
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
