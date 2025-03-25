import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PhotoListScreen(),
    );
  }
}

class PhotoEntry {
  String image;
  String caption;
  String entry;

  PhotoEntry({
    required this.image, 
    required this.caption, 
    required this.entry
  });
}

class PhotoListScreen extends StatefulWidget {
  const PhotoListScreen({Key? key}) : super(key: key);

  @override
  _PhotoListScreenState createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  List<PhotoEntry> photos = [
    PhotoEntry(
      image: 'assets/photo1.png',
      caption: 'A Beautiful Sunset',
      entry: 'This was a magical evening by the beach, watching the sun go down.'
    ),
    PhotoEntry(
      image: 'assets/photo2.png',
      caption: 'Fun at the Beach',
      entry: 'Spent the day playing volleyball and enjoying the waves with friends.'
    ),
    PhotoEntry(
      image: 'assets/photo3.jpg',
      caption: 'Hiking Adventure',
      entry: 'Hiked 10 km today! The view from the top was absolutely breathtaking.'
    ),
    PhotoEntry(
      image: 'assets/photo4.jpg',
      caption: 'Chilling with friends',
      entry: 'A great weekend spent laughing, sharing stories, and making memories.'
    ),
  ];

  List<bool> isExpandedList = [false, false, false, false];

  void _editEntry(int index) {
    final TextEditingController entryController = TextEditingController(text: photos[index].entry);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Entry"),
          content: TextField(
            controller: entryController,
            decoration: const InputDecoration(labelText: "Update your entry"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  photos[index].entry = entryController.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _editCaption(int index) {
    final TextEditingController captionController = TextEditingController(text: photos[index].caption);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Caption"),
          content: TextField(
            controller: captionController,
            decoration: const InputDecoration(labelText: "Update your caption"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  photos[index].caption = captionController.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  final ImagePicker picker = ImagePicker();
  final TextEditingController captionController = TextEditingController();
  final TextEditingController entryController = TextEditingController();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _showAddEntryDialog(pickedFile.path);
    }
  }

  void _showAddEntryDialog(String image) {
    captionController.clear();
    entryController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Photo Entry"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(image), height: 150, width: 150, fit: BoxFit.cover),
              const SizedBox(height: 10),
              TextField(
                controller: captionController,
                decoration: const InputDecoration(labelText: "Caption"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: entryController,
                decoration: const InputDecoration(labelText: "Entry"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  photos.add(PhotoEntry(
                    image: image, 
                    caption: captionController.text, 
                    entry: entryController.text
                  ));
                  isExpandedList.add(false);
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🌸 Photo Diary 🌸',
          style: TextStyle(
            fontFamily: 'Pacifico', 
            fontSize: 26, 
            fontWeight: FontWeight.w300, 
            color: Colors.white
          ),
        ),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26, 
                    blurRadius: 6, 
                    spreadRadius: 2, 
                    offset: Offset(3, 5)
                  )
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => PhotoDetailsScreen(
                          image: photos[index].image,
                          caption: photos[index].caption,
                          entry: photos[index].entry,
                        ),
                      ),
                    ),
                    child: _buildImageWidget(photos[index].image),
                  ),
                  GestureDetector(
                    onDoubleTap: () => _editCaption(index),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        photos[index].caption, 
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          fontFamily: 'Cursive'
                        )
                      ),
                    ),
                  ),
                  GestureDetector(
                    onDoubleTap: () => _editEntry(index),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: isExpandedList[index]
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                photos[index].entry, 
                                style: const TextStyle(
                                  fontSize: 16, 
                                  fontStyle: FontStyle.italic
                                )
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    try {
      if (imagePath.startsWith('assets/')) {
        return Image.asset(
          imagePath, 
          width: double.infinity, 
          height: 300, 
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading asset image: $error');
            return Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey[300],
              child: const Center(child: Text('Image failed to load')),
            );
          },
        );
      } else {
        return Image.file(
          File(imagePath), 
          width: double.infinity, 
          height: 300, 
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading file image: $error');
            return Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey[300],
              child: const Center(child: Text('Image failed to load')),
            );
          },
        );
      }
    } catch (e) {
      print('Unexpected error loading image: $e');
      return Container(
        width: double.infinity,
        height: 300,
        color: Colors.grey[300],
        child: const Center(child: Text('Image failed to load')),
      );
    }
  }
}

class PhotoDetailsScreen extends StatelessWidget {
  final String image;
  final String caption;
  final String entry;

  const PhotoDetailsScreen({
    required this.image, 
    required this.caption, 
    required this.entry, 
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📷 Photo Details"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          Image.asset(
            image, 
            width: 300, 
            height: 300, 
            fit: BoxFit.cover
          ), 
          Text(
            caption, 
            style: const TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold
            )
          ), 
          Text(entry)
        ],
      ),
    );
  }
}