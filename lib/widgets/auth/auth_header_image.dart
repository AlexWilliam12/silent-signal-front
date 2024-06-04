import 'package:flutter/widgets.dart';

class AuthHeaderImage extends StatelessWidget {
  final String asset;
  const AuthHeaderImage({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
      color: const Color.fromARGB(255, 0, 15, 83),
      child: Image(
        image: AssetImage(asset),
      ),
    );
  }
}
