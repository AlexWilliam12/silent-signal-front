import 'package:flutter/material.dart';
import 'package:refactoring/models/user_model.dart';

class PrivateChatAppBarTitle extends StatelessWidget {
  final UserModel contact;
  const PrivateChatAppBarTitle({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.green,
          child: contact.picture != null
              ? CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color.fromARGB(
                    255,
                    76,
                    78,
                    175,
                  ),
                  backgroundImage: NetworkImage(
                    contact.picture!,
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
                    contact.name.substring(0, 1),
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
            contact.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21,
              color: Colors.white,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
