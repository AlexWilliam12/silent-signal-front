import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silent_signal/app/private_chat.dart';
import 'package:silent_signal/providers/providers.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  Future<void> _saveContact() async {}

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
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          // final contact = contacts[index];
          return Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white,
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
                child: const CircleAvatar(
                  radius: 25,
                  child: Text('U'),
                ),
              ),
              title: const Text('User'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
              // onTap: () => Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => PrivateChatScreen(contact: contact),
              //   ),
              // ),
            ),
          );
        },
      ),
      // body: contacts.isEmpty
      //     ? const Center(child: Text('No contacts saved yet'))
      //     : ListView.builder(
      //         itemBuilder: (context, index) {
      //           final contact = contacts[index];
      //           return ListTile(
      //             leading: GestureDetector(
      //               child: contact.picture != null
      //                   ? CircleAvatar(
      //                       radius: 25,
      //                       backgroundImage: NetworkImage(contact.picture!),
      //                     )
      //                   : CircleAvatar(
      //                       radius: 25,
      //                       child: Text(contact.name.substring(0, 1)),
      //                     ),
      //             ),
      //             title: Text(contact.name),
      //           );
      //         },
      //       ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveContact(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
