import 'package:flutter/material.dart';

class ModalBottomSheetAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final void Function() onTap;

  const ModalBottomSheetAction({
    super.key,
    required this.onTap,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
