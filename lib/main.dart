import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  DateTime date;
  bool isexpanded;

  PhotoEntry({
    required this.image, 
    required this.caption, 
    required this.entry,
    DateTime? date,
    this.isexpanded = false
  }) : date = date ?? DateTime.now();
}

class PhotoListScreen extends StatefulWidget {
  const PhotoListScreen({super.key});

  @override
  _PhotoListScreenState createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  List<PhotoEntry> photos = [
    PhotoEntry(
      image: 'assets/photo1.png',
      caption: 'A Beautiful Sunset',
      entry: 'This was a magical evening by the beach, watching the sun go down.',
      date: DateTime(2024, 3, 15),
      isexpanded: false
    ),
    PhotoEntry(
      image: 'assets/photo2.png',
      caption: 'Fun at the Beach',
      entry: 'Spent the day playing volleyball and enjoying the waves with friends.',
      date: DateTime(2024, 3, 20),
      isexpanded: false
    ),
    PhotoEntry(
      image: 'assets/photo3.jpg',
      caption: 'Hiking Adventure',
      entry: 'Hiked 10 km today! The view from the top was absolutely breathtaking.',
      date: DateTime(2024, 3, 25),
      isexpanded: false
    ),
    PhotoEntry(
      image: 'assets/photo4.jpg',
      caption: 'Chilling with friends',
      entry: 'A great weekend spent laughing, sharing stories, and making memories.',
      date: DateTime(2024, 3, 30),
      isexpanded: false
    ),
  ];

  void _editEntry(int index) {
    final TextEditingController entryController = TextEditingController(text: photos[index].entry);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Entry"),
          content: TextField(
            controller: entryController,
            maxLines: 4,
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
                    entry: entryController.text,
                    date: DateTime.now(),
                    isexpanded: false
                  ));
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              photos[index].isexpanded = !photos[index].isexpanded;
                            });
                          },
                          onDoubleTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => PhotoDetailsScreen(
                                image: photos[index].image,
                                caption: photos[index].caption,
                                entry: photos[index].entry,
                                date: photos[index].date,
                                onCaptionEdit: () => _editCaption(index),
                                onEntryEdit: () => _editEntry(index),
                              ),
                            ),
                          ),
                          child: _buildImageWidget(photos[index].image),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            photos[index].isexpanded = !photos[index].isexpanded;
                          });
                        },
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
                    ],
                  ),
                ),
                // Entry container that shows/hides based on isexpanded
                if (photos[index].isexpanded)
                  GestureDetector(
                    onDoubleTap: () => _editEntry(index),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${DateFormat('MMMM d, yyyy').format(photos[index].date)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.pink[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            photos[index].entry,
                            style: const TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
    return Image(
      image: imagePath.startsWith('assets/') 
        ? AssetImage(imagePath)
        : FileImage(File(imagePath)),
      width: double.infinity,
      height: 300,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $error');
        return Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey[300],
          child: Center(
            child: Text(
              'Failed to load image',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      },
    );
  }
}

class PhotoDetailsScreen extends StatelessWidget {
  final String image;
  final String caption;
  final String entry;
  final DateTime date;
  final VoidCallback? onCaptionEdit;
  final VoidCallback? onEntryEdit;

  const PhotoDetailsScreen({
    required this.image, 
    required this.caption, 
    required this.entry, 
    required this.date,
    this.onCaptionEdit,
    this.onEntryEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📷 Photo Details"),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Edit Details"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text('Edit Caption'),
                          onTap: () {
                            Navigator.pop(context);
                            onCaptionEdit?.call();
                          },
                        ),
                        ListTile(
                          title: Text('Edit Entry'),
                          onTap: () {
                            Navigator.pop(context);
                            onEntryEdit?.call();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image(
                        image: image.startsWith('assets/') 
                          ? AssetImage(image)
                          : FileImage(File(image)),
                        width: 350,
                        height: 350,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 350,
                            height: 350,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            caption,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            DateFormat('MMMM d, yyyy').format(date),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            entry,
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}