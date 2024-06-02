import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silent_signal/app/private_chat.dart';
import 'package:silent_signal/models/user.dart';
import 'package:silent_signal/providers/providers.dart';
import 'package:silent_signal/services/user_service.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<User> selected = [];

  Future<void> saveContact(String contact) async {
    final service = UserService();
    final response = await service.saveContact(contact);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response)),
      );
      if (response == 'Contact saved successfully!') {
        Provider.of<UserProvider>(context, listen: false).provide();
      }
    }
  }

  void showContactDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final key = GlobalKey<FormState>();
        final controller = TextEditingController();

        return AlertDialog(
          title: const Text(
            'Save new contact',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: key,
            child: TextFormField(
              controller: controller,
              validator: (value) {
                return value == null || value.isEmpty
                    ? "Contact name can't be empty"
                    : null;
              },
              decoration: const InputDecoration(
                hintText: 'Ex: John Wick',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                if (key.currentState!.validate()) {
                  saveContact(controller.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;
    final contacts = user.contacts;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: const Color.fromARGB(255, 0, 15, 83),
        title: const Text(
          'Contacts',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        actions: [
          ...[
            if (selected.isNotEmpty)
              IconButton(
                onPressed: () {},
                icon: Row(
                  children: [
                    Text(
                      '${selected.length} selected',
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.delete),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
          ]
        ],
      ),
      body: contacts.isEmpty
          ? const Center(child: Text('No contacts saved yet'))
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    leading: GestureDetector(
                      child: contact.picture != null
                          ? CircleAvatar(
                              radius: 25,
                              backgroundColor: const Color.fromARGB(
                                255,
                                76,
                                78,
                                175,
                              ),
                              backgroundImage: NetworkImage(contact.picture!),
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
                                contact.name.substring(0, 1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                    title: Text(
                      contact.name,
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: selected.contains(contact),
                    selectedTileColor: const Color.fromARGB(31, 47, 0, 255),
                    onTap: () {
                      if (selected.isNotEmpty) {
                        setState(() {
                          (selected.contains(contact)
                              ? selected.remove(contact)
                              : selected.add(contact));
                        });
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PrivateChatScreen(
                              contact: contact,
                            ),
                          ),
                        );
                      }
                    },
                    onLongPress: () {
                      setState(() {
                        (selected.contains(contact)
                            ? selected.remove(contact)
                            : selected.add(contact));
                      });
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showContactDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
