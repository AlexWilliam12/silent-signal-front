import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refactoring/models/user_model.dart';
import 'package:refactoring/screens/contact/contact_widgets.dart';
import 'package:refactoring/screens/private_chat/private_chat_screen.dart';
import 'package:refactoring/view_models/user_view_model.dart';
import 'package:refactoring/widgets/shared/custom_app_bar.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<UserModel> selected = [];

  Future<void> saveContact(String contact, UserViewModel model) async {
    final response = await model.saveContact(contact);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response)),
      );
      if (response == 'Contact saved successfully!') {
        model.fetchUser();
      }
    }
  }

  Future<void> deleteContacts(UserViewModel model) async {
    final response = await model.deleteContacts(
      selected.map((e) => e.name).toList(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response)),
      );
      if (response == 'Successfully deleted contacts!') {
        setState(() {
          selected.clear();
        });
        model.fetchUser();
      }
    }
  }

  void showSaveContactDialog(UserViewModel model) {
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (key.currentState!.validate()) {
                  saveContact(controller.text, model).then(
                    (_) => Navigator.pop(context),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteContactsDialog(UserViewModel model) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            'Do you really want to delete ${selected.length} ${selected.length == 1 ? 'contact' : 'contacts'}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteContacts(model).then(
                  (_) => Navigator.pop(context),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<UserViewModel>(context);
    final user = model.user!;
    final contacts = user.contacts;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Contacts',
        isMainScreen: false,
        actions: [
          if (selected.isNotEmpty)
            IconButton(
              onPressed: () => showDeleteContactsDialog(model),
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
        ],
      ),
      body: contacts.isEmpty
          ? const Center(child: Text('No contacts saved yet'))
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ContactListTile(
                  contact: contact,
                  selected: selected.contains(contact),
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
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSaveContactDialog(model),
        child: const Icon(Icons.add),
      ),
    );
  }
}
