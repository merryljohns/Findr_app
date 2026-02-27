import 'package:flutter/material.dart';
import '../services/item_service.dart';

class ResellScreen extends StatefulWidget {
  const ResellScreen({super.key});

  @override
  State<ResellScreen> createState() => _ResellScreenState();
}

class _ResellScreenState extends State<ResellScreen> {
  final ItemService _itemService = ItemService();

  final BoxDecoration _pastelGradient = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFE8E0FF),
        Color(0xFFFFE5EC),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3EFFF), Color(0xFFFFF0F6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resell Items',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        Text(
                          'Second-hand treasures at great prices',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _itemService.fetchByCategory('resell'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF8E7CFF)));
                    }
                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return const Center(
                          child: Text("No items for sale yet."));
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildGalleryItem(item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _showItemDetails(item),
      child: Container(
        decoration: _pastelGradient.copyWith(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
                child: item['image_url'] != null
                    ? Image.network(item['image_url'],
                        width: double.infinity, fit: BoxFit.cover)
                    : Container(
                        color: Colors.white.withOpacity(0.3),
                        width: double.infinity,
                        child: const Icon(Icons.image, color: Colors.white),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? 'Untitled',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Color(0xFF8E7CFF)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item['location'] ?? 'Unknown',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration:
              _pastelGradient.copyWith(borderRadius: BorderRadius.circular(30)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                  child: item['image_url'] != null
                      ? Image.network(item['image_url'],
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover)
                      : Container(
                          height: 220,
                          color: Colors.black12,
                          child: const Icon(Icons.image, size: 50)),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] ?? 'No Title',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 18, color: Color(0xFFFBAED3)),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(
                                  item['location'] ?? 'Unknown Location',
                                  style:
                                      const TextStyle(color: Colors.black54))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(item['description'] ?? 'No description provided.',
                          style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.black87)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close',
                                  style: TextStyle(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w600))),
                          ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8E7CFF),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor:
                                  const Color(0xFF8E7CFF).withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            icon: const Icon(Icons.chat_bubble_outline_rounded,
                                size: 18),
                            label: const Text('Chat',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
