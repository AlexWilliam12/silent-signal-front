import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget> actions;
  final Widget? customTitle;
  final bool isMainScreen;

  const CustomAppBar({
    super.key,
    this.title,
    this.customTitle,
    required this.actions,
    required this.isMainScreen,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: customTitle ??
          Text(
            title!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.white,
            ),
          ),
      leading: !isMainScreen
          ? IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            )
          : null,
      backgroundColor: const Color.fromARGB(255, 0, 15, 83),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
