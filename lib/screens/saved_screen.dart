import 'package:flutter/material.dart';
import '../services/item_service.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Matches")),
      body: FutureBuilder(
        future: ItemService().fetchSavedMatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text("No saved matches yet"));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return ListTile(
                leading: item['image_url'] != null
                    ? Image.network(item['image_url'], width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.image),
                title: Text(item['title'] ?? ''),
                subtitle: Text(item['description'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}