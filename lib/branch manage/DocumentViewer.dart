import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DocumentViewer extends StatelessWidget {
  final String documentUrl;

  DocumentViewer({required this.documentUrl});

  @override
  Widget build(BuildContext context) {
    print('Document URL: $documentUrl'); // Print document URL
    return Scaffold(
      appBar: AppBar(
        title: Text('Document Viewer'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: documentUrl,
              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) {
                print('Error loading image: $error'); // Print error object
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error),
                    Text('Error loading image. Please check the console for details.'),
                  ],
                );
              },
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
