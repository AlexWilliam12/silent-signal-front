import 'package:flutter/material.dart';
import 'package:refactoring/models/user_model.dart';
import 'package:refactoring/widgets/shared/custom_list_tile.dart';

class ContactListTile extends StatelessWidget {
  final UserModel contact;
  final void Function() onTap;
  final void Function() onLongPress;
  final bool selected;

  const ContactListTile({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onLongPress,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return contact.picture != null
        ? CustomListTile(
            isLeadingImage: true,
            leading: contact.picture!,
            title: contact.name,
            subtitle: null,
            onTap: onTap,
            onLongPress: onLongPress,
            selected: selected,
          )
        : CustomListTile(
            isLeadingImage: false,
            leading: contact.name.substring(0, 1),
            title: contact.name,
            subtitle: null,
            onTap: onTap,
            onLongPress: onLongPress,
            selected: selected,
          );
  }
}
