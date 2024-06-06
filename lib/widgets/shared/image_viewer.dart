import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageViewer extends StatelessWidget {
  final String path;
  const ImageViewer({super.key, required this.path});

  Future<bool> loadImage() async {
    final response = await http.get(Uri.parse(path));
    return response.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PopScope(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 30),
              child: InteractiveViewer(
                minScale: 0.1,
                maxScale: 4.0,
                child: Image.network(path),
              ),
            ),
          ),
        ),
      ),
      child: FutureBuilder(
        future: loadImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Image.network(path, fit: BoxFit.cover);
          }
        },
      ),
    );
  }
}
