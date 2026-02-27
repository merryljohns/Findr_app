import 'dart:io';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/item_service.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _currentIndex = 0;
  final ImagePicker _picker = ImagePicker();
  final ItemService _itemService = ItemService(); // Instance of your service
  

  final List<Map<String, String>> cardData = [
    {
      'title': 'Lost',
      'desc':
          'Misplaced something? Post the details here and let the Findr community help you track it down in no time.',
    },
    {
      'title': 'Found',
      'desc':
          'Found an item? Upload a photo and description to reconnect it with its rightful owner quickly.',
    },
    {
      'title': 'Resell',
      'desc':
          'Ready to declutter? List your old items here and connect with buyers looking for hidden gems.',
    },
  ];

  // --- NEW UI METHODS FOR HORIZONTAL SCROLLING ---

  Widget _buildHorizontalSection(String title, String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {}, // Show All functionality
                child: const Text(
                  'Show All',
                  style: TextStyle(
                      color: Color(0xFF8E7CFF), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _itemService.fetchRecentTwoByCategory(category),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8E7CFF)));
              }

              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text("No items posted yet.",
                      style: TextStyle(color: Colors.black26)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  // Alternating between pastel purple (even) and pastel pink (odd)
                  final bool isPurple = index % 2 == 0;

                  return Container(
                    width: 180,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: isPurple
                          ? const Color(0xFFF3EFFF)
                          : const Color(0xFFFFF0F6),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGE DISPLAY
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(25)),
                            child: item['image_url'] != null &&
                                    item['image_url'].toString().isNotEmpty
                                ? Image.network(
                                    item['image_url'],
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                                color: Colors.black12,
                                                child: const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.white)),
                                  )
                                : Container(
                                    color: Colors.black12,
                                    child: const Icon(Icons.image,
                                        color: Colors.white),
                                  ),
                          ),
                        ),
                        // TEXT CONTENT
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] ?? 'Untitled',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['description'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.black54),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- REST OF YOUR ORIGINAL UI METHODS ---

  void _showAddItemDialog(BuildContext context) {
    String selectedType = 'Lost';
    Uint8List? webImage;
    XFile? pickedFile;

    final titleController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickImageInsideDialog() async {
              try {
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );

                if (image != null) {
                  final bytes = await image.readAsBytes();
                  setDialogState(() {
                    pickedFile = image;
                    webImage = bytes;
                  });
                }
              } catch (e) {
                debugPrint("Error picking image: $e");
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              title: const Text(
                'Add New Post',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: pickImageInsideDialog,
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black12, width: 1),
                            image: webImage != null
                                ? DecorationImage(
                                    image: MemoryImage(webImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: webImage == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined,
                                        color: Color(0xFF8E7CFF), size: 32),
                                    SizedBox(height: 8),
                                    Text('Upload Item Image',
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 12)),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _dialogTextField('Title', Icons.title, titleController),
                      const SizedBox(height: 12),
                      _dialogTextField(
                        'Description',
                        Icons.description_outlined,
                        descController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: _dialogInputDecoration('Category').copyWith(
                          prefixIcon: const Icon(Icons.category_outlined,
                              size: 20, color: Colors.black26),
                        ),
                        items: ['Lost', 'Found', 'Resell'].map((String type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() => selectedType = value!);
                        },
                      ),
                      const SizedBox(height: 12),
                      if (selectedType == 'Resell') ...[
                        _dialogTextField(
                          'Price',
                          Icons.attach_money,
                          priceController,
                          isNumber: true,
                        ),
                      ] else ...[
                        _dialogTextField(
                          'Location',
                          Icons.location_on_outlined,
                          locationController,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.black45)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final category = selectedType.toLowerCase();
                    String? imageUrl;
                    if (pickedFile != null) {
                      imageUrl = await ItemService().uploadImage(pickedFile!);
                    } // lost/found/resell

                    print("UPLOADED URL: $imageUrl");

                    final error = await ItemService().createItem(
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      category: category,
                      location: locationController.text.trim(),
                      imageUrl: imageUrl,
                    );

                    if (error == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Post created successfully")),
                        );
                        Navigator.pop(context);
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E7CFF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Post Now',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _dialogInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14, color: Colors.black45),
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _dialogTextField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: _dialogInputDecoration(
        hint,
      ).copyWith(prefixIcon: Icon(icon, size: 20, color: Colors.black26)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Good Morning,',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        Text(
                          'Hello User!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFFDED8FF),
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.85),
                  itemCount: cardData.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    return _buildGradientCard(
                      cardData[index]['title']!,
                      cardData[index]['desc']!,
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  cardData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentIndex == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? const Color(0xFF8E7CFF)
                          : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 30, 24, 10),
                child: Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // --- ADDED HORIZONTAL SCROLLING SECTIONS ---
              _buildHorizontalSection('Lost Items', 'lost'),
              _buildHorizontalSection('Found Items', 'found'),
              _buildHorizontalSection('Resell Items', 'resell'),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_rounded, 'Home', true),
            _navItem(Icons.search_off_rounded, 'Lost', false),
            const SizedBox(width: 40),
            _navItem(Icons.inventory_2_outlined, 'Found', false),
            _navItem(Icons.sell_outlined, 'Resell', false),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: const Color(0xFF8E7CFF),
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildGradientCard(String title, String desc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB9AAFF), Color(0xFFFBAED3)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF8E7CFF) : Colors.black26,
          size: 26,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFF8E7CFF) : Colors.black26,
          ),
        ),
      ],
    );
  }
}
