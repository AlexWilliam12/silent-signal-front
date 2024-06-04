import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final bool isLeadingImage;
  final String leading;
  final String title;
  final String? subtitle;
  final void Function() onTap;
  final void Function()? onLongPress;
  final bool? selected;

  const CustomListTile({
    super.key,
    required this.isLeadingImage,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onLongPress,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
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
        leading: isLeadingImage
            ? CircleAvatar(
                radius: 25,
                backgroundColor: const Color.fromARGB(255, 76, 78, 175),
                backgroundImage: NetworkImage(leading),
              )
            : CircleAvatar(
                radius: 25,
                backgroundColor: const Color.fromARGB(255, 76, 78, 175),
                child: Text(
                  leading,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),
        onTap: onTap,
        onLongPress: onLongPress,
        selectedTileColor: const Color.fromARGB(31, 47, 0, 255),
        selected: selected ?? false,
      ),
    );
  }
}
