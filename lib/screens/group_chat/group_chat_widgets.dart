import 'package:flutter/material.dart';
import 'package:refactoring/models/group_model.dart';

class GroupChatAppBarTitle extends StatelessWidget {
  final GroupModel group;
  const GroupChatAppBarTitle({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.green,
          child: group.picture != null
              ? CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color.fromARGB(
                    255,
                    76,
                    78,
                    175,
                  ),
                  backgroundImage: NetworkImage(
                    group.picture!,
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
                    group.name.substring(0, 1),
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
            group.name,
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
